defmodule PhoenixCms do
  @moduledoc """
  PhoenixCms keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defdelegate latest_articles, to: PhoenixCms.Repo

  defdelegate articles, to: PhoenixCms.Repo

  defdelegate contents, to: PhoenixCms.Repo

  defdelegate get_article(id), to: PhoenixCms.Repo
end
