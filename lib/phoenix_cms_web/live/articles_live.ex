defmodule PhoenixCmsWeb.ArticlesLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @topic "articles"

  @impl true
  def mount(_params, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    case fetch_articles() do
      {:ok, articles} ->
        socket =
          socket
          |> assign(:page_title, "Blog")
          |> assign(:articles, articles)

        {:ok, socket}

      {:error, _} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_info(%{event: "update"}, socket) do
    case fetch_articles() do
      {:ok, articles} ->
        {:noreply, assign(socket, :articles, articles)}

      _ ->
        {:noreply, socket}
    end
  end

  def render_article(socket, %{id: _id, slug: _slug} = article) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "article.html", socket: socket, article: article)
  end

  defp fetch_articles do
    case PhoenixCms.articles() do
      {:ok, articles} ->
        articles
        |> Enum.sort_by(& &1.published_at)
        |> LiveEncoder.articles()

        {:ok, articles}

      other ->
        other
    end
  end
end
