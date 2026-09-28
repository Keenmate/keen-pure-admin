defmodule DemoWeb.Nav do
  @moduledoc """
  On-mount hook that assigns current_path for sidebar active state,
  re-applies the request locale inside the socket process, and
  subscribes to global toast broadcasts.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  alias DemoWeb.Locale
  alias PureAdmin.Components.Toast, as: PureToast

  def on_mount(:default, _params, session, socket) do
    Phoenix.PubSub.subscribe(Demo.PubSub, "toasts")

    # The LiveView runs in its own process — re-apply the locale the plug
    # resolved so gettext/1 in templates uses the right language.
    locale = Locale.put_locale(session["locale"] || Locale.default())

    {:cont,
     socket
     |> assign(:locale, locale)
     |> assign(:languages, Locale.languages())
     |> attach_hook(:set_current_path, :handle_params, fn _params, uri, socket ->
       path = URI.parse(uri).path
       {:cont, assign(socket, :current_path, path)}
     end)
     |> attach_hook(:global_toasts, :handle_info, fn
       {:push_toast, variant, title, message, opts}, socket ->
         {:halt, PureToast.push_toast(socket, variant, title, message, opts)}

       _other, socket ->
         {:cont, socket}
     end)}
  end
end
