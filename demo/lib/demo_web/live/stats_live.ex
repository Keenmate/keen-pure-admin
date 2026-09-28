defmodule DemoWeb.Live.StatsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Stats")}
  end

  def render(assigns) do
    ~H"""
    <p>Stat and metric display components.</p>

    <.card title_text={gettext("Basic Stats")}>
      <.grid>
        <.column size="25">
          <.stat number="1,234" label_text={gettext("Total Users")} />
        </.column>
        <.column size="25">
          <.stat number="$12,345" label_text={gettext("Revenue")} />
        </.column>
        <.column size="25">
          <.stat number="567" label_text={gettext("Orders")} />
        </.column>
        <.column size="25">
          <.stat number="89%" label_text={gettext("Satisfaction")} />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Stats with Trends")}>
      <.grid>
        <.column size="1-3">
          <.stat
            number="$847,392"
            label_text={gettext("Total Revenue")}
            change_text="+12.5%"
            change_direction="positive"
          />
        </.column>
        <.column size="1-3">
          <.stat
            number="24,583"
            label_text={gettext("Active Users")}
            change_text="-5.2%"
            change_direction="negative"
          />
        </.column>
        <.column size="1-3">
          <.stat number="3.47%" label_text={gettext("Conversion Rate")} change_text="0%" change_direction="neutral" />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Stats with Icons")}>
      <.grid>
        <.column size="25">
          <.stat number="1,234" label_text={gettext("Total Users")}>
            <:icon><i class="fa-solid fa-users"></i></:icon>
          </.stat>
        </.column>
        <.column size="25">
          <.stat number="$45,678" label_text={gettext("Revenue")} icon_variant="success">
            <:icon><i class="fa-solid fa-dollar-sign"></i></:icon>
          </.stat>
        </.column>
        <.column size="25">
          <.stat number="567" label_text={gettext("Orders")} icon_variant="warning">
            <:icon><i class="fa-solid fa-box"></i></:icon>
          </.stat>
        </.column>
        <.column size="25">
          <.stat number="+12%" label_text={gettext("Growth")} change_text="+12%" change_direction="positive" icon_variant="success">
            <:icon><i class="fa-solid fa-chart-line"></i></:icon>
          </.stat>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Hero Stats")}>
      <.grid>
        <.column size="1-3">
          <.stat variant="hero" number="$847,392" label_text={gettext("Total Revenue")}
            change_text="+12.5%" change_direction="positive" />
        </.column>
        <.column size="1-3">
          <.stat variant="hero" number="24,583" label_text={gettext("Active Users")}
            change_text="-5.2%" change_direction="negative" />
        </.column>
        <.column size="1-3">
          <.stat variant="hero-compact" number="3.47%" label_text={gettext("Conversion Rate")}
            change_text="0%" change_direction="neutral" />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("5-step sentiment scale · v2.7.0")}>
      <:description>
        The hero delta scale grew from 3 (<code>positive</code> / <code>negative</code> / <code>neutral</code>) to 5 with the addition of <code>very_positive</code> and <code>very_negative</code> for outlier deltas. Neutral colour shifted from <code>--pc-text-color-2</code> (grey) to <code>--pc-neutral</code>. Compare the five deltas side-by-side below.
      </:description>
      <.grid>
        <.column size="1-5">
          <.stat variant="hero" number="$12.4M" label_text="ARR" change_text="+38.1% breakout" change_direction="very_positive" />
        </.column>
        <.column size="1-5">
          <.stat variant="hero" number="$847K" label_text="MRR" change_text="+12.5%" change_direction="positive" />
        </.column>
        <.column size="1-5">
          <.stat variant="hero" number="148 ms" label_text={gettext("Latency p95")} change_text="±0.7%" change_direction="neutral" />
        </.column>
        <.column size="1-5">
          <.stat variant="hero" number="2.4%" label_text={gettext("Churn")} change_text="-5.2%" change_direction="negative" />
        </.column>
        <.column size="1-5">
          <.stat variant="hero" number="$103K" label_text={gettext("Cloud Spend")} change_text="-38% collapse" change_direction="very_negative" />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Square Stats")}>
      <.grid>
        <.column size="25">
          <.stat variant="square" color="primary" number="42" label_text={gettext("Tasks")} />
        </.column>
        <.column size="25">
          <.stat variant="square" color="success" number="18" label_text={gettext("Completed")} symbol_text="%" />
        </.column>
        <.column size="25">
          <.stat variant="square" color="warning" number="7" label_text={gettext("Pending")} />
        </.column>
        <.column size="25">
          <.stat variant="square" color="danger" number="3" label_text={gettext("Failed")} />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Square stats — mixed units · v2.6.0")}>
      <p>
        v2.6.0 redesigned <code>pa-stat--square</code> so the decorative <code>__symbol</code> watermark sits inline with the big <code>__number</code>. Markup order alone drives visual order — pass <code>is_prefix_symbol</code> to render the symbol BEFORE the number for prefix currencies (<code>$847K</code>, <code>¥12.4M</code>); leave it off for suffix units (<code>87%</code>, <code>23°C</code>). Number font-size scales with the tile width via <code>cqi</code> (container-query inline-size), so a row of squares stays balanced regardless of grid breakpoint.
      </p>
      <.grid>
        <.column size="25">
          <.stat variant="square" color="success" number="87" symbol_text="%" label_text={gettext("Completion")} />
        </.column>
        <.column size="25">
          <.stat variant="square" color="info" number="23" symbol_text="°C" label_text={gettext("Server temp")} />
        </.column>
        <.column size="25">
          <.stat variant="square" color="primary" number="847K" symbol_text="$" label_text="MRR" is_prefix_symbol />
        </.column>
        <.column size="25">
          <.stat variant="square" color="warning" number="12.4M" symbol_text="¥" label_text={gettext("JPY revenue")} is_prefix_symbol />
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Square stats — fit-to-box + progressive disclosure · v2.9.0-rc04")}>
      <p>
        Opt into fit mode with <code>is_fit</code> on a <code>variant="square"</code> stat. It emits
        <code>data-pa-stat-fit</code> and wires the <code>PureAdminStatFit</code> hook
        (<code>pa-stat-fit.js</code>). The primary <code>__number</code> is sized to fill the tile at the
        largest font that still fits — never overflows, independent of character count (a pure-CSS
        <code>cqi</code> clamp can't guarantee that). A priority ladder reveals rows as the tile earns
        <strong>both</strong> width and height:
        <code>__number</code> (P0) → <code>__symbol</code> (P1) → <code>__label</code> (P2) →
        <code>__change</code> (P3) → <code>__context</code> (P4). Fit mode
        <strong>requires a height source</strong> on the tile (each tile below sets an explicit height).
      </p>

      <h4>Priority ladder — same content, growing box</h4>
      <p>
        Watch the tiers appear as each tile gets taller / wider. Smallest shows the number only; the
        largest reveals all five rows. The number always fits and stays maxed.
      </p>
      <.grid>
        <.column size="1-5">
          <.stat
            variant="square"
            color="info"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            context_text="Updated 2 min ago"
            style="height: 6rem;"
          />
        </.column>
        <.column size="1-5">
          <.stat
            variant="square"
            color="info"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            context_text="Updated 2 min ago"
            style="height: 9rem;"
          />
        </.column>
        <.column size="1-5">
          <.stat
            variant="square"
            color="info"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            context_text="Updated 2 min ago"
            style="height: 12rem;"
          />
        </.column>
        <.column size="1-5">
          <.stat
            variant="square"
            color="info"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            context_text="Updated 2 min ago"
            style="height: 15rem;"
          />
        </.column>
        <.column size="1-5">
          <.stat
            variant="square"
            color="info"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            context_text="Updated 2 min ago"
            style="height: 18rem;"
          />
        </.column>
      </.grid>

      <h4>Char-count independence — same box, different numbers</h4>
      <p>
        All four tiles are the same size. Each number fills its box at the max font that fits, whatever the
        character count.
      </p>
      <.grid>
        <.column size="25">
          <.stat variant="square" color="secondary" is_fit number="1" label_text={gettext("Res Version")} style="height: 10rem;" />
        </.column>
        <.column size="25">
          <.stat variant="square" color="secondary" is_fit number="92" label_text={gettext("Contracts")} style="height: 10rem;" />
        </.column>
        <.column size="25">
          <.stat
            variant="square"
            color="secondary"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Revenue")}
            style="height: 10rem;"
          />
        </.column>
        <.column size="25">
          <.stat
            variant="square"
            color="secondary"
            is_fit
            number="12.4M"
            symbol_text="¥"
            is_prefix_symbol
            label_text={gettext("Tokyo Office")}
            style="height: 10rem;"
          />
        </.column>
      </.grid>

      <h4>Wide banner layout (<code>pa-stat--fit-wide</code>)</h4>
      <p>
        Once a fit tile is ≥ 32rem wide, <code>pa-stat-fit.js</code> toggles the
        <code>pa-stat--fit-wide</code> class and the tile flips to a horizontal banner — the number fills
        the left, the metadata stacks in a column to its right. This full-width tile is wide enough to
        trigger it; the narrow one above stacks vertically.
      </p>
      <.grid>
        <.column size="100">
          <.stat
            variant="square"
            color="primary"
            is_fit
            number="847K"
            symbol_text="$"
            is_prefix_symbol
            label_text={gettext("Monthly Revenue")}
            change_text="12.5% vs last month"
            change_direction="positive"
            style="height: 12rem;"
          >
            <:context>Updated 2 min ago · <strong>FY2026 Q2</strong></:context>
          </.stat>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Stat Cards")}>
      <.grid>
        <.column size="25">
          <.card variant="stat">
            <.stat number="87%" label_text={gettext("Completion Rate")}>
              <:icon><i class="fa-solid fa-check-circle"></i></:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="25">
          <.card variant="stat">
            <.stat number="94%" label_text={gettext("Customer Satisfaction")} icon_variant="success">
              <:icon><i class="fa-solid fa-star"></i></:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="25">
          <.card variant="stat">
            <.stat number="62%" label_text={gettext("Market Share")} icon_variant="info">
              <:icon><i class="fa-solid fa-chart-pie"></i></:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="25">
          <.card variant="stat">
            <.stat number="78%" label_text={gettext("Server Capacity")} icon_variant="warning">
              <:icon><i class="fa-solid fa-server"></i></:icon>
            </.stat>
          </.card>
        </.column>
      </.grid>
    </.card>
    """
  end
end
