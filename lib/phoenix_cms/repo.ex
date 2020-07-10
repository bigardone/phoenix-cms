defmodule PhoenixCms.Repo do
  @moduledoc false

  alias __MODULE__.Cache
  alias PhoenixCms.{Article, Content}

  @type entity_types :: Article.t() | Content.t()

  @callback all(Article | Content) :: {:ok, [entity_types]} | {:error, term}
  @callback get(Article | Content, String.t()) :: {:ok, entity_types} | {:error, term}

  @adapter Application.get_env(:phoenix_cms, __MODULE__)[:adapter]

  @spec articles(boolean) :: {:ok, [Article.t()]} | {:error, term}
  def articles(skip_cache \\ false)
  def articles(false), do: all(Article)
  def articles(true), do: @adapter.all(Article)

  @spec contents(boolean) :: {:ok, [Content.t()]} | {:error, term}
  def contents(skip_cache \\ false)
  def contents(false), do: all(Content)
  def contents(true), do: @adapter.all(Content)

  @spec get_article(String.t()) :: {:ok, Article.t()} | {:error, term}
  def get_article(id), do: get(Article, id)

  defp all(entity) do
    with cache <- cache_for(entity),
         {:error, :not_found} <- Cache.all(cache),
         {:ok, items} <- @adapter.all(entity) do
      Cache.set_all(cache, items)
      {:ok, items}
    end
  end

  defp get(entity, id) do
    with cache <- cache_for(entity),
         {:error, :not_found} <- Cache.get(cache, id),
         {:ok, item} <- @adapter.get(entity, id) do
      Cache.set(cache, id, item)
      {:ok, item}
    end
  end

  defp cache_for(Article), do: PhoenixCms.Article.Cache
  defp cache_for(Content), do: PhoenixCms.Content.Cache
end
