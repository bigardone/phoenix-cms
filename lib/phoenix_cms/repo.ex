defmodule PhoenixCms.Repo do
  @moduledoc false

  alias __MODULE__.{Cache, Decoder}
  alias PhoenixCms.Article
  alias Services.Airtable

  @articles_table "articles"
  @contents_table "contents"

  @spec articles(boolean) :: {:ok, [Article]} | {:error, term}
  def articles(skip_cache \\ false)
  def articles(false), do: all(@articles_table)
  def articles(true), do: do_all(@articles_table)

  @spec contents(boolean) :: {:ok, [Article]} | {:error, term}
  def contents(skip_cache \\ false)
  def contents(false), do: all(@contents_table)
  def contents(true), do: do_all(@contents_table)

  @spec get_article(String.t()) :: {:ok, Article.t()} | {:error, term}
  def get_article(id), do: get(@articles_table, id)

  defp all(table) do
    with cache <- cache_for_table(table),
         {:error, :not_found} <- Cache.all(cache),
         {:ok, items} <- do_all(table) do
      Cache.set(cache, items)
      {:ok, items}
    end
  end

  defp get(table, id) do
    with cache <- cache_for_table(table),
         {:error, :not_found} <- Cache.get(cache, id),
         {:ok, item} <- do_get(table, id) do
      {:ok, item}
    end
  end

  defp do_all(table) do
    case Airtable.all(table) do
      {:ok, %{"records" => records}} ->
        {:ok, Decoder.decode(records)}

      other ->
        other
    end
  end

  defp do_get(table, id) do
    case Airtable.get(table, id) do
      {:ok, response} ->
        {:ok, Decoder.decode(response)}

      other ->
        other
    end
  end

  defp cache_for_table(@articles_table), do: PhoenixCms.Article.Cache

  defp cache_for_table(@contents_table), do: PhoenixCms.Content.Cache
end
