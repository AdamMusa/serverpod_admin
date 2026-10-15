# Changelog

All notable changes to this project will be documented in this file.

## 1.0.21

- Fieldsets: `AdminOptions(fieldsets: [AdminFieldset(...)])` groups a table's
  fields in the dashboard's forms and details, like Django's fieldsets, with
  a name, a description and whether the group starts folded. Columns no
  fieldset names follow in a last group named "Other"; hidden and unknown
  names are left out.
- Saved views: `admin.savedViews`, `admin.saveView` and `admin.deleteView`
  keep each user's named searches, sorts, filters and shown columns per
  table, in the new `serverpod_admin_saved_view` table. Create and apply a
  migration in your server after upgrading (`serverpod create-migration`).
  Views name only columns the user may see, of tables they may see.

## 1.0.20

- Table options, like Django's ModelAdmin:
  `register<T>(options: AdminOptions(...))` sets a table's label, sidebar
  group, default columns and ordering, read-only and hidden columns, column
  labels and help text, searched columns, and whether rows may be created,
  edited or deleted here at all. Hidden columns never leave the server;
  hidden and read-only columns keep their stored values on edits.
- Staff roles: scopes in `registry.staffScopes` may open the dashboard, with
  per-table `AdminPermissions` (view, create, edit, delete). Every endpoint
  method checks them on the server. Administrators keep full access.
  `admin.access` says whether the signed-in user may enter.
- Overview metrics: `registry.registerMetric(AdminMetric(...))` adds key
  numbers to the dashboard's overview (`admin.metrics`). A metric that fails
  or times out shows "—".
- `admin.activity` counts the rows a table gained on each recent day, by its
  `chartColumn` (detected from names such as `createdAt`).
- Only administrators change who may sign in: staff who may edit a row that
  extends an auth user cannot change its `authUser.scopeNames` or
  `authUser.blocked`.
- Fixed editing, deleting and running actions on rows of tables with UUID
  primary keys (their ids were looked up as text).

## 1.0.19

- Change history: creations, edits, deletions and custom actions made in the
  dashboard are recorded in the new `serverpod_admin_log` table (create a
  migration after upgrading), readable with `admin.history`. Secret-looking
  fields are recorded without values; `registry.historyRetention` limits how
  long entries are kept.
- Bulk changes: `deleteMany` and `updateMany` apply to many rows through the
  same validation and hooks as single edits, reporting rows that failed.
- Custom actions: `register<T>(actions: [AdminAction(...)])` adds actions
  administrators run on selected rows (`runAction`).
- Filters accept `oneOf` (comma-separated values).

## 1.0.18

- Listings are paged, sorted, searched and filtered in the database through
  the new `query` endpoint method (`AdminQuery` in, `AdminPage` out), newest
  rows first by default. Values are quoted by the package itself, never
  passed to SQL raw. Resources with a custom `listRows`, or filters on
  columns a table does not store, are handled in memory.
- `register<T>(present: ...)` adjusts rows for the dashboard (for example
  signed document links) while queries still run in the database.

## 1.0.17

- Rows that extend a Serverpod auth user (a unique `authUserId` column, or a
  relation to `serverpod_auth_core_user`) show and edit that user's
  `authUser.scopeNames` and `authUser.blocked`, saved to the auth user.
  `register<T>(authUserColumn: ...)` names the column when it is not detected.
- An admin cannot remove their own admin access or block themselves.

## 1.0.16

- Permission scopes are picked from a list: `registerAuthUsers()` offers
  `serverpod.admin` for `scopeNames`, plus any `scopes` you pass.
- `register<T>(choices: {...})` turns a list or set column into a
  multi-select of the given values.

## 1.0.15

- Enum columns are offered as dropdowns: values are discovered automatically
  on the Dart VM, and `registry.registerEnum(MyEnum.values)` declares them for
  compiled servers (`dart compile exe` / `dart build cli`).
- `registry.registerAuthUsers()` lists Serverpod's auth users so administrators
  can grant or revoke dashboard access (`scopeNames`) and block sign-in.
- List, set and map (JSON) columns are shown and saved as JSON.
- Values a model cannot hold (for example a malformed geography point) are
  rejected with an `AdminValidationException` naming the field instead of an
  internal server error.
- Foreign key dropdowns are fixed and form values reach model validation
  unchanged.

## 1.0.14

- Updated Serverpod server and test dependencies to 4.0.0-beta.1.
- Added the Serverpod 4 database and authentication schema migration.
- Confirmed the installer uses the dashboard artifact from the latest GitHub
  release.

## 1.0.13

- Updated Serverpod server dependencies to 3.4.11.

## 1.0.12

- Updated installer documentation to use local package execution with
  `dart run serverpod_admin_server:serverpod_admin install`.
- Updated README tutorial with separate non-custom prebuilt dashboard and
  advanced custom Flutter dashboard setup paths.

## 1.0.11

- Switched the prebuilt dashboard release instructions from WebAssembly output
  to the standard Flutter web JavaScript build for broader browser
  compatibility.

## 1.0.10

- Made `AdminUser.create` reset the password for existing email accounts, so
  development admin bootstrapping is repeatable.
- Updated install snippets to configure resources and jobs before serving the
  prebuilt dashboard.

## 1.0.9

- Improved `serverpod_admin install` output with a copy-paste `server.dart`
  snippet for serving the prebuilt dashboard.

## 1.0.8

- Documented the default `/admin` dashboard route.
- Added support for custom dashboard paths with or without a leading slash.

## 1.0.7

- Added prebuilt admin dashboard installer executable: `serverpod_admin install`.
- Added `serveAdminDashboard(pod)` for serving the installed Flutter web admin app at `/admin`.
- Added admin profile update and password change endpoints.
- Added Serverpod future-call jobs resource, job history, and job queue actions.
- Added admin user bootstrap helper support for email/password admin users.
- Improved CSV/XLSX import/export support and admin-resource data handling.

## 1.0.6

- Initial version
- Core admin module functionality
- Model registration system
- Admin endpoint implementation
- Support for CRUD operations on registered models
- Frontend-agnostic API design
