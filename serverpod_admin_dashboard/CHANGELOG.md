# Changelog

All notable changes to this project will be documented in this file.

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
