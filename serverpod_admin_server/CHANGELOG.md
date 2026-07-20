# Changelog

All notable changes to this project will be documented in this file.

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
