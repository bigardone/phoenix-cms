defmodule PhoenixCmsWeb.ShowArticleLive do
  use PhoenixCmsWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case PhoenixCms.get_article(id) do
      {:ok, article} ->
        {:ok, assign(socket, :article, article)}

      {:error, _} ->
        {:ok, socket}
    end
  end
end
