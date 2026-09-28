defmodule DemoWeb.Live.DocumentLive do
  @moduledoc """
  Demo for the `pa-document` component (Word-style hierarchical numbered sections).
  Mirrors `pure-admin/demo/views/document.mustache` using keen wrapper components.
  """
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Document")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      <code>pa-document</code>
      renders Word-style hierarchical sections whose outline numbers
      (<code>1</code>, <code>1.1</code>, <code>1.1.1</code> …) are generated entirely by CSS
      counters — you never write them, so inserting or reordering a section renumbers
      everything automatically (up to six levels deep).
    </.paragraph>

    <%!-- Auto-numbered document --%>
    <.card title_text={gettext("Auto-numbered sections")}>
      <.document>
        <.document_section heading="Introduction">
          <.document_text>
            This top-level section renders as "1 Introduction". Nesting a section inside it
            produces "1.1", "1.2", and so on — no manual numbering anywhere.
          </.document_text>

          <.document_section heading="Scope" level={3}>
            <.document_text>Nested one level — renders as "1.1 Scope".</.document_text>
          </.document_section>

          <.document_section heading="Goals" level={3}>
            <.document_text>Renders as "1.2 Goals".</.document_text>

            <.document_section heading="Detail" level={4}>
              <.document_text>Two levels deep — renders as "1.2.1 Detail".</.document_text>
            </.document_section>
          </.document_section>
        </.document_section>

        <.document_section heading="Architecture">
          <.document_text>A new top-level section renders as "2 Architecture".</.document_text>
        </.document_section>
      </.document>
    </.card>

    <%!-- Density + flush --%>
    <.grid>
      <.column size="100" md="50">
        <.card title_text={gettext("Compact density")}>
          <.document density="compact">
            <.document_section heading="Terms">
              <.document_text>Tighter vertical rhythm between sections.</.document_text>
              <.document_section heading="Payment" level={3}>
                <.document_text>Renders as "1.1 Payment".</.document_text>
              </.document_section>
            </.document_section>
          </.document>
        </.card>
      </.column>
      <.column size="100" md="50">
        <.card title_text={gettext("Flush (no indentation)")}>
          <.document is_flush>
            <.document_section heading="Terms">
              <.document_text>The number chain alone conveys the hierarchy.</.document_text>
              <.document_section heading="Payment" level={3}>
                <.document_text>Renders as "1.1 Payment".</.document_text>
              </.document_section>
            </.document_section>
          </.document>
        </.card>
      </.column>
    </.grid>

    <%!-- Manual numbering --%>
    <.card title_text={gettext("Manual numbering (appendix scheme)")}>
      <.paragraph class="pa-text-secondary">
        Set <code>is_manual</code> on the container and write each number via the
        <code>number</code> attr — for appendices or non-decimal schemes the auto engine can't produce.
      </.paragraph>
      <.document is_manual>
        <.document_section heading="Appendix" number="A">
          <.document_text>Author-written "A".</.document_text>
          <.document_section heading="Glossary" number="A.1" level={3}>
            <.document_text>Author-written "A.1".</.document_text>
          </.document_section>
          <.document_section heading="References" number="A.2" level={3}>
            <.document_text>Author-written "A.2".</.document_text>
          </.document_section>
        </.document_section>
      </.document>
    </.card>

    <%!-- Worked example: content mid-chapter --%>
    <.card title_text={gettext("Non-section content mid-chapter")}>
      <.paragraph class="pa-text-secondary">
        A table (or any non-section content) between the heading and the nested sections does
        NOT disturb the numbering — only sections increment the counters.
      </.paragraph>
      <.document>
        <.document_section heading="Discount policy">
          <.document_text>
            Tiers are determined by trailing-twelve-month spend, applied to the net order
            subtotal before tax and shipping.
          </.document_text>

          <div class="pa-table-container mb-4">
            <table class="pa-table pa-table--striped pa-table--bordered">
              <thead>
                <tr>
                  <th>Tier</th>
                  <th class="text-end">Annual spend</th>
                  <th class="text-end">Discount</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Bronze</td>
                  <td class="text-end">&lt; 10,000</td>
                  <td class="text-end">0%</td>
                </tr>
                <tr>
                  <td>Silver</td>
                  <td class="text-end">10,000 – 50,000</td>
                  <td class="text-end">5%</td>
                </tr>
                <tr>
                  <td>Gold</td>
                  <td class="text-end">&gt; 50,000</td>
                  <td class="text-end">10%</td>
                </tr>
              </tbody>
            </table>
          </div>

          <.document_section heading="Tier assignment" level={3}>
            <.document_text>
              Recalculated on the first day of each month — renders as "1.1 Tier assignment",
              correctly following the table.
            </.document_text>
          </.document_section>
          <.document_section heading="Combining discounts" level={3}>
            <.document_text>Tier discounts do not stack with promotional coupon codes.</.document_text>
          </.document_section>
        </.document_section>
      </.document>
    </.card>
    """
  end
end
