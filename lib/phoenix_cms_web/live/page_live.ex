defmodule PhoenixCmsWeb.PageLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, contents} <- PhoenixCms.contents(),
         {:ok, articles} <- PhoenixCms.latest_articles() do
      socket =
        socket
        |> assign(:contents, LiveEncoder.encode(contents))
        |> assign(:articles, LiveEncoder.encode(articles))

      {:ok, socket}
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

  def render_section(%{type: "hero"} = content) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "hero.html", content: content)
  end

  def render_section(%{type: "feature"} = content) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "feature.html", content: content)
  end

  def render_section(_), do: nil
end
