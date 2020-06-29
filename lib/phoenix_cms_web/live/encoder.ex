defmodule PhoenixCmsWeb.LiveEncoder do
  @moduledoc false

  alias PhoenixCms.{Article, Content}

  def encode(articles) when is_list(articles) do
    Enum.map(articles, &encode/1)
  end

  def encode(%Content{} = content) do
    Map.take(content, [:id, :type, :title, :content, :image, :styles])
  end

  def encode(%Article{published_at: published_at, description: description} = article) do
    article
    |> Map.drop([:content])
    |> Map.put(:description, description |> String.slice(0, 120) |> Kernel.<>("..."))
    |> Map.put(:published_at, Date.to_iso8601(published_at))
  end
end
