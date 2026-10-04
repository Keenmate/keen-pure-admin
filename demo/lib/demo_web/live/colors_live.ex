defmodule DemoWeb.Live.ColorsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Colors")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Pure Admin's color system uses CSS variables for full theme customization</.paragraph>

    <.card title_text={gettext("Semantic Colors")}>
      <:description>Core color variants used across all components</:description>
      <.grid>
        <.column :for={variant <- ~w(primary secondary success warning danger info)} size="1-3">
          <div class={"pa-card pa-card--#{variant} mb-2"}>
            <div class="pa-card__header"><.heading level={4}>{String.capitalize(variant)}</.heading></div>
            <div class="pa-card__body">
              <.badge variant={variant}>{variant}</.badge>
              <.button variant={variant} size="sm" class="ml-2">{variant}</.button>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Theme Colors (1-9)")}>
      <:description>Nine theme color slots for custom branding - automatically adjust text contrast</:description>
      <.grid>
        <.column :for={n <- 1..9} size="1-3">
          <div class={"pa-card pa-card--color-#{n} mb-2"}>
            <div class="pa-card__header"><.heading level={4}>{gettext("Color %{n}", n: n)}</.heading></div>
            <div class="pa-card__body">
              <code>--base-color-#{n}</code>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Text Color Utilities")}>
      <:description>Apply text colors using utility classes</:description>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Semantic Text Colors")}</.heading>
          <.basic_list>
            <li><span class="text-primary"><strong>text-primary</strong> - Primary accent color</span></li>
            <li><span class="text-secondary"><strong>text-secondary</strong> - Muted/secondary text</span></li>
            <li><span class="text-success"><strong>text-success</strong> - Success green</span></li>
            <li><span class="text-warning"><strong>text-warning</strong> - Warning yellow/orange</span></li>
            <li><span class="text-danger"><strong>text-danger</strong> - Danger/error red</span></li>
            <li><span class="text-info"><strong>text-info</strong> - Informational blue</span></li>
            <li><.text variant="secondary"><strong>text-secondary</strong> - Muted/subtle text</.text></li>
          </.basic_list>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("CSS Variables")}</.heading>
          <.table rows={[
            %{var: "--accent-color", desc: "Primary accent"},
            %{var: "--base-text-color", desc: "Default text"},
            %{var: "--base-text-color-2", desc: "Secondary text"},
            %{var: "--base-bg-color", desc: "Page background"},
            %{var: "--base-success-color", desc: "Success state"},
            %{var: "--base-warning-color", desc: "Warning state"},
            %{var: "--base-danger-color", desc: "Danger state"},
            %{var: "--base-info-color", desc: "Info state"},
            %{var: "--pc-bg-light", desc: "Subtle background"}
          ]} is_striped>
            <:col :let={row} label={gettext("Variable")}><code>{row.var}</code></:col>
            <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
          </.table>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Background Utilities")}>
      <:description>Apply background colors</:description>
      <.basic_list>
        <li><code>bg-primary</code>, <code>bg-secondary</code>, <code>bg-success</code>, <code>bg-warning</code>, <code>bg-danger</code>, <code>bg-info</code></li>
        <li><code>bg-light</code> - Subtle tinted background</li>
        <li><code>bg-transparent</code> - No background</li>
      </.basic_list>
    </.card>
    """
  end
end
