defmodule PhoenixCms.Repo do
  @moduledoc false

  alias __MODULE__.Cache
  alias PhoenixCms.{Article, Content}

  @callback all(String.t()) :: {:ok, [struct]} | {:error, term}
  @callback get(String.t(), String.t()) :: {:ok, struct} | {:error, term}

  @adapter Application.get_env(:phoenix_cms, __MODULE__)[:adapter]

  @articles_table "articles"
  @contents_table "contents"

  @spec articles(boolean) :: {:ok, [Article.t()]} | {:error, term}
  def articles(skip_cache \\ false)
  def articles(false), do: all(@articles_table)
  def articles(true), do: @adapter.all(@articles_table)

  @spec contents(boolean) :: {:ok, [Content.t()]} | {:error, term}
  def contents(skip_cache \\ false)
  def contents(false), do: all(@contents_table)
  def contents(true), do: @adapter.all(@contents_table)

  @spec get_article(String.t()) :: {:ok, Article.t()} | {:error, term}
  def get_article(id), do: get(@articles_table, id)

  defp all(table) do
    with cache <- cache_for_table(table),
         {:error, :not_found} <- Cache.all(cache),
         {:ok, items} <- @adapter.all(table) do
      Cache.set_all(cache, items)
      {:ok, items}
    end
  end

  defp get(table, id) do
    with cache <- cache_for_table(table),
         {:error, :not_found} <- Cache.get(cache, id),
         {:ok, item} <- @adapter.get(table, id) do
      Cache.set(cache, id, item)
      {:ok, item}
    end
  end

  defp cache_for_table(@articles_table), do: PhoenixCms.Article.Cache

  defp cache_for_table(@contents_table), do: PhoenixCms.Content.Cache
end
