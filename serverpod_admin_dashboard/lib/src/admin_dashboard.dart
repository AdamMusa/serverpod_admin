import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as admin_client;
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/auth_controller.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/routing/admin_router.dart';
import 'package:serverpod_admin_dashboard/src/screens/home.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/screens/login_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Lightweight customization of a resource's sidebar item, by resource key:
/// an icon, a label, or both.
///
/// ```dart
/// sidebarItemCustomizations: {
///   'ride': SidebarItemCustomization(icon: Icons.local_taxi),
///   'serverpod_future_call': SidebarItemCustomization(
///     label: 'Jobs',
///     icon: Icons.work_history,
///   ),
/// }
/// ```
class SidebarItemCustomization {
  const SidebarItemCustomization({this.label, this.icon})
      : assert(label != null || icon != null, 'Give a label, an icon or both.');

  /// Shown instead of the resource's label (the server's
  /// AdminOptions.label, else its table name); leave it out to keep that.
  final String? label;

  /// Shown instead of the default icon, also in the collapsed sidebar.
  final IconData? icon;
}

/// Builder function for custom sidebar widget
///
/// Receives the [BuildContext] and [AdminDashboardController] to build
/// a custom sidebar widget. The controller provides access to resources,
/// selected resource, loading states, etc.
typedef SidebarBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
);

/// Builder function for custom records pane/body widget
///
/// Receives the [BuildContext], [AdminDashboardController], and [HomeOperations]
/// to build a custom body/records pane widget. Use this to completely replace
/// the default records table view.
typedef BodyBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
);

/// Builder function for custom Serverpod jobs pane widget.
///
/// Receives the selected jobs [AdminResource], current job records, loading
/// state, error state, and the default callbacks used by [JobsView].
typedef JobsBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  List<Map<String, String>> records,
  bool isLoading,
  String? errorMessage,
  void Function(Map<String, String> record) onView,
  void Function(Map<String, String> record) onEdit,
  void Function(Map<String, String> record) onDiscard,
);

/// Builder function for custom record details widget
///
/// Receives the [BuildContext], [AdminDashboardController], [HomeOperations],
/// the [AdminResource], and the [Map] of record data to build a custom
/// record details view.
typedef DetailsBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> record,
);

/// Builder function for custom edit/update dialog widget
///
/// Receives the [BuildContext], [AdminDashboardController], [HomeOperations],
/// the [AdminResource], and the [Map] of current record values.
/// Should return a dialog that calls [onSubmit] with the updated payload when saved.
typedef EditDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> currentValues,
  Future<bool> Function(Map<String, String> payload) onSubmit,
);

/// Builder function for custom delete confirmation dialog widget
///
/// Receives the [BuildContext], [AdminDashboardController], [HomeOperations],
/// the [AdminResource], and the [Map] of record to delete.
/// Should return a dialog that calls [onConfirm] when deletion is confirmed.
typedef DeleteDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> record,
  Future<void> Function() onConfirm,
);

/// Builder function for custom create/new record dialog widget
///
/// Receives the [BuildContext], [AdminDashboardController], [HomeOperations],
/// and the [AdminResource].
/// Should return a dialog that calls [onSubmit] with the new record payload when saved.
typedef CreateDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Future<bool> Function(Map<String, String> payload) onSubmit,
);

