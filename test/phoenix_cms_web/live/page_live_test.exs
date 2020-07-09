defmodule PhoenixCmsWeb.PageLiveTest do
  use PhoenixCmsWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "PhoenixCMS"
    assert render(page_live) =~ "PhoenixCMS"
  end
end
