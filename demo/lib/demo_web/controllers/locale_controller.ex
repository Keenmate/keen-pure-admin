defmodule DemoWeb.LocaleController do
  @moduledoc """
  Sets the session locale and redirects back.

  A plain controller (not a LiveView event) because a LiveView cannot write the
  Plug session. The language picker links here; the full round-trip re-mounts
  every LiveView at the new locale — which is also why the command palette's
  `assign_new`-cached commands re-translate for free.
  """
  use DemoWeb, :controller

  alias DemoWeb.Locale

  def set(conn, %{"code" => code} = params) do
    return_to = safe_return_to(params["return_to"])

    conn =
      if Locale.supported?(code) do
        put_session(conn, :locale, code)
      else
        conn
      end

    redirect(conn, to: return_to)
  end

  # Only allow local, absolute-path redirects.
  defp safe_return_to("/" <> _ = path), do: path
  defp safe_return_to(_), do: "/"
end
