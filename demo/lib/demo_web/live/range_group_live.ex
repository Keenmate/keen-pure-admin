defmodule DemoWeb.Live.RangeGroupLive do
  @moduledoc """
  Port of `pure-admin/demo/views/range-group.mustache` — built with the
  keen_pure_admin wrappers (`<.range_group>`, `<.range>`, `<.filter_card>`,
  `<.card>`, `<.code_block>`, `<.paragraph>`, `<.heading>`, `<.basic_list>`,
  `<.input_group>`) rather than raw pure-admin markup.

  The `.pa-range` / `.pa-range-group` markup is emitted entirely by the
  `<.range_group>` / `<.range>` wrappers. The only raw glue is a small
  `<script>` that mirrors the upstream demo's event readout — it listens for
  the group's `pa-range-group:change/:apply/:reset` CustomEvents and prints
  the payload into a `<pre>`; that is demo instrumentation, not component
  markup (matching how `splitter_live.ex` uses inline JS for demo-only glue).

  ## Known wrapper gaps (wrapper-consistency sweep)

  * The event-readout `<pre id="range-group-output">` is rendered raw so the
    inline `<script>` can target it by id and mutate its `textContent`.
    `<.code_block>` wraps its body in `<pre><code>` but doesn't expose the
    inner id; a raw `<pre class="pa-code">` is the minimal escape hatch. Not
    a slider-markup gap — the interactive control is 100% wrapper-rendered.
  """
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Range Group",
       ticks_markup: ticks_markup(),
       tokens_markup: tokens_markup(),
       markup_reference: markup_reference()
     )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-4">
      A compact multi-range filter. One toggle summarises several numeric range
      filters inline (<.code>Age / Salary / Children</.code>) and expands into a
      floating panel with one slider per dimension — instead of spreading three
      separate sliders across a filter bar. Each row is dual-thumb (min–max) or
      single-thumb (a <.code>≥</.code> / <.code>≤</.code> threshold), configured
      per-row via slot attributes.
    </.paragraph>

    <%!-- ───────── In a filter bar ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">In a filter bar</.heading></:header>
      <.paragraph class="mb-3">
        The range group drops into a <.code>.pa-filter-card__filters</.code> row
        as a single control standing in for three sliders. Open it, drag, and Apply.
      </.paragraph>

      <.filter_card has_toggle={false} has_clear={false} has_refresh={false}>
        <:filters>
          <.input_group style="flex: 1; min-width: 200px;">
            <:prepend><i class="fas fa-search"></i></:prepend>
            <.input type="text" placeholder="Search people by name" />
          </.input_group>

          <.select prompt="Any department" options={["Engineering", "Sales", "Support"]} />

          <.range_group id="people-filters" panel_aria_label="Numeric filters">
            <:range key="age" label="Age" min={18} max={80} step={1} value_min={25} value_max={60} />
            <:range
              key="salary"
              label="Salary"
              min={0}
              max={200_000}
              step={5000}
              value_min={40_000}
              value_max={200_000}
              prefix="$"
              is_thousands
            />
            <:range
              key="children"
              label="Children"
              min={0}
              max={8}
              step={1}
              mode="single"
              bound="gte"
              value={2}
            />
          </.range_group>
        </:filters>
        <:actions>
          <.button variant="primary" class="pa-btn--icon-only" title="Search">
            <i class="fas fa-search"></i>
          </.button>
        </:actions>
      </.filter_card>

      <.heading level="4" class="mt-4">Emitted values</.heading>
      <.paragraph class="text-secondary mb-2">
        The group dispatches <.code>pa-range-group:change</.code> live and
        <.code>pa-range-group:apply</.code> / <.code>:reset</.code> on the buttons.
        Payload is keyed by <.code>data-key</.code>; a bound at its extent reports
        <.code>null</.code> (i.e. "Any").
      </.paragraph>
      <pre class="pa-code pa-code--compact" id="range-group-output"><code>// interact with the filter above…</code></pre>
    </.card>

    <%!-- ───────── Single-thumb thresholds ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">Single-thumb thresholds</.heading></:header>
      <.paragraph class="mb-3">
        Set <.code>mode="single"</.code> for a one-handle threshold.
        <.code>bound="gte"</.code> reads as "<.code>value+</.code>",
        <.code>bound="lte"</.code> as "<.code>≤ value</.code>".
      </.paragraph>

      <.range_group id="threshold-filters" panel_aria_label="Threshold filters">
        <:range
          key="rating"
          label="Rating"
          row_label="Min rating"
          min={0}
          max={5}
          step={0.5}
          mode="single"
          bound="gte"
          value={4}
          suffix="★"
        />
        <:range
          key="distance"
          label="Distance"
          row_label="Max distance"
          min={1}
          max={50}
          step={1}
          mode="single"
          bound="lte"
          value={20}
          suffix=" km"
        />
      </.range_group>
    </.card>

    <%!-- ───────── Handle shapes ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">Handle shapes</.heading></:header>
      <.paragraph class="mb-3">
        Add a <.code>handle</.code> attr to any row to restyle its handles.
        Purely cosmetic (no JS), so you can mix shapes per row —
        <.code>circle</.code> (default), <.code>rect</.code>, <.code>bar</.code>,
        <.code>arrow</.code>, and <.code>needle</.code>.
      </.paragraph>

      <.range_group id="handle-shapes" panel_aria_label="Handle shapes">
        <:range key="circle" label="Circle" min={0} max={100} value_min={20} value_max={70} />
        <:range
          key="rect"
          label="Rectangle"
          row_label="Rectangle handle-rect"
          min={0}
          max={100}
          value_min={20}
          value_max={70}
          handle="rect"
        />
        <:range
          key="bar"
          label="Bar"
          row_label="Bar handle-bar"
          min={0}
          max={100}
          value_min={20}
          value_max={70}
          handle="bar"
        />
        <:range
          key="arrow"
          label="Chevron"
          row_label="Chevron handle-arrow"
          min={0}
          max={100}
          value_min={20}
          value_max={70}
          handle="arrow"
        />
        <:range
          key="needle"
          label="Needle"
          row_label="Needle handle-needle"
          min={0}
          max={100}
          value_min={20}
          value_max={70}
          handle="needle"
        />
      </.range_group>
    </.card>

    <%!-- ───────── Ticks & click-to-seek ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">Ticks &amp; click-to-seek</.heading></:header>
      <.paragraph class="mb-3">
        Add <.code>ticks</.code> (major interval) and optionally
        <.code>ticks_minor</.code> to draw tick marks; add <.code>is_tick_labels</.code>
        to print the major values beneath. Every track is <strong>click-to-seek</strong>:
        press anywhere off the handles and the nearest thumb jumps there. Add
        <.code>is_snap_ticks</.code> to make the thumbs settle on the nearest tick —
        drag the <em>Level</em> row and it snaps to 0, 10, 20…
      </.paragraph>

      <.range_group id="ticked-filters" panel_aria_label="Ticked filters">
        <:range
          key="age"
          label="Age"
          row_label="Age ticks=20 minor=10 labels"
          min={0}
          max={80}
          step={1}
          value_min={25}
          value_max={60}
          ticks={20}
          ticks_minor={10}
          is_tick_labels
        />
        <:range
          key="score"
          label="Score"
          row_label="Score ticks=25"
          min={0}
          max={100}
          step={5}
          value_min={40}
          value_max={90}
          ticks={25}
        />
        <:range
          key="level"
          label="Level"
          row_label="Level ticks=10 snap-ticks"
          min={0}
          max={100}
          step={1}
          value_min={20}
          value_max={80}
          ticks={10}
          is_tick_labels
          is_snap_ticks
        />
        <:range
          key="rating"
          label="Rating"
          row_label="Min rating single + labels"
          min={0}
          max={5}
          step={0.5}
          mode="single"
          bound="gte"
          value={3}
          suffix="★"
          ticks={1}
          is_tick_labels
        />
      </.range_group>

      <.code_block language="html" class="mt-3">{@ticks_markup}</.code_block>
    </.card>

    <%!-- ───────── Theming tokens ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">Theming with <.code>--pa-range-*</.code> tokens</.heading>
      </:header>
      <.paragraph class="mb-3">
        Every colour and key dimension is a runtime token, so a theme or a
        per-instance <.code>panel_style</.code> can retint/resize a slider with no
        recompile. This group overrides the fill, thumb, track thickness, and handle
        size — set via <.code>panel_style</.code> (the panel reparents to
        <.code>&lt;body&gt;</.code> when open, so tokens on the group root wouldn't
        reach the sliders).
      </.paragraph>

      <.range_group
        id="themed-filters"
        panel_aria_label="Themed filters"
        panel_style={"--pa-range-fill: #8b5cf6; --pa-range-thumb-border: #8b5cf6;" <>
          " --pa-range-thumb-border-hover: #7c3aed; --pa-range-focus-ring: rgba(139, 92, 246, 0.35);" <>
          " --pa-range-track-height: 0.8rem; --pa-range-thumb-size: 2rem;"}
      >
        <:range
          key="budget"
          label="Budget"
          min={0}
          max={5000}
          step={50}
          value_min={1000}
          value_max={3500}
          prefix="$"
          is_thousands
        />
        <:range
          key="guests"
          label="Guests"
          min={1}
          max={12}
          step={1}
          mode="single"
          bound="gte"
          value={4}
          handle="bar"
        />
      </.range_group>

      <.code_block language="heex" class="mt-3">{@tokens_markup}</.code_block>
    </.card>

    <%!-- ───────── Markup reference ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">Markup</.heading></:header>
      <.paragraph class="mb-3">
        One <.code>:range</.code> slot per dimension. Positioning is driven in
        0–100% via CSS custom properties on logical inset properties, so RTL
        mirrors automatically.
      </.paragraph>
      <.code_block language="heex">{@markup_reference}</.code_block>
    </.card>

    <script>
      (function () {
        function wire() {
          var out = document.getElementById('range-group-output');
          var group = document.getElementById('people-filters');
          if (!out || !group || group.__rgWired) return;
          group.__rgWired = true;
          function log(type, e) {
            out.querySelector('code').textContent =
              type + '  →  ' + JSON.stringify(e.detail.values, null, 2);
          }
          group.addEventListener('pa-range-group:change', function (e) { log('change', e); });
          group.addEventListener('pa-range-group:apply',  function (e) { log('apply ', e); });
          group.addEventListener('pa-range-group:reset',  function (e) { log('reset ', e); });
        }
        wire();
        window.addEventListener('phx:page-loading-stop', wire);
      })();
    </script>
    """
  end

  # ── Static reference snippets ───────────────────────────────────────────────

  defp ticks_markup do
    ~s|<.range key="age" label="Age"
        min={0} max={80}
        ticks={20} ticks_minor={10} is_tick_labels />|
  end

  defp tokens_markup do
    ~s|<.range_group
  id="themed-filters"
  panel_style="--pa-range-fill: #8b5cf6;
               --pa-range-thumb-border: #8b5cf6;
               --pa-range-track-height: 0.8rem;
               --pa-range-thumb-size: 2rem;"
>
  <:range key="budget" label="Budget"
          min={0} max={5000} step={50}
          value_min={1000} value_max={3500}
          prefix="$" is_thousands />
</.range_group>|
  end

  defp markup_reference do
    ~s|<.range_group id="my-filters">
  <:range key="age" label="Age"
          min={18} max={80}
          value_min={25} value_max={60} />
  <:range key="salary" label="Salary"
          min={0} max={200_000} step={5000}
          value_min={40_000} value_max={200_000}
          prefix="$" is_thousands />
  <:range key="children" label="Children"
          min={0} max={8}
          mode="single" bound="gte" value={2} />
</.range_group>|
  end
end
