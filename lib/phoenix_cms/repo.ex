defmodule PhoenixCms.Repo do
  @moduledoc false

  alias __MODULE__.{Cache, Decoder}
  alias PhoenixCms.Article
  alias Services.Airtable

  @articles_table "articles"
  @contents_table "contents"

  @spec articles :: {:ok, [Article]} | {:error, term}
  def articles, do: all(@articles_table)

  @spec latest_articles :: {:ok, [Article]} | {:error, term}
  def latest_articles do
    @articles_table
    |> all()
    |> case do
      {:ok, articles} ->
        {:ok, Enum.take(articles, 2)}

      other ->
        other
    end
  end

  @spec contents :: {:ok, [Article]} | {:error, term}
  def contents do
    with {:ok, items} <- all(@contents_table),
         items <- Enum.sort_by(items, & &1.position) do
      {:ok, items}
    end
  end

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

  defp cache_for_table(@articles_table), do: ArticlesCache

  defp cache_for_table(@contents_table <> _), do: ContentsCache
end
