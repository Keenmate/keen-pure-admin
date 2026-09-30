defmodule Mix.Tasks.Pa.Fidelity.Dump do
  @shortdoc "Render a component's fidelity scenarios to a dump file"

  @moduledoc """
  Markup-fidelity dumper — keen-pure-admin side (component-generic).

  Reads the core NEUTRAL fixture + this repo's `<component>.map.json`, maps each
  scenario's neutral props to the component's assigns via the map, renders via
  `Phoenix.LiveViewTest.render_component/2` (server markup, pre-JS-hook — the
  layer the core snippet describes), and writes a dump the core comparator diffs
  against the goldens.

      mix pa.fidelity.dump button
      mix pa.fidelity.dump card
        # → fidelity/keen-<component>.dump.json

  Base assigns (every declared attr's default + every slot ⇒ []) are seeded from
  the component's own `__components__/0` metadata, so a component with many slots
  needs no per-component wiring — only a `render/2` + `meta/1` clause below.

  Override paths with `--fixture` / `--map` / `--out`.
  """
  use Mix.Task

  # render_component/2 is a macro — import it so it expands around our runtime assigns.
  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PureAdmin.Components.Button
  alias PureAdmin.Components.Card

  @impl Mix.Task
  def run(args) do
    {opts, positional, _} =
      OptionParser.parse(args, strict: [fixture: :string, map: :string, out: :string])

    component = List.first(positional) || "button"

    fixture_path = opts[:fixture] || "../pure-admin/packages/core/fidelity/fixtures/#{component}.json"
    map_path = opts[:map] || "fidelity/#{component}.map.json"
    out_path = opts[:out] || "fidelity/keen-#{component}.dump.json"

    fixture = fixture_path |> File.read!() |> Jason.decode!()
    features = (map_path |> File.read!() |> Jason.decode!())["features"]
    meta = meta(component)

    dump =
      for scenario <- fixture["scenarios"] do
        html =
          scenario["props"]
          |> build_assigns(features, meta)
          |> render(component)

        %{name: scenario["name"], html: html}
      end

    out_path |> Path.dirname() |> File.mkdir_p!()
    File.write!(out_path, Jason.encode!(dump, pretty: true))
    Mix.shell().info("wrote #{length(dump)} scenarios -> #{out_path}")
  end

  # render_component/2 needs a literal &Mod.fun/1 (for its attr/slot default
  # handling), so dispatch per component with the literal capture.
  defp render(assigns, "button"), do: render_component(&Button.button/1, assigns)
  defp render(assigns, "card"), do: render_component(&Card.card/1, assigns)

  defp meta("button"), do: PureAdmin.Components.Button.__components__()[:button]
  defp meta("card"), do: PureAdmin.Components.Card.__components__()[:card]

  # Base assigns from the component's own metadata: every attr that declares a
  # default gets it, every slot defaults to []. Fully generic — no per-component
  # seed list to drift.
  defp base_assigns(meta) do
    attrs =
      for a <- meta.attrs, a.name != :rest, Keyword.has_key?(a.opts, :default), into: %{} do
        {a.name, a.opts[:default]}
      end

    slots = for s <- meta.slots, into: %{}, do: {s.name, []}
    Map.merge(attrs, slots)
  end

  # Neutral scenario props → keen assigns, driven by <component>.map.json.
  # kinds: slot (→ slot list), const (fixed value from a flag, e.g. keen's stat
  # ⇒ variant="stat"), bool (with optional `negate` + `channel:"rest"`), string
  # (optional `channel:"rest"` for globals), enum. `channel:"rest"` values ride
  # in the :global :rest map with STRING keys.
  defp build_assigns(props, features, meta) do
    base = base_assigns(meta)

    {assigns, rest} =
      Enum.reduce(props, {base, %{}}, fn {key, value}, {acc, rest} ->
        case features[key] do
          nil ->
            IO.warn(~s(scenario prop "#{key}" has no entry in the map — skipped))
            {acc, rest}

          %{"kind" => "slot", "prop" => prop} ->
            atom = String.to_atom(prop)
            {Map.put(acc, atom, text_slot(atom, value || "")), rest}

          %{"kind" => "const", "prop" => prop} = e ->
            if value, do: {Map.put(acc, String.to_atom(prop), e["value"]), rest}, else: {acc, rest}

          %{"kind" => "bool"} = e ->
            val = if e["negate"], do: !value, else: !!value

            if e["channel"] == "rest",
              do: {acc, maybe_put(rest, e["prop"], val)},
              else: {Map.put(acc, String.to_atom(e["prop"]), val), rest}

          %{"channel" => "rest", "prop" => prop} ->
            {acc, maybe_put(rest, prop, value)}

          %{"prop" => prop} ->
            {Map.put(acc, String.to_atom(prop), value), rest}
        end
      end)

    Map.put(assigns, :rest, rest)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp text_slot(name, text) do
    [%{__slot__: name, inner_block: fn _, _ -> text end}]
  end
end
