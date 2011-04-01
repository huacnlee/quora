if defined?(Wice::Defaults)
 
  Wice::Defaults::JS_FRAMEWORK = :jquery
  # Wice::Defaults::JS_FRAMEWORK = :prototype
 
  # Style of the view helper.
  # +false+ is a usual view helper.
  # +true+ will allow to embed erb content in column (cell) definitions.
  Wice::Defaults::ERB_MODE = false
 
  # Default number of rows to show per page.
  Wice::Defaults::PER_PAGE = 20
 
  # Default order direction
  Wice::Defaults::ORDER_DIRECTION = 'desc'
 
  # Default name for a grid. A grid name is the basis for a lot of
  # names including parameter names, DOM IDs, etc
  # The shorter the name is the shorter the request URI will be.
  Wice::Defaults::GRID_NAME = 'grid'
 
  # If REUSE_LAST_COLUMN_FOR_FILTER_ICONS is true and the last column doesn't have any filter and column name, it will be used
  # for filter related icons (filter icon, reset icon, show/hide icon), otherwise an additional table column is added.
  Wice::Defaults::REUSE_LAST_COLUMN_FOR_FILTER_ICONS = true
 
  Wice::Defaults::SHOW_HIDE_FILTER_ICON = 'wice_grid/page_white_find.png'
 
 
  # Icon to trigger filtering.
  Wice::Defaults::FILTER_ICON = 'wice_grid/table_refresh.png'
 
  # Icon to reset the filter.
  Wice::Defaults::RESET_ICON = "wice_grid/table.png"
 
  # Icon to reset the filter.
  Wice::Defaults::TOGGLE_MULTI_SELECT_ICON = "/images/wice_grid/expand.png"
 
  # CSV Export icon.
  Wice::Defaults::CSV_EXPORT_ICON = "/images/wice_grid/page_white_excel.png"
 
  # Tick-All icon for the action column.
  Wice::Defaults::TICK_ALL_ICON = "/images/wice_grid/tick_all.png"
 
  # Untick-All icon for the action column.
  Wice::Defaults::UNTICK_ALL_ICON = "/images/wice_grid/untick_all.png"
 
  # The label of the first option of a custom dropdown list meaning 'All items'
  Wice::Defaults::CUSTOM_FILTER_ALL_LABEL = '--'
 
 
  # Allow switching between a single and multiple selection modes in custom filters (dropdown boxes)
  Wice::Defaults::ALLOW_MULTIPLE_SELECTION = false
 
  # Show the upper pagination panel by default or not
  Wice::Defaults::SHOW_UPPER_PAGINATION_PANEL = false
 
  # Enabling CSV export by default
  Wice::Defaults::ENABLE_EXPORT_TO_CSV = false
 
 
  # The strategy when to show the filter.
  # * <tt>:when_filtered</tt> - when the table is the result of filtering
  # * <tt>:always</tt>        - show the filter always
  # * <tt>:no</tt>            - never show the filter
  Wice::Defaults::SHOW_FILTER = :always
 
  # A boolean value specifying if a change in a filter triggers reloading of the grid.
  Wice::Defaults::AUTO_RELOAD = false
 
 
  # SQL operator used for matching strings in string filters.
  Wice::Defaults::STRING_MATCHING_OPERATOR = 'LIKE'
  # STRING_MATCHING_OPERATOR = 'ILIKE' # Use this for Postgresql case-insensitive matching.
 
 
  # Defining one string matching operator globally for the whole application turns is not enough
  # when you connect to two databases one of which is MySQL and the other is Postgresql.
  # If the key for an adapter is missing it will fall back to Wice::Defaults::STRING_MATCHING_OPERATOR
  Wice::Defaults::STRING_MATCHING_OPERATORS = {
    'ActiveRecord::ConnectionAdapters::MysqlAdapter' => 'LIKE',
    'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter' => 'ILIKE'
  }
 
 
 
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                              Advanced Filters                             #
 
  # Switch of the negation checkbox in all text filters
  Wice::Defaults::NEGATION_IN_STRING_FILTERS = false
 
 
 
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                              Showing All Queries                          #
 
  # Enable or disable showing all queries (non-paginated table)
  Wice::Defaults::ALLOW_SHOWING_ALL_QUERIES = true
 
  # If number of all queries is more than this value, the user will be given a warning message
  Wice::Defaults::START_SHOWING_WARNING_FROM = 100
 
 
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                               Saving Queries                              #
 
  # Icon to delete a saved query
  Wice::Defaults::DELETE_QUERY_ICON = 'wice_grid/delete.png'
 
  # ActiveRecord model to store queries. Read the documentation for details
  # QUERY_STORE_MODEL = 'WiceGridSerializedQuery'
  Wice::Defaults::QUERY_STORE_MODEL = 'WiceGridSerializedQuery'
 
 
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #            Here go settings related to the calendar helpers               #
 
  # The default style of the date and datetime helper
  # * <tt>:calendar</tt> - JS calendar
  # * <tt>:standard</tt> - standard Rails date and datetime helpers
  Wice::Defaults::HELPER_STYLE = :calendar
 
  # Format of the datetime displayed.
  # If you change the format, make sure to check if +DATETIME_PARSER+ can still parse this string.
  Wice::Defaults::DATETIME_FORMAT = "%Y-%m-%d %H:%M"
 
  # Format of the date displayed.
  # If you change the format, make sure to check if +DATE_PARSER+ can still parse this string.
  Wice::Defaults::DATE_FORMAT     =  "%Y-%m-%d"
 
  # Format of the date displayed in jQuery's Datepicker
  # If you change the format, make sure to check if +DATE_PARSER+ can still parse this string.
  Wice::Defaults::DATE_FORMAT_JQUERY     =  "yy-mm-dd"
 
 
  # With Calendar helpers enabled the parameter sent is the string displayed. This lambda will be given a date string in the
  # format defined by +DATETIME_FORMAT+ and must generate a DateTime object.
  # In many cases <tt>Time.zone.parse</tt> is enough, for instance,  <tt>%Y-%m-%d</tt>. If you change the format, make sure to check this code
  # and modify it if needed.
  Wice::Defaults::DATETIME_PARSER = lambda{|datetime_string| Time.zone.parse(datetime_string) }
 
  # With Calendar helpers enabled the parameter sent is the string displayed. This lambda will be given a date string in the
  # format defined by +DATETIME+ and must generate a Date object.
  # In many cases <tt>Date.parse</tt> is enough, for instance,  <tt>%Y-%m-%d</tt>. If you change the format, make sure to check this code
  # and modify it if needed.
  Wice::Defaults::DATE_PARSER = lambda{|date_string| Date.parse(date_string) }
 
  # Icon to popup the calendar.
  Wice::Defaults::CALENDAR_ICON = "/images/wice_grid/calendar_view_month.png"
 
  # popup calendar will be shown relative to the popup trigger element or to the mouse pointer
  Wice::Defaults::POPUP_PLACEMENT_STRATEGY = :trigger # :pointer
 
end
