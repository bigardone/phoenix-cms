defmodule PhoenixCmsWeb.ArticlesLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @topic "articles"

  @impl true
  def mount(_params, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    {:ok, assign_socket(socket)}
  end

  @impl true
  def handle_info(%{event: "update"}, socket) do
    {:noreply, assign_socket(socket)}
  end

  def render_article(socket, %{id: _id, slug: _slug} = article) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "article.html", socket: socket, article: article)
  end

  defp assign_socket(socket) do
    case fetch_articles() do
      {:ok, articles} ->
        socket
        |> assign(:page_title, "Blog")
        |> assign(:articles, articles)
        |> put_flash(:error, nil)

      _ ->
        socket
        |> assign(:page_title, "Blog")
        |> assign(:articles, nil)
        |> put_flash(:error, "Error fetching data")
    end
  end

  defp fetch_articles do
    with {:ok, articles} <- PhoenixCms.articles() do
      articles
      |> Enum.sort_by(& &1.published_at)
      |> LiveEncoder.articles()

      {:ok, articles}
    end
  end
end
