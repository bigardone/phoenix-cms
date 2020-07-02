defmodule PhoenixCmsWeb.ShowArticleLive do
  use PhoenixCmsWeb, :live_view

  @topic "articles"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    PhoenixCmsWeb.Endpoint.subscribe(@topic)

    {:ok, assign_socket(socket, id)}
  end

  @impl true
  def handle_info(%{event: "update"}, socket) do
    id = socket.assigns.article.id

    {:noreply, assign_socket(socket, id)}
  end

  defp assign_socket(socket, id) do
    case PhoenixCms.get_article(id) do
      {:ok, article} ->
        socket
        |> assign(:page_title, article.title)
        |> assign(:article, article)
        |> put_flash(:error, nil)

      {:error, _} ->
        socket
        |> assign(:page_title, "Blog")
        |> assign(:article, nil)
        |> put_flash(:error, "Error fetching data")
    end
  end
end
