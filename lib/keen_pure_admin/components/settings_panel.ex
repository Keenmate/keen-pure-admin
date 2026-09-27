defmodule PureAdmin.Components.SettingsPanel do
  @moduledoc """
  Settings panel component for Pure Admin.

  Provides runtime-configurable settings for theme, color variant, mode,
  layout width, sidebar behavior, display options, and font preferences.
  Theme/variant/mode selectors are populated dynamically from `/api/themes/manifests`.
  All settings persist to localStorage via the `PureAdminSettings` JS hook.

  ## Examples

      <.settings_panel />

      <.settings_panel default_theme="audi" />
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @doc """
  Renders the floating settings panel.

  Theme, color variant, and mode selectors are populated dynamically
  by the JS hook from `/api/themes/manifests`. All other controls use
  `data-setting` attributes bound to localStorage.
  """
  attr(:id, :string, default: "settingsPanel")
  attr(:default_theme, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def settings_panel(assigns) do
    ~H"""
    <div
      id={@id}
      class={build_classes("pa-settings-panel", [], @class)}
      phx-hook="PureAdminSettings"
      data-default-theme={@default_theme}
      {@rest}
    >
      <button class="pa-settings-panel__toggle" type="button" aria-label={t("pureAdmin.a11y.settings")}>
        <span class="pa-icon pa-icon--settings" aria-hidden="true"></span>
      </button>

      <div class="pa-settings-panel__content">
        <h3 class="pa-settings-panel__title"><%= t("pureAdmin.settings.title") %></h3>

        <%!-- Theme (populated dynamically from manifests) --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-theme"}><%= t("pureAdmin.settings.theme") %></label>
          <select id={"#{@id}-theme"} class="pa-settings-panel__select" data-setting="theme">
            <option value=""><%= t("pureAdmin.settings.loading") %></option>
          </select>
        </div>

        <%!-- Color Variant (shown/hidden dynamically based on manifest) --%>
        <div class="pa-settings-panel__section" data-section="color-variant" style="display: none;">
          <label class="pa-settings-panel__label" for={"#{@id}-color-variant"}><%= t("pureAdmin.settings.colorVariant") %></label>
          <select
            id={"#{@id}-color-variant"}
            class="pa-settings-panel__select"
            data-setting="color-variant"
          >
          </select>
        </div>

        <%!-- Theme Mode (shown/hidden dynamically based on manifest) --%>
        <div class="pa-settings-panel__section" data-section="theme-mode" style="display: none;">
          <label class="pa-settings-panel__label" for={"#{@id}-theme-mode"}><%= t("pureAdmin.settings.mode") %></label>
          <select
            id={"#{@id}-theme-mode"}
            class="pa-settings-panel__select"
            data-setting="theme-mode"
          >
          </select>
        </div>

        <%!-- Container Width --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-container-width"}><%= t("pureAdmin.settings.layoutWidth") %></label>
          <select
            id={"#{@id}-container-width"}
            class="pa-settings-panel__select"
            data-setting="container-width"
          >
            <option value="fluid"><%= t("pureAdmin.settings.fluid") %></option>
            <option value="sm"><%= t("pureAdmin.settings.small") %></option>
            <option value="md"><%= t("pureAdmin.settings.medium") %></option>
            <option value="lg"><%= t("pureAdmin.settings.large") %></option>
            <option value="xl"><%= t("pureAdmin.settings.extraLarge") %></option>
            <option value="2xl"><%= t("pureAdmin.settings.xxLarge") %></option>
          </select>
        </div>

        <%!-- Search Box position (rc12 + rc15) — previews the five search placements --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-search-position"}>Search Box</label>
          <select
            id={"#{@id}-search-position"}
            class="pa-settings-panel__select"
            data-setting="search-position"
          >
            <option value="">Off</option>
            <option value="navbar-inline">Navbar — inline search (A)</option>
            <option value="navbar-compact">Navbar — compact, opens palette (B)</option>
            <option value="sidebar">Sidebar — opens palette (C)</option>
            <option value="navbar-input">Navbar — type-and-go form (D)</option>
            <option value="sidebar-input">Sidebar — type-and-go form (E)</option>
          </select>
        </div>

        <%!-- Command Palette size (rc15) — sets the --sm/--lg/--xl width preset on
             the palette. Default (no modifier) is 608px. Press Ctrl+K to preview. --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-command-palette-size"}>Command Palette</label>
          <select
            id={"#{@id}-command-palette-size"}
            class="pa-settings-panel__select"
            data-setting="command-palette-size"
          >
            <option value="">Default (608px)</option>
            <option value="sm">Small (480px)</option>
            <option value="lg">Large (768px)</option>
            <option value="xl">Extra Large (896px)</option>
          </select>
          <small class="pa-settings-panel__hint">Press Ctrl+K to preview the palette.</small>
        </div>

        <%!-- Sidebar Mode --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-sidebar-mode"}><%= t("pureAdmin.settings.sidebarMode") %></label>
          <select
            id={"#{@id}-sidebar-mode"}
            class="pa-settings-panel__select"
            data-setting="sidebar-mode"
          >
            <option value=""><%= t("pureAdmin.settings.scrollsWithContent") %></option>
            <option value="sticky"><%= t("pureAdmin.settings.fixedPosition") %></option>
          </select>
        </div>

        <%!-- Sidebar Behavior --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-sidebar-behavior"}>
            <%= t("pureAdmin.settings.sidebarBehavior") %>
          </label>
          <select
            id={"#{@id}-sidebar-behavior"}
            class="pa-settings-panel__select"
            data-setting="sidebar-behavior"
          >
            <option value="hide"><%= t("pureAdmin.settings.hideCompletely") %></option>
            <option value="icon-collapse"><%= t("pureAdmin.settings.showIconsOnly") %></option>
          </select>
        </div>

        <%!-- Sidebar Options --%>
        <div class="pa-settings-panel__section">
          <span class="pa-settings-panel__label"><%= t("pureAdmin.settings.sidebar") %></span>
          <div class="pa-settings-panel__checkbox-group">
            <%!-- No "Collapsed" toggle here: the sidebar hide/show STATE is owned by
                 the navbar burger (sidebar.js persists `sidebar-hidden`), matching
                 pure-admin's panel which exposes only "Resizable". --%>
            <label class="pa-settings-panel__checkbox">
              <input type="checkbox" data-setting="sidebar-resizable" />
              <span><%= t("pureAdmin.settings.resizable") %></span>
            </label>
          </div>
        </div>

        <%!-- Display Options --%>
        <div class="pa-settings-panel__section">
          <span class="pa-settings-panel__label"><%= t("pureAdmin.settings.display") %></span>
          <div class="pa-settings-panel__checkbox-group">
            <label class="pa-settings-panel__checkbox">
              <input type="checkbox" data-setting="compact-mode" />
              <span><%= t("pureAdmin.settings.compactMode") %></span>
            </label>
            <label class="pa-settings-panel__checkbox">
              <input type="checkbox" data-setting="rtl-mode" />
              <span><%= t("pureAdmin.settings.rtlMode") %></span>
            </label>
          </div>
        </div>

        <%!-- Profile Panel --%>
        <div class="pa-settings-panel__section">
          <span class="pa-settings-panel__label"><%= t("pureAdmin.settings.profilePanel") %></span>
          <div class="pa-settings-panel__checkbox-group">
            <label class="pa-settings-panel__checkbox">
              <input type="checkbox" data-setting="profile-no-avatar" />
              <span><%= t("pureAdmin.settings.hideAvatar") %></span>
            </label>
            <label class="pa-settings-panel__checkbox">
              <input type="checkbox" data-setting="profile-icon-only-tabs" />
              <span><%= t("pureAdmin.settings.iconOnlyTabs") %></span>
            </label>
          </div>
        </div>

        <%!-- Font Size --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-font-size"}><%= t("pureAdmin.settings.fontSize") %></label>
          <select id={"#{@id}-font-size"} class="pa-settings-panel__select" data-setting="font-size">
            <option value="small"><%= t("pureAdmin.settings.fontSizeSmall") %></option>
            <option value="default"><%= t("pureAdmin.settings.fontSizeDefault") %></option>
            <option value="large"><%= t("pureAdmin.settings.fontSizeLarge") %></option>
            <option value="xlarge"><%= t("pureAdmin.settings.fontSizeXLarge") %></option>
          </select>
          <small class="pa-settings-panel__hint">
            <%= t("pureAdmin.settings.fontSizeHint") %>
          </small>
        </div>

        <%!-- Font Family --%>
        <div class="pa-settings-panel__section">
          <label class="pa-settings-panel__label" for={"#{@id}-font-family"}><%= t("pureAdmin.settings.fontFamily") %></label>
          <select
            id={"#{@id}-font-family"}
            class="pa-settings-panel__select"
            data-setting="font-family"
          >
            <option value="default"><%= t("pureAdmin.settings.themeDefault") %></option>
            <option value="serif">Serif</option>
            <option value="mono">Monospace</option>
            <option value="cuprum">Cuprum</option>
            <option value="fira-sans-condensed">Fira Sans Condensed</option>
            <option value="manrope">Manrope</option>
            <option value="martel">Martel</option>
            <option value="maven-pro">Maven Pro</option>
            <option value="monda">Monda</option>
            <option value="play">Play</option>
            <option value="signika">Signika</option>
            <option value="yanone-kaffeesatz">Yanone Kaffeesatz</option>
          </select>
        </div>

        <%!-- Reset Button --%>
        <div class="pa-settings-panel__section">
          <button class="pa-btn pa-btn--secondary pa-btn--block" type="button" data-reset>
            <%= t("pureAdmin.settings.resetToDefaults") %>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
