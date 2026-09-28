defmodule DemoWeb.Locale do
  @moduledoc """
  Single source of truth for the demo's supported locales and a Plug that
  resolves the active locale for each request.

  Resolution order: session (`:locale`) → `Accept-Language` header → default.
  The chosen locale is set on the Gettext process dictionary via
  `Gettext.put_locale/2` and stashed in the session so the LiveView `on_mount`
  hook (`DemoWeb.Nav`) can re-apply it inside the socket process.
  """
  @behaviour Plug

  import Plug.Conn

  @default "en"

  @languages [
    %{code: "en", name: "English", native: "English"},
    %{code: "es", name: "Spanish", native: "Español"}
  ]

  @codes Enum.map(@languages, & &1.code)

  @doc "List of supported languages (`%{code, name, native}`)."
  def languages, do: @languages

  @doc "List of supported locale codes."
  def codes, do: @codes

  @doc "The fallback locale code."
  def default, do: @default

  @doc "True if `code` is a supported locale."
  def supported?(code), do: code in @codes

  @doc """
  Resolves and applies the request locale.

  Called from the plug and from `on_mount` — given a session map (or conn),
  returns the resolved code and, as a side effect, sets the Gettext locale.
  """
  def put_locale(locale) when is_binary(locale) do
    code = if supported?(locale), do: locale, else: @default
    Gettext.put_locale(DemoWeb.Gettext, code)
    code
  end

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    code =
      get_session(conn, :locale) ||
        from_accept_language(conn) ||
        @default

    code = put_locale(code)

    conn
    |> put_session(:locale, code)
    |> assign(:locale, code)
  end

  # Best-effort parse of the first supported language tag in Accept-Language.
  defp from_accept_language(conn) do
    conn
    |> get_req_header("accept-language")
    |> List.first()
    |> case do
      nil ->
        nil

      header ->
        header
        |> String.split(",")
        |> Enum.map(fn part -> part |> String.split(";") |> hd() |> String.trim() end)
        |> Enum.map(fn tag -> tag |> String.split("-") |> hd() |> String.downcase() end)
        |> Enum.find(&supported?/1)
    end
  end
end
