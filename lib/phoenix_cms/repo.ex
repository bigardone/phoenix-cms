defmodule PhoenixCms.Repo do
  @moduledoc false

  alias __MODULE__.Decoder
  alias PhoenixCms.Article
  alias Services.Airtable

  @articles_table "articles"
  @contents_table "contents?sort%5B0%5D%5Bfield%5D=position"

  @spec articles :: {:ok, [Article]} | {:error, term}
  def articles, do: do_all(@articles_table)

  @spec latest_articles :: {:ok, [Article]} | {:error, term}
  def latest_articles, do: do_all(@articles_table <> "?maxRecords=2")

  @spec contents :: {:ok, [Article]} | {:error, term}
  def contents, do: do_all(@contents_table)

  @spec get_article(String.t()) :: {:ok, Article.t()} | {:error, term}
  def get_article(id) do
    case Airtable.get(@articles_table, id) do
      {:ok, response} ->
        {:ok, Decoder.decode(response)}

      other ->
        other
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
end
