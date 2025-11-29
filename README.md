# Serverpod Admin – The Missing Admin Panel for Serverpod 🎯

**Finally, an admin panel that Serverpod deserves!**

You've built an amazing Serverpod app with powerful endpoints, robust models, and a beautiful frontend. But when it comes to managing your data, you're stuck writing custom endpoints, building one-off admin pages, or worse—directly accessing the database.

**That's where Serverpod Admin comes in.** This is the missing piece that transforms your Serverpod backend into a fully manageable system.

---

## 🏠 Admin Dashboard Overview

![Admin Dashboard](images/posts.png)

Browse and manage all your data with a beautiful, intuitive interface.

![Search & Filter](images/search.png)

Powerful search and filtering capabilities to find exactly what you need.

![Edit Records](images/edit.png)

Edit records with a clean, user-friendly interface.

![Record Details](images/detail.png)

View detailed information about any record.

![Empty State](images/empty_record.png)

Beautiful empty states when no records are found.

---

## ✨ Why Serverpod Admin Matters

### 🚀 **Zero Configuration, Maximum Power**

No more writing boilerplate CRUD endpoints. Register your models once, and instantly get a complete admin interface with:

- **Browse & Search** – Navigate through all your data with powerful filtering
- **Create & Edit** – Intuitive forms for managing records
- **Delete** – Safe deletion with proper validation
- **Pagination** – Handle large datasets effortlessly

### 🎨 **Frontend-Agnostic Architecture**

Built with flexibility in mind. The `serverpod_admin_server` exposes a clean API that any frontend can consume. Start with Flutter today, switch to Jaspr tomorrow, or build your own custom admin UI—the choice is yours!

### ⚡ **Built for Serverpod Developers**

- **Type-Safe** – Leverages Serverpod's generated protocol classes
- **Integrated** – Works seamlessly with your existing Serverpod setup
- **Extensible** – Designed to grow with your needs

### 🛠️ **Developer Experience First**

Stop spending days building admin interfaces. Get back to building features that matter. With Serverpod Admin, you can have a production-ready admin panel in **minutes**, not weeks.

---

## 📦 Installation

Add the packages to your `pubspec.yaml`:

```yaml
dependencies:
  serverpod_admin_server:
  serverpod_admin_dashboard:
```

Then run:

```bash
flutter pub get
```

**That's it! You're good to go!** 🚀

---

## 🧩 Quick Start

### Registering Models (Server Side)

```dart
import 'package:first_site_server/src/generated/protocol.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

void registerAdminModule() {
  admin.configureAdminModule((registry) {
    registry.register<Blog>();
    registry.register<Person>();
    // Add any model you want to manage!
  });
}
```

**Call `registerAdminModule()` in your `server.dart` file just after `pod.start()`**

### Using the Admin Dashboard (Flutter)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  client = Client('http://localhost:8080/')
    ..connectivityMonitor = FlutterConnectivityMonitor();
  runApp(AdminDashboard(client: client));
}
```

**That's it!** You now have a fully working admin panel for your Serverpod app! 🚀🎉

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

## 🔮 What's Next?

This is a **proof of concept** that's already stable and production-ready. We're actively working on:

- ✅ **Full Customization** – Tailor every aspect to your needs
- ✅ **Advanced Filtering** – Complex queries made simple
- ✅ **Bulk Operations** – Manage multiple records at once
- ✅ **Export/Import** – Data portability built-in
- ✅ **Role-Based Access** – Secure your admin panel
- ✅ **Comprehensive Testing** – Ensuring reliability

---

## 💡 The Vision

Serverpod Admin fills the gap that every Serverpod developer has felt. No more custom admin code. No more database dives. Just a beautiful, powerful admin panel that works out of the box.

**Welcome to the future of Serverpod administration.** 🎉
