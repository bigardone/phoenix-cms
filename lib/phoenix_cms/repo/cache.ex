defmodule PhoenixCms.Repo.Cache do
  @moduledoc """
  Cache module for the repo
  """

  use GenServer

  alias __MODULE__.Synchronizer

  require Logger

  @callback start_link(keyword) :: GenServer.on_start()
  @callback fetch_fn :: fun
  @callback topic :: String.t()

  @articles_table :articles
  @contents_table :contents
  @secret "cache secret"

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    table = table_for(name)
    GenServer.start_link(__MODULE__, {name, table}, name: name)
  end

  def all(cache) do
    cache
    |> table_for()
    |> :ets.tab2list()
    |> case do
      values when values != [] ->
        Logger.info("#{cache}.all hit")

        {:ok, Enum.map(values, &elem(&1, 1))}

      _ ->
        Logger.info("#{cache}.all miss")

        {:error, :not_found}
    end
  end

  def get(cache, key) do
    cache
    |> table_for()
    |> :ets.lookup(key)
    |> case do
      [{^key, value} | _] ->
        Logger.info("#{cache}.get #{key} hit")
        {:ok, value}

      _ ->
        Logger.info("#{cache}.get #{key} miss")
        {:error, :not_found}
    end
  end

  def set_all(name, items), do: GenServer.cast(name, {:set_all, items})
  def set(name, id, item), do: GenServer.cast(name, {:set, id, item})

  @impl GenServer
  def init({name, table}) do
    Process.flag(:trap_exit, true)

    :ets.new(table, [:ordered_set, :protected, :named_table])

    {:ok, pid} = Synchronizer.start_link(cache: name)
    ref = Process.monitor(pid)

    {:ok, %{table: table, name: name, synchronizer_ref: ref, hash: ""}}
  end

  @impl GenServer
  def handle_cast({:set_all, items}, %{table: table, name: name, hash: hash} = state)
      when is_list(items) do
    new_hash = generate_hash(items)

    if hash != new_hash do
      Logger.info("#{name}.set_all setting new items and broadcasting")

      Enum.each(items, &:ets.insert(table, {&1.id, &1}))
      PhoenixCmsWeb.Endpoint.broadcast(apply(name, :topic, []), "update", %{})
    end

    {:noreply, %{state | hash: new_hash}}
  end

  def handle_cast({:set, id, item}, %{table: table, name: name} = state) do
    :ets.insert(table, {id, item})
    PhoenixCmsWeb.Endpoint.broadcast(apply(name, :topic, []), "update", %{})

    {:noreply, state}
  end

  def handle_cast({:set, item}, %{table: table} = state) do
    :ets.insert(table, {item.id, item})

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        {:DOWN, ref, :process, _object, _reason},
        %{synchronizer_ref: ref, name: name} = state
      ) do
    {:ok, pid} = Synchronizer.start_link(cache: name)
    ref = Process.monitor(pid)

    {:noreply, %{state | synchronizer_ref: ref}}
  end

  def handle_info({:EXIT, _, _}, state) do
    {:noreply, state}
  end

  defp table_for(PhoenixCms.Article.Cache), do: @articles_table
  defp table_for(PhoenixCms.Content.Cache), do: @contents_table

  defp generate_hash(items) do
    :sha256
    |> :crypto.hmac(@secret, :erlang.term_to_binary(items))
    |> Base.encode64()
  end
end
