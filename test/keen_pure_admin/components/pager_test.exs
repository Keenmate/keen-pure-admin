defmodule PureAdmin.Components.PagerTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Pager

  defp render(overrides) do
    base = %{
      page: 2,
      total_pages: 10,
      align: nil,
      show_page_input: true,
      show_info: true,
      info_text: nil,
      on_previous: "prev",
      on_next: "next",
      on_first: "first",
      on_last: "last",
      on_page_change: "change",
      icon_first: "«",
      icon_previous: "‹",
      icon_next: "›",
      icon_last: "»",
      class: nil,
      rest: %{},
      controls: [],
      info: [],
      first_icon: [],
      previous_icon: [],
      next_icon: [],
      last_icon: []
    }

    render_component(&Pager.pager/1, Map.merge(base, overrides))
  end

  describe "pager/1 canonical single-controls shape" do
    test "all nav buttons live in ONE pa-pager__controls group" do
      html = render(%{})
      # exactly one controls group, not two straddling __info
      assert length(Regex.scan(~r/pa-pager__controls/, html)) == 1
    end

    test "renders first/prev/next/last + trailing info" do
      html = render(%{})
      assert html =~ ~s(phx-click="first")
      assert html =~ ~s(phx-click="prev")
      assert html =~ ~s(phx-click="next")
      assert html =~ ~s(phx-click="last")
      assert_class(html, "pa-pager__info")
      # controls appear before info in the DOM
      assert :binary.match(html, "pa-pager__controls") < :binary.match(html, "pa-pager__info")
    end
  end

  describe "load_more/1 loading state" do
    defp render_load_more(overrides) do
      base = %{
        is_loading: false,
        count: nil,
        align: nil,
        class: nil,
        rest: %{},
        inner_block: [
          %{__slot__: :inner_block, inner_block: fn _, _ -> "Load More" end}
        ]
      }

      render_component(&Pager.load_more/1, Map.merge(base, overrides))
    end

    test "loading button carries the --loading modifier AND the native disabled attr" do
      html = render_load_more(%{is_loading: true})
      assert_class(html, "pa-load-more__button--loading")
      assert_class(html, "pa-load-more__spinner")
      # Markup-fidelity: a loading load-more button must be non-interactive
      # (matches svelte-pure-admin + the button 'loading ⇒ disabled' convention).
      assert html =~ ~r/<button[^>]*\sdisabled/
    end

    test "non-loading button is NOT disabled" do
      html = render_load_more(%{is_loading: false})
      refute html =~ ~r/<button[^>]*\sdisabled/
      refute html =~ "pa-load-more__button--loading"
    end
  end
end
