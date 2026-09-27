defmodule DemoWeb.Layouts do
  @moduledoc """
  Layout components for the demo app.
  """
  use DemoWeb, :html

  import DemoWeb.SidebarIcons, only: [sidebar_icon: 1]

  embed_templates "layouts/*"
end
