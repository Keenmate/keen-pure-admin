defmodule DemoWeb.Live.TimelineLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Timeline")}
  end

  def render(assigns) do
    ~H"""
    <p>Timeline components for displaying chronological events.</p>

    <.card title_text={gettext("Project Timeline")}>
      <.timeline>
        <.timeline_item variant="success">
          <:title>Project Started</:title>
          <:meta>January 15, 2024</:meta>
          The project was officially kicked off with the initial planning meeting.
        </.timeline_item>
        <.timeline_item variant="info">
          <:title>Design Phase Complete</:title>
          <:meta>February 28, 2024</:meta>
          All wireframes and mockups have been approved by stakeholders.
        </.timeline_item>
        <.timeline_item variant="warning">
          <:title>Development In Progress</:title>
          <:meta>March 15, 2024</:meta>
          Frontend and backend development is underway. Currently at 60% completion.
        </.timeline_item>
        <.timeline_item variant="primary">
          <:title>Testing Phase</:title>
          <:meta>April 1, 2024</:meta>
          QA testing has begun. Bug fixes are being addressed as they are found.
        </.timeline_item>
        <.timeline_item>
          <:title>Launch</:title>
          <:meta>May 1, 2024 (Planned)</:meta>
          Target launch date for the production release.
        </.timeline_item>
      </.timeline>
    </.card>

    <.card title_text={gettext("Activity Feed")}>
      <.timeline>
        <.timeline_item variant="success">
          <:title>Sarah Johnson</:title>
          <:meta>2 hours ago</:meta>
          Completed code review for PR #234 — "Add user authentication module"
        </.timeline_item>
        <.timeline_item variant="info">
          <:title>Mike Chen</:title>
          <:meta>4 hours ago</:meta>
          Deployed version 2.3.1 to staging environment
        </.timeline_item>
        <.timeline_item variant="danger">
          <:title>System Alert</:title>
          <:meta>6 hours ago</:meta>
          Database connection pool reached 90% capacity. Auto-scaling triggered.
        </.timeline_item>
        <.timeline_item variant="warning">
          <:title>Emma Wilson</:title>
          <:meta>Yesterday</:meta>
          Updated project dependencies. 3 packages updated, 1 security patch applied.
        </.timeline_item>
      </.timeline>
    </.card>
    """
  end
end
