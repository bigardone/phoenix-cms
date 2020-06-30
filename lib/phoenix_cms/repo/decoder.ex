defmodule PhoenixCms.Repo.Decoder do
  @moduledoc false

  alias PhoenixCms.{Article, Content}

  def decode(response) when is_list(response) do
    Enum.map(response, &decode/1)
  end

  def decode(%{
        "id" => id,
        "fields" => %{
          "slug" => slug,
          "title" => title,
          "description" => description,
          "image" => image,
          "content" => content,
          "author" => author,
          "published_at" => published_at
        }
      }) do
    %Article{
      id: id,
      slug: slug,
      title: title,
      description: description,
      image: decode_image(image),
      content: content,
      author: author,
      published_at: Date.from_iso8601!(published_at)
    }
  end

  def decode(%{
        "fields" =>
          %{
            "id" => id,
            "position" => position,
            "type" => type,
            "title" => title,
            "content" => content,
            "image" => image
          } = fields
      }) do
    %Content{
      id: id,
      position: position,
      type: type,
      title: title,
      content: content,
      image: decode_image(image),
      styles: Map.get(fields, "styles", "")
    }
  end

  defp decode_image([%{"url" => url}]), do: url
  defp decode_image(_), do: ""
end
