defmodule PhoenixCms.Repo.Fake do
  @moduledoc false

  alias PhoenixCms.{Article, Content, Repo}

  @behaviour Repo

  @impl Repo
  def all(Content) do
    {:ok, [%Content{content: "Foo", id: "hero", position: 1, title: "PhoenixCMS", type: "hero"}]}
  end

  def all(Article) do
    {:ok, []}
  end

  @impl Repo
  def get(Article, _id) do
    {:ok, %Article{}}
  end
end
