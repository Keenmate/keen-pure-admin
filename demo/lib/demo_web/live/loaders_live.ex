defmodule DemoWeb.Live.LoadersLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Loaders")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Loading indicators and spinner components for async operations.</.paragraph>

    <%!-- Spinner Sizes --%>
    <.card title_text={gettext("Spinner Sizes")} class="mb-6">
      <.callout variant="info" class="mb-4">
        Pure Admin currently only ships two spinner sizes: the default and <code>--xs</code>.
        Other size modifiers (<code>--sm/--md/--lg/--xl/--2xl</code>) are not implemented in the
        SCSS framework, so the component's <code>size</code> attr accepts only <code>"xs"</code>.
      </.callout>
      <.grid>
        <.column size="100" md="1-2" class="text-center mb-4">
          <.spinner />
          <.paragraph class="mt-2 text-secondary">Default<br />1.6rem</.paragraph>
        </.column>
        <.column size="100" md="1-2" class="text-center mb-4">
          <.spinner size="xs" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--xs<br />0.75rem</.paragraph>
        </.column>
      </.grid>
    </.card>

    <%!-- Spinner Colors --%>
    <.card title_text={gettext("Spinner Colors")} class="mb-6">
      <.grid>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="primary" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--primary</.paragraph>
        </.column>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="secondary" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--secondary</.paragraph>
        </.column>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="success" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--success</.paragraph>
        </.column>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="danger" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--danger</.paragraph>
        </.column>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="warning" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--warning</.paragraph>
        </.column>
        <.column size="100" md="1-4" class="text-center mb-4">
          <.spinner variant="info" />
          <.paragraph class="mt-2 text-secondary">.pa-spinner--info</.paragraph>
        </.column>
      </.grid>
    </.card>

    <%!-- Inline Spinners --%>
    <.card title_text={gettext("Inline Spinners")} class="mb-6">
      <.paragraph class="mb-4">
        <.spinner size="xs" variant="primary" class="d-inline-block mr-2" />
        Loading inline content...
      </.paragraph>
      <.paragraph class="mb-4">
        <.spinner variant="success" class="d-inline-block mr-2" />
        Processing your request...
      </.paragraph>
      <.paragraph>
        <.spinner variant="info" class="d-inline-block mr-2" />
        Fetching data from server...
      </.paragraph>
    </.card>

    <%!-- Centered Loaders --%>
    <.card title_text={gettext("Centered Loaders")} class="mb-6">
      <div class="hr-20 position-relative border border-dashed rounded">
        <.loader_overlay>
          <.spinner variant="primary" />
        </.loader_overlay>
      </div>
    </.card>

    <%!-- Loaders with Text --%>
    <.card title_text={gettext("Loaders with Text")} class="mb-6">
      <.grid>
        <.column size="100" md="1-2" class="mb-4">
          <.loader_center class="hr-15 border border-dashed rounded">
            <.spinner variant="primary" />
            <.paragraph class="mt-4 text-secondary">Loading data...</.paragraph>
          </.loader_center>
        </.column>
        <.column size="100" md="1-2" class="mb-4">
          <.loader_center class="hr-15 border border-dashed rounded">
            <.spinner variant="success" />
            <.paragraph class="mt-4 text-secondary">Processing...</.paragraph>
          </.loader_center>
        </.column>
      </.grid>
    </.card>

    <%!-- Card Loading States --%>
    <.card title_text={gettext("Card Loading States")} class="mb-6">
      <.grid>
        <.column size="100" md="1-3" class="mb-4">
          <.card>
            <:header><.heading level={4}>{gettext("Loading Card")}</.heading></:header>
            <div class="hr-15 position-relative">
              <.loader_overlay>
                <.spinner variant="primary" />
              </.loader_overlay>
            </div>
          </.card>
        </.column>
        <.column size="100" md="1-3" class="mb-4">
          <.card>
            <:header><.heading level={4}>{gettext("Loading with Text")}</.heading></:header>
            <.loader_center class="hr-15">
              <.spinner variant="info" />
              <.paragraph class="mt-4 text-secondary">Fetching data...</.paragraph>
            </.loader_center>
          </.card>
        </.column>
        <.column size="100" md="1-3" class="mb-4">
          <.card>
            <:header><.heading level={4}>{gettext("Loaded Content")}</.heading></:header>
            <.paragraph>Content has loaded successfully!</.paragraph>
            <.paragraph class="mt-2">This is what appears after the loader completes.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.card>

    <%!-- Loader Types --%>
    <.card title_text={gettext("Loader Types")} class="mb-6">
      <.grid>
        <.column size="100" md="1-3" class="text-center mb-6">
          <.loader type="dots" size="lg" color="primary" />
          <.paragraph class="mt-2 text-secondary"><strong>Dots Loader</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-loader-dots</code></.paragraph>
        </.column>
        <.column size="100" md="1-3" class="text-center mb-6">
          <.loader type="bars" size="lg" color="success" />
          <.paragraph class="mt-2 text-secondary"><strong>Bars Loader</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-loader-bars</code></.paragraph>
        </.column>
        <.column size="100" md="1-3" class="text-center mb-6">
          <.loader type="pulse" size="lg" color="danger" />
          <.paragraph class="mt-2 text-secondary"><strong>Pulse Loader</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-loader-pulse</code></.paragraph>
        </.column>
        <.column size="100" md="1-3" class="text-center mb-4">
          <.loader type="ring" size="lg" color="warning" />
          <.paragraph class="mt-2 text-secondary"><strong>Ring Loader</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-loader-ring</code></.paragraph>
        </.column>
        <.column size="100" md="1-3" class="text-center mb-4">
          <.loader type="wave" size="lg" color="info" />
          <.paragraph class="mt-2 text-secondary"><strong>Wave Loader</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-loader-wave</code></.paragraph>
        </.column>
        <.column size="100" md="1-3" class="text-center mb-4">
          <.spinner class="text-secondary" />
          <.paragraph class="mt-2 text-secondary"><strong>Spinner</strong></.paragraph>
          <.paragraph class="mt-2"><code>.pa-spinner</code></.paragraph>
        </.column>
      </.grid>
    </.card>

    <%!-- Button Loading States --%>
    <.card title_text={gettext("Button Loading States")} class="mb-6">
      <.button_group>
        <.button variant="primary" is_loading>{gettext("Saving...")}</.button>
        <.button variant="success" is_loading>{gettext("Processing...")}</.button>
        <.button variant="danger" is_loading>{gettext("Deleting...")}</.button>
      </.button_group>
    </.card>
    """
  end
end
