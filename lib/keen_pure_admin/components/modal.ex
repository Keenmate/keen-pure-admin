defmodule PureAdmin.Components.Modal do
  @moduledoc """
  Modal components for Pure Admin with JS-command-based show/hide.

  Uses `Phoenix.LiveView.JS` commands for toggling visibility,
  ESC key handling, and backdrop click.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @doc """
  Renders a modal dialog.

  ## Examples

      <.modal id="confirm-modal" title_text="Confirm Action">
        Are you sure you want to proceed?
        <:footer>
          <.button variant="secondary" phx-click={hide_modal("confirm-modal")}>Cancel</.button>
          <.button variant="primary" phx-click="confirm">Confirm</.button>
        </:footer>
      </.modal>

      <.modal id="danger-modal" variant="danger" title_text="Delete Item">
        This action cannot be undone.
        <:footer>
          <.button variant="danger" phx-click="delete">Delete</.button>
        </:footer>
      </.modal>

      <!-- Show modal from a button -->
      <.button phx-click={show_modal("confirm-modal")}>Open Modal</.button>
  """
  attr(:id, :string, required: true)

  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "success", "warning", "danger", "info"],
    doc: "Full modal theming"
  )

  attr(:size, :string, default: nil, values: [nil, "sm", "md", "lg", "xl", "xxl", "fw"])

  attr(:is_banded, :boolean,
    default: false,
    doc:
      "Apply `pa-modal--banded` (filled header + footer bands). Requires a band role `:variant` " <>
        "(`success` / `warning` / `danger` / `info`) — core ships band tokens for those four only, " <>
        "so `is_banded` is ignored for any other variant. Buttons inside the bands auto-invert for cross-theme contrast."
  )

  attr(:is_static, :boolean, default: false, doc: "Prevent closing via ESC/backdrop")
  attr(:is_top, :boolean, default: false, doc: "Position near top of viewport")
  attr(:is_scrollable, :boolean, default: false, doc: "Scrollable body")
  attr(:show, :boolean, default: false, doc: "Initial visibility")
  attr(:title_text, :string, default: nil, doc: "Modal title text (shorthand for :header slot)")

  attr(:title_icon, :string,
    default: nil,
    doc:
      "Optional leading severity glyph on the title (used with :title_text): a `.pa-icon--*` name, e.g. \"success\" / \"warning\" / \"danger\" / \"info\". Matches core's static severity modals."
  )

  attr(:should_show_close, :boolean, default: true, doc: "Show close button in header")
  attr(:on_cancel, JS, default: %JS{}, doc: "JS command to run when modal is cancelled")
  attr(:class, :string, default: nil)
  attr(:body_class, :string, default: nil, doc: "Additional CSS classes for body")
  attr(:footer_class, :string, default: nil, doc: "Additional CSS classes for footer")
  attr(:rest, :global)
  slot(:header, doc: "Modal header content (overrides title_text)")
  slot(:footer, doc: "Modal footer content")
  slot(:inner_block, required: true)

  def modal(assigns) do
    has_header = assigns.header != [] || assigns.title_text != nil
    assigns = assign(assigns, :has_header, has_header)

    ~H"""
    <div
      id={@id}
      class={modal_classes(assigns)}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      {@rest}
    >
      <div
        class="pa-modal__backdrop"
        phx-click={!@is_static && JS.exec(@on_cancel, "phx-remove", to: "##{@id}")}
      />
      <div class={container_classes(assigns)}>
        <div :if={@has_header} class={header_classes(assigns)}>
          <%= if @header != [] do %>
            <h3 class="pa-modal__title"><%= render_slot(@header) %></h3>
          <% else %>
            <h3 :if={@title_text} class="pa-modal__title"><span :if={@title_icon} class={"pa-icon pa-icon--#{@title_icon}"} aria-hidden="true"></span><%= if @title_icon, do: " " %><%= @title_text %></h3>
          <% end %>
          <button
            :if={@should_show_close && !@is_static}
            class={close_button_classes(assigns)}
            phx-click={JS.exec(@on_cancel, "phx-remove", to: "##{@id}")}
            aria-label={t("pureAdmin.a11y.close")}
          >
            <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
          </button>
        </div>
        <div class={body_classes(assigns)}>
          <%= render_slot(@inner_block) %>
        </div>
        <div :if={@footer != []} class={footer_classes(assigns)}>
          <%= for footer <- @footer do %>
            <%= render_slot(footer) %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Returns a JS command to show a modal by adding the `pa-modal--show` class.
  """
  @spec show_modal(String.t()) :: JS.t()
  def show_modal(id) do
    %JS{}
    |> JS.add_class("pa-modal--show", to: "##{id}")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id} .pa-modal__container")
  end

  @doc """
  Returns a JS command to hide a modal by removing the `pa-modal--show` class.
  """
  @spec hide_modal(String.t()) :: JS.t()
  def hide_modal(id) do
    %JS{}
    |> JS.remove_class("pa-modal--show", to: "##{id}")
    |> JS.remove_class("overflow-hidden", to: "body")
  end

  # Band styling exists only for these four roles (`.pa-modal--banded.pa-modal--{role}`
  # in dist). `is_banded` with any other variant would emit an unstyled `--banded`
  # class, so it's guarded to these.
  @band_variants ~w(success warning danger info)

  defp modal_classes(assigns) do
    # Core has ONE variant knob: the root `.pa-modal--{variant}`, which colours
    # the header (and, with `--banded`, the footer) via descendant rules. There
    # is NO `pa-modal__header--{variant}` class — so no separate header-only knob.
    variant = assigns.variant
    banded = assigns.is_banded and variant in @band_variants

    build_classes(
      "pa-modal",
      [
        {"pa-modal--#{variant}", variant != nil},
        {"pa-modal--banded", banded},
        {"pa-modal--static", assigns.is_static},
        {"pa-modal--top", assigns.is_top}
      ],
      assigns.class
    )
  end

  defp container_classes(assigns) do
    # "md" is the default medium — core defines no `pa-modal__container--md`
    # (sizes are sm / lg / xl / xxl / fw); a bare `.pa-modal__container` IS medium.
    size = if assigns.size in [nil, "md"], do: nil, else: assigns.size

    build_classes("pa-modal__container", [
      {"pa-modal__container--#{size}", size != nil}
    ])
  end

  # Header colour comes from the root `.pa-modal--{variant}` (see modal_classes);
  # `pa-modal__header--{variant}` does not exist in core, so the header carries
  # only its base class. (This is why there's no separate `header_variant` knob —
  # core can't theme the header independently of the modal.)
  defp header_classes(_assigns), do: "pa-modal__header"

  defp body_classes(assigns) do
    build_classes(
      "pa-modal__body",
      [
        {"pa-modal__body--scrollable", assigns.is_scrollable}
      ],
      assigns.body_class
    )
  end

  defp footer_classes(assigns) do
    build_classes("pa-modal__footer", [], assigns.footer_class)
  end

  # Header close button: themed modals get pa-btn--light to read against
  # the coloured header strip; default modal uses pa-btn--secondary.
  defp close_button_classes(assigns) do
    variant = assigns.variant
    color = if variant != nil, do: "light", else: "secondary"
    "pa-btn pa-btn--sm pa-btn--icon-only pa-btn--#{color}"
  end
end
