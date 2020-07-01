defmodule PhoenixCmsWeb.PageLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @topic "contents"

  @impl true
  def mount(_params, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    case fetch_contents() do
      {:ok, contents} ->
        socket =
          socket
          |> assign(:page_title, "Home")
          |> assign(:contents, contents)

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

  @impl true
  def handle_info(%{event: "update"}, socket) do
    case fetch_contents() do
      {:ok, contents} ->
        {:noreply, assign(socket, :contents, contents)}

      _ ->
        {:noreply, socket}
    end
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

  defp fetch_contents do
    case PhoenixCms.contents() do
      {:ok, contents} ->
        contents =
          contents
          |> Enum.sort_by(& &1.position)
          |> LiveEncoder.contents()

        {:ok, contents}

      other ->
        other
    end
  end
end
