defmodule DemoWeb.Live.VirtualScrollLive do
  use DemoWeb, :live_view

  @names ["John Smith", "Emma Davis", "Luna Bonifacio", "Yoan Almedia", "Sarah Chen", "Mike Johnson"]
  @total_items 200

  def mount(_params, _session, socket) do
    items = generate_items(0, 20)

    {:ok, assign(socket,
      page_title: "Virtual Scroll",
      items: items,
      loaded_count: 20,
      total_items: @total_items,
      has_more: true,
      loading: false
    )}
  end

  def handle_event("infinite_load_more", _, socket) do
    if socket.assigns.loading or not socket.assigns.has_more do
      {:noreply, socket}
    else
      send(self(), :do_infinite_load)
      {:noreply, assign(socket, loading: true)}
    end
  end

  def handle_info(:do_infinite_load, socket) do
    Process.sleep(500)
    offset = socket.assigns.loaded_count
    new_items = generate_items(offset, 20)
    new_count = offset + length(new_items)

    {:noreply, assign(socket,
      items: socket.assigns.items ++ new_items,
      loaded_count: new_count,
      has_more: new_count < @total_items,
      loading: false
    )}
  end

  defp generate_items(offset, count) do
    for i <- offset..(offset + count - 1), i < @total_items do
      name = Enum.at(@names, rem(i, length(@names)))
      hour = 9 + rem(i, 10)
      min = rem(i * 5, 60)
      time = "#{String.pad_leading("#{hour}", 2, "0")}:#{String.pad_leading("#{min}", 2, "0")}"

      %{
        id: i,
        name: name,
        time: time,
        action: "performed action ##{i}"
      }
    end
  end

  defp avatar(name) do
    encoded = String.replace(name, " ", "+")
    "https://ui-avatars.com/api/?name=#{encoded}&background=0D8ABC&color=fff"
  end

  def render(assigns) do
    ~H"""
    <%!-- How It Works --%>
    <.card title_text={gettext("How It Works")}>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Virtual Scroll (True Virtualization)")}</.heading>
          <.basic_list>
            <li><strong>Constant DOM size</strong> - Only ~20 items in DOM regardless of total dataset</li>
            <li><strong>Performance</strong> - Can handle millions of items smoothly</li>
            <li><strong>Fixed heights</strong> - Requires items to have consistent, known heights</li>
            <li><strong>Use case</strong> - Tables, lists with uniform row heights</li>
            <li><strong>DOM strategy</strong> - Items added/removed dynamically as you scroll</li>
          </.basic_list>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Infinite Scroll (Lazy Loading)")}</.heading>
          <.basic_list>
            <li><strong>Growing DOM</strong> - All loaded items stay in DOM</li>
            <li><strong>Performance</strong> - Good for hundreds/low thousands of items</li>
            <li><strong>Variable heights</strong> - Works with dynamic content heights</li>
            <li><strong>Use case</strong> - Feeds, timelines with rich content</li>
            <li><strong>DOM strategy</strong> - Items appended, never removed</li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>

    <%!-- Virtual Scroll Examples --%>
    <.section title_text={gettext("Virtual Scroll Examples")}>
      <.paragraph class="mb-4">True virtualization - constant DOM size</.paragraph>
      <.grid>
        <.column size="50">
          <.card title_text={gettext("Timeline - 5000 Items")}>
            <:description>{gettext("Only ~20 items in DOM at any time")}</:description>
            <.callout variant="warning">
              <:title>{gettext("Not Yet Supported")}</:title>
              True virtual scroll (windowed rendering) requires a custom JS hook that calculates visible indices from scroll position and row height, then only renders those rows. This is planned for a future release.
            </.callout>
            <.callout variant="info">
              <:title>{gettext("Why It's Complex in LiveView")}</:title>
              LiveView manages the DOM server-side. True virtualization needs client-side DOM manipulation that conflicts with LiveView's diffing. A proper implementation requires a dedicated JS hook that coordinates with the server to only request visible data windows.
            </.callout>
          </.card>
        </.column>
        <.column size="50">
          <.card title_text={gettext("Table - 10000 Rows")}>
            <:description>{gettext("Smooth scrolling through large datasets")}</:description>
            <.callout variant="warning">
              <:title>{gettext("Not Yet Supported")}</:title>
              Virtual scroll for tables requires fixed row heights and a hook that renders spacer rows above/below the visible window. This approach works in LiveView but needs careful implementation to avoid conflicts with DOM patching.
            </.callout>
            <.callout variant="info">
              <:title>{gettext("Alternative: Server-Side Pagination")}</:title>
              For large datasets, use the <code>&lt;.pager&gt;</code> component with server-side queries. This is more efficient than virtual scroll for most use cases since it transfers only the visible page of data.
            </.callout>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Infinite Scroll Example --%>
    <.section title_text={gettext("Infinite Scroll Example")}>
      <.paragraph class="mb-4">Lazy loading - items accumulate in DOM. Uses <code>PureAdminInfiniteScroll</code> hook.</.paragraph>
      <.card title_text={gettext("Timeline Feed - Infinite Scroll")}>
        <:description>Loads more items automatically as you scroll ({@loaded_count} of {@total_items} loaded)</:description>
        <div class="pa-timeline__scroll-container">
          <.timeline variant="feed">
            <.timeline_item
              :for={item <- @items}
              time_text={item.time}
              avatar_url={avatar(item.name)}
              avatar_alt={item.name}
            >
              <a href="#">{item.name}</a> {item.action}
            </.timeline_item>
          </.timeline>
          <div
            id="vs-scroll-sentinel"
            phx-hook="PureAdminInfiniteScroll"
            data-event="infinite_load_more"
            data-has-more={to_string(@has_more)}
            data-throttle="500"
          >
            <.loader_center :if={@loading}>
              <.loader />
            </.loader_center>
            <.paragraph :if={not @has_more} color="secondary" class="text-center py-4">
              All {@loaded_count} items loaded.
            </.paragraph>
          </div>
        </div>
      </.card>
    </.section>

    <%!-- Usage Reference --%>
    <.card title_text={gettext("Infinite Scroll Hook Usage")}>
      <.code_block language="heex">
        &lt;div
          id="scroll-sentinel"
          phx-hook="PureAdminInfiniteScroll"
          data-event="load_more"
          data-has-more=&#123;to_string(@has_more)&#125;
          data-throttle="500"
          data-root-margin="200px"
        &gt;
          &lt;.loader :if=&#123;@loading&#125; /&gt;
        &lt;/div&gt;
      </.code_block>
      <.table rows={[
        %{attr: "data-event", default: "load_more", desc: "LiveView event name to push"},
        %{attr: "data-has-more", default: "true", desc: "Set to \"false\" to stop observing"},
        %{attr: "data-root-margin", default: "200px", desc: "Preload buffer distance"},
        %{attr: "data-throttle", default: "500", desc: "Minimum ms between triggers"}
      ]} is_striped>
        <:col :let={row} label={gettext("Attribute")}><code>{row.attr}</code></:col>
        <:col :let={row} label={gettext("Default")}><code>{row.default}</code></:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>
    </.card>
    """
  end

end
