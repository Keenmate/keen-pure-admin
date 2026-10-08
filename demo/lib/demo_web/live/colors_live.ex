defmodule DemoWeb.Live.ColorsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Colors")}
  end

  @semantic_colors [
    %{name: "Success", var: "--pc-success", text: "--pa-btn-success-text"},
    %{name: "Warning", var: "--pc-warning", text: "--pa-btn-warning-text"},
    %{name: "Danger", var: "--pc-danger", text: "--pa-btn-danger-text"},
    %{name: "Info", var: "--pc-info", text: "--pa-btn-info-text"},
    %{name: "Accent", var: "--pc-accent", text: "--pa-btn-primary-text"},
    %{name: "Main BG", var: "--pc-main-bg", text: "--pc-text-color-1"},
    %{name: "Page BG", var: "--pc-page-bg", text: "--pc-text-color-1"}
  ]

  def render(assigns) do
    assigns = assign(assigns, :semantic_colors, @semantic_colors)

    ~H"""
    <p>Color palette reference showing semantic colors and theme color slots with their utility classes.</p>

    <.card title_text={gettext("Semantic Colors")}>
      <.paragraph>Standard semantic colors used throughout the framework for status indication.</.paragraph>
      <.grid class="gap-base">
        <.column :for={c <- @semantic_colors} size="100" sm="50" md="1-3" lg="1-4">
          <div class={swatch_classes()}>
            <div class={preview_classes()} style={preview_color(c.var, c.text)}>{c.name}</div>
            <div class="p-3 text-xs" style="background: var(--pa-card-bg);">
              <div class="font-weight-semibold mb-1">{c.name}</div>
              <div class="text-secondary font-family-mono">{c.var}</div>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Theme Color Slots (1-9)")}>
      <.paragraph>Custom theme colors that can be overridden per-theme. Use these for branded elements.</.paragraph>
      <p class="text-sm text-secondary">
        Colors are ordered by perceived luminance: <strong>color-1</strong> is always the lightest,
        <strong>color-9</strong> is always the darkest. This consistent ordering allows components to pick
        slots by relative brightness (e.g. use lower numbers for light accents, higher numbers for
        dark/muted tones) without knowing the specific theme palette.
      </p>
      <.grid class="gap-base">
        <.column :for={n <- 1..9} size="100" sm="50" md="1-3" lg="1-4">
          <div class={swatch_classes()}>
            <div class={"#{preview_classes()} surface-color-#{n}"}>
              {gettext("Color %{n}", n: n)}
            </div>
            <div class="p-3 text-xs" style="background: var(--pa-card-bg);">
              <div class="font-weight-semibold mb-1">{gettext("Color %{n}", n: n)}</div>
              <div class="text-secondary font-family-mono">--pc-color-{n}</div>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Color Utility Classes")}>
      <.paragraph>Apply theme colors to any element using these utility classes.</.paragraph>
      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Background Colors")}</.heading>
          <p><code>.surface-color-1</code> to <code>.surface-color-9</code></p>
          <p class="text-sm text-secondary">
            Slot background + auto-contrasting text. Use <code>.bg-color-N</code> for background only.
          </p>
          <div class="component-showcase mt-4">
            <span :for={n <- 1..9} class={"pa-badge surface-color-#{n}"}>bg-color-{n}</span>
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Text Colors")}</.heading>
          <p><code>.text-color-1</code> to <code>.text-color-9</code></p>
          <div class="component-showcase mt-4">
            <span :for={n <- 1..9} class={"text-color-#{n} font-weight-semibold"}>Text {n}</span>
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Border Colors")}</.heading>
          <p><code>.border-color-1</code> to <code>.border-color-9</code></p>
          <div class="d-flex flex-column gap-2 mt-4">
            <input :for={n <- 1..9} class={"pa-input border-color-#{n}"} value={"border-color-#{n}"} readonly />
          </div>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Applied to Components")}>
      <.paragraph>Examples of color utilities applied to various components.</.paragraph>

      <.heading level={4}>{gettext("Alerts with Theme Colors")}</.heading>
      <.alert theme_color="1">
        <strong>Color 1 Alert:</strong> Using <code style="color: inherit;">.pa-alert--color-1</code> variant (auto-contrasting text).
      </.alert>
      <.alert theme_color="4">
        <strong>Color 4 Alert:</strong> Using <code style="color: inherit;">.pa-alert--color-4</code> variant (auto-contrasting text).
      </.alert>
      <.alert theme_color="7">
        <strong>Color 7 Alert:</strong> Using <code style="color: inherit;">.pa-alert--color-7</code> variant (auto-contrasting text).
      </.alert>

      <.heading level={4} class="mt-4">{gettext("Cards with Colored Headers")}</.heading>
      <.grid>
        <.column size="100" md="1-3">
          <.card variant="color-1" title_text={gettext("Color 1 Header")}>
            Card with <code>.pa-card--color-1</code> variant.
          </.card>
        </.column>
        <.column size="100" md="1-3">
          <.card variant="color-5" title_text={gettext("Color 5 Header")}>
            Card with <code>.pa-card--color-5</code> variant.
          </.card>
        </.column>
        <.column size="100" md="1-3">
          <.card variant="color-8" title_text={gettext("Color 8 Header")}>
            Card with <code>.pa-card--color-8</code> variant.
          </.card>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("Mixed Badges")}</.heading>
      <div class="component-showcase">
        <.badge variant="success">Success</.badge>
        <.badge variant="warning">Warning</.badge>
        <.badge variant="danger">Danger</.badge>
        <.badge variant="info">Info</.badge>
        <.badge theme_color="1">Color 1</.badge>
        <.badge theme_color="2">Color 2</.badge>
        <.badge theme_color="6">Color 6</.badge>
        <.badge theme_color="9">Color 9</.badge>
      </div>
    </.card>
    """
  end

  # Swatch structure is all framework utility classes. The ONLY inline style left is
  # a semantic swatch's own bg + contrasting text (numbered slots use .surface-color-N
  # instead) and the info strip's --pa-card-bg (no bg-card utility).
  defp swatch_classes, do: "d-flex flex-column rounded overflow-hidden border"

  defp preview_classes,
    do: "hr-6 d-flex align-items-center justify-content-center font-weight-semibold"

  defp preview_color(bg, text), do: "background-color: var(#{bg}); color: var(#{text});"
end
