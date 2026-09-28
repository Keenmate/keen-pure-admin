defmodule DemoWeb.PaTranslate do
  @moduledoc """
  Bridge between keen's `PureAdmin.Translations` and the demo's Gettext.

  Registered via `config :keen_pure_admin, translate: &DemoWeb.PaTranslate.translate/2`.
  Every piece of library chrome (command palette, settings panel, pagination…)
  calls `PureAdmin.Translations.t(key, params)`, which forwards here.

  We look the dotted `pureAdmin.*` key up in the `pure_admin` Gettext domain.
  Because Gettext returns the msgid unchanged when there is no translation, an
  unchanged result means "no override for this locale" — we return `nil` so keen
  falls back to its built-in English default. Interpolation is a pass-through:
  keen and Gettext both use `%{param}` syntax.
  """

  @domain "pure_admin"

  @spec translate(String.t(), map()) :: String.t() | nil
  def translate(key, params) do
    bindings = normalize(params)

    case Gettext.dgettext(DemoWeb.Gettext, @domain, key, bindings) do
      ^key -> nil
      translated -> translated
    end
  end

  # Gettext binding keys must be atoms; keen params already use atom keys, but
  # be defensive against string-keyed maps.
  defp normalize(params) when is_map(params) do
    Map.new(params, fn
      {k, v} when is_atom(k) -> {k, v}
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
    end)
  end

  defp normalize(_), do: %{}
end
