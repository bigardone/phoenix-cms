defmodule PhoenixCms.Article.Cache do
  @moduledoc """
  Article cache
  """

  alias PhoenixCms.{Repo, Repo.Cache}

  @behaviour Cache

  @topic "articles"

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @impl Cache
  def table_name, do: :articles

  @impl Cache
  def start_link(_args) do
    GenServer.start_link(Cache, __MODULE__, name: __MODULE__)
  end

  @impl Cache
  def fetch_fn, do: fn -> Repo.articles(true) end

  @impl Cache
  def topic, do: @topic
end
