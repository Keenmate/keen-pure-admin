defmodule DemoWeb.CommandPaletteGuidePageTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  test "the guide page renders under /phoenix and explains the Source contract", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/phoenix/command-palette")
    assert html =~ "PureAdmin.CommandPalette.Source"
    assert html =~ "Source callbacks"
    assert html =~ "on_complete/2"
    # the guide itself sits inside the layout that mounts the global palette
    assert html =~ ~s(id="command-palette")
  end
end
