defmodule DemoWeb.ServerDialogTest do
  @moduledoc """
  Exercises the server-driven PureAdmin.Dialog feature on the Modal Dialogs page:
  a button hits the server, the server opens a dialog, every outcome (both choices
  AND the ✕/backdrop/Escape dismiss) routes back as an ordinary event that pushes a
  toast, and the dialog auto-closes via the on_mount hook. Also covers the
  custom/form dialog (open/3 + a real LiveView form with validation).

  Discriminators: the rendered dialog carries `id="pa-dialog"` / `id="edit-profile"`
  with real attribute quotes, whereas the on-page code samples render the same text
  with HTML-escaped quotes (`&quot;`) — so a raw `id="..."` match means the modal is
  actually mounted, not just shown in a code block. (`pa-modal--show` is added by
  `phx-mounted` at runtime, so it is intentionally NOT asserted in an SSR test.)
  """
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  @path "/surfaces/modal-dialogs"

  test "server opens a confirm dialog, the choice toasts back, and it auto-closes", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    refute html =~ ~s(id="pa-dialog")

    # Real phx-click -> server opens the dialog; the host renders it.
    html = view |> element("button", "Someone edited this document") |> render_click()
    assert html =~ ~s(id="pa-dialog")

    # The choice is an ordinary event; it pushes a toast and clears the dialog.
    render_click(view, "doc_reload", %{})
    assert_push_event(view, "toast", %{variant: "warning", title: "Document reloaded"})
    html = render_click(view, "pa-dialog:close", %{})
    assert html =~ "Server outcome"
    refute html =~ ~s(id="pa-dialog")
  end

  test "dismissing with the ✕ is a first-class event (on_dismiss) that toasts", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    view |> element("button", "Someone edited this document") |> render_click()

    # Click the actual header close button — wired via on_dismiss to doc_dismiss.
    view |> element(~s(#pa-dialog button[aria-label="Close"])) |> render_click()
    assert_push_event(view, "toast", %{variant: "info", title: "Dialog dismissed"})

    html = render(view)
    assert html =~ "Dismissed"
    refute html =~ ~s(id="pa-dialog")
  end

  test "a bare close (no choice) clears the dialog without recording an outcome", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    view |> element("button", "Someone edited this document") |> render_click()

    html = render_click(view, "pa-dialog:close", %{})
    refute html =~ ~s(id="pa-dialog")
    refute html =~ "Server outcome"
  end

  test "custom/form dialog validates on submit and saves on valid input", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    refute html =~ ~s(id="edit-profile")

    html = view |> element("button", "Edit profile") |> render_click()
    assert html =~ ~s(id="edit-profile")
    assert html =~ ~s(name="profile[email]")

    # Invalid email -> error shown, dialog stays open.
    html =
      view
      |> form(~s(#edit-profile form), profile: %{name: "Ada", email: "not-an-email"})
      |> render_submit()

    assert html =~ "must be a valid email"
    assert html =~ ~s(id="edit-profile")

    # Valid -> saved + dialog dismissed.
    html =
      view
      |> form(~s(#edit-profile form), profile: %{name: "Ada", email: "ada@example.com"})
      |> render_submit()

    assert html =~ "Profile saved."
    refute html =~ ~s(id="edit-profile")
  end
end
