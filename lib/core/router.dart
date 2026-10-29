import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/features/auth/presentation/screens/login_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/startup_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_choice_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_registration_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_profile_screen.dart';
import 'package:konofrontend/features/owner/presentation/screens/invite_worker_screen.dart';
import 'package:konofrontend/features/owner/presentation/screens/owner_home_screen.dart';
import 'package:konofrontend/features/owner/presentation/screens/restaurant_selection_screen.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';
import 'package:konofrontend/features/worker/presentation/screens/menu_screen.dart';
import 'package:konofrontend/features/worker/presentation/screens/worker_home_screen.dart';
import 'package:konofrontend/features/worker/presentation/screens/worker_invites_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.startup,
  routes: [
    GoRoute(
      path: AppRoutes.startup,
      builder: (context, state) => const StartupScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerLogin,
      builder: (context, state) => const LoginScreen(
        title: 'Hello boss!',
        nextRoute: AppRoutes.restaurantSelection,
        wireToBackend: true,
        isOwnerLogin: true,
      ),
    ),
    GoRoute(
      path: AppRoutes.restaurantSelection,
      builder: (context, state) => const RestaurantSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerHome,
      builder: (context, state) => const OwnerHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerInviteWorker,
      builder: (context, state) => const InviteWorkerScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerChoice,
      builder: (context, state) => const WorkerChoiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerRegister,
      builder: (context, state) => const WorkerRegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerLogin,
      builder: (context, state) => const LoginScreen(
        title: 'You are doing a good job today!',
        nextRoute: AppRoutes.workerInvites,
        wireToBackend: true,
      ),
    ),
    GoRoute(
      path: AppRoutes.workerInvites,
      builder: (context, state) => const WorkerInvitesScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerHome,
      builder: (context, state) => const WorkerHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerDrinks,
      builder: (context, state) => const MenuScreen(category: MenuCategory.drinks),
    ),
    GoRoute(
      path: AppRoutes.workerFood,
      builder: (context, state) => const MenuScreen(category: MenuCategory.food),
    ),
    GoRoute(
      path: AppRoutes.workerProfile,
      builder: (context, state) => const WorkerProfileScreen(),
    ),
  ],
);
