defmodule DemoWeb.Live.KpiNumericStripLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-numeric-strip.mustache`.
  # Canonical 5-col card + 4-col variants (no_previous_value /
  # no_delta_percent / no_target_bar) + 3-col double-drop + 2-col triple-drop
  # + Usage Guide + CSS Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Numeric strip")}
  end

  defp rows do
    [
      %{id: "revenue", metric_text: gettext("REVENUE"), prefix_text: "$", value_text: "847K", previous_value_text: "$748K", delta_text: "▲ 13.3%", delta_variant: "positive", target_bar_percent: 94, target_percent_text: "94%",
        detail_title_text: "Revenue · WTD", target_text: "$900K", delta_absolute_text: "+$99K", delta_absolute_sentiment: :pos},
      %{id: "arpu", metric_text: gettext("ARPU"), prefix_text: "$", value_text: "34.20", previous_value_text: "$31.80", delta_text: "▲ 7.5%", delta_variant: "positive", target_bar_percent: 97, target_percent_text: "97%"},
      %{id: "active-users", metric_text: gettext("ACTIVE USERS"), value_text: "12.3K", previous_value_text: "11.8K", delta_text: "▲ 4.1%", delta_variant: "positive", target_bar_percent: 108, target_percent_text: "108%"},
      %{id: "error", metric_text: gettext("ERROR RATE"), value_text: "0.18%", previous_value_text: "0.41%", delta_text: "▼ 56%", delta_variant: "up_strong", target_bar_percent: 36, target_percent_text: "36%"},
      %{id: "latency", metric_text: gettext("LATENCY p95"), value_text: "148 ms", previous_value_text: "147 ms", delta_text: "▲ 0.7%", delta_variant: "neutral", target_bar_percent: 74, target_percent_text: "74%"},
      %{id: "churn", metric_text: gettext("CHURN"), value_text: "2.4%", previous_value_text: "2.1%", delta_text: "▲ 14%", delta_variant: "negative", target_bar_percent: 120, target_percent_text: "120%"}
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Tabular spreadsheet-style table card — most data per pixel, no chart chrome. Optional columns
      (previous / Δ% / target bar) drop in independently via the matching
      <code>no_previous_value</code> / <code>no_delta_percent</code> / <code>no_target_bar</code>
      toggles. Wide-only by design — for narrow placements, use Comparison gauges instead.
    </.paragraph>

    <%!-- 1. Canonical 5-col --%>

    <.kpi_strip title_text={gettext("Weekly review · 5-col (default)")} is_live footer_text="Default 5-col layout — metric · now · prev · Δ% · target">
      <.strip_row :for={r <- rows()} {row_assigns(r, "def-")} />
    </.kpi_strip>

    <br />

    <%!-- 2. --no-prev (4-col) --%>

    <h3><code>no_previous_value</code> — 4-col (metric · now · Δ% · target)</h3>
    <p>Drop the prev column when there's no room for prev + now side-by-side, or when prev isn't material.</p>

    <.kpi_strip title_text={gettext("Operational metrics")} no_previous_value>
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "np-")} />
    </.kpi_strip>

    <br />

    <%!-- 3. --no-delta (4-col) --%>

    <h3><code>no_delta_percent</code> — 4-col (metric · now · prev · target)</h3>
    <p>Useful when the prev column is already the comparison and an extra Δ% column would be redundant.</p>

    <.kpi_strip title_text={gettext("Snapshot")} no_delta_percent>
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "nd-")} />
    </.kpi_strip>

    <br />

    <%!-- 4. --no-target (4-col) --%>

    <h3><code>no_target_bar</code> — 4-col (metric · now · prev · Δ%)</h3>
    <p>For pages without target bookkeeping — pure metric history.</p>

    <.kpi_strip title_text={gettext("Live numbers")} no_target_bar>
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "nt-")} />
    </.kpi_strip>

    <br />

    <%!-- 5. Double-drop (3-col) --%>

    <h3>Double-drop · <code>no_previous_value</code> + <code>no_target_bar</code> — 3-col (metric · now · Δ%)</h3>

    <.kpi_strip title_text={gettext("Trend strip")} no_previous_value no_target_bar>
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "dd-")} />
    </.kpi_strip>

    <br />

    <%!-- 6. Triple-drop (2-col) --%>

    <h3>Triple-drop · 2-col (metric · now only)</h3>
    <p>Strip becomes a label-value list. For overview pages where context is provided elsewhere.</p>

    <.kpi_strip title_text={gettext("Minimal")} no_previous_value no_delta_percent no_target_bar>
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "td-")} />
    </.kpi_strip>

    <br />

    <%!-- 7. Custom header labels --%>

    <h3>Custom <code>header_labels</code></h3>
    <p>The auto-header is generated from visible columns; override individual labels via the <code>header_labels</code> map keyed by column atom.</p>

    <.kpi_strip
      title_text={gettext("Localized headers")}
      header_labels={%{metric: "Метрика", now: "Сейчас", previous_value: "Раньше", delta_percent: "Δ%", target_bar: "vs цель"}}
    >
      <.strip_row :for={r <- Enum.take(rows(), 4)} {row_assigns(r, "loc-")} />
    </.kpi_strip>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text={gettext("Usage Guide")}>
      <h4>When to use</h4>
      <p>
        Densest layout in the KPI family. Best for analyst pages, weekly review reports, internal
        dashboards where the user already understands each metric and just wants to scan the numbers.
        For interactive trend-first reads, use Sparkline list or Terminal grid.
      </p>

      <h4 class="mt-4">Composable column toggles</h4>
      <p>
        <code>metric</code> and <code>now</code> are always present. <code>previous_value</code>,
        <code>delta_percent</code>, and <code>target_bar</code> drop independently via
        <code>no_previous_value</code> / <code>no_delta_percent</code> / <code>no_target_bar</code>.
        Toggles compose — 8 combinations covered by separate <code>grid-template-columns</code>
        selectors so the visible cell count always matches the grid tracks.
      </p>

      <h4 class="mt-4">Target bar semantics</h4>
      <p>
        Bar fill width = <code>target_bar_percent</code> capped at 100% visually. The percent label
        below (<code>target_percent_text</code>) may exceed 100 — overshoots are signalled by the label,
        not by overflowing the bar. Theme-neutral grey fill because the pct value itself carries
        sentiment.
      </p>

      <h4 class="mt-4">Auto-generated header row</h4>
      <p>
        The header is built from the visible columns in source order, with default English labels.
        Override individual labels via <code>header_labels</code> (map keyed by column atom),
        suppress entirely via <code>no_header</code>, or replace via the <code>:head</code> slot.
        The auto-header is the recommended path — keeps the visible-column logic in one place.
      </p>

      <h4 class="mt-4">Wide-only by design</h4>
      <p>
        No <code>@container</code> queries — narrow placements should route to Comparison gauges
        instead, which converges at small widths to a similar metric-bar-pct layout. Lets each design
        keep a single canonical shape.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text={gettext("CSS Classes Reference")}>
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-strip</code> — page-namespace class on <code>.pa-card</code>.</li>
        <li><code>pa-kpi-strip__body</code> — <code>padding: 0</code> so dividers reach the card edges.</li>
        <li><code>pa-kpi-strip--no-prev</code> / <code>--no-delta</code> / <code>--no-target</code> — independently composable column toggles.</li>
      </ul>

      <h4 class="mt-4">Header</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-strip__head-row</code> — header row.</li>
        <li><code>pa-kpi-strip__head</code> — header cell.</li>
        <li><code>pa-kpi-strip__head--num</code> — right-align modifier for numeric columns (now / prev / Δ%).</li>
      </ul>

      <h4 class="mt-4">Data row + cells</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-strip__row</code> — single data row.</li>
        <li><code>pa-kpi-strip__metric</code> / <code>__now</code> / <code>__prev</code> / <code>__delta</code> / <code>__target</code> — cell elements.</li>
        <li><code>pa-kpi-strip__num</code> / <code>__unit</code> — value spans inside <code>__now</code>.</li>
        <li><code>pa-kpi-strip__delta--positive</code> / <code>--negative</code> / <code>--neutral</code> / <code>--up-strong</code> / <code>--down-strong</code> — delta sentiment.</li>
        <li><code>pa-kpi-strip__bar</code> / <code>__fill</code> — target bar (theme-neutral grey).</li>
        <li><code>pa-kpi-strip__bar-pct</code> — percent label below the bar (may exceed 100%).</li>
      </ul>
    </.card>
    """
  end

  defp row_assigns(r, id_prefix), do: Map.merge(r, %{id: id_prefix <> r.id})

  attr(:id, :string, required: true)
  attr(:metric_text, :string, required: true)
  attr(:value_text, :string, required: true)
  attr(:prefix_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil)
  attr(:target_bar_percent, :integer, default: nil)
  attr(:target_percent_text, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil)

  defp strip_row(assigns) do
    ~H"""
    <.kpi_strip_row
      id={@id}
      metric_text={@metric_text}
      value_text={@value_text}
      prefix_text={@prefix_text}
      previous_value_text={@previous_value_text}
      delta_text={@delta_text}
      delta_variant={@delta_variant}
      target_bar_percent={@target_bar_percent}
      target_percent_text={@target_percent_text}
      detail_title_text={@detail_title_text}
      target_text={@target_text}
      delta_absolute_text={@delta_absolute_text}
      delta_absolute_sentiment={@delta_absolute_sentiment}
    />
    """
  end
end
