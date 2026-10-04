defmodule DemoWeb.Live.TimelineFeedLive do
  use DemoWeb, :live_view

  @all_entries [
    %{date: "January 22, 2021", items: [
      %{time: "18:15", name: "Emma Davis", action: :created, target: "new sprint"},
      %{time: "15:20", name: "John Smith", action: :updated, target: "documentation"}
    ]},
    %{date: "January 21, 2021", items: [
      %{time: "14:32", name: "Luna Bonifacio", action: :changed, target: "2 attributes"},
      %{time: "11:15", name: "Yoan Almedia", action: :moved, target: "Eric Lubin", dest: "Technical Test"},
      %{time: "09:42", name: "Yoan Almedia", action: :commented, comment: "I've sent him the assignment we discussed recently, he is coming back to us this week. Regarding our last call, I really enjoyed talking to him and so far he has the profile we are looking for. Can't wait to see his technical test, I'll keep you posted and we'll debrief it all together!"}
    ]},
    %{date: "January 20, 2021", items: [
      %{time: "16:45", name: "Sarah Chen", action: :attached, target: "3 files"},
      %{time: "14:20", name: "Mike Johnson", action: :completed, target: "Design Review"},
      %{time: "10:30", name: "Alex Rivera", action: :created, target: "3 new tickets", dest: "Sprint 14"}
    ]},
    %{date: "January 19, 2021", items: [
      %{time: "17:00", name: "Emma Wilson", action: :closed, target: "Sprint 13"},
      %{time: "11:30", name: "Luna Bonifacio", action: :updated, target: "project documentation"}
    ]},
    %{date: "January 18, 2021", items: [
      %{time: "16:00", name: "Sarah Chen", action: :completed, target: "Code Review"},
      %{time: "10:15", name: "Mike Johnson", action: :created, target: "deployment plan"}
    ]},
    %{date: "January 17, 2021", items: [
      %{time: "15:30", name: "Yoan Almedia", action: :completed, target: "API integration"},
      %{time: "09:00", name: "Alex Rivera", action: :created, target: "test suite"}
    ]}
  ]

  @page_size 2

  def mount(_params, _session, socket) do
    visible = Enum.take(@all_entries, @page_size)

    {:ok, assign(socket,
      page_title: "Timeline Feed",
      # Load more state
      lm_page: 1,
      lm_entries: visible,
      lm_has_more: length(@all_entries) > @page_size,
      lm_loading: false,
      # Infinite scroll state
      is_page: 1,
      is_entries: visible,
      is_has_more: length(@all_entries) > @page_size,
      is_loading: false
    )}
  end

  # Load More button
  def handle_event("load_more", _, socket) do
    send(self(), :do_load_more)
    {:noreply, assign(socket, lm_loading: true)}
  end

  # Infinite scroll sentinel
  def handle_event("scroll_more", _, socket) do
    if socket.assigns.is_loading or not socket.assigns.is_has_more do
      {:noreply, socket}
    else
      send(self(), :do_scroll_more)
      {:noreply, assign(socket, is_loading: true)}
    end
  end

  def handle_info(:do_load_more, socket) do
    Process.sleep(500)
    next_page = socket.assigns.lm_page + 1
    count = next_page * @page_size
    visible = Enum.take(@all_entries, count)

    {:noreply, assign(socket,
      lm_page: next_page,
      lm_entries: visible,
      lm_has_more: length(@all_entries) > count,
      lm_loading: false
    )}
  end

  def handle_info(:do_scroll_more, socket) do
    Process.sleep(800)
    next_page = socket.assigns.is_page + 1
    count = next_page * @page_size
    visible = Enum.take(@all_entries, count)

    {:noreply, assign(socket,
      is_page: next_page,
      is_entries: visible,
      is_has_more: length(@all_entries) > count,
      is_loading: false
    )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Feed-style timeline with avatars and actions - perfect for activity logs</.paragraph>

    <%!-- Activity Feed Timeline (static) --%>
    <.card title_text={gettext("Activity Feed Timeline")}>
      <:description>{gettext("Feed-style timeline with avatars and actions")}</:description>
      <.timeline variant="feed">
        <.timeline_item avatar_url={avatar("Luna Bonifacio")} avatar_alt="Luna Bonifacio">
          <a href="#">Luna Bonifacio</a> has changed <a href="#">2 attributes</a> on <time datetime="2021-01-21">Jan 21, 2021</time>
        </.timeline_item>
        <.timeline_item avatar_url={avatar("Yoan Almedia")} avatar_alt="Yoan Almedia">
          <a href="#">Yoan Almedia</a> moved <a href="#">Eric Lubin</a> to <a href="#">Technical Test</a> on <time datetime="2021-01-20">Jan 20, 2021</time>
        </.timeline_item>
        <.timeline_item avatar_url={avatar("Yoan Almedia")} avatar_alt="Yoan Almedia">
          <a href="#">Yoan Almedia</a> commented on <time datetime="2021-01-20">Jan 20, 2021</time>
          <:comment>
            I've sent him the assignment we discussed recently, he is coming back to us this week. Regarding our last call, I really enjoyed talking to him and so far he has the profile we are looking for. Can't wait to see his technical test, I'll keep you posted and we'll debrief it all together!
          </:comment>
        </.timeline_item>
        <.timeline_item avatar_url={avatar("Sarah Chen")} avatar_alt="Sarah Chen">
          <a href="#">Sarah Chen</a> attached <a href="#">3 files</a> to the project on <time datetime="2021-01-19">Jan 19, 2021</time>
        </.timeline_item>
        <.timeline_item avatar_url={avatar("Mike Johnson")} avatar_alt="Mike Johnson">
          <a href="#">Mike Johnson</a> completed <a href="#">Design Review</a> task on <time datetime="2021-01-18">Jan 18, 2021</time>
        </.timeline_item>
      </.timeline>
    </.card>

    <.grid>
      <%!-- Load More (button) --%>
      <.column size="50">
        <.card title_text={gettext("Timeline Feed - Load More")}>
          <:description>{gettext("Click button to load more entries")}</:description>
          <.timeline variant="feed">
            <%= for group <- @lm_entries do %>
              <.timeline_item is_date_header icon_text="📅">
                {String.upcase(group.date)}
              </.timeline_item>
              <%= for item <- group.items do %>
                <.timeline_item time_text={item.time} avatar_url={avatar(item.name)} avatar_alt={item.name}>
                  {render_action(item)}
                  <:comment :if={item[:comment]}>
                    {item.comment}
                  </:comment>
                </.timeline_item>
              <% end %>
            <% end %>
          </.timeline>
          <div :if={@lm_has_more} class="pa-timeline__load-more-wrapper">
            <.button variant="primary" phx-click="load_more" is_loading={@lm_loading}>
              <:icon><i class="fa-solid fa-arrow-down"></i></:icon>
              {gettext("Load More")}
            </.button>
          </div>
          <.callout :if={not @lm_has_more} variant="info" class="mt-4">
            {gettext("All entries loaded.")}
          </.callout>
        </.card>
      </.column>

      <%!-- Infinite Scroll (automatic) --%>
      <.column size="50">
        <.card title_text={gettext("Timeline Feed - Infinite Scroll")}>
          <:description>{gettext("Automatically loads more entries as you scroll down")}</:description>
          <div class="pa-timeline__scroll-container">
            <.timeline variant="feed">
              <%= for group <- @is_entries do %>
                <.timeline_item is_date_header icon_text="📅">
                  {String.upcase(group.date)}
                </.timeline_item>
                <%= for item <- group.items do %>
                  <.timeline_item time_text={item.time} avatar_url={avatar(item.name)} avatar_alt={item.name}>
                    {render_action(item)}
                    <:comment :if={item[:comment]}>
                      {item.comment}
                    </:comment>
                  </.timeline_item>
                <% end %>
              <% end %>
            </.timeline>
            <div
              id="feed-scroll-sentinel"
              phx-hook="PureAdminInfiniteScroll"
              data-event="scroll_more"
              data-has-more={to_string(@is_has_more)}
              data-throttle="800"
            >
              <.loader_center :if={@is_loading}>
                <.loader />
              </.loader_center>
              <.paragraph :if={not @is_has_more} color="secondary" class="text-center pa-py-4">
                {gettext("All entries loaded.")}
              </.paragraph>
            </div>
          </div>
        </.card>
      </.column>
    </.grid>
    """
  end

  defp avatar(name) do
    encoded = name |> String.replace(" ", "+")
    "https://ui-avatars.com/api/?name=#{encoded}&background=0D8ABC&color=fff"
  end

  defp render_action(%{action: :changed, name: name, target: target}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> has changed <a href="#">#{target}</a>])
  end

  defp render_action(%{action: :moved, name: name, target: target, dest: dest}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> moved <a href="#">#{target}</a> to <a href="#">#{dest}</a>])
  end

  defp render_action(%{action: :commented, name: name}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> commented])
  end

  defp render_action(%{action: :attached, name: name, target: target}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> attached <a href="#">#{target}</a> to the project])
  end

  defp render_action(%{action: :completed, name: name, target: target}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> completed <a href="#">#{target}</a> task])
  end

  defp render_action(%{action: :created, name: name, target: target} = item) do
    dest = if item[:dest], do: ~s[ in <a href="#">#{item.dest}</a>], else: ""
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> created <a href="#">#{target}</a>#{dest}])
  end

  defp render_action(%{action: :closed, name: name, target: target}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> closed <a href="#">#{target}</a> — all tasks completed])
  end

  defp render_action(%{action: :updated, name: name, target: target}) do
    Phoenix.HTML.raw(~s[<a href="#">#{name}</a> updated #{target}])
  end
end
