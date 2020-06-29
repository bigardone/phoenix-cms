defmodule PhoenixCms.Content do
  @moduledoc """
  Represents each section content
  """

  alias __MODULE__

  @type t :: %Content{
          id: String.t(),
          type: String.t(),
          title: String.t(),
          content: String.t(),
          image: String.t(),
          styles: String.t()
        }

  defstruct [:id, :type, :title, :content, :image, :styles]
end
