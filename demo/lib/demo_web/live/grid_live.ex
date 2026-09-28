defmodule DemoWeb.Live.GridLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    code_examples = %{
      basic: ~s"""
      <.grid>
        <.column size="50">Left half</.column>
        <.column size="50">Right half</.column>
      </.grid>

      <!-- Thirds -->
      <.grid>
        <.column size="1-3">One third</.column>
        <.column size="2-3">Two thirds</.column>
      </.grid>\
      """,
      responsive: ~s"""
      <!-- Stack on mobile, columns on desktop -->
      <.grid>
        <.column size="100" md="50">
          Full on mobile, half on desktop
        </.column>
        <.column size="100" md="50">
          Full on mobile, half on desktop
        </.column>
      </.grid>

      <!-- Progressive breakpoints -->
      <.column size="100" sm="50" lg="25">
        100% → 50% → 25%
      </.column>\
      """,
      grid_props: ~s"""
      <!-- Alignment -->
      <.grid align="center">...</.grid>
      <.grid align="between">...</.grid>
      <.grid valign="middle">...</.grid>

      <!-- Same height columns -->
      <.grid is_same_height>...</.grid>

      <!-- No gutter -->
      <.grid is_no_gutter>...</.grid>\
      """,
      column_props: ~s"""
      <!-- Sizes (percentage or fraction) -->
      <.column size="50">Half</.column>
      <.column size="1-3">One third</.column>

      <!-- Responsive -->
      <.column size="100" md="50" lg="25">
        Mobile → Tablet → Desktop
      </.column>

      <!-- Offset -->
      <.column size="50" offset="25">
        Centered 50%
      </.column>\
      """
    }

    {:ok, assign(socket, page_title: "Grid System", code_examples: code_examples)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Responsive grid layout with percentage and fraction-based columns.</.paragraph>

    <style>
      .grid-demo-cell { background: #007bff; color: white; padding: 1rem; text-align: center; border-radius: 4px; font-size: 1.2rem; margin-bottom: 0.4rem; }
    </style>

    <%!-- Overview --%>
    <.card title_text={gettext("Overview")}>
      <.paragraph class="pa-text--secondary mb-4">
        Pure Admin uses a custom flexbox grid system with intuitive naming. Columns use <.code>pc-col-&#123;size&#125;</.code> for percentages
        and <.code>pc-col-&#123;x&#125;-&#123;y&#125;</.code> for fractions.
      </.paragraph>

      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Key Features")}</.heading>
          <ul style="line-height: 1.8;">
            <li><strong>Gutter:</strong> 0.8rem (8px) per side, 1.6rem (16px) total gap</li>
            <li><strong>Percentage columns:</strong> 5% increments (5, 10, 15... 100)</li>
            <li><strong>Fraction columns:</strong> Halves, thirds, quarters, fifths, sixths, twelfths</li>
            <li><strong>Responsive:</strong> All columns have breakpoint variants</li>
            <li><strong>Offsets:</strong> Left margin in 5% increments</li>
          </ul>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Breakpoints")}</.heading>
          <.table rows={[
            %{prefix: "sm", width: "576px", example: "pc-col-sm-50"},
            %{prefix: "md", width: "768px", example: "pc-col-md-50"},
            %{prefix: "lg", width: "992px", example: "pc-col-lg-50"},
            %{prefix: "xl", width: "1200px", example: "pc-col-xl-50"}
          ]} is_striped>
            <:col :let={row} label={gettext("Prefix")}><.code>{row.prefix}</.code></:col>
            <:col :let={row} label={gettext("Min Width")}>{row.width}</:col>
            <:col :let={row} label={gettext("Example")}><.code>{row.example}</.code></:col>
          </.table>
        </.column>
      </.grid>
    </.card>

    <%!-- Basic Usage --%>
    <.card title_text={gettext("Basic Usage")}>
      <:subtitle>Auto-equal width columns with <.code>.pc-col</.code></:subtitle>
      <.heading level={4}>{gettext("Two Equal Columns")}</.heading>
      <.grid class="mb-4">
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
      </.grid>

      <.heading level={4}>{gettext("Three Equal Columns")}</.heading>
      <.grid class="mb-4">
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
      </.grid>

      <.heading level={4}>{gettext("Four Equal Columns")}</.heading>
      <.grid class="mb-4">
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
        <.column>
          <div class="grid-demo-cell">.pc-col</div>
        </.column>
      </.grid>

      <.heading level={4}>{gettext("Auto Width Column")}</.heading>
      <.grid>
        <.column>
          <div class="grid-demo-cell">.pc-col (fills remaining)</div>
        </.column>
        <.column size="auto">
          <div class="grid-demo-cell">.pc-col-auto (content width)</div>
        </.column>
      </.grid>
    </.card>

    <%!-- Percentage Columns --%>
    <.card title_text={gettext("Percentage Columns")}>
      <:subtitle>Fixed widths in 5% increments: <.code>.pc-col-5</.code> through <.code>.pc-col-100</.code></:subtitle>
      <.grid class="mb-2">
        <.column size="25"><div class="grid-demo-cell">.pc-col-25</div></.column>
        <.column size="75"><div class="grid-demo-cell">.pc-col-75</div></.column>
      </.grid>
      <.grid class="mb-2">
        <.column size="1-3"><div class="grid-demo-cell">.pc-col-1-3</div></.column>
        <.column size="2-3"><div class="grid-demo-cell">.pc-col-2-3</div></.column>
      </.grid>
      <.grid class="mb-2">
        <.column size="50"><div class="grid-demo-cell">.pc-col-50</div></.column>
        <.column size="50"><div class="grid-demo-cell">.pc-col-50</div></.column>
      </.grid>
      <.grid class="mb-2">
        <.column size="40"><div class="grid-demo-cell">.pc-col-40</div></.column>
        <.column size="60"><div class="grid-demo-cell">.pc-col-60</div></.column>
      </.grid>
      <.grid class="mb-2">
        <.column size="20"><div class="grid-demo-cell">20</div></.column>
        <.column size="20"><div class="grid-demo-cell">20</div></.column>
        <.column size="20"><div class="grid-demo-cell">20</div></.column>
        <.column size="20"><div class="grid-demo-cell">20</div></.column>
        <.column size="20"><div class="grid-demo-cell">20</div></.column>
      </.grid>
      <.grid>
        <.column size="100"><div class="grid-demo-cell">.pc-col-100 (full width)</div></.column>
      </.grid>

      <.alert variant="info" class="mt-4">
        <strong>Available percentages:</strong> 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100
      </.alert>
    </.card>

    <%!-- Fraction Columns --%>
    <.card title_text={gettext("Fraction Columns")}>
      <:subtitle>Intuitive naming for common layouts: <.code>.pc-col-1-3</.code>, <.code>.pc-col-2-3</.code>, etc.</:subtitle>
      <.heading level={4}>{gettext("Halves (1/2)")}</.heading>
      <.grid class="mb-4">
        <.column size="1-2"><div class="grid-demo-cell">.pc-col-1-2 (50%)</div></.column>
        <.column size="1-2"><div class="grid-demo-cell">.pc-col-1-2 (50%)</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Thirds (1/3, 2/3)")}</.heading>
      <.grid class="mb-2">
        <.column size="1-3"><div class="grid-demo-cell">.pc-col-1-3 (33.3%)</div></.column>
        <.column size="2-3"><div class="grid-demo-cell">.pc-col-2-3 (66.7%)</div></.column>
      </.grid>
      <.grid class="mb-4">
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Quarters (1/4, 3/4)")}</.heading>
      <.grid class="mb-2">
        <.column size="1-4"><div class="grid-demo-cell">.pc-col-1-4 (25%)</div></.column>
        <.column size="3-4"><div class="grid-demo-cell">.pc-col-3-4 (75%)</div></.column>
      </.grid>
      <.grid class="mb-4">
        <.column size="1-4"><div class="grid-demo-cell">1/4</div></.column>
        <.column size="1-4"><div class="grid-demo-cell">1/4</div></.column>
        <.column size="1-4"><div class="grid-demo-cell">1/4</div></.column>
        <.column size="1-4"><div class="grid-demo-cell">1/4</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Fifths (1/5, 2/5, 3/5, 4/5)")}</.heading>
      <.grid class="mb-2">
        <.column size="1-5"><div class="grid-demo-cell">1/5</div></.column>
        <.column size="4-5"><div class="grid-demo-cell">4/5</div></.column>
      </.grid>
      <.grid class="mb-4">
        <.column size="2-5"><div class="grid-demo-cell">2/5</div></.column>
        <.column size="3-5"><div class="grid-demo-cell">3/5</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Sixths (1/6, 5/6)")}</.heading>
      <.grid class="mb-2">
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="5-6"><div class="grid-demo-cell">5/6</div></.column>
      </.grid>
      <.grid class="mb-4">
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
        <.column size="1-6"><div class="grid-demo-cell">1/6</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Twelfths (1/12, 5/12, 7/12, 11/12)")}</.heading>
      <.grid class="mb-2">
        <.column size="1-12"><div class="grid-demo-cell">1/12</div></.column>
        <.column size="11-12"><div class="grid-demo-cell">11/12</div></.column>
      </.grid>
      <.grid>
        <.column size="5-12"><div class="grid-demo-cell">5/12</div></.column>
        <.column size="7-12"><div class="grid-demo-cell">7/12</div></.column>
      </.grid>
    </.card>

    <%!-- Responsive Grid --%>
    <.card title_text={gettext("Responsive Grid")} subtitle_text={gettext("Stack on mobile, columns on larger screens. Resize your browser to see the effect.")}>
      <.heading level={4}>{gettext("Mobile-First Pattern")}</.heading>
      <.paragraph class="pa-text--secondary mb-2">Full width on mobile, 50% on medium screens and up:</.paragraph>
      <.grid class="mb-4">
        <.column size="100" md="50"><div class="grid-demo-cell">.pc-col-100 .pc-col-md-50</div></.column>
        <.column size="100" md="50"><div class="grid-demo-cell">.pc-col-100 .pc-col-md-50</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Progressive Columns")}</.heading>
      <.paragraph class="pa-text--secondary mb-2">Different layouts at each breakpoint:</.paragraph>
      <.grid class="mb-4">
        <.column size="100" sm="50" lg="25">
          <div class="grid-demo-cell">100% &rarr; 50% &rarr; 25%</div>
        </.column>
        <.column size="100" sm="50" lg="25">
          <div class="grid-demo-cell">100% &rarr; 50% &rarr; 25%</div>
        </.column>
        <.column size="100" sm="50" lg="25">
          <div class="grid-demo-cell">100% &rarr; 50% &rarr; 25%</div>
        </.column>
        <.column size="100" sm="50" lg="25">
          <div class="grid-demo-cell">100% &rarr; 50% &rarr; 25%</div>
        </.column>
      </.grid>

      <.heading level={4}>{gettext("Responsive Fractions")}</.heading>
      <.paragraph class="pa-text--secondary mb-2">Fractions also support breakpoints:</.paragraph>
      <.grid>
        <.column size="100" md="1-3"><div class="grid-demo-cell">.pc-col-100 .pc-col-md-1-3</div></.column>
        <.column size="100" md="2-3"><div class="grid-demo-cell">.pc-col-100 .pc-col-md-2-3</div></.column>
      </.grid>
    </.card>

    <%!-- Offsets --%>
    <.card title_text={gettext("Offsets")}>
      <:subtitle>Push columns with left margin: <.code>.pc-offset-{"{size}"}</.code></:subtitle>
      <.heading level={4}>{gettext("Centering with Offsets")}</.heading>
      <.grid class="mb-2">
        <.column size="50" offset="25"><div class="grid-demo-cell">.pc-col-50 .pc-offset-25</div></.column>
      </.grid>
      <.grid class="mb-4">
        <.column size="1-3" class="pc-offset-33"><div class="grid-demo-cell">.pc-col-1-3 .pc-offset-33</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Asymmetric Layouts")}</.heading>
      <.grid>
        <.column size="30" offset="10"><div class="grid-demo-cell">.pc-col-30 .pc-offset-10</div></.column>
        <.column size="40" offset="10"><div class="grid-demo-cell">.pc-col-40 .pc-offset-10</div></.column>
      </.grid>
    </.card>

    <%!-- Row Alignment --%>
    <.card title_text={gettext("Row Alignment")} subtitle_text={gettext("Control horizontal and vertical alignment of columns")}>
      <.heading level={4}>{gettext("Horizontal Alignment")}</.heading>

      <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--center</.code></.paragraph>
      <.grid align="center" class="mb-2" style="background: var(--pc-surface-hover);">
        <.column size="30"><div class="grid-demo-cell">Centered</div></.column>
      </.grid>

      <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--end</.code></.paragraph>
      <.grid align="end" class="mb-2" style="background: var(--pc-surface-hover);">
        <.column size="30"><div class="grid-demo-cell">Right aligned</div></.column>
      </.grid>

      <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--between</.code></.paragraph>
      <.grid align="between" class="mb-2" style="background: var(--pc-surface-hover);">
        <.column size="20"><div class="grid-demo-cell">Left</div></.column>
        <.column size="20"><div class="grid-demo-cell">Right</div></.column>
      </.grid>

      <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--around</.code></.paragraph>
      <.grid align="around" class="mb-4" style="background: var(--pc-surface-hover);">
        <.column size="20"><div class="grid-demo-cell">A</div></.column>
        <.column size="20"><div class="grid-demo-cell">B</div></.column>
        <.column size="20"><div class="grid-demo-cell">C</div></.column>
      </.grid>

      <.heading level={4}>{gettext("Vertical Alignment")}</.heading>
      <.grid>
        <.column size="100" md="1-3">
          <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--top</.code></.paragraph>
          <.grid valign="top" style="background: var(--pc-surface-hover); min-height: 100px;">
            <.column><div class="grid-demo-cell">Top</div></.column>
            <.column><div class="grid-demo-cell">Top</div></.column>
          </.grid>
        </.column>
        <.column size="100" md="1-3">
          <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--middle</.code></.paragraph>
          <.grid valign="middle" style="background: var(--pc-surface-hover); min-height: 100px;">
            <.column><div class="grid-demo-cell">Middle</div></.column>
            <.column><div class="grid-demo-cell">Middle</div></.column>
          </.grid>
        </.column>
        <.column size="100" md="1-3">
          <.paragraph class="pa-text--secondary mb-2"><.code>.pc-row--bottom</.code></.paragraph>
          <.grid valign="bottom" style="background: var(--pc-surface-hover); min-height: 100px;">
            <.column><div class="grid-demo-cell">Bottom</div></.column>
            <.column><div class="grid-demo-cell">Bottom</div></.column>
          </.grid>
        </.column>
      </.grid>
    </.card>

    <%!-- No Gutter --%>
    <.card title_text={gettext("No Gutter")}>
      <:subtitle>Remove spacing between columns with <.code>.pc-row--no-gutter</.code></:subtitle>
      <.heading level={4}>{gettext("Default (with gutter)")}</.heading>
      <.grid class="mb-4">
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
      </.grid>

      <.heading level={4}>{gettext("No Gutter")}</.heading>
      <.grid is_no_gutter>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
        <.column size="1-3"><div class="grid-demo-cell">1/3</div></.column>
      </.grid>
    </.card>

    <%!-- Visibility Utilities --%>
    <.card title_text={gettext("Visibility Utilities")} subtitle_text={gettext("Show/hide elements at different breakpoints")}>
      <.table rows={[
        %{class: ".pc-hide", desc: "Always hidden"},
        %{class: ".pc-show", desc: "Always visible"},
        %{class: ".pc-hide-{bp}", desc: "Hidden at breakpoint and up"},
        %{class: ".pc-show-{bp}", desc: "Visible at breakpoint and up"},
        %{class: ".pc-hide-below-{bp}", desc: "Hidden below breakpoint"},
        %{class: ".pc-show-below-{bp}", desc: "Visible below breakpoint"}
      ]} is_striped class="mb-4">
        <:col :let={row} label={gettext("Class")}><.code>{row.class}</.code></:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>

      <.heading level={4}>{gettext("Live Demo (resize browser)")}</.heading>
      <.grid>
        <.column>
          <div class="grid-demo-cell pc-hide-md" style="background: var(--base-danger-color);">
            <strong>Mobile Only</strong><br />.pc-hide-md
          </div>
          <div class="grid-demo-cell pc-hide-below-md" style="background: var(--base-success-color);">
            <strong>Desktop Only</strong><br />.pc-hide-below-md
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Nested Grids --%>
    <.card title_text={gettext("Nested Grids")} subtitle_text={gettext("Grids can be nested inside columns")}>
      <.grid>
        <.column size="1-3">
          <div class="grid-demo-cell">1/3</div>
        </.column>
        <.column size="2-3">
          <div style="background: var(--pc-surface-hover); padding: 0.8rem; border-radius: 4px;">
            <p class="pa-text pa-text--secondary mb-2">Nested grid inside 2/3 column:</p>
            <.grid>
              <.column size="1-2"><div class="grid-demo-cell" style="background: var(--base-text-color-2);">Nested 1/2</div></.column>
              <.column size="1-2"><div class="grid-demo-cell" style="background: var(--base-text-color-2);">Nested 1/2</div></.column>
            </.grid>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- pc-grid: CSS-Grid layout primitive --%>
    <.card title_text={gettext("pc-grid — CSS-Grid layout primitive")} subtitle_text={gettext("Two-dimensional cell co-alignment + a ruled box-matrix that prints (real borders). Companion to the flex grid/column.")}>
      <.heading level={4}>{gettext("3 columns, ruled")}</.heading>
      <.pc_grid cols={3} is_ruled class="mb-4">
        <.pc_grid_cell col_span={2}><div class="grid-demo-cell">col_span=2</div></.pc_grid_cell>
        <.pc_grid_cell><div class="grid-demo-cell">cell</div></.pc_grid_cell>
        <.pc_grid_cell><div class="grid-demo-cell">cell</div></.pc_grid_cell>
        <.pc_grid_cell><div class="grid-demo-cell">cell</div></.pc_grid_cell>
        <.pc_grid_cell><div class="grid-demo-cell">cell</div></.pc_grid_cell>
      </.pc_grid>

      <.heading level={4}>{gettext("pa-table--plain (neutral ruled grid)")}</.heading>
      <.paragraph class="pa-text--secondary mb-2">
        <.code>is_plain</.code> strips the themed header/stripe fills so the table reads as a plain ruled
        grid — for paper forms and embedded sheet grids. Pair with <.code>is_bordered</.code>.
      </.paragraph>
      <.table
        rows={[%{f: "Gross weight", v: "2.4 kg"}, %{f: "Country of origin", v: "DE"}]}
        is_plain
        is_bordered
      >
        <:col :let={row} label={gettext("Field")}>{row.f}</:col>
        <:col :let={row} label={gettext("Value")}>{row.v}</:col>
      </.table>
    </.card>

    <%!-- Quick Reference --%>
    <.card title_text={gettext("Quick Reference")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Percentage Classes")}</.heading>
          <.paragraph class="pa-text--secondary">
            <.code>.pc-col-5</.code> <.code>.pc-col-10</.code> <.code>.pc-col-15</.code> <.code>.pc-col-20</.code> <.code>.pc-col-25</.code><br />
            <.code>.pc-col-30</.code> <.code>.pc-col-35</.code> <.code>.pc-col-40</.code> <.code>.pc-col-45</.code> <.code>.pc-col-50</.code><br />
            <.code>.pc-col-55</.code> <.code>.pc-col-60</.code> <.code>.pc-col-65</.code> <.code>.pc-col-70</.code> <.code>.pc-col-75</.code><br />
            <.code>.pc-col-80</.code> <.code>.pc-col-85</.code> <.code>.pc-col-90</.code> <.code>.pc-col-95</.code> <.code>.pc-col-100</.code>
          </.paragraph>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Fraction Classes")}</.heading>
          <.paragraph class="pa-text--secondary">
            <.code>.pc-col-1-2</.code><br />
            <.code>.pc-col-1-3</.code> <.code>.pc-col-2-3</.code><br />
            <.code>.pc-col-1-4</.code> <.code>.pc-col-3-4</.code><br />
            <.code>.pc-col-1-5</.code> <.code>.pc-col-2-5</.code> <.code>.pc-col-3-5</.code> <.code>.pc-col-4-5</.code><br />
            <.code>.pc-col-1-6</.code> <.code>.pc-col-5-6</.code><br />
            <.code>.pc-col-1-12</.code> <.code>.pc-col-5-12</.code> <.code>.pc-col-7-12</.code> <.code>.pc-col-11-12</.code>
          </.paragraph>
        </.column>
      </.grid>
    </.card>

    <%!-- Code Examples --%>
    <.card title_text={gettext("Code Examples")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Basic Grid")}</.heading>
          <.code_block language="heex"><%= @code_examples.basic %></.code_block>
        </.column>
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Responsive Grid")}</.heading>
          <.code_block language="heex"><%= @code_examples.responsive %></.code_block>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Grid Props")}</.heading>
          <.code_block language="heex"><%= @code_examples.grid_props %></.code_block>
        </.column>
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Column Props")}</.heading>
          <.code_block language="heex"><%= @code_examples.column_props %></.code_block>
        </.column>
      </.grid>
    </.card>
    """
  end
end
