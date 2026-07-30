import 'package:go_router/go_router.dart';
import '../../domain/entities/apex_game.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/how_it_works/how_it_works_screen.dart';
import '../../presentation/screens/permissions/permissions_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/game_detail/game_detail_screen.dart';
import '../../presentation/screens/gfx_profile/gfx_profile_screen.dart';
import '../../presentation/screens/configuracoes/honest_booster_mode_screen.dart';
import '../../presentation/screens/result_card/result_card_screen.dart';
import '../../presentation/screens/share_studio/share_studio_screen.dart';
import '../../domain/entities/session_record.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/how-it-works',
      builder: (context, state) => const HowItWorksScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game-detail/:id',
      builder: (context, state) => GameDetailScreen(
        gameId: state.pathParameters['id'] ?? '',
        initialGame: state.extra is ApexGame ? state.extra as ApexGame : null,
      ),
    ),
    GoRoute(
      path: '/gfx-profile/:id',
      builder: (context, state) => GfxProfileScreen(
        gameId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/honest-booster-mode',
      builder: (context, state) => const HonestBoosterModeScreen(),
    ),
    GoRoute(
      path: '/share-studio/:gameId',
      builder: (context, state) => ApexStudioScreen(
        gameId: state.pathParameters['gameId'] ?? '',
        initialMediaPath: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/result-card',
      builder: (context, state) => ResultCardScreen(
        session: state.extra is SessionRecord ? state.extra as SessionRecord : null,
      ),
    ),
  ],
);
