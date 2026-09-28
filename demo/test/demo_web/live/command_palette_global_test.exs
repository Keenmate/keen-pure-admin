defmodule DemoWeb.GlobalPaletteTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  test "the palette is mounted globally from the layout (works on any page)", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ ~s(id="command-palette")
    assert html =~ ~s(phx-hook="PureAdminCommandPalette")
  end

  test "open_with_query drives the global component into the command list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/components/command-palette")

    view |> element(~s(button[phx-value-query="/"])) |> render_click()
    html = render(view)

    assert html =~ "pa-command-palette--active"
    assert html =~ "Deploy to Environment"
    assert html =~ "Go to Page"
  end

  test "selecting the /deploy command steps into its first (environment) step", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/components/command-palette")

    # /deploy filters the command list to the single command; select it.
    view |> element(~s(button[phx-value-query="/deploy"])) |> render_click()

    step_html =
      view
      |> element(~s(#command-palette [phx-click="cp:select"][phx-value-index="0"]))
      |> render_click()

    assert step_html =~ "Production"
    assert step_html =~ "Staging"
    assert step_html =~ "Development"
  end

  test "toggling display via send_update flips the component to tokens mode", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/components/command-palette")

    view |> element(~s(button[phx-value-display="tokens"])) |> render_click()
    html = render(view)

    assert html =~ ~s(data-display="tokens")
  end
end
