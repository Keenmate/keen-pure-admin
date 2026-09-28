defmodule DemoWeb.Live.TimelineBlockLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Timeline Block")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Centered timeline with items alternating start and end - great for storytelling</.paragraph>

    <%!-- Two examples side by side --%>
    <.grid>
      <.column size="50">
        <.card title_text={gettext("Timeline Block")}>
          <:description>{gettext("Centered alternating layout")}</:description>
          <.timeline variant="alternating">
            <.timeline_item time_text="15 Dec" icon_text="🏠">
              <:title>Project Started</:title>
              New project "Pure Admin Dashboard" has been initialized with base configuration and team setup.
            </.timeline_item>
            <.timeline_item time_text="22 Oct" icon_text="🎁">
              <:title>First Release</:title>
              Version 1.0 released to production with core features and documentation.
            </.timeline_item>
            <.timeline_item time_text="10 Jul" icon_text="👤">
              <:title>Team Expansion</:title>
              Added three new developers to the team to accelerate development.
            </.timeline_item>
            <.timeline_item time_text="18 May" icon_text="🏃">
              <:title>Sprint Milestone</:title>
              Completed major refactoring sprint, improving code quality and performance.
            </.timeline_item>
            <.timeline_item time_text="10 Feb" icon_text="⚙️">
              <:title>System Upgrade</:title>
              Migrated to new infrastructure with improved scalability and reliability.
            </.timeline_item>
            <.timeline_item time_text="01 Jan" icon_text="🏆">
              <:title>Award Recognition</:title>
              Received "Best Admin Framework" award from the developer community.
            </.timeline_item>
          </.timeline>
        </.card>
      </.column>
      <.column size="50">
        <.card title_text={gettext("Timeline Block")}>
          <:description>{gettext("Another example with different content")}</:description>
          <.timeline variant="alternating">
            <.timeline_item time_text="Q1 2024" icon_text="📋">
              <:title>Planning Phase</:title>
              Strategic planning and goal setting for the year ahead.
            </.timeline_item>
            <.timeline_item time_text="Q2 2024" icon_text="🚀">
              <:title>Launch Preparation</:title>
              Final testing and deployment preparation phase.
            </.timeline_item>
            <.timeline_item time_text="Q3 2024" icon_text="📈">
              <:title>Growth Period</:title>
              User acquisition and feature expansion phase.
            </.timeline_item>
            <.timeline_item time_text="Q4 2024" icon_text="🎯">
              <:title>Optimization</:title>
              Performance improvements and user feedback implementation.
            </.timeline_item>
          </.timeline>
        </.card>
      </.column>
    </.grid>

    <%!-- Layout Modifiers --%>
    <.section title_text={gettext("Layout Modifiers")}>
      <.grid>
        <.column size="1-3">
          <.card title_text={gettext("Start Aligned")}>
            <:description>{gettext("All items on start side")}</:description>
            <.timeline variant="alternating" align="start">
              <.timeline_item time_text="Jan" icon_text="💡">
                <:title>Idea</:title>
                Initial concept and brainstorming.
              </.timeline_item>
              <.timeline_item time_text="Feb" icon_text="🔧">
                <:title>Build</:title>
                Development and implementation.
              </.timeline_item>
              <.timeline_item time_text="Mar" icon_text="🚀">
                <:title>Launch</:title>
                Product release and deployment.
              </.timeline_item>
            </.timeline>
          </.card>
        </.column>
        <.column size="1-3">
          <.card title_text={gettext("End Aligned")}>
            <:description>{gettext("All items on end side")}</:description>
            <.timeline variant="alternating" align="end">
              <.timeline_item time_text="Jan" icon_text="💡">
                <:title>Idea</:title>
                Initial concept and brainstorming.
              </.timeline_item>
              <.timeline_item time_text="Feb" icon_text="🔧">
                <:title>Build</:title>
                Development and implementation.
              </.timeline_item>
              <.timeline_item time_text="Mar" icon_text="🚀">
                <:title>Launch</:title>
                Product release and deployment.
              </.timeline_item>
            </.timeline>
          </.card>
        </.column>
        <.column size="1-3">
          <.card title_text={gettext("Keep Layout")}>
            <:description>{gettext("No mobile collapse")}</:description>
            <.timeline variant="alternating" is_keep_layout>
              <.timeline_item time_text="Jan" icon_text="💡">
                <:title>Idea</:title>
                Initial concept and brainstorming.
              </.timeline_item>
              <.timeline_item time_text="Feb" icon_text="🔧">
                <:title>Build</:title>
                Development and implementation.
              </.timeline_item>
              <.timeline_item time_text="Mar" icon_text="🚀">
                <:title>Launch</:title>
                Layout maintained at all widths.
              </.timeline_item>
            </.timeline>
          </.card>
        </.column>
      </.grid>

      <.grid>
        <.column size="50">
          <.card title_text={gettext("Start + Keep Layout")}>
            <:description>{gettext("Start-aligned, stays start on mobile")}</:description>
            <.timeline variant="alternating" align="start" is_keep_layout>
              <.timeline_item time_text="Step 1" icon_text="📋">
                <:title>Plan</:title>
                Define objectives and milestones.
              </.timeline_item>
              <.timeline_item time_text="Step 2" icon_text="🔧">
                <:title>Execute</:title>
                Implement the plan with the team.
              </.timeline_item>
              <.timeline_item time_text="Step 3" icon_text="✅">
                <:title>Review</:title>
                Evaluate results and iterate.
              </.timeline_item>
            </.timeline>
          </.card>
        </.column>
        <.column size="50">
          <.card title_text={gettext("End + Keep Layout")}>
            <:description>{gettext("End-aligned, stays end on mobile")}</:description>
            <.timeline variant="alternating" align="end" is_keep_layout>
              <.timeline_item time_text="Step 1" icon_text="📋">
                <:title>Plan</:title>
                Define objectives and milestones.
              </.timeline_item>
              <.timeline_item time_text="Step 2" icon_text="🔧">
                <:title>Execute</:title>
                Implement the plan with the team.
              </.timeline_item>
              <.timeline_item time_text="Step 3" icon_text="✅">
                <:title>Review</:title>
                Evaluate results and iterate.
              </.timeline_item>
            </.timeline>
          </.card>
        </.column>
      </.grid>
    </.section>
    """
  end
end
