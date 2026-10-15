import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/routing/admin_route.dart';

/// Reads and writes the dashboard's address (see [AdminRoute]).
class AdminRouteParser extends RouteInformationParser<AdminRoute> {
  const AdminRouteParser();

  @override
  Future<AdminRoute> parseRouteInformation(
    RouteInformation routeInformation,
  ) => SynchronousFuture(AdminRoute.fromUri(routeInformation.uri));

  @override
  RouteInformation restoreRouteInformation(AdminRoute configuration) =>
      RouteInformation(uri: configuration.toUri());
}

/// Keeps the browser's address and history in step with what the
/// dashboard shows: each table, page, sort, filter or record opened adds a
/// history entry, so links can be shared and Back returns to the previous
/// one. Refining a search, or correcting an address that names something
/// gone, replaces the current entry instead.
class AdminRouterDelegate extends RouterDelegate<AdminRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AdminRoute> {
  AdminRouterDelegate({required this.controller, required this.builder}) {
    _reported = controller.route;
    controller.addListener(_onControllerChanged);
  }

  final AdminDashboardController controller;

  /// Builds what is shown: the sign-in screen or the dashboard.
  final WidgetBuilder builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AdminRoute? _reported;

  @override
  AdminRoute get currentConfiguration => controller.route;

  void _onControllerChanged() {
    final route = controller.route;
    final replace = controller.takeRouteReplace();
    final previous = _reported;
    if (route == previous) return;
    _reported = route;
    final context = navigatorKey.currentContext;
    if (context != null && (replace || _refinesSearch(previous, route))) {
      Router.neglect(context, notifyListeners);
    } else {
      notifyListeners();
    }
  }

  /// Typing in the search box changes one entry rather than adding one per
  /// letter; starting or clearing a search adds one.
  static bool _refinesSearch(AdminRoute? previous, AdminRoute route) =>
      previous != null &&
      previous.search.isNotEmpty &&
      route.search.isNotEmpty &&
      previous.withSearch('') == route.withSearch('');

  @override
  Future<void> setNewRoutePath(AdminRoute configuration) {
    _reported = configuration;
    return controller.applyRoute(configuration);
  }

  /// Closes a dialog or the drawer first, then an open record.
  @override
  Future<bool> popRoute() async {
    if (await super.popRoute()) return true;
    if (controller.isShowingDetails) {
      controller.closeDetails();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: const ValueKey('serverpod_admin'),
        child: Builder(builder: builder),
      ),
    ],
    onDidRemovePage: (_) {},
  );

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    super.dispose();
  }
}
