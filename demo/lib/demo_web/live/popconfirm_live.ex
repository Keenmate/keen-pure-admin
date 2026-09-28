defmodule DemoWeb.Live.PopconfirmLive do
  use DemoWeb, :live_view

  @users [
    %{id: 1, name: "John Doe", status: "Active", status_variant: "success"},
    %{id: 2, name: "Jane Smith", status: "Pending", status_variant: "warning"},
    %{id: 3, name: "Bob Johnson", status: "Inactive", status_variant: "secondary"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Popconfirm",
      users: @users,
      last_action: nil
    )}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, last_action: "Deleted item ##{id}")}
  end

  def handle_event("archive", _params, socket) do
    {:noreply, assign(socket, last_action: "Item archived")}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, last_action: "Settings reset to defaults")}
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    users = Enum.reject(socket.assigns.users, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, users: users, last_action: "User ##{id} deleted")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Small confirmation dialogs anchored to trigger buttons — perfect for delete confirmations and quick decisions.</.paragraph>

    <.alert :if={@last_action} variant="success" class="mb-4">
      <strong>Action:</strong> {@last_action}
    </.alert>

    <%!-- Basic Popconfirms --%>
    <.card title_text={gettext("Popconfirm Component")} subtitle_text={gettext("Small confirmation dialogs anchored to trigger buttons")}>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Basic Popconfirms")}</.heading>
          <div class="minhr-12">
            <div style="display: flex; gap: 8px; flex-wrap: wrap;">
              <.popconfirm
                id="popconfirm-delete"
                message={gettext("Are you sure you want to delete this item? This action cannot be undone.")}
                icon_variant="danger"
                confirm_text={gettext("Delete")}
                confirm_variant="danger"
                confirm_event="delete"
                confirm_value={%{id: "1"}}
              >
                <.button variant="danger">{gettext("Delete Item")}</.button>
              </.popconfirm>

              <.popconfirm
                id="popconfirm-warning"
                message={gettext("Archive this item? It will be moved to the archive folder.")}
                icon_variant="warning"
                confirm_text={gettext("Archive")}
                confirm_variant="warning"
                confirm_event="archive"
              >
                <.button variant="warning">{gettext("Archive Item")}</.button>
              </.popconfirm>

              <.popconfirm
                id="popconfirm-info"
                message={gettext("Reset all settings to default values?")}
                icon_variant="info"
                confirm_text={gettext("Reset")}
                confirm_variant="primary"
                confirm_event="reset"
              >
                <.button variant="secondary">{gettext("Reset Settings")}</.button>
              </.popconfirm>
            </div>
          </div>
        </.column>

        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Compact Variant")}</.heading>
          <div class="minhr-12">
            <div style="display: flex; gap: 8px; flex-wrap: wrap;">
              <.popconfirm
                id="popconfirm-compact"
                message={gettext("Delete this item?")}
                is_compact
                confirm_text={gettext("Yes")}
                cancel_text={gettext("No")}
                confirm_variant="danger"
                confirm_event="delete"
                confirm_value={%{id: "2"}}
              >
                <.button variant="danger" size="xs" is_icon_only><i class="fa-solid fa-trash"></i></.button>
              </.popconfirm>

              <.popconfirm
                id="popconfirm-compact-2"
                message={gettext("Remove this item?")}
                is_compact
                confirm_text={gettext("Yes")}
                cancel_text={gettext("No")}
                confirm_variant="danger"
                confirm_event="delete"
                confirm_value={%{id: "3"}}
              >
                <.button variant="danger" size="xs" is_outline>{gettext("Remove")}</.button>
              </.popconfirm>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Table Example --%>
    <.card title_text={gettext("Table with Popconfirms")} subtitle_text={gettext("Common use case: delete confirmations in data tables")} has_padding={false}>
      <.table rows={@users} size="sm">
        <:col :let={user} label="ID">{user.id}</:col>
        <:col :let={user} label={gettext("Name")}>{user.name}</:col>
        <:col :let={user} label={gettext("Status")}>
          <.badge variant={user.status_variant}>{user.status}</.badge>
        </:col>
        <:col :let={user} label={gettext("Actions")} class="col-auto">
          <.button_group>
            <.button variant="primary" size="xs">{gettext("Edit")}</.button>
            <.popconfirm
              id={"popconfirm-user-#{user.id}"}
              message={gettext("Delete %{name}?", name: user.name)}
              is_compact
              confirm_text={gettext("Yes")}
              cancel_text={gettext("No")}
              confirm_variant="danger"
              confirm_event="delete_user"
              confirm_value={%{id: "#{user.id}"}}
            >
              <.button variant="danger" size="xs">{gettext("Delete")}</.button>
            </.popconfirm>
          </.button_group>
        </:col>
      </.table>
    </.card>
    """
  end
end
