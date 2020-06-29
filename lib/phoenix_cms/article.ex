defmodule PhoenixCms.Article do
  @moduledoc false

  alias __MODULE__

  @type t :: %Article{
          id: String.t(),
          slug: String.t(),
          title: String.t(),
          description: String.t(),
          image: String.t(),
          content: String.t(),
          author: String.t(),
          published_at: Date.t()
        }

  defstruct [:id, :slug, :title, :description, :image, :content, :author, :published_at]
end
