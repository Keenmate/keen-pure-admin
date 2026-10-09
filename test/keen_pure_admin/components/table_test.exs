defmodule PureAdmin.Components.TableTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Table

  describe "table/1" do
    test "renders basic table" do
      html =
        render_component(&Table.table/1, %{
          id: nil,
          rows: [%{name: "John", email: "john@example.com"}],
          row_id: nil,
          row_click: nil,
          is_striped: false,
          size: nil,
          class: nil,
          col: [
            %{
              __slot__: :col,
              label: "Name",
              class: nil,
              col_class: nil,
              inner_block: fn _assigns, row -> row.name end
            },
            %{
              __slot__: :col,
              label: "Email",
              class: nil,
              col_class: nil,
              inner_block: fn _assigns, row -> row.email end
            }
          ],
          action: []
        })

      assert_class(html, "pa-table")
      assert html =~ "Name"
      assert html =~ "Email"
      assert html =~ "John"
      assert html =~ "john@example.com"
    end

    test "renders striped table with size" do
      html =
        render_component(&Table.table/1, %{
          id: nil,
          rows: [],
          row_id: nil,
          row_click: nil,
          is_striped: true,
          size: "xs",
          class: nil,
          col: [
            %{
              __slot__: :col,
              label: "Col",
              class: nil,
              col_class: nil,
              inner_block: fn _, _ -> "" end
            }
          ],
          action: []
        })

      assert_class(html, "pa-table--striped")
      assert_class(html, "pa-table--xs")
    end
  end

  describe "table/1 container-only (no :col)" do
    # With NO `:col` slots, table/1 renders the core-blessed container shape:
    # a bare <table class="pa-table ..."> around inner_block (the consumer
    # hand-authors thead/tbody), instead of the data-driven thead/tbody. Same
    # pa-table class contract, so every pa-table--* modifier still applies.
    test "renders a bare <table class=\"pa-table\"> around inner_block, no generated thead/tbody" do
      html =
        render_component(&Table.table/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "<tbody><tr><td>cell</td></tr></tbody>" end}
          ]
        })

      assert_class(html, "pa-table")
      # The consumer-authored body passes straight through…
      assert html =~ "cell"
      # …and table/1 does NOT inject its own empty data-driven skeleton.
      refute html =~ ~r{<thead>\s*<tr>\s*</tr>\s*</thead>}
    end

    test "pa-table--* modifiers still apply on the container-only path" do
      html =
        render_component(&Table.table/1, %{
          is_striped: true,
          is_bordered: true,
          is_plain: true,
          is_responsive: true,
          is_responsive_grid: true,
          size: "lg",
          class: "mb-4",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pa-table--striped")
      assert_class(html, "pa-table--bordered")
      assert_class(html, "pa-table--plain")
      assert_class(html, "pa-table--responsive")
      assert_class(html, "pa-table--responsive-grid")
      assert_class(html, "pa-table--lg")
      assert_class(html, "mb-4")
    end

    test "rows now defaults to [] — container-only needs no rows attr" do
      html =
        render_component(&Table.table/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "body" end}]
        })

      assert_class(html, "pa-table")
      assert html =~ "body"
    end
  end

  describe "table/1 is_responsive" do
    test "emits the pa-table--responsive modifier and no phantom wrapper" do
      html =
        render_component(&Table.table/1, %{
          rows: [%{name: "A"}],
          is_responsive: true,
          col: [
            %{
              __slot__: :col,
              label: "Name",
              class: nil,
              col_class: nil,
              inner_block: fn _, row -> row.name end
            }
          ],
          action: []
        })

      assert_class(html, "pa-table--responsive")
      refute_class(html, "pa-table-responsive")
    end
  end

  defp render_resp(opts) do
    base = %{
      rows: [%{name: "A", email: "a@x"}],
      is_responsive: false,
      is_responsive_grid: false,
      responsive_grid_cols: nil,
      col: [
        %{__slot__: :col, label: "Name", inner_block: fn _, r -> r.name end},
        %{__slot__: :col, label: "Email", span: "full", inner_block: fn _, r -> r.email end}
      ],
      action: []
    }

    render_component(&Table.table/1, Map.merge(base, opts))
  end

  describe "table/1 responsive data-* attributes" do
    test "is_responsive auto-emits data-label from each :col label" do
      html = render_resp(%{is_responsive: true})
      assert html =~ ~s(data-label="Name")
      assert html =~ ~s(data-label="Email")
    end

    test "non-responsive tables emit no data-label" do
      refute render_resp(%{}) =~ "data-label"
    end

    test "responsive-grid emits data-grid on rows + data-span from :col span + data-label" do
      html = render_resp(%{is_responsive_grid: true, responsive_grid_cols: "2"})
      assert html =~ ~s(data-grid="2")
      assert html =~ ~s(data-span="full")
      assert html =~ ~s(data-label="Name")
    end

    test "responsive-grid without responsive_grid_cols emits bare data-grid" do
      assert render_resp(%{is_responsive_grid: true}) =~ ~s(data-grid="")
    end
  end

  defp render_sel(opts) do
    base = %{
      rows: [%{id: 1, name: "A"}, %{id: 2, name: "B"}],
      selectable: true,
      row_selected: fn r -> r.id == 1 end,
      select_id: fn r -> r.id end,
      on_row_select: "toggle-row",
      on_select_all: "toggle-all",
      all_selected: false,
      some_selected: true,
      col: [%{__slot__: :col, label: "Name", inner_block: fn _, r -> r.name end}],
      action: []
    }

    render_component(&Table.table/1, Map.merge(base, opts))
  end

  describe "table/1 selectable" do
    test "renders the checkbox column in header + rows" do
      assert_class(render_sel(%{}), "pa-table__checkbox-col")
    end

    test "row_selected marks the row pa-table__row--selected" do
      assert_class(render_sel(%{}), "pa-table__row--selected")
    end

    test "row checkbox carries on_row_select + phx-value-id from select_id" do
      html = render_sel(%{})
      assert html =~ ~s(phx-click="toggle-row")
      assert html =~ ~s(phx-value-id="1")
      assert html =~ ~s(phx-value-id="2")
    end

    test "header select-all checkbox carries on_select_all" do
      assert render_sel(%{}) =~ ~s(phx-click="toggle-all")
    end

    test "not selectable emits no checkbox column" do
      refute render_sel(%{selectable: false}) =~ "pa-table__checkbox-col"
    end
  end

  describe "table_container/1" do
    test "bare container has no header (blessed card-less shape)" do
      html =
        render_component(&Table.table_container/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "t" end}]
        })

      assert_class(html, "pa-table-container")
      refute_class(html, "pa-table-container--panel")
      refute_class(html, "pa-table-container__header")
    end

    test "is_panel still renders the deprecated (rc10) --panel shape" do
      html =
        render_component(&Table.table_container/1, %{
          is_panel: true,
          title_text: "Users",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "t" end}]
        })

      assert_class(html, "pa-table-container--panel")
      assert_class(html, "pa-table-container__header")
    end
  end

  describe "table_card/1" do
    test "is_scrollable adds __body--scrollable for wide tables" do
      html =
        render_component(&Table.table_card/1, %{
          is_scrollable: true,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "t" end}]
        })

      assert_class(html, "pa-table-card")
      assert_class(html, "pa-table-card__body--scrollable")
    end

    test "is_plain drops the card chrome" do
      html =
        render_component(&Table.table_card/1, %{
          is_plain: true,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "t" end}]
        })

      assert_class(html, "pa-table-card--plain")
    end

    test "header wraps the title in __title > h3.__title-text (rc05 canonical)" do
      html =
        render_component(&Table.table_card/1, %{
          title_text: "Recent",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "t" end}]
        })

      assert html =~ ~r{<h3 class="pa-table-card__title-text">Recent</h3>}
    end
  end
end
