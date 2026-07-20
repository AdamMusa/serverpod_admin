# Changelog

All notable changes to this project will be documented in this file.

## 1.0.13

- Updated Serverpod client dependencies to 3.4.11.

## 1.0.12

- Updated README tutorial with separate non-custom and advanced custom setup
  paths.
- Documented local package installer usage with
  `dart run serverpod_admin_server:serverpod_admin install`.

## 1.0.9

- Superseded by 1.0.12 to keep the Serverpod Admin package family on the same
  release version.

## 1.0.8

- Updated the `find` endpoint client signature to send record ids as strings,
  matching Serverpod 3.4 endpoint deserialization.

## 1.0.7

- Added client protocol support for admin profile and password operations.
- Added client protocol support for Serverpod future-call history and job actions.
- Updated generated protocol compatibility for Serverpod 3.4.x.

## 1.0.6

- Initial version
- Client-side protocol definitions for admin module
- Admin resource and column type definitions
- Integration with serverpod_client
