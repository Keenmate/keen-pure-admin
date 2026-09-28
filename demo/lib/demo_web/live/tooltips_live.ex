defmodule DemoWeb.Live.TooltipsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Tooltips")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>CSS-only tooltips and click-triggered popovers for contextual information.</.paragraph>

    <.grid>
      <%!-- Left Column --%>
      <.column size="100" lg="1-2">
        <%!-- Tooltip Positions & Colors --%>
        <.card title_text={gettext("Tooltip Positions & Colors")} class="mb-4">
          <.grid>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Tooltip on top")}>{gettext("Top")}</.tooltip>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Tooltip on end")} position="end">{gettext("End")}</.tooltip>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Tooltip on bottom")} position="bottom">{gettext("Bottom")}</.tooltip>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Tooltip on start")} position="start">{gettext("Start")}</.tooltip>
            </.column>
          </.grid>
          <hr class="my-3" />
          <.grid>
            <.column size="1-3" md="1-5" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Default dark")}>{gettext("Default")}</.tooltip>
            </.column>
            <.column size="1-3" md="1-5" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Primary blue")} variant="primary">{gettext("Primary")}</.tooltip>
            </.column>
            <.column size="1-3" md="1-5" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Success green")} variant="success">{gettext("Success")}</.tooltip>
            </.column>
            <.column size="1-2" md="1-5" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Warning yellow")} variant="warning">{gettext("Warning")}</.tooltip>
            </.column>
            <.column size="1-2" md="1-5" class="text-center mb-3 p-4">
              <.tooltip text={gettext("Danger red")} variant="danger">{gettext("Danger")}</.tooltip>
            </.column>
          </.grid>
          <hr class="my-3" />
          <.paragraph class="text-sm mb-3">{gettext("Theme colors (color-1 to color-9):")}</.paragraph>
          <.grid>
            <.column :for={i <- 1..9} class="text-center mb-3 p-2">
              <.tooltip text={"Color #{i}"} variant={"color-#{i}"}><%= i %></.tooltip>
            </.column>
          </.grid>
        </.card>

        <%!-- Buttons with Tooltips --%>
        <.card title_text={gettext("Buttons & Icon-Only")} class="mb-4">
          <.paragraph class="mb-3 text-sm">{gettext("Regular buttons:")}</.paragraph>
          <div class="text-center mb-4">
            <.button_group>
              <.tooltip text={gettext("Save your changes")} position="start">
                <.button variant="primary" size="sm">
                  <:icon><i class="fa-solid fa-floppy-disk"></i></:icon>
                  {gettext("Save")}
                </.button>
              </.tooltip>
              <.tooltip text={gettext("Cancel and go back")} position="bottom">
                <.button variant="secondary" size="sm">
                  <:icon><i class="fa-solid fa-xmark"></i></:icon>
                  {gettext("Cancel")}
                </.button>
              </.tooltip>
              <.tooltip text={gettext("Delete this item")} position="bottom">
                <.button variant="danger" size="sm">
                  <:icon><i class="fa-solid fa-trash"></i></:icon>
                  {gettext("Delete")}
                </.button>
              </.tooltip>
            </.button_group>
          </div>
          <.paragraph class="mb-3 text-sm">{gettext("Icon-only buttons:")}</.paragraph>
          <div class="text-center">
            <.button_group>
              <.tooltip text={gettext("Edit")} position="bottom">
                <.button variant="primary" size="sm" is_icon_only><i class="fa-solid fa-pen"></i></.button>
              </.tooltip>
              <.tooltip text={gettext("Copy")} position="bottom">
                <.button variant="secondary" size="sm" is_icon_only><i class="fa-solid fa-copy"></i></.button>
              </.tooltip>
              <.tooltip text={gettext("Download")} position="bottom">
                <.button variant="success" size="sm" is_icon_only><i class="fa-solid fa-download"></i></.button>
              </.tooltip>
              <.tooltip text={gettext("Settings")} position="bottom">
                <.button variant="warning" size="sm" is_icon_only><i class="fa-solid fa-gear"></i></.button>
              </.tooltip>
              <.tooltip text={gettext("Delete")} position="bottom">
                <.button variant="danger" size="sm" is_icon_only><i class="fa-solid fa-trash"></i></.button>
              </.tooltip>
              <.tooltip text={gettext("Info")} position="bottom">
                <.button variant="info" size="sm" is_icon_only><i class="fa-solid fa-circle-info"></i></.button>
              </.tooltip>
            </.button_group>
          </div>
        </.card>

        <%!-- Multiline Tooltips --%>
        <.card title_text={gettext("Multiline Tooltips")} class="mb-4">
          <.paragraph class="mb-3 text-sm">
            Use <code>multiline</code> prop for longer text (20rem width, left-aligned):
          </.paragraph>
          <div class="text-center">
            <.button_group>
              <.tooltip text="This button will save your changes to the database. Make sure you have reviewed all fields before clicking. Changes cannot be undone after saving." position="bottom" multiline>
                <.button variant="primary" size="sm">
                  <:icon><i class="fa-solid fa-floppy-disk"></i></:icon>
                  {gettext("Save")}
                </.button>
              </.tooltip>
              <.tooltip text="This action will permanently delete the selected item and all associated data. This operation cannot be reversed. Please confirm you want to proceed." position="bottom" multiline>
                <.button variant="danger" size="sm">
                  <:icon><i class="fa-solid fa-trash"></i></:icon>
                  {gettext("Delete")}
                </.button>
              </.tooltip>
            </.button_group>
          </div>
        </.card>

        <%!-- Inline Text Tooltips --%>
        <.card title_text={gettext("Inline Text Tooltips")} class="mb-4">
          <.paragraph>
            Tooltips can explain <.tooltip text="Application Programming Interface" variant="primary" is_inline>API</.tooltip> terms,
            <.tooltip text="Cascading Style Sheets" variant="success" is_inline>CSS</.tooltip>, or
            <.tooltip text="HyperText Markup Language" variant="danger" is_inline>HTML</.tooltip> abbreviations.
          </.paragraph>
        </.card>
      </.column>

      <%!-- Right Column --%>
      <.column size="100" lg="1-2">
        <%!-- Popovers --%>
        <.card title_text={gettext("Popovers - Interactive Help")} class="mb-4">
          <.paragraph class="mb-3 text-sm">
            Rich content with links, formatting. Click <strong>?</strong> to open:
          </.paragraph>
          <.grid>
            <.column size="1-2" md="1-4" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("Basic")}
                <.popover title_text={gettext("Help")} placement="bottom">
                  <.paragraph>Basic popover with <strong>bold</strong>, <em>italic</em>, and <a href="#">links</a>.</.paragraph>
                </.popover>
              </label>
            </.column>
            <.column size="1-2" md="1-4" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("With List")}
                <.popover title_text={gettext("Options")} placement="bottom">
                  <.paragraph>Select from:</.paragraph>
                  <.basic_list>
                    <li>Option A</li>
                    <li>Option B</li>
                    <li>Option C</li>
                  </.basic_list>
                </.popover>
              </label>
            </.column>
            <.column size="1-2" md="1-4" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("Large")}
                <.popover title_text={gettext("Documentation")} placement="bottom" size="lg">
                  <.paragraph>Use <code>size="lg"</code> prop for wider content (up to 28rem).</.paragraph>
                  <.paragraph>Perfect for detailed explanations and documentation.</.paragraph>
                </.popover>
              </label>
            </.column>
            <.column size="1-2" md="1-4" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("Small")}
                <.popover title_text={gettext("Tip")} placement="bottom" size="sm">
                  <.paragraph>Brief hints use <code>size="sm"</code>.</.paragraph>
                </.popover>
              </label>
            </.column>
          </.grid>
          <hr class="my-3" />
          <.paragraph class="mb-3 text-sm">Text alignment variants:</.paragraph>
          <.grid>
            <.column size="1-3" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("Start (default)")}
                <.popover title_text={gettext("Start Aligned")} placement="bottom">
                  <.paragraph>Default alignment is start.</.paragraph>
                  <.basic_list>
                    <li>Lists look natural</li>
                    <li>Easy to read</li>
                    <li>Best for content</li>
                  </.basic_list>
                </.popover>
              </label>
            </.column>
            <.column size="1-3" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("Center")}
                <.popover title_text={gettext("Centered")} placement="bottom" alignment="center">
                  <.paragraph>Use <code>alignment="center"</code> prop.</.paragraph>
                  <.paragraph>Good for short messages.</.paragraph>
                </.popover>
              </label>
            </.column>
            <.column size="1-3" class="mb-3 text-center p-2">
              <label class="text-sm">
                {gettext("End")}
                <.popover title_text={gettext("End Aligned")} placement="bottom" alignment="end">
                  <.paragraph>Use <code>alignment="end"</code> prop.</.paragraph>
                  <.paragraph>For RTL or special layouts.</.paragraph>
                </.popover>
              </label>
            </.column>
          </.grid>
        </.card>

        <%!-- Popover Positions --%>
        <.card title_text={gettext("Popover Positions")} class="mb-4">
          <.grid>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <span class="text-sm">{gettext("Top")} </span>
              <.popover title_text={gettext("Top")}>
                <.paragraph>Appears above trigger.</.paragraph>
              </.popover>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <span class="text-sm">{gettext("End")} </span>
              <.popover title_text={gettext("End")} placement="end">
                <.paragraph>Appears at the inline-end.</.paragraph>
              </.popover>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <span class="text-sm">{gettext("Bottom")} </span>
              <.popover title_text={gettext("Bottom")} placement="bottom">
                <.paragraph>Appears below trigger.</.paragraph>
              </.popover>
            </.column>
            <.column size="1-2" md="1-4" class="text-center mb-3 p-4">
              <span class="text-sm">{gettext("Start")} </span>
              <.popover title_text={gettext("Start")} placement="start">
                <.paragraph>Appears at the inline-start.</.paragraph>
              </.popover>
            </.column>
          </.grid>
        </.card>
      </.column>
    </.grid>
    """
  end
end
