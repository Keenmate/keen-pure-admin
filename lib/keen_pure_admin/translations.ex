defmodule PureAdmin.Translations do
  @moduledoc """
  Translation system for PureAdmin components.

  Ships with English defaults that work out of the box. Applications can
  override translations at runtime by providing a callback function via config:

      # config/config.exs
      config :keen_pure_admin,
        translate: &MyApp.Translations.translate/2

  The callback receives a translation key and a params map:

      defmodule MyApp.Translations do
        def translate(key, params) do
          # Load from DB, Gettext, ETS, etc.
          translation = MyApp.Repo.get_translation(key, current_locale())
          # Use the interpolation helper to replace %{param} placeholders
          PureAdmin.Translations.interpolate(translation, params)
        end
      end

  If the callback returns `nil`, the English default is used as fallback.

  ## Translation Keys

  All keys follow the flat `pureAdmin.*` convention:

  - `pureAdmin.buttons.*` — Cancel, Confirm, Close, OK
  - `pureAdmin.search.*` — Searching..., No results
  - `pureAdmin.pagination.*` — First/Prev/Next/Last Page, Load More, page counts
  - `pureAdmin.commandPalette.*` — Placeholder, hints, step indicators
  - `pureAdmin.popconfirm.*` — Confirm, Cancel
  - `pureAdmin.settings.*` — Theme, Mode, Layout Width, etc.
  - `pureAdmin.a11y.*` — Accessibility labels

  ## Interpolation

  Use `%{param}` placeholders in translation strings:

      t("pureAdmin.pagination.pages", %{page: 2, total: 5})
      # => "2 of 5 pages"

      t("pureAdmin.commandPalette.stepOf", %{current: 1, total: 3})
      # => "Step 1 of 3"
  """

  @defaults %{
    # Buttons
    "pureAdmin.buttons.cancel" => "Cancel",
    "pureAdmin.buttons.confirm" => "Confirm",
    "pureAdmin.buttons.close" => "Close",
    "pureAdmin.buttons.ok" => "OK",

    # Search
    "pureAdmin.search.searching" => "Searching...",
    "pureAdmin.search.noResults" => "No results found",

    # Pagination
    "pureAdmin.pagination.firstPage" => "First Page",
    "pureAdmin.pagination.prevPage" => "Previous Page",
    "pureAdmin.pagination.nextPage" => "Next Page",
    "pureAdmin.pagination.lastPage" => "Last Page",
    "pureAdmin.pagination.pages" => "/ %{total} pages",
    "pureAdmin.pagination.loadMore" => "Load More",

    # Command Palette
    "pureAdmin.commandPalette.placeholder" => "Type / for commands, : for search, or just type...",
    "pureAdmin.commandPalette.emptyText" => "Type / for commands, : to search, or just start typing",
    "pureAdmin.commandPalette.searching" => "Searching...",
    "pureAdmin.commandPalette.filterPlaceholder" => "Type to filter...",
    "pureAdmin.commandPalette.navigate" => "Navigate",
    "pureAdmin.commandPalette.select" => "Select",
    "pureAdmin.commandPalette.pages" => "Pages",
    "pureAdmin.commandPalette.back" => "Back",
    "pureAdmin.commandPalette.close" => "Close",
    "pureAdmin.commandPalette.stepOf" => "Step %{current} of %{total}",
    "pureAdmin.commandPalette.searchingIn" => "Searching in %{name}",
    "pureAdmin.commandPalette.pageOf" => "Page %{page} of %{total} · %{count} results",
    "pureAdmin.commandPalette.commands" => "Commands",
    "pureAdmin.commandPalette.search" => "Search",

    # Popconfirm
    "pureAdmin.popconfirm.confirm" => "Confirm",
    "pureAdmin.popconfirm.cancel" => "Cancel",

    # Settings Panel
    "pureAdmin.settings.title" => "Settings",
    "pureAdmin.settings.theme" => "Theme",
    "pureAdmin.settings.colorVariant" => "Color Variant",
    "pureAdmin.settings.mode" => "Mode",
    "pureAdmin.settings.layoutWidth" => "Layout Width",
    "pureAdmin.settings.sidebarMode" => "Sidebar Mode",
    "pureAdmin.settings.loading" => "Loading...",
    "pureAdmin.settings.fluid" => "Fluid (Full Width)",
    "pureAdmin.settings.small" => "Small (768px)",
    "pureAdmin.settings.medium" => "Medium (1024px)",
    "pureAdmin.settings.large" => "Large (1280px)",
    "pureAdmin.settings.extraLarge" => "Extra Large (1600px)",
    "pureAdmin.settings.xxLarge" => "2X Large (1920px)",
    "pureAdmin.settings.sidebarBehavior" => "Sidebar Behavior",
    "pureAdmin.settings.sidebar" => "Sidebar",
    "pureAdmin.settings.display" => "Display",
    "pureAdmin.settings.profilePanel" => "Profile Panel",
    "pureAdmin.settings.fontSize" => "Font Size",
    "pureAdmin.settings.fontFamily" => "Font Family",
    "pureAdmin.settings.resetToDefaults" => "Reset to Defaults",
    "pureAdmin.settings.scrollsWithContent" => "Scrolls with Content",
    "pureAdmin.settings.fixedPosition" => "Fixed Position",
    "pureAdmin.settings.hideCompletely" => "Hide Completely",
    "pureAdmin.settings.showIconsOnly" => "Show Icons Only",
    "pureAdmin.settings.collapsed" => "Collapsed",
    "pureAdmin.settings.resizable" => "Resizable",
    "pureAdmin.settings.compactMode" => "Compact Mode",
    "pureAdmin.settings.rtlMode" => "RTL Mode",
    "pureAdmin.settings.hideAvatar" => "Hide Avatar",
    "pureAdmin.settings.iconOnlyTabs" => "Icon-Only Tabs",
    "pureAdmin.settings.fontSizeSmall" => "Small (14px)",
    "pureAdmin.settings.fontSizeDefault" => "Default (16px)",
    "pureAdmin.settings.fontSizeLarge" => "Large (18px)",
    "pureAdmin.settings.fontSizeXLarge" => "Extra Large (20px)",
    "pureAdmin.settings.fontSizeHint" => "Body text size. All elements scale proportionally.",
    "pureAdmin.settings.themeDefault" => "Theme Default",

    # Accessibility
    "pureAdmin.a11y.close" => "Close",
    "pureAdmin.a11y.settings" => "Settings",

    # Forms — used by PureAdmin.Components.Form (form_error_summary/1)
    "pureAdmin.form.errorFound" => "%{count} error found:",
    "pureAdmin.form.errorsFound" => "%{count} errors found:",

    # Date & time — used by PureAdmin.DateTime
    "pureAdmin.datetime.at" => "at",
    "pureAdmin.datetime.now" => "now",
    "pureAdmin.datetime.in" => "in %{duration}",
    "pureAdmin.datetime.yesterday" => "yesterday",
    "pureAdmin.datetime.yesterdayAgo" => "yesterday",
    "pureAdmin.datetime.seconds" => "%{count}s",
    "pureAdmin.datetime.secondsAgo" => "%{count}s ago",
    "pureAdmin.datetime.minute" => "a minute",
    "pureAdmin.datetime.minuteAgo" => "a minute ago",
    "pureAdmin.datetime.minutes" => "%{count} minutes",
    "pureAdmin.datetime.minutesAgo" => "%{count} minutes ago",
    "pureAdmin.datetime.hour" => "an hour",
    "pureAdmin.datetime.hourAgo" => "an hour ago",
    "pureAdmin.datetime.hours" => "%{count} hours",
    "pureAdmin.datetime.hoursAgo" => "%{count} hours ago",
    "pureAdmin.datetime.days" => "%{count} days",
    "pureAdmin.datetime.daysAgo" => "%{count} days ago",
    "pureAdmin.datetime.week" => "a week",
    "pureAdmin.datetime.weekAgo" => "a week ago",
    "pureAdmin.datetime.weeks" => "%{count} weeks",
    "pureAdmin.datetime.weeksAgo" => "%{count} weeks ago",
    "pureAdmin.datetime.month" => "a month",
    "pureAdmin.datetime.monthAgo" => "a month ago",
    "pureAdmin.datetime.months" => "%{count} months",
    "pureAdmin.datetime.monthsAgo" => "%{count} months ago",
    "pureAdmin.datetime.year" => "a year",
    "pureAdmin.datetime.yearAgo" => "a year ago",
    "pureAdmin.datetime.years" => "%{count} years",
    "pureAdmin.datetime.yearsAgo" => "%{count} years ago",

    # Month names
    "pureAdmin.datetime.months.january" => "January",
    "pureAdmin.datetime.months.february" => "February",
    "pureAdmin.datetime.months.march" => "March",
    "pureAdmin.datetime.months.april" => "April",
    "pureAdmin.datetime.months.may" => "May",
    "pureAdmin.datetime.months.june" => "June",
    "pureAdmin.datetime.months.july" => "July",
    "pureAdmin.datetime.months.august" => "August",
    "pureAdmin.datetime.months.september" => "September",
    "pureAdmin.datetime.months.october" => "October",
    "pureAdmin.datetime.months.november" => "November",
    "pureAdmin.datetime.months.december" => "December",

    # Weekday names
    "pureAdmin.datetime.weekdays.monday" => "Monday",
    "pureAdmin.datetime.weekdays.tuesday" => "Tuesday",
    "pureAdmin.datetime.weekdays.wednesday" => "Wednesday",
    "pureAdmin.datetime.weekdays.thursday" => "Thursday",
    "pureAdmin.datetime.weekdays.friday" => "Friday",
    "pureAdmin.datetime.weekdays.saturday" => "Saturday",
    "pureAdmin.datetime.weekdays.sunday" => "Sunday"
  }

  @doc """
  Translates a key with optional parameter interpolation.

  Calls the app-configured callback if set, falls back to English defaults.

  ## Examples

      t("pureAdmin.buttons.cancel")
      # => "Cancel"

      t("pureAdmin.pagination.pages", %{total: 5})
      # => "/ 5 pages"

      t("pureAdmin.commandPalette.stepOf", %{current: 1, total: 3})
      # => "Step 1 of 3"
  """
  @spec t(String.t(), map()) :: String.t()
  def t(key, params \\ %{})

  def t(key, params) do
    case Application.get_env(:keen_pure_admin, :translate) do
      nil ->
        default(key, params)

      fun when is_function(fun, 2) ->
        case fun.(key, params) do
          nil -> default(key, params)
          "" -> default(key, params)
          result -> result
        end
    end
  end

  @doc """
  Returns the default English translation for a key with interpolation.

  Returns the key itself if no default exists.
  """
  @spec default(String.t(), map()) :: String.t()
  def default(key, params \\ %{}) do
    case Map.get(@defaults, key) do
      nil -> key
      text -> interpolate(text, params)
    end
  end

  @doc """
  Interpolates `%{param}` placeholders in a string with values from the params map.

  Exported for use by app translation callbacks.

  ## Examples

      interpolate("Found %{count} results", %{count: 3})
      # => "Found 3 results"

      interpolate("Page %{page} of %{total}", %{page: 2, total: 5})
      # => "Page 2 of 5"
  """
  @spec interpolate(String.t(), map()) :: String.t()
  def interpolate(string, params) when is_binary(string) and map_size(params) == 0, do: string

  def interpolate(string, params) when is_binary(string) do
    Enum.reduce(params, string, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  @doc """
  Returns the full map of default English translations.

  Useful for apps that want to see all available keys.
  """
  @spec defaults() :: map()
  def defaults, do: @defaults
end
