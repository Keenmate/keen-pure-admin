defmodule DemoWeb.I18nTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "locale switch" do
    test "GET /locale/:code stores the locale in session and redirects back", %{conn: conn} do
      conn = get(conn, ~p"/locale/es?return_to=/")
      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "es"
    end

    test "an unsupported code is ignored (keeps the current locale)", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{locale: "es"})
        |> get(~p"/locale/xx?return_to=/")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "es"
    end

    test "a non-local return_to is rejected", %{conn: conn} do
      conn = get(conn, "/locale/cs?return_to=https://evil.example.com")
      assert redirected_to(conn) == "/"
    end
  end

  describe "rendered content follows the session locale" do
    test "English by default", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Dashboard"
      assert html =~ "Real-time overview of key performance metrics"
    end

    test "Spanish when the session locale is es", %{conn: conn} do
      conn = init_test_session(conn, %{locale: "es"})
      {:ok, _view, html} = live(conn, "/")
      # demo content (default domain)
      assert html =~ "Panel"
      assert html =~ "Resumen en tiempo real de las métricas clave de rendimiento"
      # sidebar label
      assert html =~ "Primeros pasos"
    end
  end

  describe "library chrome bridges into Gettext (pure_admin domain)" do
    test "keen t/2 resolves Spanish via the DemoWeb.PaTranslate bridge" do
      Gettext.put_locale(DemoWeb.Gettext, "es")
      assert PureAdmin.Translations.t("pureAdmin.buttons.confirm") == "Confirmar"
      # a key with no es override falls back to keen's English default
      assert PureAdmin.Translations.t("pureAdmin.datetime.now") == "now"
    after
      Gettext.put_locale(DemoWeb.Gettext, "en")
    end
  end

  describe "command palette Source translates at runtime (not compile-time)" do
    test "commands/0 reflects the active locale" do
      Gettext.put_locale(DemoWeb.Gettext, "es")
      es_name = DemoWeb.CommandPaletteSource.commands() |> hd() |> Map.get(:name)
      assert es_name == "Desplegar a entorno"

      Gettext.put_locale(DemoWeb.Gettext, "en")
      en_name = DemoWeb.CommandPaletteSource.commands() |> hd() |> Map.get(:name)
      assert en_name == "Deploy to Environment"
    after
      Gettext.put_locale(DemoWeb.Gettext, "en")
    end
  end
end
