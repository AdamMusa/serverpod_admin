# Serverpod Admin – The Missing Admin Panel for Serverpod 🎯

**Finally, an admin panel that Serverpod deserves!**

You've built an amazing Serverpod app with powerful endpoints, robust models, and a beautiful frontend. But when it comes to managing your data, you're stuck writing custom endpoints, building one-off admin pages, or worse—directly accessing the database.

**That's where Serverpod Admin comes in.** This is the missing piece that transforms your Serverpod backend into a fully manageable system.

---

## 🏠 Admin Dashboard Overview

Secure login screen for admin users. Only users with the `serverpod.admin` scope can access the dashboard.

![Admin Login](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/login.png)

Browse and manage all your data with a beautiful, intuitive interface.

![Admin Dashboard](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/posts.png)

New record with a clean, user-friendly interface.
![Admin Dashboard](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/new.png)

Powerful search and filtering capabilities to find exactly what you need.

![Search & Filter](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/search.png)

Edit record with a clean, user-friendly interface.

![Edit Records](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/edit.png)

Delete record with a clean, user-friendly interface.
![Admin Dashboard](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/delete.png)

View detailed information about any record.

![Record Details](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/detail.png)

Beautiful empty states when no records are found.

![Empty State](https://raw.githubusercontent.com/AdamMusa/serverpod_admin/main/images/empty_record.png)

---

## ✨ Why Serverpod Admin Matters

### 🚀 **Zero Configuration, Maximum Power**

No more writing boilerplate CRUD endpoints. Register your models once, and instantly get a complete admin interface with:

- **Browse & Search** – Navigate through all your data with powerful filtering
- **Create & Edit** – Intuitive forms for managing records
- **Delete** – Safe deletion with proper validation
- **Pagination** – Handle large datasets effortlessly
- **CSV/XLSX Import & Export** – Move admin data in and out of your app without custom scripts
- **Profile Management** – Admin users can update their profile from the dashboard
- **Password Updates** – Admin users can securely change their password
- **Job Monitoring UI** – A full Serverpod jobs dashboard for scheduled, ready, paused, failed, finished, and historical jobs

### 🎨 **Frontend-Agnostic Architecture**

Built with flexibility in mind. The `serverpod_admin_server` exposes a clean API that any frontend can consume. Start with Flutter today, switch to Jaspr tomorrow, or build your own custom admin UI—the choice is yours!

### ⚡ **Built for Serverpod Developers**

- **Type-Safe** – Leverages Serverpod's generated protocol classes
- **Integrated** – Works seamlessly with your existing Serverpod setup
- **Job-Aware** – Enable `admin.jobs = true` to monitor Serverpod future calls from the admin dashboard
- **Extensible** – Designed to grow with your needs

### 🛠️ **Developer Experience First**

Stop spending days building admin interfaces. Get back to building features that matter. With Serverpod Admin, you can have a production-ready admin panel in **minutes**, not weeks.

---

## 📦 Installation

Serverpod Admin has two UI paths:

- **Non-custom / prebuilt UI:** install the ready-made Flutter web dashboard
  into your Serverpod server and serve it at `/admin`.
- **Custom Flutter UI:** use `serverpod_admin_dashboard` directly in your own
  Flutter app when you want to customize layout, theme, sidebar, dialogs, or
  jobs UI.

### Server Package

Run:

```bash
dart pub add serverpod_admin_server
```

### Option 1: Non-Custom Prebuilt Admin UI

Use this when you do not want to build a Flutter admin app yourself. Your
Serverpod backend serves the admin dashboard directly.

From your Serverpod server package directory:

```bash
dart run serverpod_admin_server:serverpod_admin install
```

Then serve it from your `server.dart`:

```dart
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  admin.serveAdminDashboard(pod); // /admin

  await pod.start();
}
```

By default the installer places the build in `web/admin`, and
`serveAdminDashboard(pod)` serves it at `/admin`.

If you want another route, pass a custom path:

```dart
admin.serveAdminDashboard(
  pod,
  path: '/customadminpath',
);
```

The leading slash is optional, so `path: 'customadminpath'` also serves the
dashboard at `/customadminpath`.

Open:

```text
http://localhost:8082/admin
```

The prebuilt app talks to your Serverpod API. In local development it maps
`localhost:8082/admin` to `localhost:8080/` for API calls by default. For
deployments or custom routing, build the prebuilt app with:

```bash
flutter build web --wasm --base-href /admin/ --dart-define=SERVER_URL=https://api.example.com/
```

### Option 2: Custom Flutter Dashboard

Use this when you want to customize the admin UI in your own Flutter app. Add
the dashboard package:

```bash
flutter pub get serverpod_admin_dashboard
```

Both options use the same server package, same auth, and same admin endpoints.

---

## 🧩 Quick Start

### Registering Models (Server Side)

```dart
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

import 'package:use_serverpod_admin_server/src/generated/protocol.dart';

void registerAdminModule() {
  admin.jobs = true;

  admin.configureAdminModule((registry) {
    registry.register<Post>();
    registry.register<Person>();
    registry.register<Comment>();
    registry.register<Setting>();
    // Add any model you want to manage!
  });
}
```

Set `admin.jobs = true` to show Serverpod's persisted future-call jobs table
(`serverpod_future_call`) in the admin resources. Scheduled jobs can be
updated/rescheduled by editing their row and canceled/discarded by deleting
their row.

**Call `registerAdminModule()` in your `server.dart` file just after `pod.start()`**

### Setting Up Authentication

Serverpod Admin uses `serverpod_auth_idp` for authentication. Make sure you have it configured in your server:

```dart
pod.initializeAuthServices(
  tokenManagerBuilders: [
    JwtConfigFromPasswords(),
  ],
  identityProviderBuilders: [
    EmailIdpConfigFromPasswords(
      sendRegistrationVerificationCode: _sendRegistrationCode,
      sendPasswordResetVerificationCode: _sendPasswordResetCode,
    ),
  ],
);
```

### Creating an Admin User

To access the admin panel, users must have the `serverpod.admin` scope. Here's how to create an admin user:

```dart
import 'dart:io';

import 'package:serverpod_admin_server/serverpod_admin_server.dart';

Future<void> findOrCreateAndLinkEmail() async {
  final email = Platform.environment['SERVERPOD_ADMIN_EMAIL'];
  final password = Platform.environment['SERVERPOD_ADMIN_PASSWORD'];

  if (email == null || password == null) {
    throw StateError(
      'Set SERVERPOD_ADMIN_EMAIL and SERVERPOD_ADMIN_PASSWORD first.',
    );
  }

  await AdminUser.create(
    email: email,
    password: password,
  );
}
```

**Call `findOrCreateAndLinkEmail()` in your `server.dart` file after `pod.start()` to create your first admin user. Keep this as a development/bootstrap helper, and remove or guard it once your admin user exists.**

### Using the Custom Flutter Dashboard

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  client = Client('http://localhost:8080/')
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  client.auth.initialize();
  runApp(AdminDashboard(client: client));
}
```

**That's it!** You now have a fully working admin panel with authentication for your Serverpod app! 🚀🎉

The admin dashboard will automatically show a login screen for unauthenticated users. Only users with the `serverpod.admin` scope can access the admin panel.

### Building the Prebuilt UI Yourself

The bundled app lives in `serverpod_admin_app` and is built by GitHub Actions:

```bash
cd serverpod_admin_app
flutter build web --wasm --base-href /admin/
```

The build output is packaged as `serverpod_admin_dashboard_web.zip`. You can
install a local build with:

```bash
dart run serverpod_admin_server:serverpod_admin install --source serverpod_admin_app/build/web --force
```

---

## 🎨 Customization

Serverpod Admin offers flexible customization options, from simple sidebar tweaks to complete UI replacement.

### Sidebar Level Customization

Customize individual sidebar items with custom labels and icons:

```dart
AdminDashboard(
  client: client,
  sidebarItemCustomizations: {
    'posts': SidebarItemCustomization(
      label: 'Posts',
      icon: Icons.post_add,
    ),
    'persons': SidebarItemCustomization(
      label: 'Person',
      icon: Icons.person,
    ),
    'comments': SidebarItemCustomization(
      label: 'Comment',
      icon: Icons.comment,
    ),
    'settings': SidebarItemCustomization(
      label: 'Setting',
      icon: Icons.settings,
    ),
  },
)
```

This allows you to:

- **Customize labels** – Change the display name for any resource
- **Customize icons** – Use your own icons for better visual identification
- **Keep it simple** – Only customize what you need, leave the rest default

### Full Customization

For complete control over the admin interface, you can replace any component with your own custom widgets:

```dart
AdminDashboard(
  client: client,
  // Custom sidebar - completely replace the default sidebar
  customSidebarBuilder: (context, controller) {
    return CustomSidebar(controller: controller);
  },

  // Custom body/records pane - replace the default table view
  customBodyBuilder: (context, controller, operations) {
    return CustomBody(
      controller: controller,
      operations: operations,
    );
  },

  // Custom record details view
  customDetailsBuilder: (context, controller, operations, resource, record) {
    return CustomDetails(
      controller: controller,
      operations: operations,
      resource: resource,
      record: record,
    );
  },

  // Custom edit dialog
  customEditDialogBuilder: (context, controller, operations, resource,
      currentValues, onSubmit) {
    return CustomEditDialog(
      resource: resource,
      currentValues: currentValues,
      onSubmit: onSubmit,
    );
  },

  // Custom delete confirmation dialog
  customDeleteDialogBuilder: (context, controller, operations, resource,
      record, onConfirm) {
    return CustomDeleteDialog(
      resource: resource,
      record: record,
      onConfirm: onConfirm,
    );
  },

  // Custom create dialog
  customCreateDialogBuilder: (context, controller, operations, resource,
      onSubmit) {
    return CustomCreateDialog(
      resource: resource,
      onSubmit: onSubmit,
    );
  },

  // Custom footer (displayed above the default footer)
  customFooterBuilder: (context, controller) {
    return CustomFooter(controller: controller);
  },

  // Custom themes
  lightTheme: myLightTheme,
  darkTheme: myDarkTheme,
  initialThemeMode: ThemeMode.dark,
)
```

#### Available Customization Options

| Builder                     | Purpose                                | Parameters                                                             |
| --------------------------- | -------------------------------------- | ---------------------------------------------------------------------- |
| `customSidebarBuilder`      | Replace the entire sidebar             | `(context, controller)`                                                |
| `customBodyBuilder`         | Replace the records table view         | `(context, controller, operations)`                                    |
| `customDetailsBuilder`      | Replace the record details view        | `(context, controller, operations, resource, record)`                  |
| `customEditDialogBuilder`   | Replace the edit dialog                | `(context, controller, operations, resource, currentValues, onSubmit)` |
| `customDeleteDialogBuilder` | Replace the delete confirmation dialog | `(context, controller, operations, resource, record, onConfirm)`       |
| `customCreateDialogBuilder` | Replace the create dialog              | `(context, controller, operations, resource, onSubmit)`                |
| `customFooterBuilder`       | Add custom footer above default footer | `(context, controller)`                                                |

#### Custom Builder Guidelines

When creating custom builders, you have access to:

- **`AdminDashboardController`** – Provides access to:

  - `resources` – List of all registered resources
  - `selectedResource` – Currently selected resource
  - `loading` – Loading states
  - `themeMode` – Current theme mode
  - Methods to load data, refresh, etc.

- **`HomeOperations`** – Provides CRUD operations:

  - `list()` – Get list of records
  - `find()` – Find a specific record
  - `create()` – Create a new record
  - `update()` – Update an existing record
  - `delete()` – Delete a record

- **`AdminResource`** – Information about the resource:
  - `key` – Resource identifier
  - `tableName` – Database table name
  - `columns` – List of column definitions

#### Example: Custom Sidebar

```dart
Widget CustomSidebar(AdminDashboardController controller) {
  return Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('My Admin Panel'),
        ),
        ...controller.resources.map((resource) {
          final customization = controller.sidebarItemCustomizations?[resource.key];
          return ListTile(
            leading: Icon(customization?.icon ?? Icons.table_chart),
            title: Text(customization?.label ?? resource.tableName),
            selected: controller.selectedResource?.key == resource.key,
            onTap: () => controller.selectResource(resource),
          );
        }),
      ],
    ),
  );
}
```

#### Example: Custom Edit Dialog

```dart
Widget CustomEditDialog({
  required AdminResource resource,
  required Map<String, String> currentValues,
  required Future<bool> Function(Map<String, String> payload) onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final controllers = currentValues.map(
    (key, value) => MapEntry(key, TextEditingController(text: value)),
  );

  return AlertDialog(
    title: Text('Edit ${resource.tableName}'),
    content: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: resource.columns.map((column) {
            return TextFormField(
              controller: controllers[column.name],
              decoration: InputDecoration(labelText: column.name),
              enabled: !column.isId, // Disable editing ID fields
            );
          }).toList(),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            final payload = controllers.map(
              (key, controller) => MapEntry(key, controller.text),
            );
            final success = await onSubmit(payload);
            if (success && context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
```

---

## 🔒 Security & Access Control

### Role-Based Access Control

Serverpod Admin implements strict role-based access control:

- ✅ **Admin-Only Access** – By default, **all access requires the `serverpod.admin` scope**
- ✅ **Secure by Default** – Without admin privileges, users cannot access any part of the admin panel
- ✅ **Authentication Required** – The dashboard automatically shows a login screen for unauthenticated users
- ✅ **Scope Validation** – Users must have the `serverpod.admin` scope to access any admin functionality

**Important:** Without the `serverpod.admin` scope, users will see an error message and cannot access the admin panel, even if they successfully authenticate with email/password.

### Login Flow

1. User enters email and password on the login screen
2. Authentication is handled via `serverpod_auth_idp` (EmailAuthController)
3. Upon successful authentication, the system checks for the `serverpod.admin` scope
4. If the user has admin scope, they're granted access to the dashboard
5. If the user lacks admin scope, they see an error: "User does not have admin privileges"

---

## 🔮 What's Next?

This is a **proof of concept** that's already stable and production-ready. We're actively working on:

- ✅ **Export/Import** – Data portability built-in
- ✅ **Role-Based Access** – Secure your admin panel (✅ **Implemented**)
- ✅ **Comprehensive Testing** – Ensuring reliability

---

## 💡 The Vision

Serverpod Admin fills the gap that every Serverpod developer has felt. No more custom admin code. No more database dives. Just a beautiful, powerful admin panel that works out of the box.

**Welcome to the future of Serverpod administration.** 🎉
