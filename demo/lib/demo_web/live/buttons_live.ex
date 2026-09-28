defmodule DemoWeb.Live.ButtonsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Buttons", loading_btn: nil)}
  end

  def handle_event("toggle_loading", %{"btn" => btn}, socket) do
    Process.send_after(self(), {:stop_loading, btn}, Enum.random(1000..3000))
    {:noreply, assign(socket, :loading_btn, btn)}
  end

  def handle_event("split_action", %{"action" => action}, socket) do
    {:noreply,
     PureAdmin.Components.Toast.push_toast(socket, "info", "Split Button", "Action: #{action}")}
  end

  def handle_event("split_action", _params, socket) do
    {:noreply,
     PureAdmin.Components.Toast.push_toast(
       socket,
       "info",
       "Split Button",
       "Primary button clicked"
     )}
  end

  def handle_event("remove_item", %{"action" => item}, socket) do
    {:noreply,
     PureAdmin.Components.Toast.push_toast(socket, "warning", "Removed", "Removed: #{item}",
       duration: 3000
     )}
  end

  def handle_event("remove_member", %{"action" => member}, socket) do
    {:noreply,
     PureAdmin.Components.Toast.push_toast(
       socket,
       "danger",
       "Member Removed",
       "Removed member: #{member}",
       duration: 3000
     )}
  end

  def handle_info({:stop_loading, _btn}, socket) do
    {:noreply, assign(socket, :loading_btn, nil)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Various button styles and sizes for actions and navigation.</.paragraph>

    <script>
      document.addEventListener("click", function(e) {
        var btn = e.target.closest("[data-ripple]");
        if (!btn) return;
        btn.classList.add("pa-btn--ripple-active");
        setTimeout(function() { btn.classList.remove("pa-btn--ripple-active"); }, 600);
      });
    </script>

    <%!-- Button Variants and Sizes --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button Variants")}>
          <.button_group>
            <.button variant="primary">Primary</.button>
            <.button variant="secondary">Secondary</.button>
            <.button variant="success">Success</.button>
            <.button variant="warning">Warning</.button>
            <.button variant="danger">Danger</.button>
            <.button variant="info">Info</.button>
            <.button variant="light">Light</.button>
            <.button variant="dark">Dark</.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button Sizes")}>
          <.button_group>
            <.button variant="primary" size="xs">Extra Small</.button>
            <.button variant="primary" size="sm">Small</.button>
            <.button variant="primary">Default</.button>
            <.button variant="primary" size="lg">Large</.button>
            <.button variant="primary" size="xl">Extra Large</.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Theme Color Buttons --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Theme Color Buttons")}>
          <.button_group>
            <.button :for={n <- 1..9} theme_color={to_string(n)}>Color {n}</.button>
          </.button_group>
        </.card>
      </.column>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Theme Color Outline Buttons")}>
          <.button_group>
            <.button :for={n <- 1..9} theme_color={to_string(n)} is_outline>Color {n}</.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Outline and States --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Outline Buttons")}>
          <.button_group>
            <.button variant="primary" is_outline>Primary</.button>
            <.button variant="secondary" is_outline>Secondary</.button>
            <.button variant="success" is_outline>Success</.button>
            <.button variant="warning" is_outline>Warning</.button>
            <.button variant="danger" is_outline>Danger</.button>
            <.button variant="info" is_outline>Info</.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button States")}>
          <.button_group>
            <.button variant="primary">Normal</.button>
            <.button variant="primary" disabled>Disabled</.button>
            <.button variant="primary" is_loading>Loading...</.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Block Buttons --%>
    <.card title_text={gettext("Block Buttons")}>
      <.button_group is_vertical>
        <.button variant="primary" is_block>Block Level Button</.button>
        <.button variant="secondary" is_block>Another Block Button</.button>
      </.button_group>
    </.card>

    <%!-- Button Groups --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button Groups - Basic")}>
          <.heading level={4}>{gettext("Horizontal (default)")}</.heading>
          <.button_group>
            <.button variant="secondary">Start</.button>
            <.button variant="secondary">Middle</.button>
            <.button variant="secondary">End</.button>
          </.button_group>

          <.heading level={4} class="mt-2">{gettext("Vertical")}</.heading>
          <.button_group is_vertical>
            <.button variant="secondary">Top</.button>
            <.button variant="secondary">Middle</.button>
            <.button variant="secondary">Bottom</.button>
          </.button_group>

          <.heading level={4} class="mt-2">{gettext("No-Wrap (prevents line breaks)")}</.heading>
          <.button_group is_nowrap>
            <.button variant="primary">One</.button>
            <.button variant="primary">Two</.button>
            <.button variant="primary">Three</.button>
            <.button variant="primary">Four</.button>
            <.button variant="primary">Five</.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button Groups - Gap Sizes")}>
          <.heading level={4}>{gettext("Semantic Gap Classes")}</.heading>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-xs</code> (4px)</.paragraph>
          <.button_group class="gap-xs mb-1">
            <.button variant="primary">A</.button>
            <.button variant="primary">B</.button>
            <.button variant="primary">C</.button>
            <.button variant="primary">D</.button>
          </.button_group>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-sm</code> (8px)</.paragraph>
          <.button_group class="gap-sm mb-1">
            <.button variant="secondary">A</.button>
            <.button variant="secondary">B</.button>
            <.button variant="secondary">C</.button>
            <.button variant="secondary">D</.button>
          </.button_group>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-md</code> (12px)</.paragraph>
          <.button_group class="gap-md mb-1">
            <.button variant="success">A</.button>
            <.button variant="success">B</.button>
            <.button variant="success">C</.button>
            <.button variant="success">D</.button>
          </.button_group>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-base</code> (16px)</.paragraph>
          <.button_group class="gap-base mb-1">
            <.button variant="info">A</.button>
            <.button variant="info">B</.button>
            <.button variant="info">C</.button>
            <.button variant="info">D</.button>
          </.button_group>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-lg</code> (24px)</.paragraph>
          <.button_group class="gap-lg mb-1">
            <.button variant="warning">A</.button>
            <.button variant="warning">B</.button>
            <.button variant="warning">C</.button>
            <.button variant="warning">D</.button>
          </.button_group>
          <.paragraph class="pa-text--secondary mb-1"><code>gap-xl</code> (32px)</.paragraph>
          <.button_group class="gap-xl">
            <.button variant="danger">A</.button>
            <.button variant="danger">B</.button>
            <.button variant="danger">C</.button>
            <.button variant="danger">D</.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Vertical Alignment & Responsive --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Vertical Alignment")}>
          <.paragraph class="pa-text--secondary mb-md">
            Use semantic gap classes (<code>gap-sm</code>, <code>gap-md</code>, <code>gap-lg</code>, <code>gap-xl</code>) to control vertical spacing between buttons.
          </.paragraph>
          <.grid>
            <.column size="50" xl="25">
              <.heading level={4}>Start <code>gap-sm</code></.heading>
              <.button_group is_vertical class="gap-sm">
                <.button variant="secondary" class="text-truncate">Short</.button>
                <.button variant="secondary" class="text-truncate">Medium Btn</.button>
                <.button variant="secondary" class="text-truncate">Long Button</.button>
              </.button_group>
            </.column>
            <.column size="50" xl="25">
              <.heading level={4}>Center <code>gap-md</code></.heading>
              <.button_group is_vertical align="center" class="gap-md">
                <.button variant="secondary" class="text-truncate">Short</.button>
                <.button variant="secondary" class="text-truncate">Medium Btn</.button>
                <.button variant="secondary" class="text-truncate">Long Button</.button>
              </.button_group>
            </.column>
            <.column size="50" xl="25">
              <.heading level={4}>End <code>gap-lg</code></.heading>
              <.button_group is_vertical align="end" class="gap-lg">
                <.button variant="secondary" class="text-truncate">Short</.button>
                <.button variant="secondary" class="text-truncate">Medium Btn</.button>
                <.button variant="secondary" class="text-truncate">Long Button</.button>
              </.button_group>
            </.column>
            <.column size="50" xl="25">
              <.heading level={4}>Stretch <code>gap-xl</code></.heading>
              <.button_group is_vertical align="stretch" class="gap-xl">
                <.button variant="primary" class="text-truncate">Save</.button>
                <.button variant="secondary" class="text-truncate">Cancel</.button>
                <.button variant="danger" class="text-truncate">DELETE</.button>
              </.button_group>
            </.column>
          </.grid>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Responsive Direction")}>
          <.heading level={4}>Horizontal → Vertical at md (768px)</.heading>
          <.paragraph class="pa-text--secondary mb-1">Resize window to see change</.paragraph>
          <.button_group responsive="md-vertical">
            <.button variant="primary">Save</.button>
            <.button variant="secondary">Cancel</.button>
            <.button variant="danger">Delete</.button>
          </.button_group>

          <.heading level={4} class="mt-2">Vertical → Horizontal at lg (992px)</.heading>
          <.paragraph class="pa-text--secondary mb-1">
            Starts vertical, becomes horizontal on large screens
          </.paragraph>
          <.button_group is_vertical responsive="lg-horizontal">
            <.button variant="success">Approve</.button>
            <.button variant="warning">Review</.button>
            <.button variant="danger">Reject</.button>
          </.button_group>

          <.heading level={4} class="mt-2">{gettext("Class Reference")}</.heading>
          <ul class="text-sm">
            <li><code>--sm-vertical</code> / <code>--sm-horizontal</code> at 576px</li>
            <li><code>--md-vertical</code> / <code>--md-horizontal</code> at 768px</li>
            <li><code>--lg-vertical</code> / <code>--lg-horizontal</code> at 992px</li>
            <li><code>--xl-vertical</code> / <code>--xl-horizontal</code> at 1200px</li>
          </ul>
        </.card>
      </.column>
    </.grid>

    <%!-- Split Buttons --%>
    <.card
      title_text={gettext("Split Buttons")}
      subtitle_text={gettext("Primary action + dropdown toggle combined into a single control")}
    >
      <.button_group class="gap-lg">
        <.split_button label={gettext("Save")} variant="primary" on_click="split_action">
          <:item icon="fas fa-file" on_click="split_action" action="save-draft">{gettext("Save as Draft")}</:item>
          <:item icon="fas fa-door-closed" on_click="split_action" action="save-close">
            {gettext("Save & Close")}
          </:item>
          <:item icon="fas fa-plus" on_click="split_action" action="save-new">{gettext("Save & New")}</:item>
        </.split_button>

        <.split_button label={gettext("Delete")} variant="danger" on_click="split_action">
          <:item is_danger on_click="split_action" action="delete-all">{gettext("Delete All")}</:item>
          <:item on_click="split_action" action="archive">{gettext("Archive Instead")}</:item>
        </.split_button>

        <.split_button
          label={gettext("Export")}
          icon="fas fa-download"
          variant="secondary"
          on_click="split_action"
        >
          <:item icon="fas fa-file-csv" on_click="split_action" action="export-csv">
            {gettext("Export as CSV")}
          </:item>
          <:item icon="fas fa-file-excel" on_click="split_action" action="export-excel">
            {gettext("Export as Excel")}
          </:item>
          <:item icon="fas fa-file-pdf" on_click="split_action" action="export-pdf">
            {gettext("Export as PDF")}
          </:item>
        </.split_button>
      </.button_group>

      <.heading level="4" class="mt-4">{gettext("Sizes")}</.heading>
      <.button_group class="gap-lg align-items-start">
        <.split_button label="XS Action" variant="primary" size="xs">
          <:item>Option A</:item>
          <:item>Option B</:item>
        </.split_button>

        <.split_button label="SM Action" variant="primary" size="sm">
          <:item>Option A</:item>
          <:item>Option B</:item>
        </.split_button>

        <.split_button label="Default" variant="primary">
          <:item>Option A</:item>
          <:item>Option B</:item>
        </.split_button>

        <.split_button label="LG Action" variant="primary" size="lg">
          <:item>Option A</:item>
          <:item>Option B</:item>
        </.split_button>
      </.button_group>

      <.heading level="4" class="mt-4">{gettext("Upward Placement")}</.heading>
      <.paragraph class="mb-1">
        Use <code>data-placement="top-end"</code>
        to open the menu upward. Floating UI will auto-flip if there's not enough space.
      </.paragraph>
      <.button_group class="gap-lg">
        <.split_button label={gettext("Upload")} variant="primary" placement="top-end">
          <:item>{gettext("Upload File")}</:item>
          <:item>{gettext("Upload Folder")}</:item>
          <:item>{gettext("Import from URL")}</:item>
        </.split_button>

        <.split_button label={gettext("New")} icon="fas fa-plus" variant="secondary" placement="top-end">
          <:item>{gettext("New Document")}</:item>
          <:item>{gettext("New Spreadsheet")}</:item>
          <:item>{gettext("New Presentation")}</:item>
        </.split_button>
      </.button_group>

      <.heading level="4" class="mt-4">{gettext("Custom Icons (no rotation)")}</.heading>
      <.paragraph class="mb-1">
        Omit <code>pa-btn-split__chevron</code>
        from the icon for static icons that don't rotate on open.
      </.paragraph>
      <.button_group class="gap-lg">
        <.split_button label={gettext("Share")} icon="fas fa-share" variant="primary" on_click="split_action">
          <:item>{gettext("Share via Email")}</:item>
          <:item>{gettext("Share via Link")}</:item>
          <:item>{gettext("Copy to Clipboard")}</:item>
        </.split_button>

        <.split_button label={gettext("Settings")} icon="fas fa-cog" variant="secondary" on_click="split_action">
          <:item>{gettext("General")}</:item>
          <:item>{gettext("Advanced")}</:item>
          <:item is_danger>{gettext("Reset All")}</:item>
        </.split_button>

        <.split_button label={gettext("Delete")} icon="fas fa-trash" variant="danger" on_click="split_action">
          <:item is_danger>{gettext("Delete Permanently")}</:item>
          <:item>{gettext("Move to Trash")}</:item>
        </.split_button>
      </.button_group>

      <.heading level="4" class="mt-4">{gettext("Items with Actions")}</.heading>
      <.paragraph class="mb-1">
        Menu items can include inline action buttons for quick operations like delete.
      </.paragraph>
      <.button_group class="gap-lg">
        <.split_button
          label={gettext("Bookmarks")}
          icon="fas fa-bookmark"
          variant="primary"
          on_click="split_action"
        >
          <:item
            icon="fas fa-home"
            on_click="split_action"
            action="Dashboard"
            action_icon="fas fa-trash-can"
            action_event="remove_item"
            action_value="Dashboard"
          >
            Dashboard
          </:item>
          <:item
            icon="fas fa-chart-line"
            on_click="split_action"
            action="Analytics"
            action_icon="fas fa-trash-can"
            action_event="remove_item"
            action_value="Analytics"
          >
            Analytics
          </:item>
          <:item
            icon="fas fa-users"
            on_click="split_action"
            action="Team Members"
            action_icon="fas fa-trash-can"
            action_event="remove_item"
            action_value="Team Members"
          >
            Team Members
          </:item>
        </.split_button>

        <.split_button
          label={gettext("Recent")}
          icon="fas fa-clock-rotate-left"
          variant="secondary"
          on_click="split_action"
        >
          <:item
            icon="fas fa-file"
            on_click="split_action"
            action="Report Q4.pdf"
            action_icon="fas fa-xmark"
            action_event="remove_item"
            action_value="Report Q4.pdf"
            action_variant="secondary"
          >
            Report Q4.pdf
          </:item>
          <:item
            icon="fas fa-file-code"
            on_click="split_action"
            action="schema.sql"
            action_icon="fas fa-xmark"
            action_event="remove_item"
            action_value="schema.sql"
            action_variant="secondary"
          >
            schema.sql
          </:item>
        </.split_button>

        <.split_button
          label={gettext("Members")}
          icon="fas fa-user-plus"
          variant="danger"
          on_click="split_action"
        >
          <:item
            icon="fas fa-user"
            on_click="split_action"
            action="Alice Cooper"
            action_icon="fas fa-trash-can"
            action_event="remove_member"
            action_value="Alice Cooper"
          >
            Alice Cooper
          </:item>
          <:item
            icon="fas fa-user"
            on_click="split_action"
            action="Bob Dylan"
            action_icon="fas fa-trash-can"
            action_event="remove_member"
            action_value="Bob Dylan"
          >
            Bob Dylan
          </:item>
          <:item
            icon="fas fa-user"
            on_click="split_action"
            action="Charlie Parker"
            action_icon="fas fa-trash-can"
            action_event="remove_member"
            action_value="Charlie Parker"
          >
            Charlie Parker
          </:item>
        </.split_button>
      </.button_group>
    </.card>

    <%!-- Overflow Toolbar --%>
    <.card
      title_text={gettext("Overflow Toolbar")}
      subtitle_text={gettext("Buttons collapse into a dedicated [⋮] more menu when the row runs out of horizontal space, and pop back out as room returns")}
    >
      <.paragraph class="pa-text--secondary mb-1">
        Drag the resize handle in the bottom-right of the box below to shrink the bar. Lowest
        <code>data-pa-actions-priority</code>
        (default <code>0</code>) drops into the <code>[⋮]</code>
        menu first; ties broken by the child nearest the end. "Publish" is pinned
        with <code>data-pa-actions-priority="10"</code>, "Members" with <code>15</code>, and "Run"
        stays visible longest with <code>20</code>. Drag all the way in and even a split button
        collapses into the <code>[⋮]</code>
        menu as an atomic labeled group — its primary plus its
        own options, nothing foreign mixes in. The "Members" split button's rows carry inline delete
        buttons that survive the collapse and still fire.
      </.paragraph>
      <div style="overflow: auto; resize: horizontal; min-width: 64px; max-width: 100%; padding: 1rem; border: 1px dashed var(--pc-border-color); border-radius: var(--pc-border-radius);">
        <.overflow id="overflow-demo-end">
          <.button variant="secondary" phx-click="split_action" phx-value-action="save">
            <:icon><i class="fas fa-floppy-disk"></i></:icon>
            {gettext("Save")}
          </.button>
          <.button variant="secondary" phx-click="split_action" phx-value-action="format">
            <:icon><i class="fas fa-wand-magic-sparkles"></i></:icon>
            {gettext("Format")}
          </.button>
          <.button variant="secondary" phx-click="split_action" phx-value-action="refresh">
            <:icon><i class="fas fa-rotate"></i></:icon>
            {gettext("Refresh")}
          </.button>
          <.button
            variant="success"
            data-pa-actions-priority="10"
            phx-click="split_action"
            phx-value-action="publish"
          >
            <:icon><i class="fas fa-cloud-arrow-up"></i></:icon>
            {gettext("Publish")}
          </.button>
          <.split_button
            label={gettext("Run")}
            icon="fas fa-play"
            variant="primary"
            on_click="split_action"
            data-pa-actions-priority="20"
          >
            <:item icon="fas fa-gear" on_click="split_action" action="run-options">
              {gettext("Run with options…")}
            </:item>
            <:item is_danger icon="fas fa-stop" on_click="split_action" action="stop-all">
              {gettext("Stop all jobs")}
            </:item>
          </.split_button>
          <.split_button
            label={gettext("Members")}
            icon="fas fa-user-plus"
            variant="danger"
            on_click="split_action"
            data-pa-actions-priority="15"
          >
            <:item
              icon="fas fa-user"
              on_click="split_action"
              action="member-alice"
              action_icon="fas fa-trash-can"
              action_event="remove_member"
              action_value="Alice Cooper"
            >
              Alice Cooper
            </:item>
            <:item
              icon="fas fa-user"
              on_click="split_action"
              action="member-bob"
              action_icon="fas fa-trash-can"
              action_event="remove_member"
              action_value="Bob Dylan"
            >
              Bob Dylan
            </:item>
            <:item
              icon="fas fa-user"
              on_click="split_action"
              action="member-charlie"
              action_icon="fas fa-trash-can"
              action_event="remove_member"
              action_value="Charlie Parker"
            >
              Charlie Parker
            </:item>
          </.split_button>
        </.overflow>
      </div>

      <.heading level="4" class="mt-4">{gettext("Drop direction & ghost trigger")}</.heading>
      <.paragraph class="pa-text--secondary mb-1">
        Default drops the child nearest the end first. Set <code>overflow_from="start"</code> to drop
        the leftmost child first instead. This bar also uses <code>trigger="ghost"</code> for the
        chromeless <code>[⋮]</code> look.
      </.paragraph>
      <div style="overflow: auto; resize: horizontal; min-width: 64px; max-width: 100%; padding: 1rem; border: 1px dashed var(--pc-border-color); border-radius: var(--pc-border-radius);">
        <.overflow id="overflow-demo-start" overflow_from="start" trigger="ghost">
          <.button variant="info" is_outline>
            <:icon><i class="fas fa-filter"></i></:icon>
            {gettext("Filter")}
          </.button>
          <.button variant="secondary" is_outline>
            <:icon><i class="fas fa-arrow-down-wide-short"></i></:icon>
            {gettext("Sort")}
          </.button>
          <.button variant="warning" is_outline>
            <:icon><i class="fas fa-layer-group"></i></:icon>
            {gettext("Group")}
          </.button>
          <.button variant="primary" is_outline>
            <:icon><i class="fas fa-table-cells"></i></:icon>
            {gettext("Pivot")}
          </.button>
          <.split_button
            label={gettext("Export")}
            icon="fas fa-download"
            variant="primary"
            on_click="split_action"
          >
            <:item icon="fas fa-file-csv" on_click="split_action" action="export-csv">
              {gettext("Export as CSV")}
            </:item>
            <:item icon="fas fa-file-code" on_click="split_action" action="export-json">
              {gettext("Export as JSON")}
            </:item>
            <:item icon="fas fa-file-pdf" on_click="split_action" action="export-pdf">
              {gettext("Export as PDF")}
            </:item>
          </.split_button>
        </.overflow>
      </div>

      <.heading level="4" class="mt-4">{gettext("In card headers")}</.heading>
      <.paragraph class="pa-text--secondary mb-1">
        In a card header, set <code>actions_variant="overflow"</code>
        on the <code>&lt;.card&gt;</code>
        —
        the <code>:tools</code>
        become direct children of <code>.pa-card__actions--overflow</code>
        (no
        inner wrapper), it appends its own <code>[⋮]</code>
        more-menu, and the title yields before the
        actions collapse. Laid out three-up so each card is already narrow — resize the window to watch
        each toolbar collapse at its own breakpoint.
      </.paragraph>
      <.grid class="mt-2">
        <.column size="100" lg="1-3">
          <.card
            title_text="Quarterly Performance & Customer Engagement Analytics Dashboard"
            title_class="minw-45"
            actions_variant="overflow"
          >
            <:tools>
              <.button
                variant="ghost"
                size="xs"
                title="Refresh"
                phx-click="split_action"
                phx-value-action="refresh"
              >
                <:icon><i class="fas fa-rotate"></i></:icon>
                {gettext("Refresh")}
              </.button>
              <.button
                variant="info"
                is_outline
                size="xs"
                phx-click="split_action"
                phx-value-action="filter"
              >
                <:icon><i class="fas fa-filter"></i></:icon>
                {gettext("Filter")}
              </.button>
              <.button
                variant="secondary"
                is_outline
                size="xs"
                phx-click="split_action"
                phx-value-action="configure"
              >
                <:icon><i class="fas fa-gear"></i></:icon>
                {gettext("Configure")}
              </.button>
              <.button
                variant="success"
                size="xs"
                data-pa-actions-priority="10"
                phx-click="split_action"
                phx-value-action="export"
              >
                <:icon><i class="fas fa-download"></i></:icon>
                {gettext("Export")}
              </.button>
              <.split_button
                label={gettext("Add widget")}
                icon="fas fa-plus"
                variant="primary"
                size="xs"
                on_click="split_action"
                data-pa-actions-priority="20"
              >
                <:item icon="fas fa-chart-line" on_click="split_action" action="add-chart">
                  {gettext("Add chart")}
                </:item>
                <:item icon="fas fa-table" on_click="split_action" action="add-table">
                  {gettext("Add table")}
                </:item>
              </.split_button>
            </:tools>
            <.paragraph class="pa-text--secondary">
              The actions bar in the header carries the overflow behavior — narrow the window to watch
              Configure, Filter, and Refresh fold into the <code>[⋮]</code> more-menu in that order
              (lowest priority first; Export is pinned, and the Add-widget split button survives longest).
            </.paragraph>
          </.card>
        </.column>

        <.column size="100" lg="1-3">
          <.card
            title_text="Database Migration Tasks — Production Environment Schema Updates"
            actions_variant="overflow"
          >
            <:tools>
              <.button variant="info" size="xs" phx-click="split_action" phx-value-action="validate">
                <:icon><i class="fas fa-circle-check"></i></:icon>
                {gettext("Validate")}
              </.button>
              <.button variant="warning" size="xs" phx-click="split_action" phx-value-action="backup">
                <:icon><i class="fas fa-database"></i></:icon>
                {gettext("Backup")}
              </.button>
              <.button
                variant="danger"
                is_outline
                size="xs"
                phx-click="split_action"
                phx-value-action="rollback"
              >
                <:icon><i class="fas fa-rotate-left"></i></:icon>
                {gettext("Rollback")}
              </.button>
              <.split_button
                label={gettext("Deploy")}
                icon="fas fa-rocket"
                variant="success"
                size="xs"
                on_click="split_action"
                data-pa-actions-priority="20"
              >
                <:item icon="fas fa-flask" on_click="split_action" action="dry-run">
                  {gettext("Dry-run only")}
                </:item>
                <:item icon="fas fa-vial" on_click="split_action" action="deploy-staging">
                  {gettext("Deploy to staging")}
                </:item>
                <:item is_danger icon="fas fa-fire" on_click="split_action" action="force-deploy">
                  {gettext("Force deploy (skip checks)")}
                </:item>
              </.split_button>
            </:tools>
            <.paragraph class="pa-text--secondary">
              No pinning here — siblings collapse in default order (rightmost first: Rollback → Backup →
              Validate). The Deploy split button survives longest, dropping into the <code>[⋮]</code>
              more-menu as an atomic labeled group.
            </.paragraph>
          </.card>
        </.column>

        <.column size="100" lg="1-3">
          <.card
            title_text="Team Members & Permissions Management — Enterprise Console"
            title_class="minw-60"
            actions_variant="overflow"
          >
            <:tools>
              <.button variant="ghost" size="xs" phx-click="split_action" phx-value-action="search">
                <:icon><i class="fas fa-magnifying-glass"></i></:icon>
                {gettext("Search")}
              </.button>
              <.button
                variant="secondary"
                is_outline
                size="xs"
                phx-click="split_action"
                phx-value-action="sort"
              >
                <:icon><i class="fas fa-arrow-down-wide-short"></i></:icon>
                {gettext("Sort")}
              </.button>
              <.button
                variant="info"
                is_outline
                size="xs"
                phx-click="split_action"
                phx-value-action="filter"
              >
                <:icon><i class="fas fa-filter"></i></:icon>
                {gettext("Filter")}
              </.button>
              <.button
                variant="secondary"
                size="xs"
                phx-click="split_action"
                phx-value-action="import"
              >
                <:icon><i class="fas fa-file-import"></i></:icon>
                {gettext("Import CSV")}
              </.button>
              <.button
                variant="info"
                size="xs"
                data-pa-actions-priority="5"
                phx-click="split_action"
                phx-value-action="invite"
              >
                <:icon><i class="fas fa-envelope"></i></:icon>
                {gettext("Invite")}
              </.button>
              <.split_button
                label={gettext("Add user")}
                icon="fas fa-user-plus"
                variant="primary"
                size="xs"
                on_click="split_action"
                data-pa-actions-priority="20"
              >
                <:item icon="fas fa-user-tag" on_click="split_action" action="add-role">
                  {gettext("Add user with role…")}
                </:item>
                <:item icon="fas fa-users" on_click="split_action" action="bulk-add">
                  {gettext("Bulk add from team")}
                </:item>
              </.split_button>
            </:tools>
            <.paragraph class="pa-text--secondary">
              Six siblings — Invite is pinned with priority 5, so it survives the first wave of collapses
              but still folds away before Add user. The title yields first (truncating to a min-width
              floor) so the action bar keeps its buttons; only when the header is genuinely tiny does the
              split button fold its own primary into the <code>[⋮]</code>
              more-menu, leaving just the toggle.
            </.paragraph>
          </.card>
        </.column>
      </.grid>
    </.card>

    <%!-- Text Truncation --%>
    <.card title_text={gettext("Text Truncation")}>
      <.paragraph class="pa-text--secondary mb-1">
        Use <code>.text-truncate</code>
        with a fixed width (<code>.wr-*</code>) to truncate long text with ellipsis
      </.paragraph>
      <div class="component-showcase">
        <.button variant="secondary" class="text-truncate wr-15">
          This is a very long button text that will be truncated with ellipsis
        </.button>
        <.button variant="primary" class="text-truncate wr-10">
          Another long button
        </.button>
        <.button variant="success" class="text-truncate wr-8">
          Short width truncation
        </.button>
      </div>
    </.card>

    <%!-- Icon Buttons --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Buttons with Text Icons")}>
          <.paragraph class="mb-1">
            Buttons with icons are automatically left-aligned with fixed-width icon container:
          </.paragraph>
          <.button_group>
            <.button variant="primary">
              <:icon>→</:icon>
              Next
            </.button>
            <.button variant="secondary">
              <:icon>←</:icon>
              Previous
            </.button>
            <.button variant="success">
              <:icon>✓</:icon>
              Save
            </.button>
            <.button variant="danger">
              <:icon>×</:icon>
              Delete
            </.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Icon Only Buttons")}>
          <.paragraph class="mb-2">Icon-only button sizes (XS → XL):</.paragraph>
          <.button_group class="mb-2">
            <.button variant="primary" is_icon_only size="xs" title="XS - 28px">
              <i class="fa-solid fa-star"></i>
            </.button>
            <.button variant="primary" is_icon_only size="sm" title="SM - 32px">
              <i class="fa-solid fa-star"></i>
            </.button>
            <.button variant="primary" is_icon_only title="Default - 40px">
              <i class="fa-solid fa-star"></i>
            </.button>
            <.button variant="primary" is_icon_only size="lg" title="LG - 48px">
              <i class="fa-solid fa-star"></i>
            </.button>
            <.button variant="primary" is_icon_only size="xl" title="XL - 56px">
              <i class="fa-solid fa-star"></i>
            </.button>
          </.button_group>
          <.paragraph class="mb-2">Various colors - default size:</.paragraph>
          <.button_group class="mb-2">
            <.button variant="primary" is_icon_only title="Save">
              <i class="fa-solid fa-floppy-disk"></i>
            </.button>
            <.button variant="secondary" is_icon_only title="Search">
              <i class="fa-solid fa-magnifying-glass"></i>
            </.button>
            <.button variant="success" is_icon_only title="Check">
              <i class="fa-solid fa-check"></i>
            </.button>
            <.button variant="warning" is_icon_only title="Warning">
              <i class="fa-solid fa-triangle-exclamation"></i>
            </.button>
            <.button variant="danger" is_icon_only title="Trash">
              <i class="fa-solid fa-trash"></i>
            </.button>
            <.button variant="info" is_icon_only title="Info">
              <i class="fa-solid fa-circle-info"></i>
            </.button>
          </.button_group>
          <.paragraph class="mb-2">Compact (XS) - perfect for table actions:</.paragraph>
          <.button_group>
            <.button variant="primary" is_icon_only size="xs" title="View">👁️</.button>
            <.button variant="secondary" is_icon_only size="xs" title="Edit">✏️</.button>
            <.button variant="danger" is_icon_only size="xs" title="Delete">🗑️</.button>
            <.button variant="success" is_icon_only size="xs" title="Check">
              <i class="fa-solid fa-check"></i>
            </.button>
            <.button variant="warning" is_icon_only size="xs" title="Warning">
              <i class="fa-solid fa-triangle-exclamation"></i>
            </.button>
            <.button variant="info" is_icon_only size="xs" title="Download">
              <i class="fa-solid fa-download"></i>
            </.button>
          </.button_group>
          <.paragraph class="mb-2">With ripple and loading states (click to test):</.paragraph>
          <.button_group>
            <.button
              variant="primary"
              is_icon_only
              is_ripple
              title="Save"
              is_loading={@loading_btn == "icon-save"}
              phx-click="toggle_loading"
              phx-value-btn="icon-save"
            >
              <i class="fa-solid fa-floppy-disk"></i>
            </.button>
            <.button
              variant="secondary"
              is_icon_only
              is_ripple
              title="Refresh"
              is_loading={@loading_btn == "icon-refresh"}
              phx-click="toggle_loading"
              phx-value-btn="icon-refresh"
            >
              <i class="fa-solid fa-rotate-right"></i>
            </.button>
            <.button
              variant="success"
              is_icon_only
              is_ripple
              title="Upload"
              is_loading={@loading_btn == "icon-upload"}
              phx-click="toggle_loading"
              phx-value-btn="icon-upload"
            >
              <i class="fa-solid fa-upload"></i>
            </.button>
            <.button
              variant="danger"
              is_icon_only
              is_ripple
              title="Delete"
              is_loading={@loading_btn == "icon-delete"}
              phx-click="toggle_loading"
              phx-value-btn="icon-delete"
            >
              <i class="fa-solid fa-trash"></i>
            </.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Fixed Width Buttons --%>
    <.card title_text={gettext("Fixed Width Buttons")}>
      <.paragraph class="mb-1">
        Use <code>minwr-*</code>
        + <code>maxwr-*</code>
        to constrain width. Add <code>text-truncate</code>
        on an inner span for ellipsis:
      </.paragraph>
      <div class="d-flex flex-column align-items-start gap-sm">
        <.button variant="primary" class="minwr-10 maxwr-10">
          <:icon>✓</:icon>
          <span class="text-truncate">OK</span>
        </.button>
        <.button variant="success" class="minwr-10 maxwr-10">
          <:icon>→</:icon>
          <span class="text-truncate">Save Changes</span>
        </.button>
        <.button variant="secondary" class="minwr-10 maxwr-10">
          <:icon>×</:icon>
          <span class="text-truncate">Cancel and Go Back</span>
        </.button>
      </div>

      <.heading level={4} class="mt-6">
        Different Widths (<code>minwr-8</code> to <code>minwr-20</code>)
      </.heading>
      <div class="d-flex flex-column align-items-start gap-sm">
        <.button variant="primary" class="minwr-8">minwr-8</.button>
        <.button variant="primary" class="minwr-10">minwr-10</.button>
        <.button variant="primary" class="minwr-15">minwr-15</.button>
        <.button variant="primary" class="minwr-20">minwr-20</.button>
      </div>
    </.card>

    <%!-- Button Text Alignment --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Button Text Alignment")}>
          <.paragraph class="mb-1">
            Control text alignment within fixed-width buttons. Note the varied text lengths to show the effect:
          </.paragraph>

          <.heading level={4}>{gettext("Inline Start Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="start">
              <:icon>✓</:icon>
              OK
            </.button>
            <.button variant="success" class="wr-20" align="start">
              <:icon>→</:icon>
              Continue
            </.button>
            <.button variant="secondary" class="wr-20" align="start">
              <:icon>×</:icon>
              Discard All Changes
            </.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Inline End Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="end" icon_position="end">
              <:icon>✓</:icon>
              OK
            </.button>
            <.button variant="success" class="wr-20" align="end" icon_position="end">
              <:icon>→</:icon>
              Continue
            </.button>
            <.button variant="secondary" class="wr-20" align="end" icon_position="end">
              <:icon>×</:icon>
              Discard All Changes
            </.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Center Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="center">
              <:icon>✓</:icon>
              OK
            </.button>
            <.button variant="success" class="wr-20" align="center">Continue</.button>
            <.button variant="secondary" class="wr-20" align="center">Discard All Changes</.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Justified")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="justify">
              <:icon>✓</:icon>
              OK
            </.button>
            <.button variant="success" class="wr-20" align="justify">
              <:icon>→</:icon>
              Continue
            </.button>
            <.button variant="secondary" class="wr-20" align="justify">
              <:icon>×</:icon>
              Discard All Changes
            </.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Font Awesome Icons")}>
          <.paragraph class="mb-1">
            Font Awesome icons with varied text lengths to show alignment:
          </.paragraph>

          <.heading level={4}>{gettext("Inline Start Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="start">
              <:icon><i class="fa-solid fa-floppy-disk"></i></:icon>
              {gettext("Save")}
            </.button>
            <.button variant="success" class="wr-20" align="start">
              <:icon><i class="fa-solid fa-check"></i></:icon>
              Approve Request
            </.button>
            <.button variant="danger" class="wr-20" align="start">
              <:icon><i class="fa-solid fa-trash"></i></:icon>
              Delete Selected Items
            </.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Inline End Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="end" icon_position="end">
              <:icon><i class="fa-solid fa-floppy-disk"></i></:icon>
              {gettext("Save")}
            </.button>
            <.button variant="success" class="wr-20" align="end" icon_position="end">
              <:icon><i class="fa-solid fa-arrow-right"></i></:icon>
              Approve Request
            </.button>
            <.button variant="secondary" class="wr-20" align="end" icon_position="end">
              <:icon><i class="fa-solid fa-gear"></i></:icon>
              Delete Selected Items
            </.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Center Aligned")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="center">
              <:icon><i class="fa-solid fa-upload"></i></:icon>
              {gettext("Upload")}
            </.button>
            <.button variant="success" class="wr-20" align="center">
              <:icon><i class="fa-solid fa-plus"></i></:icon>
              Add New Item
            </.button>
            <.button variant="info" class="wr-20" align="center">
              <:icon><i class="fa-solid fa-magnifying-glass"></i></:icon>
              Search Entire Database
            </.button>
          </.button_group>

          <.heading level={4} class="mt-6">{gettext("Justified")}</.heading>
          <.button_group is_vertical>
            <.button variant="primary" class="wr-20" align="justify">
              <:icon><i class="fa-solid fa-user"></i></:icon>
              {gettext("Profile")}
            </.button>
            <.button variant="success" class="wr-20" align="justify">
              <:icon><i class="fa-solid fa-envelope"></i></:icon>
              {gettext("Messages")}
            </.button>
            <.button variant="danger" class="wr-20" align="justify">
              <:icon><i class="fa-solid fa-right-from-bracket"></i></:icon>
              {gettext("Logout")}
            </.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Interactive Effects --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Ripple Effect Buttons")}>
          <.paragraph class="mb-1">Click buttons to see ripple animation effect:</.paragraph>
          <.button_group>
            <.button variant="primary" is_ripple>Primary Ripple</.button>
            <.button variant="secondary" is_ripple>Secondary Ripple</.button>
            <.button variant="success" is_ripple>Success Ripple</.button>
            <.button variant="warning" is_ripple>Warning Ripple</.button>
            <.button variant="danger" is_ripple>Danger Ripple</.button>
          </.button_group>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Loading State Buttons")}>
          <.paragraph class="mb-1">Click buttons to simulate loading states (1-3s):</.paragraph>
          <.button_group>
            <.button
              variant="primary"
              is_loading={@loading_btn == "save"}
              phx-click="toggle_loading"
              phx-value-btn="save"
            >
              Save Changes
            </.button>
            <.button
              variant="secondary"
              is_loading={@loading_btn == "load"}
              phx-click="toggle_loading"
              phx-value-btn="load"
            >
              Load Data
            </.button>
            <.button
              variant="success"
              is_loading={@loading_btn == "submit"}
              phx-click="toggle_loading"
              phx-value-btn="submit"
            >
              Submit Form
            </.button>
            <.button
              variant="warning"
              is_loading={@loading_btn == "process"}
              phx-click="toggle_loading"
              phx-value-btn="process"
            >
              Process
            </.button>
            <.button
              variant="danger"
              is_loading={@loading_btn == "delete"}
              phx-click="toggle_loading"
              phx-value-btn="delete"
            >
              Delete Item
            </.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>

    <%!-- Usage Guide --%>
    <.card title_text={gettext("Usage Guide")}>
      <.heading level={4}>{gettext("Ripple Effect")}</.heading>
      <.paragraph>
        Add <code>pa-btn--ripple</code>
        class and <code>data-ripple</code>
        attribute to any button for click animation feedback.
      </.paragraph>

      <.heading level={4}>{gettext("Loading States")}</.heading>
      <.paragraph>
        Use <code>pa-btn--loading</code>
        class to show spinner. JavaScript can toggle this class during async operations.
      </.paragraph>

      <.heading level={4}>{gettext("Best Practices")}</.heading>
      <.basic_list>
        <li>
          <strong>Fast Sites:</strong>
          Always show loading feedback, even for quick operations (200-500ms minimum)
        </li>
        <li>
          <strong>User Confidence:</strong> Ripple effects confirm button clicks were registered
        </li>
        <li>
          <strong>Prevent Double-clicks:</strong>
          Disable buttons during loading to prevent duplicate submissions
        </li>
        <li><strong>Accessibility:</strong> Loading states are announced to screen readers</li>
      </.basic_list>
    </.card>

    <%!-- CSS Classes Reference --%>
    <.card title_text={gettext("CSS Classes Reference")}>
      <.heading level={4}>Button Base</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn</code> - Base button styling</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button Variants (Colors)</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--primary</code> - Primary accent color</li>
        <li><code>pa-btn--secondary</code> - Secondary/neutral color</li>
        <li><code>pa-btn--success</code> - Success/green color</li>
        <li><code>pa-btn--warning</code> - Warning/yellow color</li>
        <li><code>pa-btn--danger</code> - Danger/red color</li>
        <li><code>pa-btn--info</code> - Info/blue color</li>
        <li><code>pa-btn--light</code> - Light background</li>
        <li><code>pa-btn--dark</code> - Dark background</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Outline Variants</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--outline-primary</code> - Outline primary</li>
        <li><code>pa-btn--outline-secondary</code> - Outline secondary</li>
        <li><code>pa-btn--outline-success</code> - Outline success</li>
        <li><code>pa-btn--outline-warning</code> - Outline warning</li>
        <li><code>pa-btn--outline-danger</code> - Outline danger</li>
        <li><code>pa-btn--outline-info</code> - Outline info</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Theme Color Variants</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--color-{1 - 9}</code> - Theme color slot buttons</li>
        <li><code>pa-btn--outline-color-{1 - 9}</code> - Outline theme color slot buttons</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button Sizes</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--xs</code> - Extra small button</li>
        <li><code>pa-btn--sm</code> - Small button</li>
        <li><code>pa-btn--lg</code> - Large button</li>
        <li><code>pa-btn--xl</code> - Extra large button</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button States & Modifiers</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--loading</code> - Loading state with spinner</li>
        <li><code>pa-btn--ripple</code> - Enable ripple click effect</li>
        <li><code>pa-btn--block</code> - Full width block button</li>
        <li><code>pa-btn--icon-only</code> - Square icon-only button</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Content Alignment</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn--align-start</code> - Inline-start align content (RTL: right)</li>
        <li><code>pa-btn--align-end</code> - Inline-end align content (RTL: left)</li>
        <li><code>pa-btn--align-center</code> - Center-align content</li>
        <li><code>pa-btn--align-justify</code> - Space-between content</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button Elements</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn__icon</code> - Icon container with fixed width</li>
        <li><code>pa-btn__label</code> - Text label wrapper (enables centering with icons)</li>
        <li><code>pa-btn__spinner</code> - Loading spinner element</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button Groups</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn-group</code> - Container for grouped buttons</li>
        <li><code>pa-btn-group--vertical</code> - Vertical stacking</li>
        <li><code>pa-btn-group--nowrap</code> - Prevent wrapping</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Button Group Alignment (vertical only)</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn-group--center</code> - Center-align buttons</li>
        <li><code>pa-btn-group--end</code> - End-align buttons</li>
        <li><code>pa-btn-group--stretch</code> - Full width buttons</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Split Buttons</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn-split</code> - Container for split button</li>
        <li><code>pa-btn-split__toggle</code> - Toggle/chevron button</li>
        <li><code>pa-btn-split__chevron</code> - Chevron icon (rotates on open)</li>
        <li><code>pa-btn-split__menu</code> - Dropdown menu panel</li>
        <li><code>pa-btn-split__menu-inner</code> - Inner wrapper (flex layout)</li>
        <li><code>pa-btn-split__menu--open</code> - Show dropdown menu</li>
        <li><code>pa-btn-split__item</code> - Menu item button</li>
        <li><code>pa-btn-split__item--danger</code> - Destructive action styling</li>
        <li><code>pa-btn-split__item-icon</code> - Menu item icon container</li>
        <li><code>pa-btn-split__item-row</code> - Row with item + inline action button</li>
        <li><code>data-placement="top-end"</code> - Open menu upward</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Responsive Button Groups</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-btn-group--sm-vertical</code> - Vertical at 576px+</li>
        <li><code>pa-btn-group--sm-horizontal</code> - Horizontal at 576px+</li>
        <li><code>pa-btn-group--md-vertical</code> - Vertical at 768px+</li>
        <li><code>pa-btn-group--md-horizontal</code> - Horizontal at 768px+</li>
        <li><code>pa-btn-group--lg-vertical</code> - Vertical at 992px+</li>
        <li><code>pa-btn-group--lg-horizontal</code> - Horizontal at 992px+</li>
        <li><code>pa-btn-group--xl-vertical</code> - Vertical at 1200px+</li>
        <li><code>pa-btn-group--xl-horizontal</code> - Horizontal at 1200px+</li>
      </.basic_list>
    </.card>
    """
  end
end
