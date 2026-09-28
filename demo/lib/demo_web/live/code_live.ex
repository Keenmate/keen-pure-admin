defmodule DemoWeb.Live.CodeLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Code",
       elixir_code: """
       defmodule MyApp.Greeting do
         def hello(name) do
           "Hello, \#{name}!"
         end
       end\
       """,
       js_code: """
       import { Socket } from "phoenix"
       import { LiveSocket } from "phoenix_live_view"

       const csrfToken = document
         .querySelector("meta[name='csrf-token']")
         .getAttribute("content")

       const liveSocket = new LiveSocket("/live", Socket, {
         params: { _csrf_token: csrfToken }
       })

       liveSocket.connect()\
       """,
       html_code: """
       <div class="pa-card">
         <div class="pa-card__header">
           <h3>Card Title</h3>
         </div>
         <div class="pa-card__body">
           Content goes here.
         </div>
       </div>\
       """,
       css_code: """
       .pa-card {
         border-radius: var(--pc-border-radius);
         background: var(--pc-card-bg);
         box-shadow: var(--pc-card-shadow);
       }

       .pa-card__header {
         padding: var(--pc-card-header-padding);
         border-bottom: 1px solid var(--pc-border-color);
       }\
       """
     )}
  end

  def render(assigns) do
    ~H"""
    <p>Code display components for inline code and code blocks.</p>

    <.card title_text={gettext("Inline Code")}>
      <p>
        Use the
        <.code>mix phx.server</.code>
        command to start the Phoenix server.
        You can also run
        <.code>mix test</.code>
        to execute the test suite.
      </p>
    </.card>

    <.card title_text={gettext("Code Block")}>
      <.code_block language="elixir">{@elixir_code}</.code_block>
    </.card>

    <.card title_text={gettext("Code Block with Header")}>
      <.code_block language="javascript" filename="app.js">{@js_code}</.code_block>
    </.card>

    <.grid>
      <.column size="50">
        <.card title_text={gettext("HTML Example")}>
          <.code_block language="html">{@html_code}</.code_block>
        </.card>
      </.column>
      <.column size="50">
        <.card title_text={gettext("CSS Example")}>
          <.code_block language="css">{@css_code}</.code_block>
        </.card>
      </.column>
    </.grid>
    """
  end
end
