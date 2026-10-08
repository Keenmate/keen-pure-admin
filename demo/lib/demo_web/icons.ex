defmodule DemoWeb.Icons do
  @moduledoc """
  Demo icon provider wired into `<.icon>` via `:keen_pure_admin, :icon_providers`.

  Handles one set and passes everything else on:

    * `"lucide-X"` → `<img>` pointing at `/assets/icons/lucide/X.svg`
    * any other name → `nil`, so the next provider (or the library's built-in
      `hero-X` / FA-style fallback) gets a turn.

  The Lucide SVGs ship `stroke="currentColor"` so they pick up the parent
  text color when embedded inline; via `<img>` that's lost — only sizing
  and the title/alt attrs come through. For full recoloring you'd inline
  the SVG (read at compile time or at request time).
  """
  use Phoenix.Component

  def render(%{name: "lucide-" <> file} = assigns) do
    assigns = assign(assigns, :file, file)

    ~H"""
    <img
      src={"/assets/icons/lucide/#{@file}.svg"}
      style={"width: #{@size_value}; height: #{@size_value};"}
      class={@class}
      alt={@aria_label || @file}
      title={@title}
    />
    """
  end

  def render(_assigns), do: nil
end
