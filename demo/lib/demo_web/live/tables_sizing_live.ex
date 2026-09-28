defmodule DemoWeb.Live.TablesSizingLive do
  use DemoWeb, :live_view

  @employees [
    %{name: "Tiger Nixon", position: "System Architect", office: "Edinburgh", age: 61},
    %{name: "Garrett Winters", position: "Accountant", office: "Tokyo", age: 63},
    %{name: "Ashton Cox", position: "Junior Technical Author", office: "San Francisco", age: 66}
  ]

  @sizes [
    %{size: "xs", class: "pa-table--xs", padding: "0.6rem 0.8rem", best_for: "Dense data grids, logs"},
    %{size: "Default", class: "pa-table", padding: "0.8rem 0.8rem", best_for: "Standard tables"},
    %{size: "SM", class: "pa-table--sm", padding: "0.8rem 1rem", best_for: "Slightly wider spacing"},
    %{size: "LG", class: "pa-table--lg", padding: "0.8rem 1.4rem", best_for: "Forms in tables"},
    %{size: "XL", class: "pa-table--xl", padding: "0.8rem 1.6rem", best_for: "Presentation tables"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Table Sizing",
      employees: @employees,
      sizes: @sizes
    )}
  end

  def render(assigns) do
    ~H"""
    <p>Table size variants synchronized with button/input sizes. Each variant provides enough space for buttons and inputs of the same size.</p>

    <%!-- XS Size --%>
    <.card>
      <:header>
        <h3>{gettext("XS Size")} <.code>pa-table--xs</.code></h3>
      </:header>
      <p>Compact rows - fits button/input XS. Best for dense data grids.</p>
      <.table_container>
        <.table rows={@employees} size="xs">
          <:col :let={e} label={gettext("Name")}>{e.name}</:col>
          <:col :let={e} label={gettext("Position")}>{e.position}</:col>
          <:col :let={e} label={gettext("Office")}>{e.office}</:col>
          <:col :let={e} label={gettext("Age")}>{e.age}</:col>
          <:action :let={_e}>
            <.button variant="secondary" size="xs">{gettext("Edit")}</.button>
            <.button variant="danger" size="xs">{gettext("Delete")}</.button>
          </:action>
        </.table>
      </.table_container>
    </.card>

    <%!-- Default Size --%>
    <.card>
      <:header>
        <h3>{gettext("Default Size")} <.code>pa-table</.code></h3>
      </:header>
      <p>Standard rows - fits button/input SM and default sizes.</p>
      <.table_container>
        <.table rows={@employees}>
          <:col :let={e} label={gettext("Name")}>{e.name}</:col>
          <:col :let={e} label={gettext("Position")}>{e.position}</:col>
          <:col :let={e} label={gettext("Office")}>{e.office}</:col>
          <:col :let={e} label={gettext("Age")}>{e.age}</:col>
          <:action :let={_e}>
            <.button variant="secondary" size="sm">{gettext("Edit")}</.button>
            <.button variant="danger" size="sm">{gettext("Delete")}</.button>
          </:action>
        </.table>
      </.table_container>
    </.card>

    <%!-- SM Size --%>
    <.card>
      <:header>
        <h3>{gettext("SM Size")} <.code>pa-table--sm</.code></h3>
      </:header>
      <p>Slightly wider horizontal padding than default.</p>
      <.table_container>
        <.table rows={@employees} size="sm">
          <:col :let={e} label={gettext("Name")}>{e.name}</:col>
          <:col :let={e} label={gettext("Position")}>{e.position}</:col>
          <:col :let={e} label={gettext("Office")}>{e.office}</:col>
          <:col :let={e} label={gettext("Age")}>{e.age}</:col>
          <:action :let={_e}>
            <.button variant="secondary" size="sm">{gettext("Edit")}</.button>
            <.button variant="danger" size="sm">{gettext("Delete")}</.button>
          </:action>
        </.table>
      </.table_container>
    </.card>

    <%!-- LG Size --%>
    <.card>
      <:header>
        <h3>{gettext("LG Size")} <.code>pa-table--lg</.code></h3>
      </:header>
      <p>Spacious rows - fits button/input LG. Good for forms in tables.</p>
      <.table_container>
        <.table rows={@employees} size="lg">
          <:col :let={e} label={gettext("Name")}>{e.name}</:col>
          <:col :let={e} label={gettext("Position")}>{e.position}</:col>
          <:col :let={e} label={gettext("Office")}>{e.office}</:col>
          <:col :let={e} label={gettext("Age")}>{e.age}</:col>
          <:action :let={_e}>
            <.button variant="secondary" size="lg">{gettext("Edit")}</.button>
            <.button variant="danger" size="lg">{gettext("Delete")}</.button>
          </:action>
        </.table>
      </.table_container>
    </.card>

    <%!-- XL Size --%>
    <.card>
      <:header>
        <h3>{gettext("XL Size")} <.code>pa-table--xl</.code></h3>
      </:header>
      <p>Extra spacious rows - fits button/input XL. Best for presentation tables.</p>
      <.table_container>
        <.table rows={@employees} size="xl">
          <:col :let={e} label={gettext("Name")}>{e.name}</:col>
          <:col :let={e} label={gettext("Position")}>{e.position}</:col>
          <:col :let={e} label={gettext("Office")}>{e.office}</:col>
          <:col :let={e} label={gettext("Age")}>{e.age}</:col>
          <:action :let={_e}>
            <.button variant="secondary" size="xl">{gettext("Edit")}</.button>
            <.button variant="danger" size="xl">{gettext("Delete")}</.button>
          </:action>
        </.table>
      </.table_container>
    </.card>

    <%!-- Size Reference --%>
    <.card title_text={gettext("Size Reference")}>
      <.table rows={@sizes}>
        <:col :let={s} label={gettext("Size")}>{s.size}</:col>
        <:col :let={s} label={gettext("Class")}><.code>{s.class}</.code></:col>
        <:col :let={s} label={gettext("Padding")}>{s.padding}</:col>
        <:col :let={s} label={gettext("Best for")}>{s.best_for}</:col>
      </.table>
    </.card>
    """
  end
end
