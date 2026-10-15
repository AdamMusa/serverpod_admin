# Changelog

All notable changes to this project will be documented in this file.

## 1.0.20

- Follows the server's table options: labels, sidebar groups, the columns
  shown at first, the default sort, help text under fields, read-only fields
  when editing, and no Add, Edit, Delete or bulk buttons where they are not
  allowed (per table and per signed-in user).
- Staff with the scopes the server lists in `staffScopes` can sign in, in the
  prebuilt dashboard too; `AdminDashboard(staffScopes: ...)` lets them in
  without asking the server.
- The overview shows the server's metrics, and a chart of the rows each table
  gained on each of the last 30 days.
- Filters offer Today, Last 7 days, Last 30 days and This month for a date
  column in one click.
- List tiles in record details show their ink again on Flutter 3.44.

## 1.0.19

- An overview home page with every table's row count and recent actions.
- Record pages have Details, Related (rows pointing at the record, with a
  link to all of them) and History tabs.
- Foreign keys show the related row's name and open it; pickers in forms
  search the related table instead of loading it whole.
- Select rows (or all matching), then delete them, set a field on all of
  them, or run the model's custom actions.

## 1.0.18

- Tables page, sort (click a column header), search and filter on the server,
  so large tables stay fast. Filters fit each column type and show as chips.
- URLs open inside the dashboard: images with zoom, PDFs in the browser's
  viewer, other links in a new tab; tables and details show image thumbnails.
- Show or hide columns, refresh, and export every row matching the current
  search and filters (CSV or XLSX).

## 1.0.16

- Columns with declared choices, such as permission scopes, are edited with a
  multi-select instead of raw JSON. Stored values outside the choices stay
  visible so saving never drops them.

## 1.0.15

- Optional (nullable) fields may be left empty, and field errors clear as soon
  as the value is corrected.
- Save errors show the server's explanation, such as which field is invalid.
- Enum columns are edited with dropdowns; foreign key dropdowns are fixed.

## 1.0.14

- Updated Serverpod dashboard dependencies to 4.0.0-beta.1.

## 1.0.13

- Updated Serverpod dashboard dependencies to 3.4.11.

## 1.0.12

- Added dashboard auth restoration so embedded custom Flutter apps keep users
  signed in across page refreshes when the configured auth session is valid.
- Improved Serverpod jobs dashboard spacing and finished-job actions.
- Updated README tutorial with separate non-custom and advanced custom setup
  paths.

## 0.1.7

- Added Serverpod jobs dashboard with scheduled, ready, paused, failed, finished, and all-job tabs.
- Added pagination to the jobs dashboard using the shared admin pagination controls.
- Added profile update and password change UI.
- Added CSV/XLSX import/export support.
- Improved authentication error display for invalid credentials and session-storage failures.

## 0.1.6

- Initial version
- Reusable Serverpod admin dashboard widget
- Flutter-based admin interface
- Browse, search, create, edit, and delete functionality
- Pagination support
- Integration with serverpod_admin_client
- Material Design UI components