/// Builder function for custom footer widget
///
/// Receives the [BuildContext] and [AdminDashboardController] to build
/// a custom footer widget. The custom footer will be displayed above the
/// default footer. The default footer is always shown and cannot be changed.
typedef FooterBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.client,
    this.title = 'Serverpod Admin Dashboard',
    this.initialThemeMode = ThemeMode.system,
    this.lightTheme,
    this.darkTheme,
    this.customSidebarBuilder,
    this.sidebarItemCustomizations,
    this.customBodyBuilder,
    this.customJobsBuilder,
    this.customDetailsBuilder,
    this.customEditDialogBuilder,
    this.customDeleteDialogBuilder,
    this.customCreateDialogBuilder,
    this.customFooterBuilder,
    this.loginTitle,
    this.loginSubtitle,
    this.staffScopes = const {},
    this.deepLinks = true,
  });

  final ServerpodClientShared client;
  final String title;
  final ThemeMode initialThemeMode;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  /// Optional custom sidebar builder. If provided, replaces the default sidebar.
  final SidebarBuilder? customSidebarBuilder;

  /// Optional map of sidebar item customizations.
  /// Key is the resource key, value contains a custom icon, label or both.
  /// Example: {'users': SidebarItemCustomization(icon: Icons.people)}
  final Map<String, SidebarItemCustomization>? sidebarItemCustomizations;

  /// Optional custom body/records pane builder. If provided, replaces the default records pane.
  final BodyBuilder? customBodyBuilder;

  /// Optional custom Serverpod jobs pane builder. If provided, replaces only
  /// the default jobs dashboard while keeping normal resources on [RecordsView].
  final JobsBuilder? customJobsBuilder;

  /// Optional custom record details builder. If provided, replaces the default record details view.
  final DetailsBuilder? customDetailsBuilder;

  /// Optional custom edit/update dialog builder. If provided, replaces the default edit dialog.
  final EditDialogBuilder? customEditDialogBuilder;

  /// Optional custom delete confirmation dialog builder. If provided, replaces the default delete dialog.
  final DeleteDialogBuilder? customDeleteDialogBuilder;

  /// Optional custom create/new record dialog builder. If provided, replaces the default create dialog.
  final CreateDialogBuilder? customCreateDialogBuilder;

  /// Optional custom footer builder. If provided, the custom footer will be
  /// displayed above the default footer. The default footer is always shown
  /// and cannot be changed.
  final FooterBuilder? customFooterBuilder;

  /// Optional login callback. If provided, a login screen will be shown first.
  /// The callback receives username and password and should return true if login
  /// is successful, false otherwise.
  /// Login screen title. Defaults to 'Serverpod Admin'.
  final String? loginTitle;

  /// Login screen subtitle.
  final String? loginSubtitle;

  /// Scope names, besides serverpod.admin, let in without asking the server.
  /// Optional: other users are let in when the server's
  /// AdminRegistry.staffScopes include one of theirs. The server decides
  /// what each may do.
  final Set<String> staffScopes;

  /// Keeps the open table, record, page, sort, search and filters in the
  /// address (for example `/admin/#/ride?status__exact=open&page=2`), so
  /// links can be shared and the browser's Back button works. It applies
  /// when the dashboard is the app (`runApp(AdminDashboard(...))`); inside
  /// another app's MaterialApp, which owns the address, it is off.
  final bool deepLinks;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final admin_client.EndpointAdmin _adminEndpoint =
      _resolveAdminEndpoint(widget.client);

  late final AuthController _authController =
      AuthController(
        client: widget.client,
        staffScopes: widget.staffScopes,
        serverAccess: () async => (await _adminEndpoint.access()).allowed,
      );

  late final AdminDashboardController _controller = AdminDashboardController(
    adminEndpoint: _adminEndpoint,
    initialThemeMode: widget.initialThemeMode,
  );

  bool _isRestoringAuthentication = true;

  late final AdminRouterDelegate _routerDelegate = AdminRouterDelegate(
    controller: _controller,
    builder: _buildContent,
  );

  bool _routing = false;

  @override
  void dispose() {
    if (_routing) _routerDelegate.dispose();
    _authController.removeListener(_onAuthStateChanged);
    // Note: Don't dispose _authController here as it might be used elsewhere
    super.dispose();
  }

  admin_client.EndpointAdmin _resolveAdminEndpoint(
    ServerpodClientShared client,
  ) {
    final module = client.moduleLookup['serverpod_admin'];

    if (module is admin_client.Caller) {
      return module.admin;
    }
    throw StateError(
      'Provided client has not registered the serverpod_admin module. '
      'Ensure config/generator.yaml includes it and regenerate code.',
    );
  }

  ThemeData get _lightTheme => widget.lightTheme ?? _buildLightTheme();
  ThemeData get _darkTheme => widget.darkTheme ?? _buildDarkTheme();

  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF6A5AE0);
    const surfaceTint = Color(0xFFF5F7FB);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(surface: surfaceTint, surfaceContainerHighest: Colors.white),
      scaffoldBackgroundColor: surfaceTint,
      appBarTheme: AppBarTheme(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: surfaceTint,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFFACA6FF);
    const darkBackground = Color(0xFF0E101D);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(surface: darkBackground),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF181B2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textTheme: Typography.whiteMountainView,
    );
  }

  @override
  void initState() {
    super.initState();
    _authController.addListener(_onAuthStateChanged);
    _restoreAuthentication();
  }

  Future<void> _restoreAuthentication() async {
    await _authController.restoreAuthentication();
    if (!mounted) return;
    setState(() {
      _isRestoringAuthentication = false;
    });
  }

  void _onAuthStateChanged() {
    print(
        "_onAuthStateChanged called - isAuthenticated: ${_authController.isAuthenticated}}");
    if (_authController.isAuthenticated) {
      _controller.loadResources();
    }
  }

  void _handleLogout() {
    // Sign out from the client by clearing the authentication key first
    try {
      (widget.client.auth as dynamic).keyManager?.remove();
    } catch (_) {
      // If keyManager is not available, just clear auth state
    }
    // Then logout from the controller - this will trigger rebuild via AnimatedBuilder
    // and replace Home widget with LoginScreen
    _authController.logout();
  }

  @override
  Widget build(BuildContext context) {
    // Inside another app, that app's navigator owns the address.
    final routing = widget.deepLinks && Navigator.maybeOf(context) == null;
    _routing = _routing || routing;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _authController]),
      builder: (context, _) {
        if (routing) {
          return MaterialApp.router(
            title: widget.title,
            themeMode: _controller.themeMode,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            debugShowCheckedModeBanner: false,
            routerDelegate: _routerDelegate,
            routeInformationParser: const AdminRouteParser(),
          );
        }
        return MaterialApp(
          title: widget.title,
          themeMode: _controller.themeMode,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          debugShowCheckedModeBanner: false,
          home: Builder(builder: _buildContent),
        );
      },
    );
  }

  /// The sign-in screen, or the dashboard once signed in.
  Widget _buildContent(BuildContext context) {
    if (_isRestoringAuthentication) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (!_authController.isAuthenticated) {
      return LoginScreen(
        authController: _authController,
        title: widget.loginTitle ?? 'Serverpod Admin',
        subtitle: widget.loginSubtitle,
      );
    }
    return Home(
      controller: _controller,
      title: widget.title,
      customSidebarBuilder: widget.customSidebarBuilder,
      sidebarItemCustomizations: widget.sidebarItemCustomizations,
      customBodyBuilder: widget.customBodyBuilder,
      customJobsBuilder: widget.customJobsBuilder,
      customDetailsBuilder: widget.customDetailsBuilder,
      customEditDialogBuilder: widget.customEditDialogBuilder,
      customDeleteDialogBuilder: widget.customDeleteDialogBuilder,
      customCreateDialogBuilder: widget.customCreateDialogBuilder,
      customFooterBuilder: widget.customFooterBuilder,
      client: widget.client,
      onLogout: _handleLogout,
    );
  }
}
