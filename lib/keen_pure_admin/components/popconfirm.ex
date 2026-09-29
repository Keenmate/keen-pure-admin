defmodule PureAdmin.Components.Popconfirm do
  @moduledoc """
  Popconfirm component for Pure Admin.

  Small confirmation dialogs anchored to trigger buttons.
  Perfect for delete confirmations and quick yes/no decisions.
  Uses Floating UI for positioning with automatic collision detection.
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @doc """
  Renders a popconfirm with a trigger button and confirmation dialog.

  ## Examples

      <.popconfirm
        id="delete-item"
        message="Are you sure you want to delete this item?"
        confirm_event="delete"
        confirm_value={%{id: @item.id}}
      >
        <.button variant="danger" size="xs">Delete</.button>
      </.popconfirm>

      <.popconfirm
        id="archive"
        message="Archive this item?"
        icon_variant="warning"
        confirm_text="Archive"
        confirm_variant="warning"
        confirm_event="archive"
      >
        <.button variant="warning">Archive</.button>
      </.popconfirm>
  """
  attr(:id, :string, required: true)
  attr(:message, :string, required: true, doc: "Confirmation message text")
  attr(:placement, :string, default: "bottom", values: ["top", "bottom", "start", "end"])

  attr(:icon_variant, :string,
    default: nil,
    values: [nil, "default", "danger", "warning", "info"],
    doc:
      "Message icon. `nil` = no icon; `\"default\"` = the bare `pa-popconfirm__icon` (the base " <>
        "triangle-alert glyph, no colour modifier); `danger`/`warning`/`info` add " <>
        "`pa-popconfirm__icon--{variant}` for the coloured severity glyph."
  )

  attr(:is_compact, :boolean, default: false, doc: "Compact variant for table actions")
  attr(:confirm_text, :string, default: nil, doc: "Confirm button text (default: translated)")
  attr(:cancel_text, :string, default: nil, doc: "Cancel button text (default: translated)")

  attr(:confirm_variant, :string,
    default: "danger",
    values: ["primary", "secondary", "success", "warning", "danger", "info"],
    doc: "Confirm button color variant"
  )

  attr(:confirm_event, :string, default: nil, doc: "LiveView event to push on confirm")
  attr(:confirm_value, :map, default: %{}, doc: "Value to send with confirm event")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true, doc: "Trigger content (usually a button)")

  def popconfirm(assigns) do
    assigns =
      assigns
      |> assign(:confirm_text, assigns.confirm_text || t("pureAdmin.popconfirm.confirm"))
      |> assign(:cancel_text, assigns.cancel_text || t("pureAdmin.popconfirm.cancel"))
      |> assign(:confirm_value_attrs, confirm_value_attrs(assigns.confirm_value))

    ~H"""
    <%!-- Anchor wrapper: keen can't attach the trigger data-attr to arbitrary
         slot content, so it wraps the trigger. No `pa-popconfirm-wrapper` class —
         that's not a core class (core's trigger is a bare sibling); the JS anchors
         via `data-pa-popconfirm-trigger`, and inline-block/relative come from style. --%>
    <div
      style="display: inline-block; position: relative;"
      data-pa-popconfirm-trigger={@id}
    >
      <%= render_slot(@inner_block) %>
    </div>
    <div
      id={@id}
      class={build_classes("pa-popconfirm", [
        {"pa-popconfirm--#{@placement}", true},
        {"pa-popconfirm--compact", @is_compact}
      ], @class)}
      data-placement={@placement}
      {@rest}
    >
      <div class="pa-popconfirm__arrow"></div>
      <div class="pa-popconfirm__content">
        <div class={build_classes("pa-popconfirm__message", [
          {"pa-popconfirm__icon", @icon_variant != nil},
          {"pa-popconfirm__icon--#{@icon_variant}", @icon_variant not in [nil, "default"]}
        ])}>
          <p><%= @message %></p>
        </div>
        <div class="pa-popconfirm__actions">
          <button class="pa-btn pa-btn--secondary" type="button" data-pa-popconfirm-close={@id}>
            <%= @cancel_text %>
          </button>
          <button
            class={"pa-btn pa-btn--#{@confirm_variant}"}
            type="button"
            phx-click={@confirm_event}
            data-pa-popconfirm-close={@id}
            {@confirm_value_attrs}
          >
            <%= @confirm_text %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  # Forward EVERY key of `confirm_value` as a `phx-value-*` attribute (was only
  # `:id`). So `confirm_value={%{id: 1, kind: "row"}}` sends both id + kind with
  # the confirm event. Nil values are dropped (Phoenix omits nil attrs).
  defp confirm_value_attrs(confirm_value) do
    Map.new(confirm_value, fn {k, v} -> {"phx-value-#{k}", v} end)
  end
end
