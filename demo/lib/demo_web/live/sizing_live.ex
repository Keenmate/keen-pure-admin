defmodule DemoWeb.Live.SizingLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Sizing & Layout")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Utility classes for controlling width, height, spacing, and layout dimensions</.paragraph>

    <.card title_text={gettext("Width Utilities")}>
      <:description>Fixed and responsive width classes using rem-based scale</:description>
      <.table rows={[
        %{class: "wr-1", value: "1rem", desc: "Tiny elements"},
        %{class: "wr-2", value: "2rem", desc: "Small icons"},
        %{class: "wr-3", value: "3rem", desc: "Buttons"},
        %{class: "wr-4", value: "4rem", desc: "Small inputs"},
        %{class: "wr-5", value: "5rem", desc: "Compact fields"},
        %{class: "wr-6", value: "6rem", desc: "Labels"},
        %{class: "wr-8", value: "8rem", desc: "Short inputs"},
        %{class: "wr-10", value: "10rem", desc: "Medium inputs"},
        %{class: "wr-15", value: "15rem", desc: "Standard inputs"},
        %{class: "wr-20", value: "20rem", desc: "Panels"},
        %{class: "wr-25", value: "25rem", desc: "Cards"},
        %{class: "wr-30", value: "30rem", desc: "Wide cards"},
        %{class: "wr-35", value: "35rem", desc: "Sidebars"},
        %{class: "wr-40", value: "40rem", desc: "Content areas"},
        %{class: "wr-45", value: "45rem", desc: "Wide content"},
        %{class: "wr-50", value: "50rem", desc: "Extra wide"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>.{row.class}</code></:col>
        <:col :let={row} label={gettext("Width")}>{row.value}</:col>
        <:col :let={row} label={gettext("Use Case")}>{row.desc}</:col>
      </.table>
    </.card>

    <.card title_text={gettext("Max-Width Utilities")}>
      <:description>Constrain maximum width with truncation support</:description>
      <.table rows={[
        %{class: "maxwr-5", value: "5rem"},
        %{class: "maxwr-8", value: "8rem"},
        %{class: "maxwr-10", value: "10rem"},
        %{class: "maxwr-15", value: "15rem"},
        %{class: "maxwr-20", value: "20rem"},
        %{class: "maxwr-25", value: "25rem"},
        %{class: "maxwr-30", value: "30rem"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>.{row.class}</code></:col>
        <:col :let={row} label={gettext("Max Width")}>{row.value}</:col>
        <:col :let={row} label={gettext("Demo")}>
          <span class={"#{row.class} text-truncate d-inline-block"}>This text will be truncated when it exceeds the max width</span>
        </:col>
      </.table>
    </.card>

    <.card title_text={gettext("Spacing Utilities")}>
      <:description>Margin and padding classes based on spacing scale</:description>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Spacing Scale")}</.heading>
          <.table rows={[
            %{name: "xs", value: "0.4rem (4px)"},
            %{name: "sm", value: "0.8rem (8px)"},
            %{name: "base", value: "1.6rem (16px)"},
            %{name: "md", value: "1.6rem (16px)"},
            %{name: "lg", value: "2.4rem (24px)"},
            %{name: "xl", value: "3.2rem (32px)"},
            %{name: "2xl", value: "4.8rem (48px)"}
          ]} is_striped>
            <:col :let={row} label={gettext("Name")}><code>{row.name}</code></:col>
            <:col :let={row} label={gettext("Value")}>{row.value}</:col>
          </.table>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Class Pattern")}</.heading>
          <.basic_list spacing="compact">
            <li><code>m-&#123;size&#125;</code> - Margin all sides</li>
            <li><code>mt-&#123;size&#125;</code> - Margin top</li>
            <li><code>mb-&#123;size&#125;</code> - Margin bottom</li>
            <li><code>ml-&#123;size&#125;</code> - Margin left</li>
            <li><code>mr-&#123;size&#125;</code> - Margin right</li>
            <li><code>mx-&#123;size&#125;</code> - Margin horizontal</li>
            <li><code>my-&#123;size&#125;</code> - Margin vertical</li>
            <li><code>p-&#123;size&#125;</code> - Padding all sides</li>
            <li><code>pt-&#123;size&#125;</code>, <code>pb-&#123;size&#125;</code>, etc.</li>
            <li><code>m-0</code> - Reset margin</li>
            <li><code>p-0</code> - Reset padding</li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Gap Utilities")}>
      <:description>Control spacing between flex/grid children</:description>
      <.table rows={[
        %{class: "gap-xs", value: "0.4rem"},
        %{class: "gap-sm", value: "0.8rem"},
        %{class: "gap-base", value: "1.6rem"},
        %{class: "gap-lg", value: "2.4rem"},
        %{class: "gap-xl", value: "3.2rem"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>.{row.class}</code></:col>
        <:col :let={row} label={gettext("Gap Size")}>{row.value}</:col>
      </.table>
    </.card>

    <.card title_text={gettext("Display Utilities")}>
      <:description>Common display and flex utilities</:description>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Display")}</.heading>
          <.basic_list spacing="compact">
            <li><code>d-none</code> - Hidden</li>
            <li><code>d-block</code> - Block</li>
            <li><code>d-inline</code> - Inline</li>
            <li><code>d-inline-block</code> - Inline block</li>
            <li><code>d-flex</code> - Flex container</li>
            <li><code>d-inline-flex</code> - Inline flex</li>
            <li><code>d-grid</code> - Grid container</li>
          </.basic_list>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Flex")}</.heading>
          <.basic_list spacing="compact">
            <li><code>flex-row</code> / <code>flex-column</code></li>
            <li><code>flex-wrap</code> / <code>flex-nowrap</code></li>
            <li><code>justify-content-start</code> / <code>center</code> / <code>end</code> / <code>between</code></li>
            <li><code>align-items-start</code> / <code>center</code> / <code>end</code></li>
            <li><code>align-self-start</code> / <code>center</code> / <code>end</code></li>
            <li><code>flex-grow-1</code> / <code>flex-shrink-0</code></li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Text Utilities")}>
      <:description>Typography and text alignment helpers</:description>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Alignment")}</.heading>
          <.basic_list spacing="compact">
            <li><code>text-start</code> - Start-aligned (RTL-aware)</li>
            <li><code>text-center</code> - Centered</li>
            <li><code>text-end</code> - End-aligned (RTL-aware)</li>
          </.basic_list>
          <.heading level={4} class="mt-4">{gettext("Wrapping")}</.heading>
          <.basic_list spacing="compact">
            <li><code>text-truncate</code> - Ellipsis overflow</li>
            <li><code>text-nowrap</code> - No wrapping</li>
            <li><code>text-break</code> - Break long words</li>
          </.basic_list>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Font Size")}</.heading>
          <.basic_list spacing="compact">
            <li><code>font-xs</code> - 1rem</li>
            <li><code>font-sm</code> - 1.2rem</li>
            <li><code>font-base</code> - 1.4rem</li>
            <li><code>font-lg</code> - 1.8rem</li>
            <li><code>font-xl</code> - 2.4rem</li>
            <li><code>font-2xl</code> - 3.2rem</li>
          </.basic_list>
          <.heading level={4} class="mt-4">{gettext("Font Weight")}</.heading>
          <.basic_list spacing="compact">
            <li><code>font-light</code> - 300</li>
            <li><code>font-normal</code> - 400</li>
            <li><code>font-medium</code> - 500</li>
            <li><code>font-semibold</code> - 600</li>
            <li><code>font-bold</code> - 700</li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>
    """
  end
end
