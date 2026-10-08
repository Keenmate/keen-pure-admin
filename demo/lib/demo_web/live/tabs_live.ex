defmodule DemoWeb.Live.TabsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Tabs", card_tab: "card-tab-1", inline_tab: "inline-tab-1", inline_only_tab: "inline-only-1")}
  end

  def handle_event("switch_tab", %{"tab" => tab, "group" => group}, socket) do
    {:noreply, assign(socket, String.to_existing_atom(group), tab)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Tab navigation components for organizing content into separate sections.</.paragraph>

    <%!-- Tabs as Card Header (Same Height) --%>
    <.heading level={3} class="mt-4 mb-4">{gettext("Tabs as Card Header (Same Height)")}</.heading>
    <.grid is_same_height class="mb-4">
      <.column size="100" md="1-2">
        <.card title_text={gettext("Normal Card")}>
          <.paragraph>This is a regular card with a header. The header has a min-height of 40px.</.paragraph>
        </.card>
      </.column>
      <.column size="100" md="1-2">
        <.tabs_container is_card>
          <.tabs id="card-compare-tabs">
            <.tab_item tabs_id="card-compare-tabs" target="card-compare-1" is_active>{gettext("Overview")}</.tab_item>
            <.tab_item tabs_id="card-compare-tabs" target="card-compare-2">{gettext("Details")}</.tab_item>
            <.tab_item tabs_id="card-compare-tabs" target="card-compare-3">{gettext("Settings")}</.tab_item>
          </.tabs>
          <.tabs_content id="card-compare-tabs-content">
            <.tab_panel id="card-compare-1" is_active>
              <.paragraph>Tabs replace the header using <code>TabsContainer card</code>. The tabs row has the same height (40px) as a card header.</.paragraph>
            </.tab_panel>
            <.tab_panel id="card-compare-2">
              <.paragraph>Details content.</.paragraph>
            </.tab_panel>
            <.tab_panel id="card-compare-3">
              <.paragraph>Settings content.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.tabs_container>
      </.column>
    </.grid>

    <%!-- Card-Based Tabs + Standalone Tabs --%>
    <.grid>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Card Tabs (Built-in)")}>
          <:tabs>
            <.card_tab is_active={@card_tab == "card-tab-1"} phx-click="switch_tab" phx-value-tab="card-tab-1" phx-value-group="card_tab">{gettext("Overview")}</.card_tab>
            <.card_tab is_active={@card_tab == "card-tab-2"} phx-click="switch_tab" phx-value-tab="card-tab-2" phx-value-group="card_tab">{gettext("Details")}</.card_tab>
            <.card_tab is_active={@card_tab == "card-tab-3"} phx-click="switch_tab" phx-value-tab="card-tab-3" phx-value-group="card_tab">{gettext("Settings")}</.card_tab>
            <.card_tab is_active={@card_tab == "card-tab-4"} phx-click="switch_tab" phx-value-tab="card-tab-4" phx-value-group="card_tab">{gettext("Reports")}</.card_tab>
          </:tabs>
          <div :if={@card_tab == "card-tab-1"}>
            <.heading level={4}>{gettext("Overview")}</.heading>
            <.paragraph>Card tabs integrate seamlessly.</.paragraph>
          </div>
          <div :if={@card_tab == "card-tab-2"}>
            <.heading level={4}>{gettext("Details")}</.heading>
            <.paragraph>Detailed information goes here.</.paragraph>
          </div>
          <div :if={@card_tab == "card-tab-3"}>
            <.heading level={4}>{gettext("Settings")}</.heading>
            <.paragraph>Configuration options here.</.paragraph>
          </div>
          <div :if={@card_tab == "card-tab-4"}>
            <.heading level={4}>{gettext("Reports")}</.heading>
            <.paragraph>Analytics data displayed here.</.paragraph>
          </div>
        </.card>
      </.column>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Standalone Tabs")}>
          <.tabs id="standalone-tabs">
            <.tab_item tabs_id="standalone-tabs" target="standalone-1" is_active>{gettext("Home")}</.tab_item>
            <.tab_item tabs_id="standalone-tabs" target="standalone-2">{gettext("Profile")}</.tab_item>
            <.tab_item tabs_id="standalone-tabs" target="standalone-3">{gettext("Messages")}</.tab_item>
            <.tab_item tabs_id="standalone-tabs" target="standalone-4">{gettext("Settings")}</.tab_item>
          </.tabs>
          <.tabs_content id="standalone-tabs-content">
            <.tab_panel id="standalone-1" is_active>
              <.heading level={4}>{gettext("Home")}</.heading>
              <.paragraph>Standalone tabs work anywhere.</.paragraph>
            </.tab_panel>
            <.tab_panel id="standalone-2">
              <.heading level={4}>{gettext("Profile")}</.heading>
              <.paragraph>User profile information here.</.paragraph>
            </.tab_panel>
            <.tab_panel id="standalone-3">
              <.heading level={4}>{gettext("Messages")}</.heading>
              <.paragraph>Messages and conversations.</.paragraph>
            </.tab_panel>
            <.tab_panel id="standalone-4">
              <.heading level={4}>{gettext("Settings")}</.heading>
              <.paragraph>Application settings here.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Tabs with Icons + Fixed Width Tabs --%>
    <.grid>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Tabs with Icons")}>
          <.tabs id="icon-tabs">
            <.tab_item tabs_id="icon-tabs" target="icon-tab-1" is_active>
              <:icon><i class="fa-solid fa-house"></i></:icon>
              <span>{gettext("Home")}</span>
            </.tab_item>
            <.tab_item tabs_id="icon-tabs" target="icon-tab-2">
              <:icon><i class="fa-solid fa-user"></i></:icon>
              <span>{gettext("Profile")}</span>
            </.tab_item>
            <.tab_item tabs_id="icon-tabs" target="icon-tab-3">
              <:icon><i class="fa-solid fa-envelope"></i></:icon>
              <span>{gettext("Messages")}</span>
            </.tab_item>
            <.tab_item tabs_id="icon-tabs" target="icon-tab-4">
              <:icon><i class="fa-solid fa-gear"></i></:icon>
              <span>{gettext("Settings")}</span>
            </.tab_item>
          </.tabs>
          <.tabs_content id="icon-tabs-content">
            <.tab_panel id="icon-tab-1" is_active><.paragraph>Home with icons.</.paragraph></.tab_panel>
            <.tab_panel id="icon-tab-2"><.paragraph>Profile with icons.</.paragraph></.tab_panel>
            <.tab_panel id="icon-tab-3"><.paragraph>Messages with icons.</.paragraph></.tab_panel>
            <.tab_panel id="icon-tab-4"><.paragraph>Settings with icons.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>

      <.column size="100" md="1-2">
        <.card title_text={gettext("Fixed Width Tabs")}>
          <.alert variant="info">
            <strong>Sizing utilities:</strong> Use <code>minwr-&#123;n&#125;</code> / <code>wr-&#123;n&#125;</code> / <code>maxwr-&#123;n&#125;</code> (rem width) on a tab item — <code>n</code> = 1&ndash;10, 15, 20&hellip;50. <code>minwr-*</code> sets a floor (short labels align, long ones still grow); <code>wr-*</code> pins an exact width.
          </.alert>

          <.heading level={4}>{gettext("Min-width 6rem (minwr-6)")}</.heading>
          <.tabs id="fixed-6x-tabs">
            <.tab_item tabs_id="fixed-6x-tabs" target="fixed-6x-1" is_active class="minwr-6">{gettext("View")}</.tab_item>
            <.tab_item tabs_id="fixed-6x-tabs" target="fixed-6x-2" class="minwr-6">{gettext("Edit")}</.tab_item>
            <.tab_item tabs_id="fixed-6x-tabs" target="fixed-6x-3" class="minwr-6">{gettext("Delete")}</.tab_item>
          </.tabs>
          <.tabs_content id="fixed-6x-tabs-content">
            <.tab_panel id="fixed-6x-1" is_active><.paragraph>Fixed width tabs maintain consistent sizing.</.paragraph></.tab_panel>
            <.tab_panel id="fixed-6x-2"><.paragraph>Edit content here.</.paragraph></.tab_panel>
            <.tab_panel id="fixed-6x-3"><.paragraph>Delete operations here.</.paragraph></.tab_panel>
          </.tabs_content>

          <.heading level={4} class="mt-6">{gettext("Min-width 8rem with icons (minwr-8)")}</.heading>
          <.tabs id="fixed-8x-tabs">
            <.tab_item tabs_id="fixed-8x-tabs" target="fixed-8x-1" is_active class="minwr-8">
              <:icon><i class="fa-solid fa-chart-line"></i></:icon>
              <span>{gettext("Dashboard")}</span>
            </.tab_item>
            <.tab_item tabs_id="fixed-8x-tabs" target="fixed-8x-2" class="minwr-8">
              <:icon><i class="fa-solid fa-chart-bar"></i></:icon>
              <span>{gettext("Analytics")}</span>
            </.tab_item>
          </.tabs>
          <.tabs_content id="fixed-8x-tabs-content">
            <.tab_panel id="fixed-8x-1" is_active><.paragraph>Dashboard data.</.paragraph></.tab_panel>
            <.tab_panel id="fixed-8x-2"><.paragraph>Analytics data.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Wrap Labels: multi-line titles with unified height --%>
    <.grid>
      <.column size="100">
        <.card title_text={gettext("Wrap Labels (multi-line titles)")}>
          <.alert variant="info">
            <strong>The problem:</strong> an irregular label set like
            <em>Orders / Invoices / Delivery sheets / Complaints and missed items</em>
            looks bad both ways &mdash; <code>--full</code> stretches the short tabs into dead space,
            and plain auto width leaves the long one huge and the edge ragged.
            <code>pa-tabs--wrap-labels</code> lets the long title wrap; cap it with
            <code>maxwr-*</code> to choose the wrap point. The row then keeps every tab as tall
            as the wrapped one &mdash; no zig-zag &mdash; via the flex row's default
            <code>align-items: stretch</code>.
          </.alert>

          <.heading level={4}>Default (auto width, no wrap) &mdash; ragged, long tab dominates</.heading>
          <.tabs id="wl-auto-tabs">
            <.tab_item tabs_id="wl-auto-tabs" target="wl-auto-1" is_active>{gettext("Orders")}</.tab_item>
            <.tab_item tabs_id="wl-auto-tabs" target="wl-auto-2">{gettext("Invoices")}</.tab_item>
            <.tab_item tabs_id="wl-auto-tabs" target="wl-auto-3">{gettext("Delivery sheets")}</.tab_item>
            <.tab_item tabs_id="wl-auto-tabs" target="wl-auto-4">{gettext("Complaints and missed items")}</.tab_item>
          </.tabs>
          <.tabs_content id="wl-auto-tabs-content">
            <.tab_panel id="wl-auto-1" is_active><.paragraph>Orders content.</.paragraph></.tab_panel>
            <.tab_panel id="wl-auto-2"><.paragraph>Invoices content.</.paragraph></.tab_panel>
            <.tab_panel id="wl-auto-3"><.paragraph>Delivery sheets content.</.paragraph></.tab_panel>
            <.tab_panel id="wl-auto-4"><.paragraph>Complaints content.</.paragraph></.tab_panel>
          </.tabs_content>

          <.heading level={4} class="mt-6">With <code>&lt;.tabs is_wrap_labels&gt;</code> + <code>maxwr-15</code> on the long tab &mdash; tidy, level</.heading>
          <.tabs id="wl-wrap-tabs" is_wrap_labels>
            <.tab_item tabs_id="wl-wrap-tabs" target="wl-wrap-1" is_active>{gettext("Orders")}</.tab_item>
            <.tab_item tabs_id="wl-wrap-tabs" target="wl-wrap-2">{gettext("Invoices")}</.tab_item>
            <.tab_item tabs_id="wl-wrap-tabs" target="wl-wrap-3">{gettext("Delivery sheets")}</.tab_item>
            <.tab_item tabs_id="wl-wrap-tabs" target="wl-wrap-4" class="maxwr-15">{gettext("Complaints and missed items")}</.tab_item>
          </.tabs>
          <.tabs_content id="wl-wrap-tabs-content">
            <.tab_panel id="wl-wrap-1" is_active><.paragraph>Orders content &mdash; the long tab wraps to two lines; the short tabs stretch to match its height.</.paragraph></.tab_panel>
            <.tab_panel id="wl-wrap-2"><.paragraph>Invoices content.</.paragraph></.tab_panel>
            <.tab_panel id="wl-wrap-3"><.paragraph>Delivery sheets content.</.paragraph></.tab_panel>
            <.tab_panel id="wl-wrap-4"><.paragraph>Complaints content.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Pills Style + Pills with Icons --%>
    <.grid>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Pills Style Tabs")}>
          <.tabs id="pills-tabs" style="pills">
            <.tab_item tabs_id="pills-tabs" target="pills-1" is_active>{gettext("Dashboard")}</.tab_item>
            <.tab_item tabs_id="pills-tabs" target="pills-2">{gettext("Analytics")}</.tab_item>
            <.tab_item tabs_id="pills-tabs" target="pills-3">{gettext("Reports")}</.tab_item>
          </.tabs>
          <.tabs_content id="pills-tabs-content">
            <.tab_panel id="pills-1" is_active>
              <.heading level={4}>{gettext("Dashboard")}</.heading>
              <.paragraph>Key metrics overview.</.paragraph>
            </.tab_panel>
            <.tab_panel id="pills-2">
              <.heading level={4}>{gettext("Analytics")}</.heading>
              <.paragraph>Detailed insights.</.paragraph>
            </.tab_panel>
            <.tab_panel id="pills-3">
              <.heading level={4}>{gettext("Reports")}</.heading>
              <.paragraph>Generated summaries.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.card>
      </.column>

      <.column size="100" md="1-2">
        <.card title_text={gettext("Pills with Icons")}>
          <.tabs id="icon-pills-tabs" style="pills">
            <.tab_item tabs_id="icon-pills-tabs" target="icon-pills-1" is_active>
              <:icon><i class="fa-solid fa-chart-line"></i></:icon>
              <span>{gettext("Dashboard")}</span>
            </.tab_item>
            <.tab_item tabs_id="icon-pills-tabs" target="icon-pills-2">
              <:icon><i class="fa-solid fa-chart-bar"></i></:icon>
              <span>{gettext("Analytics")}</span>
            </.tab_item>
            <.tab_item tabs_id="icon-pills-tabs" target="icon-pills-3">
              <:icon><i class="fa-solid fa-file-lines"></i></:icon>
              <span>{gettext("Reports")}</span>
            </.tab_item>
          </.tabs>
          <.tabs_content id="icon-pills-tabs-content">
            <.tab_panel id="icon-pills-1" is_active><.paragraph>Dashboard pills.</.paragraph></.tab_panel>
            <.tab_panel id="icon-pills-2"><.paragraph>Analytics pills.</.paragraph></.tab_panel>
            <.tab_panel id="icon-pills-3"><.paragraph>Reports pills.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Vertical Tabs + Boxed Tabs --%>
    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text={gettext("Vertical Tabs")}>
          <.tabs_vertical_layout>
            <.tabs id="vertical-tabs" style="vertical">
              <.tab_item tabs_id="vertical-tabs" target="vert-1" is_active>
                <:icon><i class="fa-solid fa-user"></i></:icon>
                <span>{gettext("Account")}</span>
              </.tab_item>
              <.tab_item tabs_id="vertical-tabs" target="vert-2">
                <:icon><i class="fa-solid fa-lock"></i></:icon>
                <span>{gettext("Security")}</span>
              </.tab_item>
              <.tab_item tabs_id="vertical-tabs" target="vert-3">
                <:icon><i class="fa-solid fa-bell"></i></:icon>
                <span>{gettext("Notifications")}</span>
              </.tab_item>
              <.tab_item tabs_id="vertical-tabs" target="vert-4">
                <:icon><i class="fa-solid fa-palette"></i></:icon>
                <span>{gettext("Appearance")}</span>
              </.tab_item>
            </.tabs>
            <.tabs_content id="vertical-tabs-content" class="flex-grow-1">
              <.tab_panel id="vert-1" is_active>
                <.heading level={4}>{gettext("Account Settings")}</.heading>
                <.paragraph>Manage your account information and preferences.</.paragraph>
              </.tab_panel>
              <.tab_panel id="vert-2">
                <.heading level={4}>{gettext("Security Settings")}</.heading>
                <.paragraph>Configure password and two-factor authentication.</.paragraph>
              </.tab_panel>
              <.tab_panel id="vert-3">
                <.heading level={4}>{gettext("Notification Preferences")}</.heading>
                <.paragraph>Control how and when you receive notifications.</.paragraph>
              </.tab_panel>
              <.tab_panel id="vert-4">
                <.heading level={4}>{gettext("Appearance Options")}</.heading>
                <.paragraph>Customize the look and feel of your interface.</.paragraph>
              </.tab_panel>
            </.tabs_content>
          </.tabs_vertical_layout>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text={gettext("Boxed Tabs")}>
          <.tabs id="boxed-tabs" style="boxed">
            <.tab_item tabs_id="boxed-tabs" target="boxed-1" is_active>{gettext("Code")}</.tab_item>
            <.tab_item tabs_id="boxed-tabs" target="boxed-2">{gettext("Issues")}</.tab_item>
            <.tab_item tabs_id="boxed-tabs" target="boxed-3">{gettext("Pull Requests")}</.tab_item>
          </.tabs>
          <.tabs_content id="boxed-tabs-content">
            <.tab_panel id="boxed-1" is_active><.paragraph>Code repository and file browser.</.paragraph></.tab_panel>
            <.tab_panel id="boxed-2"><.paragraph>Issue tracker and bug reports.</.paragraph></.tab_panel>
            <.tab_panel id="boxed-3"><.paragraph>Pull request reviews and merges.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Tab Sizes --%>
    <.card title_text={gettext("Tab Sizes")}>
      <.heading level={4}>{gettext("Small Tabs")}</.heading>
      <.tabs id="size-sm-tabs" size="sm">
        <.tab_item tabs_id="size-sm-tabs" target="size-sm-1" is_active>{gettext("Tab 1")}</.tab_item>
        <.tab_item tabs_id="size-sm-tabs" target="size-sm-2">{gettext("Tab 2")}</.tab_item>
        <.tab_item tabs_id="size-sm-tabs" target="size-sm-3">{gettext("Tab 3")}</.tab_item>
      </.tabs>
      <.tabs_content id="size-sm-tabs-content">
        <.tab_panel id="size-sm-1" is_active><.paragraph>Small tabs content - compact and space-efficient.</.paragraph></.tab_panel>
        <.tab_panel id="size-sm-2"><.paragraph>Small tabs - Tab 2</.paragraph></.tab_panel>
        <.tab_panel id="size-sm-3"><.paragraph>Small tabs - Tab 3</.paragraph></.tab_panel>
      </.tabs_content>

      <.heading level={4} class="mt-6">{gettext("Default Tabs")}</.heading>
      <.tabs id="size-def-tabs">
        <.tab_item tabs_id="size-def-tabs" target="size-def-1" is_active>{gettext("Tab 1")}</.tab_item>
        <.tab_item tabs_id="size-def-tabs" target="size-def-2">{gettext("Tab 2")}</.tab_item>
        <.tab_item tabs_id="size-def-tabs" target="size-def-3">{gettext("Tab 3")}</.tab_item>
      </.tabs>
      <.tabs_content id="size-def-tabs-content">
        <.tab_panel id="size-def-1" is_active><.paragraph>Default size tabs content - standard spacing.</.paragraph></.tab_panel>
        <.tab_panel id="size-def-2"><.paragraph>Default tabs - Tab 2</.paragraph></.tab_panel>
        <.tab_panel id="size-def-3"><.paragraph>Default tabs - Tab 3</.paragraph></.tab_panel>
      </.tabs_content>

      <.heading level={4} class="mt-6">{gettext("Large Tabs")}</.heading>
      <.tabs id="size-lg-tabs" size="lg">
        <.tab_item tabs_id="size-lg-tabs" target="size-lg-1" is_active>{gettext("Tab 1")}</.tab_item>
        <.tab_item tabs_id="size-lg-tabs" target="size-lg-2">{gettext("Tab 2")}</.tab_item>
        <.tab_item tabs_id="size-lg-tabs" target="size-lg-3">{gettext("Tab 3")}</.tab_item>
      </.tabs>
      <.tabs_content id="size-lg-tabs-content">
        <.tab_panel id="size-lg-1" is_active><.paragraph>Large tabs content - more generous spacing.</.paragraph></.tab_panel>
        <.tab_panel id="size-lg-2"><.paragraph>Large tabs - Tab 2</.paragraph></.tab_panel>
        <.tab_panel id="size-lg-3"><.paragraph>Large tabs - Tab 3</.paragraph></.tab_panel>
      </.tabs_content>
    </.card>

    <%!-- Tabs with Badges --%>
    <.card title_text={gettext("Tabs with Badges")}>
      <.tabs id="badge-tabs">
        <.tab_item tabs_id="badge-tabs" target="badge-1" is_active>
          <span>{gettext("All")}</span>
          <.badge size="sm">48</.badge>
        </.tab_item>
        <.tab_item tabs_id="badge-tabs" target="badge-2">
          <span>{gettext("Active")}</span>
          <.badge variant="success" size="sm">12</.badge>
        </.tab_item>
        <.tab_item tabs_id="badge-tabs" target="badge-3">
          <span>{gettext("Pending")}</span>
          <.badge variant="warning" size="sm">5</.badge>
        </.tab_item>
        <.tab_item tabs_id="badge-tabs" target="badge-4">
          <span>{gettext("Closed")}</span>
          <.badge variant="secondary" size="sm">31</.badge>
        </.tab_item>
      </.tabs>
      <.tabs_content id="badge-tabs-content">
        <.tab_panel id="badge-1" is_active><.paragraph>All items (48 total).</.paragraph></.tab_panel>
        <.tab_panel id="badge-2"><.paragraph>Active items (12 items).</.paragraph></.tab_panel>
        <.tab_panel id="badge-3"><.paragraph>Pending items (5 items).</.paragraph></.tab_panel>
        <.tab_panel id="badge-4"><.paragraph>Closed items (31 items).</.paragraph></.tab_panel>
      </.tabs_content>
    </.card>

    <%!-- Centered Tabs --%>
    <.card title_text={gettext("Centered Tabs")}>
      <.tabs id="centered-tabs" align="centered">
        <.tab_item tabs_id="centered-tabs" target="center-1" is_active>{gettext("Features")}</.tab_item>
        <.tab_item tabs_id="centered-tabs" target="center-2">{gettext("Pricing")}</.tab_item>
        <.tab_item tabs_id="centered-tabs" target="center-3">{gettext("Testimonials")}</.tab_item>
      </.tabs>
      <.tabs_content id="centered-tabs-content">
        <.tab_panel id="center-1" is_active><.paragraph class="text-center">Feature highlights and capabilities.</.paragraph></.tab_panel>
        <.tab_panel id="center-2"><.paragraph class="text-center">Pricing plans and options.</.paragraph></.tab_panel>
        <.tab_panel id="center-3"><.paragraph class="text-center">Customer testimonials and reviews.</.paragraph></.tab_panel>
      </.tabs_content>
    </.card>

    <%!-- Full Width Tabs --%>
    <.card title_text={gettext("Full Width Tabs")}>
      <.tabs id="full-tabs" align="full">
        <.tab_item tabs_id="full-tabs" target="full-1" is_active>
          <:icon><i class="fa-solid fa-mobile-screen"></i></:icon>
          <span>{gettext("Mobile")}</span>
        </.tab_item>
        <.tab_item tabs_id="full-tabs" target="full-2">
          <:icon><i class="fa-solid fa-tablet-screen-button"></i></:icon>
          <span>{gettext("Tablet")}</span>
        </.tab_item>
        <.tab_item tabs_id="full-tabs" target="full-3">
          <:icon><i class="fa-solid fa-desktop"></i></:icon>
          <span>{gettext("Desktop")}</span>
        </.tab_item>
      </.tabs>
      <.tabs_content id="full-tabs-content">
        <.tab_panel id="full-1" is_active><.paragraph>Mobile view and responsive design.</.paragraph></.tab_panel>
        <.tab_panel id="full-2"><.paragraph>Tablet view and layout.</.paragraph></.tab_panel>
        <.tab_panel id="full-3"><.paragraph>Desktop view and features.</.paragraph></.tab_panel>
      </.tabs_content>
    </.card>

    <%!-- Border Top Tabs --%>
    <.grid>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Border Top Tabs")}>
          <.tabs id="border-top-tabs" style="border-top">
            <.tab_item tabs_id="border-top-tabs" target="bt-1" is_active>{gettext("Profile")}</.tab_item>
            <.tab_item tabs_id="border-top-tabs" target="bt-2">{gettext("Favorites")}</.tab_item>
            <.tab_item tabs_id="border-top-tabs" target="bt-3">{gettext("Settings")}</.tab_item>
          </.tabs>
          <.tabs_content id="border-top-tabs-content">
            <.tab_panel id="bt-1" is_active>
              <.paragraph>Active indicator on top instead of bottom. Useful for profile panels and similar UI patterns.</.paragraph>
            </.tab_panel>
            <.tab_panel id="bt-2">
              <.paragraph>Favorites content.</.paragraph>
            </.tab_panel>
            <.tab_panel id="bt-3">
              <.paragraph>Settings content.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Border Top + Full Width")}>
          <.tabs id="border-top-full-tabs" style="border-top" align="full">
            <.tab_item tabs_id="border-top-full-tabs" target="btf-1" is_active>
              <:icon><i class="fa-solid fa-user"></i></:icon>
              <span>{gettext("Profile")}</span>
            </.tab_item>
            <.tab_item tabs_id="border-top-full-tabs" target="btf-2">
              <:icon><i class="fa-solid fa-star"></i></:icon>
              <span>{gettext("Favorites")}</span>
            </.tab_item>
            <.tab_item tabs_id="border-top-full-tabs" target="btf-3">
              <:icon><i class="fa-solid fa-gear"></i></:icon>
              <span>{gettext("Settings")}</span>
            </.tab_item>
          </.tabs>
          <.tabs_content id="border-top-full-tabs-content">
            <.tab_panel id="btf-1" is_active>
              <.paragraph>Full width border-top tabs with icons. Clean profile panel style.</.paragraph>
            </.tab_panel>
            <.tab_panel id="btf-2">
              <.paragraph>Favorites content.</.paragraph>
            </.tab_panel>
            <.tab_panel id="btf-3">
              <.paragraph>Settings content.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    <%!-- Icon-Only Tabs --%>
    <.grid>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Icon-Only Tabs - Horizontal")}>
          <.tabs id="icon-only-tabs">
            <.tab_item tabs_id="icon-only-tabs" target="icon-only-1" is_active class="pa-tooltip" data-tooltip="Dashboard">
              <i class="fa-solid fa-chart-line"></i>
            </.tab_item>
            <.tab_item tabs_id="icon-only-tabs" target="icon-only-2" class="pa-tooltip" data-tooltip="Analytics">
              <i class="fa-solid fa-chart-bar"></i>
            </.tab_item>
            <.tab_item tabs_id="icon-only-tabs" target="icon-only-3" class="pa-tooltip" data-tooltip="Users">
              <i class="fa-solid fa-users"></i>
            </.tab_item>
            <.tab_item tabs_id="icon-only-tabs" target="icon-only-4" class="pa-tooltip" data-tooltip="Settings">
              <i class="fa-solid fa-gear"></i>
            </.tab_item>
          </.tabs>
          <.tabs_content id="icon-only-tabs-content">
            <.tab_panel id="icon-only-1" is_active>
              <.heading level={4}>{gettext("Dashboard")}</.heading>
              <.paragraph>Icon-only tabs save space.</.paragraph>
            </.tab_panel>
            <.tab_panel id="icon-only-2">
              <.heading level={4}>{gettext("Analytics")}</.heading>
              <.paragraph>Analytics data here.</.paragraph>
            </.tab_panel>
            <.tab_panel id="icon-only-3">
              <.heading level={4}>{gettext("Users")}</.heading>
              <.paragraph>User management here.</.paragraph>
            </.tab_panel>
            <.tab_panel id="icon-only-4">
              <.heading level={4}>{gettext("Settings")}</.heading>
              <.paragraph>Settings here.</.paragraph>
            </.tab_panel>
          </.tabs_content>
        </.card>
      </.column>

      <.column size="100" md="1-2">
        <.card title_text={gettext("Icon-Only Tabs - Vertical")}>
          <.tabs_vertical_layout>
            <.tabs id="icon-vert-tabs" style="vertical" align="centered">
              <.tab_item tabs_id="icon-vert-tabs" target="icon-vert-1" is_active class="minwr-3 minhr-3 pa-tooltip" data-tooltip="Home">
                <i class="fa-solid fa-house"></i>
              </.tab_item>
              <.tab_item tabs_id="icon-vert-tabs" target="icon-vert-2" class="minwr-3 minhr-3 pa-tooltip" data-tooltip="Profile">
                <i class="fa-solid fa-user"></i>
              </.tab_item>
              <.tab_item tabs_id="icon-vert-tabs" target="icon-vert-3" class="minwr-3 minhr-3 pa-tooltip" data-tooltip="Messages">
                <i class="fa-solid fa-envelope"></i>
              </.tab_item>
              <.tab_item tabs_id="icon-vert-tabs" target="icon-vert-4" class="minwr-3 minhr-3 pa-tooltip" data-tooltip="Settings">
                <i class="fa-solid fa-gear"></i>
              </.tab_item>
            </.tabs>
            <.tabs_content id="icon-vert-tabs-content" class="flex-grow-1">
              <.tab_panel id="icon-vert-1" is_active>
                <.heading level={4}>{gettext("Home")}</.heading>
                <.paragraph>Vertical icon-only tabs with centered icons.</.paragraph>
              </.tab_panel>
              <.tab_panel id="icon-vert-2">
                <.heading level={4}>{gettext("Profile")}</.heading>
                <.paragraph>Profile settings.</.paragraph>
              </.tab_panel>
              <.tab_panel id="icon-vert-3">
                <.heading level={4}>{gettext("Messages")}</.heading>
                <.paragraph>Message inbox.</.paragraph>
              </.tab_panel>
              <.tab_panel id="icon-vert-4">
                <.heading level={4}>{gettext("Settings")}</.heading>
                <.paragraph>Application settings.</.paragraph>
              </.tab_panel>
            </.tabs_content>
          </.tabs_vertical_layout>
        </.card>
      </.column>
    </.grid>

    <%!-- Standalone Tabs (Outside Cards) --%>
    <.heading level={3} class="mt-8 mb-4">{gettext("Standalone Tabs - No Card Required")}</.heading>

    <.tabs id="standalone-page-tabs">
      <.tab_item tabs_id="standalone-page-tabs" target="standalone-page-1" is_active>{gettext("Overview")}</.tab_item>
      <.tab_item tabs_id="standalone-page-tabs" target="standalone-page-2">{gettext("Details")}</.tab_item>
      <.tab_item tabs_id="standalone-page-tabs" target="standalone-page-3">{gettext("Reports")}</.tab_item>
    </.tabs>
    <.tabs_content id="standalone-page-tabs-content">
      <.tab_panel id="standalone-page-1" is_active>
        <.card>
          <.heading level={4}>{gettext("Overview Section")}</.heading>
          <.paragraph>Tabs can exist outside of cards for page-level navigation. Each tab can contain cards or any other content.</.paragraph>
        </.card>
      </.tab_panel>
      <.tab_panel id="standalone-page-2">
        <.card>
          <.heading level={4}>{gettext("Details Section")}</.heading>
          <.paragraph>This pattern is useful for organizing page content into sections.</.paragraph>
        </.card>
      </.tab_panel>
      <.tab_panel id="standalone-page-3">
        <.card>
          <.heading level={4}>{gettext("Reports Section")}</.heading>
          <.paragraph>The tab content can include multiple cards or complex layouts.</.paragraph>
        </.card>
      </.tab_panel>
    </.tabs_content>

    <.heading level={3} class="mt-8 mb-4">{gettext("Standalone Vertical Tabs")}</.heading>

    <.tabs_vertical_layout>
      <.tabs id="standalone-vert-tabs" style="vertical">
        <.tab_item tabs_id="standalone-vert-tabs" target="standalone-vert-1" is_active class="minhr-3">
          <:icon><i class="fa-solid fa-house"></i></:icon>
          <span>{gettext("Dashboard")}</span>
        </.tab_item>
        <.tab_item tabs_id="standalone-vert-tabs" target="standalone-vert-2" class="minhr-3">
          <:icon><i class="fa-solid fa-chart-bar"></i></:icon>
          <span>{gettext("Analytics")}</span>
        </.tab_item>
        <.tab_item tabs_id="standalone-vert-tabs" target="standalone-vert-3" class="minhr-3">
          <:icon><i class="fa-solid fa-users"></i></:icon>
          <span>{gettext("Users")}</span>
        </.tab_item>
      </.tabs>
      <.tabs_content id="standalone-vert-tabs-content" class="flex-grow-1">
        <.tab_panel id="standalone-vert-1" is_active>
          <.card title_text={gettext("Dashboard")}>
            <.paragraph>Vertical tabs work great for sidebar-style navigation outside of cards.</.paragraph>
          </.card>
        </.tab_panel>
        <.tab_panel id="standalone-vert-2">
          <.card title_text={gettext("Analytics")}>
            <.paragraph>Analytics content goes here.</.paragraph>
          </.card>
        </.tab_panel>
        <.tab_panel id="standalone-vert-3">
          <.card title_text={gettext("Users")}>
            <.paragraph>User management content here.</.paragraph>
          </.card>
        </.tab_panel>
      </.tabs_content>
    </.tabs_vertical_layout>

    <%!-- Inline Tabs in Header --%>
    <.heading level={3} class="mt-8 mb-4">{gettext("Inline Tabs in Header (Same Height Alignment)")}</.heading>

    <.grid is_same_height>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Card with Title + Inline Tabs")} has_inline_tabs>
          <:tabs>
            <.card_tab is_active={@inline_tab == "inline-tab-1"} phx-click="switch_tab" phx-value-tab="inline-tab-1" phx-value-group="inline_tab">Active</.card_tab>
            <.card_tab is_active={@inline_tab == "inline-tab-2"} phx-click="switch_tab" phx-value-tab="inline-tab-2" phx-value-group="inline_tab">Pending</.card_tab>
            <.card_tab is_active={@inline_tab == "inline-tab-3"} phx-click="switch_tab" phx-value-tab="inline-tab-3" phx-value-group="inline_tab">Closed</.card_tab>
          </:tabs>
          <.paragraph :if={@inline_tab == "inline-tab-1"}>Inline tabs sit in the header row, so this card has the same header height as the card next to it.</.paragraph>
          <.paragraph :if={@inline_tab == "inline-tab-2"}>Pending items content.</.paragraph>
          <.paragraph :if={@inline_tab == "inline-tab-3"}>Closed items content.</.paragraph>
        </.card>
      </.column>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Regular Card (Header Only)")}>
          <.paragraph>This card has no tabs - just a header. Notice how both card headers align perfectly when side by side.</.paragraph>
          <.paragraph>Use <code>has_inline_tabs</code> prop when you need cards with tabs to match the height of cards without tabs.</.paragraph>
        </.card>
      </.column>
    </.grid>

    <.grid is_same_height class="mt-4">
      <.column size="100" md="1-2">
        <.card has_inline_tabs>
          <:tabs>
            <.card_tab is_active={@inline_only_tab == "inline-only-1"} phx-click="switch_tab" phx-value-tab="inline-only-1" phx-value-group="inline_only_tab">Overview</.card_tab>
            <.card_tab is_active={@inline_only_tab == "inline-only-2"} phx-click="switch_tab" phx-value-tab="inline-only-2" phx-value-group="inline_only_tab">Details</.card_tab>
            <.card_tab is_active={@inline_only_tab == "inline-only-3"} phx-click="switch_tab" phx-value-tab="inline-only-3" phx-value-group="inline_only_tab">Settings</.card_tab>
          </:tabs>
          <.paragraph :if={@inline_only_tab == "inline-only-1"}>Tabs can also be used alone in the header without a title.</.paragraph>
          <.paragraph :if={@inline_only_tab == "inline-only-2"}>Details content.</.paragraph>
          <.paragraph :if={@inline_only_tab == "inline-only-3"}>Settings content.</.paragraph>
        </.card>
      </.column>
      <.column size="100" md="1-2">
        <.card title_text={gettext("Summary Stats")}>
          <:tools>
            <.button variant="secondary" size="sm" is_icon_only>
              <i class="fa-solid fa-refresh"></i>
            </.button>
          </:tools>
          <.paragraph>Cards with different header content still align because inline tabs use the same header height.</.paragraph>
        </.card>
      </.column>
    </.grid>

    <.heading level={3} class="mt-8 mb-4">{gettext("Bordered Tabs - Card-Like Wrapper")}</.heading>

    <.tabs_container is_bordered>
      <.tabs id="bordered-tabs">
        <.tab_item tabs_id="bordered-tabs" target="bordered-1" is_active>{gettext("Dashboard")}</.tab_item>
        <.tab_item tabs_id="bordered-tabs" target="bordered-2">{gettext("Settings")}</.tab_item>
        <.tab_item tabs_id="bordered-tabs" target="bordered-3">{gettext("Profile")}</.tab_item>
      </.tabs>
      <.tabs_content id="bordered-tabs-content">
        <.tab_panel id="bordered-1" is_active>
          <.heading level={4}>{gettext("Dashboard")}</.heading>
          <.paragraph>Bordered tabs wrap the entire tab system in a card-like border. The content has no separate border - it's all unified.</.paragraph>
        </.tab_panel>
        <.tab_panel id="bordered-2">
          <.heading level={4}>{gettext("Settings")}</.heading>
          <.paragraph>This pattern works well for standalone tabs that need visual separation from the page background.</.paragraph>
        </.tab_panel>
        <.tab_panel id="bordered-3">
          <.heading level={4}>{gettext("Profile")}</.heading>
          <.paragraph>Use <code>pa-tabs__container--bordered</code> wrapper for horizontal tabs.</.paragraph>
        </.tab_panel>
      </.tabs_content>
    </.tabs_container>

    <.heading level={3} class="mt-8 mb-4">{gettext("Bordered Vertical Tabs")}</.heading>

    <.tabs_vertical_layout is_bordered>
      <.tabs id="bordered-vert-tabs" style="vertical">
        <.tab_item tabs_id="bordered-vert-tabs" target="bordered-vert-1" is_active class="minhr-3">
          <:icon><i class="fa-solid fa-gauge"></i></:icon>
          <span>{gettext("Overview")}</span>
        </.tab_item>
        <.tab_item tabs_id="bordered-vert-tabs" target="bordered-vert-2" class="minhr-3">
          <:icon><i class="fa-solid fa-chart-pie"></i></:icon>
          <span>{gettext("Reports")}</span>
        </.tab_item>
        <.tab_item tabs_id="bordered-vert-tabs" target="bordered-vert-3" class="minhr-3">
          <:icon><i class="fa-solid fa-gear"></i></:icon>
          <span>{gettext("Settings")}</span>
        </.tab_item>
      </.tabs>
      <.tabs_content id="bordered-vert-tabs-content" class="flex-grow-1">
        <.tab_panel id="bordered-vert-1" is_active>
          <.heading level={4}>{gettext("Overview")}</.heading>
          <.paragraph>Bordered vertical tabs create a unified card-like appearance.</.paragraph>
          <.paragraph>The border wraps both the tab navigation and content area with a divider between them.</.paragraph>
        </.tab_panel>
        <.tab_panel id="bordered-vert-2">
          <.heading level={4}>{gettext("Reports")}</.heading>
          <.paragraph>Perfect for sidebar-style navigation that needs to stand out.</.paragraph>
        </.tab_panel>
        <.tab_panel id="bordered-vert-3">
          <.heading level={4}>{gettext("Settings")}</.heading>
          <.paragraph>Use <code>pa-tabs__vertical-layout--bordered</code> modifier for vertical tabs.</.paragraph>
        </.tab_panel>
      </.tabs_content>
    </.tabs_vertical_layout>

    <%!-- Long Tab Titles --%>
    <.heading level={3} class="mt-8 mb-4">{gettext("Long Tab Titles in Constrained Space")}</.heading>

    <.grid>
      <.column size="100" md="1-3">
        <.card title_text={gettext("Default (Wrap)")}>
          <.tabs id="long-wrap-tabs">
            <.tab_item tabs_id="long-wrap-tabs" target="long-1" is_active>{gettext("Organizations Tree")}</.tab_item>
            <.tab_item tabs_id="long-wrap-tabs" target="long-2">{gettext("User Management System")}</.tab_item>
            <.tab_item tabs_id="long-wrap-tabs" target="long-3">{gettext("Reports & Analytics")}</.tab_item>
            <.tab_item tabs_id="long-wrap-tabs" target="long-4">{gettext("Settings & Configuration")}</.tab_item>
          </.tabs>
          <.tabs_content id="long-wrap-tabs-content">
            <.tab_panel id="long-1" is_active><.paragraph>Default behavior - tabs wrap to multiple lines when needed.</.paragraph></.tab_panel>
            <.tab_panel id="long-2"><.paragraph>User Management System content.</.paragraph></.tab_panel>
            <.tab_panel id="long-3"><.paragraph>Reports & Analytics content.</.paragraph></.tab_panel>
            <.tab_panel id="long-4"><.paragraph>Settings & Configuration content.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>

      <.column size="100" md="1-3">
        <.card title_text={gettext("Collapse Modifier")}>
          <.tabs id="collapse-tabs" overflow="collapse">
            <.tab_item tabs_id="collapse-tabs" target="collapse-1" is_active class="pa-tooltip" data-tooltip="Organizations Tree">
              <:icon><i class="fa-solid fa-sitemap"></i></:icon>
              <span>{gettext("Organizations Tree")}</span>
            </.tab_item>
            <.tab_item tabs_id="collapse-tabs" target="collapse-2" class="pa-tooltip" data-tooltip="User Management System">
              <:icon><i class="fa-solid fa-users"></i></:icon>
              <span>{gettext("User Management System")}</span>
            </.tab_item>
            <.tab_item tabs_id="collapse-tabs" target="collapse-3" class="pa-tooltip" data-tooltip="Reports & Analytics">
              <:icon><i class="fa-solid fa-chart-bar"></i></:icon>
              <span>{gettext("Reports & Analytics")}</span>
            </.tab_item>
            <.tab_item tabs_id="collapse-tabs" target="collapse-4" class="pa-tooltip" data-tooltip="Settings & Configuration">
              <:icon><i class="fa-solid fa-gear"></i></:icon>
              <span>{gettext("Settings")}</span>
            </.tab_item>
          </.tabs>
          <.tabs_content id="collapse-tabs-content">
            <.tab_panel id="collapse-1" is_active><.paragraph>Collapse mode - inactive tabs show only icons, active tab shows full title.</.paragraph></.tab_panel>
            <.tab_panel id="collapse-2"><.paragraph>User Management content.</.paragraph></.tab_panel>
            <.tab_panel id="collapse-3"><.paragraph>Reports content.</.paragraph></.tab_panel>
            <.tab_panel id="collapse-4"><.paragraph>Settings content.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>

      <.column size="100" md="1-3">
        <.card title_text={gettext("Scrollable Modifier")}>
          <.tabs id="scroll-tabs" overflow="scrollable">
            <.tab_item tabs_id="scroll-tabs" target="scroll-1" is_active>{gettext("Organizations Tree")}</.tab_item>
            <.tab_item tabs_id="scroll-tabs" target="scroll-2">{gettext("User Management System")}</.tab_item>
            <.tab_item tabs_id="scroll-tabs" target="scroll-3">{gettext("Reports & Analytics")}</.tab_item>
            <.tab_item tabs_id="scroll-tabs" target="scroll-4">{gettext("Settings & Configuration")}</.tab_item>
          </.tabs>
          <.tabs_content id="scroll-tabs-content">
            <.tab_panel id="scroll-1" is_active><.paragraph>Scrollable tabs - scroll horizontally to see more tabs.</.paragraph></.tab_panel>
            <.tab_panel id="scroll-2"><.paragraph>User Management content.</.paragraph></.tab_panel>
            <.tab_panel id="scroll-3"><.paragraph>Reports content.</.paragraph></.tab_panel>
            <.tab_panel id="scroll-4"><.paragraph>Settings content.</.paragraph></.tab_panel>
          </.tabs_content>
        </.card>
      </.column>
    </.grid>

    """
  end
end
