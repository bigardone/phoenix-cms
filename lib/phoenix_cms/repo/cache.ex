defmodule PhoenixCms.Repo.Cache do
  @moduledoc """
  Cache module for the repo
  """

  use GenServer

  alias __MODULE__.Synchronizer

  @callback start_link(keyword) :: GenServer.on_start()
  @callback fetch_fn :: fun
  @callback topic :: String.t()

  @articles_table :articles
  @contents_table :contents

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
        {:ok, Enum.map(values, &elem(&1, 1))}

      _ ->
        {:error, :not_found}
    end
  end

  def get(cache, key) do
    cache
    |> table_for()
    |> :ets.lookup(key)
    |> case do
      [{^key, value} | _] ->
        {:ok, value}

      _ ->
        {:error, :not_found}
    end
  end

  def set(name, items), do: GenServer.cast(name, {:set, items})

  @impl GenServer
  def init({name, table}) do
    :ets.new(table, [:set, :protected, :named_table])

    Process.flag(:trap_exit, true)
    {:ok, pid} = Synchronizer.start_link(cache: name)
    ref = Process.monitor(pid)

    {:ok, %{table: table, name: name, synchronizer_ref: ref}}
  end

  @impl GenServer
  def handle_cast({:set, items}, %{table: table, name: name} = state) when is_list(items) do
    Enum.each(items, &:ets.insert(table, {&1.id, &1}))
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
end
