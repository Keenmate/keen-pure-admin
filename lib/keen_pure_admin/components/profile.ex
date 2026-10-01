defmodule PureAdmin.Components.Profile do
  @moduledoc """
  Profile panel components for Pure Admin.

  Provides a slide-out profile panel with user info, avatar, navigation,
  and optional tabs/footer.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import PureAdmin.Components.Icon
  import PureAdmin.Helpers

  @doc """
  Renders a profile panel with overlay.

  ## Examples

      <.profile_panel id="profile" name="John Doe" email="john@example.com" role="Admin">
        <:nav>
          <.profile_nav_item href="/profile" icon="fa-solid fa-user">Profile Settings</.profile_nav_item>
          <.profile_nav_item href="/security" icon="fa-solid fa-lock">Security</.profile_nav_item>
        </:nav>
        <:footer_>
          <button class="pa-btn pa-btn--danger pa-btn--block">Sign Out</button>
        </:footer_>
      </.profile_panel>
  """
  attr(:id, :string, default: "profile-panel")
  attr(:name, :string, required: true, doc: "User display name")
  attr(:email, :string, required: true, doc: "User email")
  attr(:role, :string, default: nil, doc: "User role badge text")
  attr(:has_avatar, :boolean, default: true, doc: "Show avatar section")
  attr(:has_icon_only_tabs, :boolean, default: false, doc: "Tabs show only icons")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:avatar, doc: "Custom avatar content (default: user icon)")
  slot(:tabs, doc: "Tabs section between header and body")
  slot(:nav, doc: "Navigation items in the body")
  slot(:actions, doc: "Action buttons in the body (deprecated, use footer_)")
  slot(:footer_, doc: "Fixed footer content (e.g. sign out button)")
  slot(:inner_block, doc: "Full body content (replaces nav+actions when using tabs)")

  def profile_panel(assigns) do
    ~H"""
    <div id={@id} class={profile_panel_classes(assigns)} phx-hook="PureAdminProfilePanel" {@rest}>
      <div class="pa-profile-panel__overlay" phx-click={close_profile_panel(@id)}></div>

      <div class="pa-profile-panel__content">
        <div class={profile_header_classes(assigns)}>
          <div class="pa-profile-panel__avatar">
            <%= if @avatar != [] do %>
              <%= for avatar <- @avatar do %>
                <%= render_slot(avatar) %>
              <% end %>
            <% else %>
              <span class="pa-profile-panel__avatar-icon"><span class="pa-icon pa-icon--user" aria-hidden="true"></span></span>
            <% end %>
          </div>

          <div class="pa-profile-panel__info">
            <h3 class="pa-profile-panel__name" title={@name}><%= @name %></h3>
            <p class="pa-profile-panel__email" title={@email}><%= @email %></p>
            <span :if={@role} class="pa-badge"><%= @role %></span>
          </div>

          <button
            class="pa-profile-panel__close"
            phx-click={close_profile_panel(@id)}
            aria-label="Close Profile"
          >
            <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
          </button>
        </div>

        <div
          :if={@tabs != []}
          class={build_classes("pa-profile-panel__tabs", [{"pa-profile-panel__tabs--icon-only", @has_icon_only_tabs}])}
        >
          <%= for tabs <- @tabs do %>
            <%= render_slot(tabs) %>
          <% end %>
        </div>

        <div class="pa-profile-panel__body">
          <%= if @inner_block != [] do %>
            <%= render_slot(@inner_block) %>
          <% else %>
            <nav :if={@nav != []} class="pa-profile-panel__nav">
              <ul>
                <%= for nav <- @nav do %>
                  <%= render_slot(nav) %>
                <% end %>
              </ul>
            </nav>
            <div :if={@actions != []} class="pa-profile-panel__actions">
              <%= for actions <- @actions do %>
                <%= render_slot(actions) %>
              <% end %>
            </div>
          <% end %>
        </div>

        <div :if={@footer_ != []} class="pa-profile-panel__footer">
          <%= for footer_ <- @footer_ do %>
            <%= render_slot(footer_) %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp profile_panel_classes(assigns) do
    build_classes("pa-profile-panel", [], assigns.class)
  end

  defp profile_header_classes(assigns) do
    build_classes(
      "pa-profile-panel__header",
      [{"pa-profile-panel__header--no-avatar", !assigns.has_avatar}]
    )
  end

  @doc """
  Renders a navigation item within the profile panel.

  ## Examples

      <.profile_nav_item href="/settings" icon="fa-solid fa-gear">Settings</.profile_nav_item>
  """
  attr(:href, :string, default: "#")
  attr(:icon, :string, default: nil, doc: "Icon: an FA/hero class, or raw inline SVG markup (rendered verbatim)")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(navigate patch))
  slot(:inner_block, required: true)

  def profile_nav_item(assigns) do
    ~H"""
    <li>
      <a href={safe_url(@href)} class={build_classes("pa-profile-panel__nav-item", [], @class)} {@rest}>
        <span :if={@icon} class="pa-profile-panel__nav-icon"><%= if svg_icon?(@icon) do %><%= Phoenix.HTML.raw(@icon) %><% else %><.icon name={@icon} /><% end %></span>
        <%= render_slot(@inner_block) %>
      </a>
    </li>
    """
  end

  # Raw inline SVG markup (e.g. a Lucide glyph) is detected by a leading `<` and
  # rendered verbatim; anything else is treated as an FA/hero icon class.
  defp svg_icon?(icon) when is_binary(icon), do: String.starts_with?(String.trim_leading(icon), "<")
  defp svg_icon?(_), do: false

  @doc "JS command to toggle the profile panel open/closed."
  @spec toggle_profile_panel(String.t()) :: JS.t()
  def toggle_profile_panel(id \\ "profile-panel") do
    JS.toggle_class("pa-profile-panel--open", to: "##{id}")
  end

  @doc "JS command to close the profile panel."
  @spec close_profile_panel(String.t()) :: JS.t()
  def close_profile_panel(id \\ "profile-panel") do
    JS.remove_class("pa-profile-panel--open", to: "##{id}")
  end
end
