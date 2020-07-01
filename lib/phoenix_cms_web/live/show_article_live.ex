defmodule PhoenixCmsWeb.ShowArticleLive do
  use PhoenixCmsWeb, :live_view

  @topic "articles"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    case PhoenixCms.get_article(id) do
      {:ok, article} ->
        socket =
          socket
          |> assign(:page_title, article.title)
          |> assign(:article, article)

        {:ok, socket}

      {:error, _} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_info(%{event: "update"}, socket) do
    id = socket.assigns.article.id

    case PhoenixCms.get_article(id) do
      {:ok, article} ->
        {:noreply, assign(socket, :article, article)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
