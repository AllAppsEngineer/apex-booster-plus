import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:apex_booster_plus/core/routing/app_route_observer.dart';
import 'package:apex_booster_plus/core/routing/app_router.dart';

void main() {
  List<String> collectPaths() {
    final paths = <String>[];
    void visit(List<RouteBase> list) {
      for (final r in list) {
        if (r is GoRoute) paths.add(r.path);
        visit(r.routes);
      }
    }

    visit(appRouter.configuration.routes);
    return paths;
  }

  test(
    'appRouter registers the shared route observer exactly once '
    '(PREP-PANEL-SCANNER-LIFECYCLE-U2C-B)',
    () {
      expect(appRouter.routerDelegate.builder.observers, [appRouteObserver]);
    },
  );

  test('all pre-existing routes remain registered', () {
    final paths = collectPaths();
    expect(paths, contains('/'));
    expect(paths, contains('/welcome'));
    expect(paths, contains('/how-it-works'));
    expect(paths, contains('/permissions'));
    expect(paths, contains('/home'));
    expect(paths, contains('/game-detail/:id'));
    expect(paths, contains('/gfx-profile/:id'));
    expect(paths, contains('/honest-booster-mode'));
    expect(paths, contains('/share-studio/:gameId'));
    expect(paths, contains('/result-card'));
  });
}
