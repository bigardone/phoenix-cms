defmodule PhoenixCmsWeb.ArticlesLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, articles} <- PhoenixCms.articles() do
      {:ok, assign(socket, :articles, LiveEncoder.articles(articles))}
    else
      {:error, _} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("show", %{"id" => id, "slug" => slug}, socket) do
    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, PhoenixCmsWeb.ShowArticleLive, id, slug))}
  end

  def render_article(socket, %{id: _id, slug: _slug} = article) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "article.html", socket: socket, article: article)
  end
end
