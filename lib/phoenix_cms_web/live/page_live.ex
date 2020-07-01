defmodule PhoenixCmsWeb.PageLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @impl true
  def mount(_params, _session, socket) do
    case PhoenixCms.contents() do
      {:ok, contents} ->
        socket = assign(socket, :contents, LiveEncoder.contents(contents))

        {:ok, socket}

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

  def render_section(%{type: "text_and_image"} = content) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "text_and_image.html", content: content)
  end

  def render_section(%{features: content}) do
    Phoenix.View.render(PhoenixCmsWeb.PageView, "features.html", content: content)
  end

  def render_section(_), do: ""
end
