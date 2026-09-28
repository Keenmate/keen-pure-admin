defmodule DemoWeb.Live.FormDemoLive do
  use DemoWeb, :live_view

  alias Demo.FormCache
  alias PureAdmin.Components.Flash, as: PureFlash
  alias PureAdmin.Components.Toast, as: PureToast

  @empty_params %{
    "first_name" => "",
    "last_name" => "",
    "email" => "",
    "department" => "",
    "start_date" => "",
    "bio" => "",
    "force_errors" => ""
  }

  @departments ["Engineering", "Marketing", "Sales", "Support", "Product"]

  # `:seconds_ago` is applied at seed time so the relative column shows variance.
  @seed_entries [
    %{
      first_name: "Dale",
      last_name: "Cooper",
      email: "dale.cooper@twinpeaks.example",
      department: "Support",
      start_date: "2024-02-24",
      bio: "Damn fine coffee enthusiast. FBI-level attention to detail.",
      seconds_ago: 90
    },
    %{
      first_name: "Audrey",
      last_name: "Horne",
      email: "audrey.horne@twinpeaks.example",
      department: "Sales",
      start_date: "2023-09-12",
      bio: "Great Northern hospitality brought to enterprise accounts.",
      seconds_ago: 5 * 3600
    },
    %{
      first_name: "Donna",
      last_name: "Hayward",
      email: "donna.hayward@twinpeaks.example",
      department: "Marketing",
      start_date: "2025-01-07",
      bio: "",
      seconds_ago: 3 * 86_400
    }
  ]

  @impl true
  def mount(_params, session, socket) do
    session_id = session["form_session_id"]

    entries =
      case session_id do
        nil -> []
        id -> maybe_seed(id, FormCache.list(id))
      end

    {:ok,
     assign(socket,
       page_title: "Form Demo",
       session_id: session_id,
       entries: entries,
       editing_id: nil,
       last_deleted: nil
     )
     |> assign_form(@empty_params, [])}
  end

  @impl true
  def handle_event("submit", %{"entry" => params}, socket) do
    params = Map.merge(@empty_params, Map.take(params, Map.keys(@empty_params)))

    case {validate(params), socket.assigns.session_id, socket.assigns.editing_id} do
      {[], nil, _} ->
        {:noreply,
         PureFlash.push_flash(socket, "form-demo", "danger",
           "Session not initialised — reload the page and try again.",
           title: "Error",
           replace: true
         )}

      {[], session_id, nil} ->
        entries = FormCache.put(session_id, to_entry(params))
        {:noreply, reset_after_save(socket, entries, "Entry saved to session cache.")}

      {[], session_id, id} ->
        entries = FormCache.update(session_id, id, to_entry(params))
        {:noreply, reset_after_save(socket, entries, "Entry updated.")}

      {errors, _, _} ->
        {:noreply,
         socket
         |> assign_form(params, errors)
         |> PureFlash.push_flash("form-demo", "danger", "Please fix the errors below.",
           title: "Validation failed",
           replace: true
         )}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    with {int_id, ""} <- Integer.parse(id),
         session_id when is_binary(session_id) <- socket.assigns.session_id,
         %{} = entry <- FormCache.get(session_id, int_id) do
      {:noreply,
       socket
       |> assign(editing_id: int_id)
       |> assign_form(entry_to_params(entry), [])
       |> push_event("reset-form", %{id: "form-demo-form"})
       |> PureFlash.push_flash("form-demo", "info", "Editing entry — make changes and click Update.",
         title: "Edit mode",
         duration: 3000,
         replace: true
       )}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(editing_id: nil)
     |> assign_form(@empty_params, [])
     |> push_event("reset-form", %{id: "form-demo-form"})
     |> PureFlash.clear_flash("form-demo")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    with {int_id, ""} <- Integer.parse(id),
         session_id when is_binary(session_id) <- socket.assigns.session_id,
         %{} = entry <- FormCache.get(session_id, int_id) do
      entries = FormCache.delete(session_id, int_id)

      socket =
        if socket.assigns.editing_id == int_id do
          socket
          |> assign(editing_id: nil)
          |> assign_form(@empty_params, [])
          |> push_event("reset-form", %{id: "form-demo-form"})
        else
          socket
        end

      {:noreply,
       socket
       |> assign(entries: entries, last_deleted: entry)
       |> PureToast.push_toast("info", "Entry deleted", "#{full_name(entry)} removed.",
         duration: 6000,
         actions: [
           %{label: "Undo", event: "undo_delete", variant: "primary"},
           %{label: "Dismiss", dismiss: true, variant: "secondary"}
         ]
       )}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("undo_delete", _params, socket) do
    case {socket.assigns[:last_deleted], socket.assigns.session_id} do
      {%{} = entry, session_id} when is_binary(session_id) ->
        entries = FormCache.put(session_id, Map.drop(entry, [:id, :inserted_at]))

        {:noreply,
         socket
         |> assign(entries: entries, last_deleted: nil)
         |> PureToast.push_toast("success", "Restored", "#{full_name(entry)} is back.",
           duration: 2500
         )}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", _params, socket) do
    if socket.assigns.session_id, do: FormCache.clear(socket.assigns.session_id)

    {:noreply,
     socket
     |> assign(entries: [], editing_id: nil)
     |> assign_form(@empty_params, [])
     |> push_event("reset-form", %{id: "form-demo-form"})
     |> PureFlash.push_flash("form-demo", "info", "All entries removed.", duration: 3000, replace: true)}
  end

  # After a successful insert/update: clear the form, drop editing state, reset the DOM, flash success.
  defp reset_after_save(socket, entries, message) do
    socket
    |> assign(entries: entries, editing_id: nil)
    |> assign_form(@empty_params, [])
    |> push_event("reset-form", %{id: "form-demo-form"})
    |> PureFlash.push_flash("form-demo", "success", message,
      title: "Saved",
      duration: 3000,
      replace: true
    )
  end

  defp maybe_seed(_session_id, [_ | _] = entries), do: entries

  defp maybe_seed(session_id, []) do
    now = DateTime.utc_now()

    Enum.reduce(Enum.reverse(@seed_entries), [], fn entry, _acc ->
      {seconds_ago, entry} = Map.pop(entry, :seconds_ago, 0)
      inserted_at = DateTime.add(now, -seconds_ago, :second)
      FormCache.put(session_id, Map.put(entry, :inserted_at, inserted_at))
    end)
  end

  defp entry_to_params(entry) do
    %{
      "first_name" => entry.first_name,
      "last_name" => entry.last_name,
      "email" => entry.email,
      "department" => entry.department,
      "start_date" => entry.start_date,
      "bio" => entry.bio,
      "force_errors" => ""
    }
  end

  # -- helpers --

  defp assign_form(socket, params, errors) do
    assign(socket, :form, to_form(params, as: :entry, errors: errors))
  end

  defp to_entry(params) do
    %{
      first_name: String.trim(params["first_name"]),
      last_name: String.trim(params["last_name"]),
      email: String.trim(params["email"]),
      department: params["department"],
      start_date: params["start_date"],
      bio: String.trim(params["bio"])
    }
  end

  defp validate(params) do
    if params["force_errors"] == "true" do
      [
        first_name: {"forced error: first name is bad", []},
        last_name: {"forced error: last name is bad", []},
        email: {"forced error: email is bad", []},
        department: {"forced error: pick a different one", []},
        start_date: {"forced error: date is off", []},
        bio: {"forced error: rewrite this", []}
      ]
    else
      []
      |> check_required(params, :first_name, "first name is required")
      |> check_required(params, :last_name, "last name is required")
      |> check_email(params)
      |> Enum.reverse()
    end
  end

  defp check_required(errors, params, field, message) do
    if String.trim(params[to_string(field)] || "") == "" do
      [{field, {message, []}} | errors]
    else
      errors
    end
  end

  defp check_email(errors, params) do
    value = String.trim(params["email"] || "")

    cond do
      value == "" ->
        [{:email, {"email is required", []}} | errors]

      not (String.contains?(value, "@") and String.contains?(value, ".")) ->
        [{:email, {"enter a valid email address", []}} | errors]

      true ->
        errors
    end
  end

  defp full_name(%{first_name: first, last_name: last}), do: String.trim("#{first} #{last}")

  defp truncate(nil, _), do: ""
  defp truncate("", _), do: ""

  defp truncate(str, max) when is_binary(str) do
    if String.length(str) > max, do: String.slice(str, 0, max) <> "…", else: str
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :departments, @departments)

    ~H"""
    <.paragraph>
      End-to-end example of building forms with PureAdmin components wired through Phoenix
      LiveView's <code>to_form</code> and <code>simple_form</code>. Submissions land in a
      per-session ETS cache (<code>Demo.FormCache</code>) with a sliding 30-minute TTL, and
      the table below renders them with editing, toast-based undo on delete, and relative
      timestamps via <code>PureAdmin.DateTime</code>.
    </.paragraph>

    <.callout variant="info">
      <strong>Things to try:</strong>
      <ul class="mt-2 mb-0">
        <li>Submit valid data — the form resets and a success flash replaces any prior status.</li>
        <li>Tick <em>Force validation errors</em> before saving — typed values stick and every
          field shows an inline error via the <code>field=&#123;@form[:x]&#125;</code> binding.</li>
        <li>Click the pencil to edit a row inline; the submit button switches to <em>Update Entry</em>.</li>
        <li>Click × to delete — the entry disappears and a toast with an <em>Undo</em> action appears.</li>
        <li>Refresh the page — entries (seeded or submitted) survive. <em>Clear All</em> and
          refresh again to re-seed the defaults.</li>
      </ul>
    </.callout>

    <.card title_text={gettext("New Entry")} is_header_underlined>
      <.flash_container id="form-demo" />

      <.simple_form for={@form} id="form-demo-form" phx-submit="submit">
        <.grid>
          <.column size="100" md="50">
            <.form_group field={@form[:first_name]}>
              <.form_label>{gettext("First Name")}</.form_label>
              <.input field={@form[:first_name]} placeholder="Jane" required />
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group field={@form[:last_name]}>
              <.form_label>{gettext("Last Name")}</.form_label>
              <.input field={@form[:last_name]} placeholder="Doe" required />
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group field={@form[:email]}>
              <.form_label>{gettext("Email")}</.form_label>
              <.input field={@form[:email]} type="email" placeholder="jane@example.com" required />
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Department")}</.form_label>
              <.select
                field={@form[:department]}
                prompt={gettext("Choose a department...")}
                options={@departments}
              />
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Start Date")}</.form_label>
              <.input field={@form[:start_date]} type="date" />
            </.form_group>
          </.column>

          <.column size="100">
            <.form_group>
              <.form_label>{gettext("Bio")}</.form_label>
              <.textarea field={@form[:bio]} rows="3" placeholder={gettext("A few words about this person...")} />
            </.form_group>
          </.column>

          <.column size="100">
            <.form_group>
              <.checkbox field={@form[:force_errors]} label={gettext("Force validation errors on every field (for testing that values stick and errors render)")} />
            </.form_group>
          </.column>
        </.grid>

        <:actions>
          <.button
            :if={@editing_id != nil}
            type="button"
            variant="secondary"
            phx-click="cancel_edit"
          >
            {gettext("Cancel")}
          </.button>
          <.button :if={@editing_id == nil} type="reset" variant="secondary">{gettext("Reset")}</.button>
          <.button type="submit" variant="primary">
            <i class="fa-solid fa-floppy-disk"></i>
            <%= if @editing_id, do: gettext("Update Entry"), else: gettext("Save Entry") %>
          </.button>
        </:actions>
      </.simple_form>
    </.card>

    <.table_card title_text={gettext("Stored Submissions")} is_scrollable>
      <:actions>
        <.badge variant="secondary">{length(@entries)} {gettext("total")}</.badge>
        <.popconfirm
          :if={@entries != []}
          id="clear-all-confirm"
          message={gettext("Remove all stored submissions for this session?")}
          icon_variant="danger"
          confirm_text={gettext("Clear all")}
          confirm_variant="danger"
          confirm_event="clear"
        >
          <.button variant="danger" size="sm">
            <i class="fa-solid fa-trash"></i> {gettext("Clear All")}
          </.button>
        </.popconfirm>
      </:actions>

      <.callout :if={@entries == []} variant="info">
        No submissions yet. Fill in the form above and click <strong>Save Entry</strong>.
      </.callout>

      <.table :if={@entries != []} rows={@entries} is_striped>
        <:col :let={e} label={gettext("Name")}>{full_name(e)}</:col>
        <:col :let={e} label={gettext("Email")}>
          <a href={"mailto:" <> e.email} class="pa-link">{e.email}</a>
        </:col>
        <:col :let={e} label={gettext("Department")}>
          <.badge :if={e.department != ""} variant="info">{e.department}</.badge>
          <span :if={e.department == ""} class="pa-text--secondary">—</span>
        </:col>
        <:col :let={e} label={gettext("Start Date")}>
          <span :if={e.start_date == ""} class="pa-text--secondary">—</span>
          <span :if={e.start_date != ""}>{e.start_date}</span>
        </:col>
        <:col :let={e} label={gettext("Bio")} class="col-auto">
          <span :if={e.bio == ""} class="pa-text--secondary">—</span>
          <span :if={e.bio != ""} title={e.bio}>{truncate(e.bio, 60)}</span>
        </:col>
        <:col :let={e} label={gettext("Submitted")}>
          <span class="pa-text--secondary" title={PureAdmin.DateTime.format(e.inserted_at, :long_date_time)}>
            {PureAdmin.DateTime.relative(e.inserted_at)}
          </span>
        </:col>
        <:action :let={e}>
          <.button
            variant="danger"
            size="xs"
            title={gettext("Delete entry")}
            phx-click="delete"
            phx-value-id={e.id}
          >
            <i class="fa-solid fa-xmark"></i>
          </.button>
          <.button
            variant="secondary"
            size="xs"
            title={gettext("Edit entry")}
            phx-click="edit"
            phx-value-id={e.id}
          >
            <i class="fa-solid fa-pencil"></i>
          </.button>
        </:action>
      </.table>
    </.table_card>

    <.card title_text={gettext("How it works")}>
      <.heading level={4}>{gettext("Form binding")}</.heading>
      <.basic_list>
        <li>
          <code>&lt;.simple_form for=&#123;@form&#125;&gt;</code> wraps a Phoenix form; every input uses
          <code>field=&#123;@form[:x]&#125;</code> to derive <code>name</code>, <code>id</code>,
          <code>value</code>, and error state automatically.
        </li>
        <li>
          Validation returns <code>[&#123;field, &#123;msg, opts&#125;&#125;, ...]</code>;
          <code>to_form(params, errors: errors)</code> attaches them to the form struct and
          the input components render the inline error text themselves — no per-field
          <code>form_help</code> boilerplate in the template.
        </li>
        <li>
          Clearing the form after a successful submit uses
          <code>push_event("reset-form", %&#123;id: ...&#125;)</code> plus a tiny listener
          in <code>app.js</code> — LiveView preserves typed values across submits on purpose
          so errors don't wipe input, so clearing is an explicit opt-in.
        </li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("State & UX")}</.heading>
      <.basic_list>
        <li>
          Per-browser session id is planted in the cookie by <code>DemoWeb.SessionPlug</code>.
          <code>Demo.FormCache</code> stores submissions in a named ETS table keyed by that id,
          with a sliding 30-minute TTL and a minute-interval sweeper
          (<code>Demo.FormCache.Sweeper</code>) that evicts inactive rows.
        </li>
        <li>
          Flash banners above the form use <code>push_flash(..., replace: true)</code> so the
          next result wipes the previous one instead of stacking.
        </li>
        <li>
          Delete uses the optimistic <em>toast + undo</em> pattern
          (<code>push_toast</code> with <code>actions:</code>). The destructive bulk action
          (<em>Clear All</em>) uses <code>&lt;.popconfirm&gt;</code> because there's no undo.
        </li>
        <li>
          The <em>Submitted</em> column uses <code>PureAdmin.DateTime.relative/2</code>
          (localisable via the <code>pureAdmin.datetime.*</code> translation keys); the full
          timestamp is in the cell's <code>title</code> tooltip.
        </li>
      </.basic_list>
    </.card>
    """
  end
end
