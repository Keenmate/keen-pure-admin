defmodule DemoWeb.Live.NotificationsLive do
  use DemoWeb, :live_view

  @initial_notifications [
    %{id: 1, title: "New user registration", text: "John Doe has registered a new account and is awaiting approval.", time: "2 minutes ago", variant: "primary", is_unread: true},
    %{id: 2, title: "Server warning", text: "CPU usage exceeded 85% threshold on production server.", time: "15 minutes ago", variant: "warning", is_unread: true},
    %{id: 3, title: "Deployment complete", text: "Version 2.4.1 deployed to staging environment successfully.", time: "1 hour ago", variant: "success", is_unread: true},
    %{id: 4, title: "Payment failed", text: "Payment processing failed for Order #4521. Please review.", time: "2 hours ago", variant: "danger", is_unread: true},
    %{id: 5, title: "Scheduled maintenance", text: "System maintenance window: Tonight 11PM - 2AM UTC.", time: "3 hours ago", variant: "info", is_unread: false},
    %{id: 6, title: "Backup completed", text: "Daily backup completed. 2.4GB archived successfully.", time: "5 hours ago", variant: "success", is_unread: false},
    %{id: 7, title: "New comment", text: "Sarah left a comment on Task #234: 'Looks great, approved!'", time: "Yesterday", variant: "primary", is_unread: false},
    %{id: 8, title: "License expiring", text: "Your enterprise license expires in 14 days. Please renew.", time: "Yesterday", variant: "warning", is_unread: false}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Notifications",
      notifications: @initial_notifications,
      filter: "all"
    )}
  end

  def handle_event("filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, filter: filter)}
  end

  def handle_event("mark_read", %{"id" => id}, socket) do
    id = String.to_integer(id)
    notifications = Enum.map(socket.assigns.notifications, fn
      %{id: ^id} = n -> %{n | is_unread: false}
      n -> n
    end)
    {:noreply, assign(socket, notifications: notifications)}
  end

  def handle_event("mark_all_read", _, socket) do
    notifications = Enum.map(socket.assigns.notifications, &%{&1 | is_unread: false})
    {:noreply, assign(socket, notifications: notifications)}
  end

  def render(assigns) do
    unread_count = Enum.count(assigns.notifications, & &1.is_unread)

    filtered = case assigns.filter do
      "unread" -> Enum.filter(assigns.notifications, & &1.is_unread)
      "read" -> Enum.reject(assigns.notifications, & &1.is_unread)
      type when type in ~w(primary warning success danger info) ->
        Enum.filter(assigns.notifications, &(&1.variant == type))
      _ -> assigns.notifications
    end

    assigns = assign(assigns, filtered: filtered, unread_count: unread_count)

    ~H"""
    <.grid class="mb-2">
      <.column>
        <.paragraph>View and manage all your notifications</.paragraph>
      </.column>
      <.column class="col-auto">
        <.button variant="secondary" size="sm" phx-click="mark_all_read">{gettext("Mark all as read")}</.button>
      </.column>
    </.grid>

    <%!-- Filters --%>
    <.card class="mb-2">
      <.button_group>
        <.button size="sm" variant={if @filter == "all", do: "primary", else: "secondary"} phx-click="filter" phx-value-filter="all">{gettext("All")}</.button>
        <.button size="sm" variant={if @filter == "unread", do: "primary", else: "secondary"} phx-click="filter" phx-value-filter="unread">{gettext("Unread")}</.button>
        <.button size="sm" variant={if @filter == "read", do: "primary", else: "secondary"} phx-click="filter" phx-value-filter="read">{gettext("Read")}</.button>
      </.button_group>
      <.button_group class="ml-4">
        <.button size="sm" variant={if @filter == "primary", do: "primary", else: "secondary"} phx-click="filter" phx-value-filter="primary">{gettext("Info")}</.button>
        <.button size="sm" variant={if @filter == "warning", do: "warning", else: "secondary"} phx-click="filter" phx-value-filter="warning">{gettext("Warning")}</.button>
        <.button size="sm" variant={if @filter == "success", do: "success", else: "secondary"} phx-click="filter" phx-value-filter="success">{gettext("Success")}</.button>
        <.button size="sm" variant={if @filter == "danger", do: "danger", else: "secondary"} phx-click="filter" phx-value-filter="danger">{gettext("Error")}</.button>
      </.button_group>
    </.card>

    <%!-- Notifications List --%>
    <.card title_text={gettext("All Notifications")} has_padding={false}>
      <:tools><.badge variant="primary">{gettext("%{count} unread", count: @unread_count)}</.badge></:tools>
      <.list>
        <.list_item
          :for={n <- @filtered}
          title_text={n.title}
          subtitle_text={n.text}
          class={if n.is_unread, do: "pa-list__item--highlighted"}
        >
          <:avatar>
            <.notification_icon variant={n.variant} />
          </:avatar>
          <:meta>
            <.text variant="secondary" class="text-sm">{n.time}</.text>
            <.button
              :if={n.is_unread}
              variant="ghost"
              size="xs"
              phx-click="mark_read"
              phx-value-id={n.id}
              title={gettext("Mark as read")}
            >
              <i class="fa-solid fa-check"></i>
            </.button>
          </:meta>
        </.list_item>
      </.list>
    </.card>

    <%!-- Notification Components Reference --%>
    <.card title_text={gettext("Notification Components")}>
      <:description>Components used in the navbar notification dropdown</:description>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Navbar Notifications")}</.heading>
          <.code_block language="heex">
            &lt;.notifications count={3}&gt;
              &lt;.notification_item variant="primary" icon="fa-solid fa-bell" is_unread&gt;
                &lt;:title&gt;New message&lt;/:title&gt;
                &lt;:text&gt;You have a new message&lt;/:text&gt;
                &lt;:time&gt;2 min ago&lt;/:time&gt;
              &lt;/.notification_item&gt;
            &lt;/.notifications&gt;
          </.code_block>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Available Props")}</.heading>
          <.table rows={[
            %{prop: "count", desc: "Badge count on bell icon"},
            %{prop: "variant", desc: "Color variant (primary, success, warning, danger, info)"},
            %{prop: "icon", desc: "Font Awesome icon class"},
            %{prop: "is_unread", desc: "Highlight as unread"}
          ]} is_striped>
            <:col :let={row} label={gettext("Prop")}><code>{row.prop}</code></:col>
            <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
          </.table>
        </.column>
      </.grid>
    </.card>
    """
  end

  defp notification_icon(%{variant: "success"} = assigns) do
    ~H"""
    <span class="text-success"><i class="fa-solid fa-check-circle"></i></span>
    """
  end

  defp notification_icon(%{variant: "warning"} = assigns) do
    ~H"""
    <span class="text-warning"><i class="fa-solid fa-triangle-exclamation"></i></span>
    """
  end

  defp notification_icon(%{variant: "danger"} = assigns) do
    ~H"""
    <span class="text-danger"><i class="fa-solid fa-circle-exclamation"></i></span>
    """
  end

  defp notification_icon(%{variant: "info"} = assigns) do
    ~H"""
    <span class="text-info"><i class="fa-solid fa-circle-info"></i></span>
    """
  end

  defp notification_icon(assigns) do
    ~H"""
    <span class="text-primary"><i class="fa-solid fa-bell"></i></span>
    """
  end
end
