defmodule DemoWeb.Live.TablesComparisonLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Comparison Tables")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Two-column and three-column comparison patterns for version control, data changes, and A/B comparisons.</.paragraph>

    <%!-- Two-Column Comparison --%>
    <.table_card title_text={gettext("Version Detail (2-Column)")}>
      <:actions>
        <.button variant="primary" size="sm">
          <:icon><i class="fa-solid fa-table-list"></i></:icon>
          {gettext("View in form")}
        </.button>
        <.button variant="secondary" size="sm">
          <:icon><i class="fa-solid fa-table"></i></:icon>
          {gettext("View in table")}
        </.button>
        <.button variant="secondary" size="sm" is_icon_only title="Location">
          <i class="fa-solid fa-location-dot"></i>
        </.button>
      </:actions>

      <.comparison_table>
        <:head>
          <th style="width: 20%;">#</th>
          <th style="width: 40%;">{gettext("Base values")}</th>
          <th style="width: 40%;">{gettext("New values")}</th>
        </:head>

        <.comparison_row label={gettext("Country Iso 2")}>
          <:cell data_label={gettext("Base values")}><.comparison_value value="be" /></:cell>
          <:cell data_label={gettext("New values")}><.comparison_value value="be" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Region")} cells={2} />
        <.comparison_row label={gettext("Subregion")} cells={2} />
        <.comparison_row label={gettext("Town")}>
          <:cell data_label={gettext("Base values")}><.comparison_value value="Beveren" /></:cell>
          <:cell data_label={gettext("New values")} is_changed><.comparison_value value="Antwerpen" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Postal Code")}>
          <:cell><.comparison_value value="9130" /></:cell>
          <:cell is_changed><.comparison_value value="2018" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Street Full Name")} cells={2} />
        <.comparison_row label={gettext("Street Num.")} cells={2} />
        <.comparison_row label={gettext("Street Sub Num.")} cells={2} />
        <.comparison_row label={gettext("Street Add. Num.")} cells={2} />
        <.comparison_row label={gettext("Address line 1")}>
          <:cell><.comparison_value value="Ketenislaan 1" /></:cell>
          <:cell is_changed><.comparison_value value="Desguinlei 100" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Address line 2")} cells={2} />
        <.comparison_row label={gettext("Address line 3")} cells={2} />
        <.comparison_row label={gettext("Address line 4")} cells={2} />
        <.comparison_row label={gettext("Address line 5")} cells={2} />
        <.comparison_row label={gettext("Address line 6")} cells={2} />
        <.comparison_row label={gettext("Address line 7")} cells={2} />
        <.comparison_row label={gettext("Address line 8")} cells={2} />

        <.comparison_section colspan={3}>{gettext("Address metadata")}</.comparison_section>

        <.comparison_row label={gettext("Source Location Name")}>
          <:cell><.comparison_value value="2243544870:Beveren:Ketenislaan 1" /></:cell>
          <:cell is_changed><.comparison_value value="2243544870:Antwerpen:Desguinlei 100" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Is active")}>
          <:cell><i class="fa-solid fa-check" style="color: var(--base-success-color);"></i></:cell>
          <:cell><i class="fa-solid fa-check" style="color: var(--base-success-color);"></i></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Coordinates (lat,lng)")} cells={2} />
      </.comparison_table>
    </.table_card>

    <%!-- Three-Column Comparison --%>
    <.table_card title_text={gettext("Merge Comparison (3-Column)")}>
      <:actions>
        <.button variant="success" size="sm">
          <:icon><i class="fa-solid fa-code-merge"></i></:icon>
          {gettext("Accept A")}
        </.button>
        <.button variant="info" size="sm">
          <:icon><i class="fa-solid fa-code-merge"></i></:icon>
          {gettext("Accept B")}
        </.button>
        <.button variant="secondary" size="sm">
          <:icon><i class="fa-solid fa-xmark"></i></:icon>
          {gettext("Reject Both")}
        </.button>
      </:actions>

      <.comparison_table>
        <:head>
          <th style="width: 20%;">#</th>
          <th style="width: 26.67%;">{gettext("Base")}</th>
          <th style="width: 26.67%;">{gettext("Change A")}</th>
          <th style="width: 26.67%;">{gettext("Change B")}</th>
        </:head>

        <.comparison_section colspan={4}>{gettext("Contact Information")}</.comparison_section>

        <.comparison_row label={gettext("Email")}>
          <:cell><.comparison_value value="john.doe@company.com" /></:cell>
          <:cell is_changed><.comparison_value value="john.doe@newcompany.com" /></:cell>
          <:cell><.comparison_value value="john.doe@company.com" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Phone")}>
          <:cell><.comparison_value value="+32 123 456 789" /></:cell>
          <:cell><.comparison_value value="+32 123 456 789" /></:cell>
          <:cell is_changed><.comparison_value value="+32 987 654 321" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Department")}>
          <:cell><.comparison_value value="Sales" /></:cell>
          <:cell is_changed><.comparison_value value="Marketing" /></:cell>
          <:cell is_changed is_conflict><.comparison_value value="Engineering" /></:cell>
        </.comparison_row>

        <.comparison_section colspan={4}>{gettext("Employment Details")}</.comparison_section>

        <.comparison_row label={gettext("Start Date")}>
          <:cell><.comparison_value value="2020-01-15" /></:cell>
          <:cell><.comparison_value value="2020-01-15" /></:cell>
          <:cell><.comparison_value value="2020-01-15" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Status")}>
          <:cell><.badge variant="success">Active</.badge></:cell>
          <:cell><.badge variant="success">Active</.badge></:cell>
          <:cell><.badge variant="success">Active</.badge></:cell>
        </.comparison_row>
      </.comparison_table>
    </.table_card>

    <%!-- Solid Background Variant --%>
    <.table_card title_text={gettext("Version Detail (Solid Background Variant)")}>
      <:header>
        <h3>{gettext("Version Detail (Solid Background Variant)")}</h3>
        <.paragraph size="sm" color="secondary" class="mt-2">
          Using <code>pa-comparison-table__changed--solid</code> for uniform background highlighting without left border accent
        </.paragraph>
      </:header>

      <.comparison_table>
        <:head>
          <th style="width: 20%;">#</th>
          <th style="width: 40%;">{gettext("Base values")}</th>
          <th style="width: 40%;">{gettext("New values")}</th>
        </:head>

        <.comparison_row label={gettext("Country Iso 2")}>
          <:cell><.comparison_value value="be" /></:cell>
          <:cell><.comparison_value value="be" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Town")}>
          <:cell><.comparison_value value="Beveren" /></:cell>
          <:cell is_changed is_solid><.comparison_value value="Antwerpen" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Postal Code")}>
          <:cell><.comparison_value value="9130" /></:cell>
          <:cell is_changed is_solid><.comparison_value value="2018" /></:cell>
        </.comparison_row>
        <.comparison_row label={gettext("Address line 1")}>
          <:cell><.comparison_value value="Ketenislaan 1" /></:cell>
          <:cell is_changed is_solid><.comparison_value value="Desguinlei 100" /></:cell>
        </.comparison_row>
      </.comparison_table>
    </.table_card>

    <%!-- Implementation Notes --%>
    <.card title_text={gettext("Implementation Notes")}>
      <.heading level={4}>{gettext("Component Classes")}</.heading>
      <ul>
        <li><code>pa-comparison-table</code> - Apply to table element</li>
        <li><code>pa-comparison-table__label</code> - Field name column</li>
        <li><code>pa-comparison-table__value</code> - Wrapper for value + copy button</li>
        <li><code>pa-comparison-table__copy</code> - Copy button styling</li>
        <li><code>pa-comparison-table__changed</code> - Pink highlight for changed values (light bg + left border)</li>
        <li><code>pa-comparison-table__changed--solid</code> - Solid pink background (no left border accent)</li>
        <li><code>pa-comparison-table__conflict</code> - Orange highlight for merge conflicts</li>
        <li><code>pa-comparison-table__conflict--solid</code> - Solid orange background (no left border accent)</li>
        <li><code>pa-comparison-table__section</code> - Section header row</li>
      </ul>
    </.card>
    """
  end
end
