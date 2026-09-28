defmodule DemoWeb.Live.TimelineSimpleLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Simple Timeline")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Start-aligned timeline with dot markers - perfect for logs and simple event lists</.paragraph>

    <%!-- Color-Coded Events --%>
    <.card title_text={gettext("Color-Coded Events")}>
      <:description>{gettext("Use color modifiers to categorize different event types")}</:description>
      <.timeline variant="simple">
        <.timeline_item variant="primary" time_text="09:00 AM">
          System startup initialized
        </.timeline_item>
        <.timeline_item variant="success" time_text="09:05 AM">
          Database connection established successfully
        </.timeline_item>
        <.timeline_item variant="info" time_text="09:30 AM">
          Loading user preferences and settings
        </.timeline_item>
        <.timeline_item variant="warning" time_text="01:00 PM">
          High memory usage detected - 85% utilized
        </.timeline_item>
        <.timeline_item variant="success" time_text="01:30 PM">
          Cache cleared successfully - memory optimized
        </.timeline_item>
        <.timeline_item variant="primary" time_text="03:30 PM">
          Backup process started automatically
        </.timeline_item>
        <.timeline_item variant="success" time_text="04:30 PM">
          Backup completed - 2.4GB archived
        </.timeline_item>
        <.timeline_item variant="danger" time_text="07:00 PM">
          Critical error: Failed to connect to external API
        </.timeline_item>
        <.timeline_item variant="warning" time_text="07:30 PM">
          Retrying connection with exponential backoff
        </.timeline_item>
        <.timeline_item variant="success" time_text="08:00 PM">
          Connection restored - all systems operational
        </.timeline_item>
      </.timeline>
    </.card>

    <%!-- Filled Bullets --%>
    <.card title_text={gettext("Filled Bullets")}>
      <:description>{gettext("Solid bullet markers for stronger visual emphasis")}</:description>
      <.timeline variant="simple">
        <.timeline_item variant="primary" is_filled time_text="Jan 2024">
          Project kickoff and team formation
        </.timeline_item>
        <.timeline_item variant="info" is_filled time_text="Feb 2024">
          Requirements gathering and analysis phase
        </.timeline_item>
        <.timeline_item variant="success" is_filled time_text="Mar 2024">
          Design mockups approved by stakeholders
        </.timeline_item>
        <.timeline_item variant="primary" is_filled time_text="Apr 2024">
          Development sprint 1 completed
        </.timeline_item>
        <.timeline_item variant="warning" is_filled time_text="May 2024">
          Performance issues identified in testing
        </.timeline_item>
        <.timeline_item variant="success" is_filled time_text="Jun 2024">
          Optimization complete - ready for deployment
        </.timeline_item>
      </.timeline>
    </.card>
    """
  end
end
