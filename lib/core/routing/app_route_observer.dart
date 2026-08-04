import 'package:flutter/material.dart';

/// PREP-PANEL-SCANNER-LIFECYCLE-U2C-B: shared [RouteObserver] registered on
/// [appRouter]'s `observers`. Lets any [RouteAware] widget (currently only
/// the Game Detail preparation panel's ambient scanner) learn when its own
/// route is covered by another pushed route and when it becomes visible
/// again — a case plain [TickerMode] does not cover on its own (see the
/// routing PoC documented in preparation_panel_test.dart).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
