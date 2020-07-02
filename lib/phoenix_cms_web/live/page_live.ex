defmodule PhoenixCmsWeb.PageLive do
  use PhoenixCmsWeb, :live_view

  alias PhoenixCmsWeb.LiveEncoder

  @topic "contents"

  @impl true
  def mount(_params, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    {:ok, assign_socket(socket)}
  end

  @impl true
  def handle_event("show", %{"id" => id, "slug" => slug}, socket) do
    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, PhoenixCmsWeb.ShowArticleLive, id, slug))}
  end

  @impl true
  def handle_info(%{event: "update"}, socket) do
    {:noreply, assign_socket(socket)}
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

  defp assign_socket(socket) do
    case fetch_contents() do
      {:ok, contents} ->
        socket
        |> assign(:page_title, "Home")
        |> assign(:contents, contents)
        |> put_flash(:error, nil)

      {:error, _} ->
        socket
        |> assign(:page_title, "Home")
        |> assign(:contents, nil)
        |> put_flash(:error, "Error fetching data")
    end
  end

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
