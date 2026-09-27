defmodule PureAdmin.Components.DataViz do
  @moduledoc """
  Data visualization components for Pure Admin.

  CSS-only visualizations: progress bars, stacked bars, progress rings,
  gauges, data bars, heatmaps, sparklines.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # -- progress/1 --

  @doc """
  Renders a progress bar.

  ## Examples

      <.progress value={65} />
      <.progress value={89} variant="success" size="lg" is_striped is_animated />
  """
  attr(:value, :integer, default: 0, doc: "Progress percentage (0-100)")
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info"])
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg"])
  attr(:is_striped, :boolean, default: false)
  attr(:is_animated, :boolean, default: false)
  attr(:is_rounded, :boolean, default: false, doc: "Pill shape")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def progress(assigns) do
    ~H"""
    <div class={build_classes("pa-progress", [
      {"pa-progress--#{@variant}", @variant not in [nil, "primary"]},
      {"pa-progress--#{@size}", @size != nil},
      {"pa-progress--striped", @is_striped},
      {"pa-progress--animated", @is_animated},
      {"pa-progress--rounded", @is_rounded}
    ], @class)} {@rest}>
      <div class="pa-progress__fill" style={"--value: #{@value}%"}></div>
    </div>
    """
  end

  # -- progress_group/1 --

  @doc """
  Renders a labeled progress bar.

  ## Examples

      <.progress_group label="Storage Used" value={65} />
      <.progress_group label="Upload" value={89} variant="success" />
  """
  attr(:label, :string, required: true)
  attr(:value, :integer, required: true)
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info"])
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg"])
  attr(:is_striped, :boolean, default: false)
  attr(:is_animated, :boolean, default: false)
  attr(:is_rounded, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def progress_group(assigns) do
    ~H"""
    <div class={build_classes("pa-progress-group", [], @class)} {@rest}>
      <div class="pa-progress__label">
        <span><%= @label %></span>
        <span class="pa-progress__label-value"><%= @value %>%</span>
      </div>
      <.progress value={@value} variant={@variant} size={@size} is_striped={@is_striped} is_animated={@is_animated} is_rounded={@is_rounded} />
    </div>
    """
  end

  # -- stacked_bar/1 --

  @doc """
  Renders a stacked bar with multiple segments.

  ## Examples

      <.stacked_bar>
        <.stacked_segment value={35} />
        <.stacked_segment value={25} variant="success" />
      </.stacked_bar>
  """
  attr(:size, :string, default: nil, values: [nil, "lg"])
  attr(:is_rounded, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def stacked_bar(assigns) do
    ~H"""
    <div class={build_classes("pa-stacked-bar", [
      {"pa-stacked-bar--#{@size}", @size != nil},
      {"pa-stacked-bar--rounded", @is_rounded}
    ], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a segment in a stacked bar."
  attr(:value, :integer, required: true, doc: "Percentage width")
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info", "secondary"])

  def stacked_segment(assigns) do
    ~H"""
    <div class={build_classes("pa-stacked-bar__segment", [{"pa-stacked-bar__segment--#{@variant}", @variant not in [nil, "primary"]}])} style={"--value: #{@value}%"}></div>
    """
  end

  # -- stacked_bar_legend/1 --

  @doc "Renders a legend for stacked bars."
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def stacked_bar_legend(assigns) do
    ~H"""
    <div class={build_classes("pa-stacked-bar__legend", [], @class)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a legend item."
  attr(:label, :string, required: true)
  attr(:variant, :string, default: "primary", values: ["primary", "success", "warning", "danger", "info", "secondary"])

  def stacked_legend_item(assigns) do
    ~H"""
    <div class="pa-stacked-bar__legend-item">
      <span class={"pa-stacked-bar__legend-swatch pa-stacked-bar__legend-swatch--#{@variant}"}></span>
      <%= @label %>
    </div>
    """
  end

  # -- progress_ring/1 --

  @doc """
  Renders a circular progress ring.

  ## Examples

      <.progress_ring value={72} label="CPU" />
      <.progress_ring value={94} label="Uptime" variant="success" size="lg" />
  """
  attr(:value, :integer, required: true, doc: "0-100")
  attr(:label, :string, default: nil)
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info"])
  attr(:size, :string, default: nil, values: [nil, "sm", "lg"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def progress_ring(assigns) do
    ~H"""
    <div class={build_classes("pa-progress-ring", [
      {"pa-progress-ring--#{@variant}", @variant not in [nil, "primary"]},
      {"pa-progress-ring--#{@size}", @size != nil}
    ], @class)} style={"--value: #{@value}"} {@rest}>
      <div class="pa-progress-ring__inner">
        <span class="pa-progress-ring__value"><%= @value %>%</span>
        <span :if={@label} class="pa-progress-ring__label"><%= @label %></span>
      </div>
    </div>
    """
  end

  # -- gauge/1 --

  @doc """
  Renders a semi-circle dashboard gauge.

  Tracks `_data-viz.scss` v2.7.0+: the gauge was rebuilt as a true ring with
  a transparent centre. The label now sits in a sibling row below the
  gauge (`__min · __label · __max`) — the `__inner` holds only the value.

  Set `:size` (CSS length) to scale the entire gauge via `--pa-gauge-size`
  (default upstream `12rem`). Text inside the donut doesn't auto-scale —
  if you go much smaller / larger, override `font-size` on `.pa-gauge__value`
  in your own stylesheet.

  ## Examples

      <.gauge value={72} label="CPU" />
      <.gauge value={45} label="Memory" variant="success" min="0" max="32 GB" />
      <.gauge value={88} label="Throughput" size="16rem" variant="info" />
  """
  attr(:value, :integer, required: true, doc: "0-100")
  attr(:value_text, :string, default: nil, doc: "Custom value display text")
  attr(:label, :string, default: nil)
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info"])
  attr(:is_zones, :boolean, default: false, doc: "Zone-coloured gauge (multi-zone fill)")
  attr(:size, :string, default: nil, doc: "CSS length for `--pa-gauge-size` (default upstream `12rem`)")
  attr(:min, :string, default: "0")
  attr(:max, :string, default: "100")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def gauge(assigns) do
    value_text = assigns.value_text || "#{assigns.value}%"
    assigns = assign(assigns, :display_value, value_text)

    ~H"""
    <div class="text-center">
      <div class={build_classes("pa-gauge", [
        {"pa-gauge--#{@variant}", @variant not in [nil, "primary"]},
        {"pa-gauge--zones", @is_zones}
      ], @class)} style={gauge_style(@value, @size)} {@rest}>
        <div class="pa-gauge__inner">
          <span class="pa-gauge__value"><%= @display_value %></span>
        </div>
        <span class="pa-gauge__min"><%= @min %></span>
        <span :if={@label} class="pa-gauge__label"><%= @label %></span>
        <span class="pa-gauge__max"><%= @max %></span>
      </div>
    </div>
    """
  end

  defp gauge_style(value, nil), do: "--value: #{value}"
  defp gauge_style(value, size), do: "--value: #{value}; --pa-gauge-size: #{size};"

  # -- data_bar/1 --

  @doc """
  Renders an inline data bar for table cells.

  ## Examples

      <.data_bar value={95} variant="success" />
  """
  attr(:value, :integer, required: true, doc: "Percentage (0-100)")
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info", "negative"])
  attr(:class, :string, default: nil)

  def data_bar(assigns) do
    ~H"""
    <div class={build_classes("pa-data-bar", [{"pa-data-bar--#{@variant}", @variant not in [nil, "primary"]}], @class)}>
      <div class="pa-data-bar__track">
        <div class="pa-data-bar__fill" style={"--value: #{@value}%"}></div>
      </div>
    </div>
    """
  end

  # -- heatmap/1 --

  @doc """
  Renders an activity heatmap grid.

  ## Examples

      <.heatmap columns={12} levels={[0,1,2,3,4,2,0, 1,3,4,2,1,3,4]} />
  """
  attr(:columns, :integer, required: true, doc: "Number of columns in grid")
  attr(:levels, :list, required: true, doc: "List of level values (0-4)")
  attr(:variant, :string, default: nil, values: [nil, "success", "danger"], doc: "Core only styles success/danger cell ramps")
  attr(:is_compact, :boolean, default: false, doc: "Denser cells (pa-heatmap--compact)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def heatmap(assigns) do
    ~H"""
    <div class={build_classes("pa-heatmap", [
      {"pa-heatmap--#{@variant}", @variant != nil},
      {"pa-heatmap--compact", @is_compact}
    ], @class)}
         style={"grid-template-columns: repeat(#{@columns}, 1.2rem)"} {@rest}>
      <%= for level <- @levels do %>
        <div class="pa-heatmap__cell" data-level={level}></div>
      <% end %>
    </div>
    """
  end

  @doc "Renders a heatmap legend."
  def heatmap_legend(assigns) do
    ~H"""
    <div class="pa-heatmap__legend">
      <span>Less</span>
      <div class="pa-heatmap__legend-cell" data-level="0"></div>
      <div class="pa-heatmap__legend-cell" data-level="1"></div>
      <div class="pa-heatmap__legend-cell" data-level="2"></div>
      <div class="pa-heatmap__legend-cell" data-level="3"></div>
      <div class="pa-heatmap__legend-cell" data-level="4"></div>
      <span>More</span>
    </div>
    """
  end

  # -- sparkline/1 --

  @doc """
  Renders sparkline mini bars.

  ## Examples

      <.sparkline values={[40, 65, 55, 80, 70, 90, 85]} />
      <.sparkline values={[30, 50, 70, 45, 80, 60, 55]} variant="success" />
  """
  attr(:values, :list, required: true, doc: "List of percentage values (0-100)")
  attr(:variant, :string, default: nil, values: [nil, "primary", "success", "warning", "danger", "info"])
  attr(:size, :string, default: nil, values: [nil, "lg"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def sparkline(assigns) do
    ~H"""
    <div class={build_classes("pa-sparkline", [
      {"pa-sparkline--#{@variant}", @variant not in [nil, "primary"]},
      {"pa-sparkline--#{@size}", @size != nil}
    ], @class)} {@rest}>
      <%= for val <- @values do %>
        <div class="pa-sparkline__bar" style={"--value: #{val}%"}></div>
      <% end %>
    </div>
    """
  end
end
