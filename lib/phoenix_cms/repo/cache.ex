defmodule PhoenixCms.Repo.Cache do
  @moduledoc """
  Cache module for the repo
  """

  use GenServer

  @articles_table :articles
  @contents_table :contents

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    table = table_for(name)
    GenServer.start_link(__MODULE__, table, name: name)
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
  def init(table) do
    :ets.new(table, [:set, :protected, :named_table])

    {:ok, table}
  end

  @impl GenServer
  def handle_cast({:set, items}, table) when is_list(items) do
    Enum.each(items, &:ets.insert(table, {&1.id, &1}))

    {:noreply, table}
  end

  def handle_cast({:set, item}, table) do
    :ets.insert(table, {item.id, item})

    {:noreply, table}
  end

  defp table_for(ArticlesCache), do: @articles_table
  defp table_for(ContentsCache), do: @contents_table
end

