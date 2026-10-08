defmodule PureAdmin do
  @moduledoc """
  Phoenix LiveView component library for the Pure Admin CSS framework.

  PureAdmin wraps Pure Admin's HTML/CSS BEM patterns into Phoenix LiveView
  function components and LiveComponents, providing a full CoreComponents
  replacement for Phoenix applications.

  ## Quick Start

  1. Add `keen_pure_admin` to your `mix.exs` dependencies
  2. Install `@keenmate/pure-admin-core` via npm in `assets/`
  3. Replace `import MyAppWeb.CoreComponents` with `use PureAdmin.Components`
  4. Import JS hooks in `app.js`:

      ```javascript
      import { PureAdminHooks } from "../deps/keen_pure_admin/assets/js/keen_pure_admin"
      let liveSocket = new LiveSocket("/live", Socket, { hooks: { ...PureAdminHooks } })
      ```

  ## Module Structure

  - `PureAdmin.Components` - `use` macro that imports all function components
  - `PureAdmin.Components.*` - Individual component modules (Button, Badge, Alert, etc.)
  - `PureAdmin.CommandPalette` - Stateful command-palette LiveComponent
  - `PureAdmin.Dialog` - Server-driven modal dialogs (confirm/alert/custom) for LiveView
  - `PureAdmin.Helpers` - BEM class builder utilities
  - `PureAdmin.Config` - NimbleOptions configuration
  - `PureAdmin.Types` - Shared type definitions
  """
end
