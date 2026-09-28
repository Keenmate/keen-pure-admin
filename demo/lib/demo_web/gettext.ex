defmodule DemoWeb.Gettext do
  @moduledoc """
  Gettext backend for the demo site.

  Two domains are used:

    * `default` — the demo's own content (nav labels, page copy). Idiomatic
      Gettext: msgid is the English source string, extracted automatically by
      `mix gettext.extract`.

    * `pure_admin` — the bridge domain for library chrome. Here the msgid is a
      dotted `pureAdmin.*` key (e.g. `pureAdmin.commandPalette.placeholder`),
      matching the keys `PureAdmin.Translations.t/2` requests. Authored by hand
      in `priv/gettext/<locale>/LC_MESSAGES/pure_admin.po`; missing entries fall
      back to keen's built-in English defaults via `DemoWeb.PaTranslate`.
  """
  use Gettext.Backend, otp_app: :demo
end
