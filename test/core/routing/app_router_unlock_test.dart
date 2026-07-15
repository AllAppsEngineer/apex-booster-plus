import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:apex_booster_plus/core/routing/app_router.dart';

void main() {
  test('appRouter contains /unlock route', () {
    final routes = appRouter.configuration.routes;
    bool found = false;
    void visit(List<RouteBase> list) {
      for (final r in list) {
        if (r is GoRoute && r.path == '/unlock') {
          found = true;
        }
        visit(r.routes);
      }
    }
    visit(routes);
    expect(found, true);
  });
}
