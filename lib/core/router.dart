import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/features/auth/presentation/screens/login_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_choice_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_registration_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/wait_for_invite_screen.dart';
import 'package:konofrontend/features/auth/presentation/screens/worker_profile_screen.dart';
import 'package:konofrontend/features/owner/presentation/screens/owner_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.roleSelection,
  routes: [
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerLogin,
      builder: (context, state) =>
          const LoginScreen(title: 'Hello boss!', nextRoute: AppRoutes.ownerHome),
    ),
    GoRoute(
      path: AppRoutes.ownerHome,
      builder: (context, state) => const OwnerHomeScreen(),
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
        nextRoute: AppRoutes.workerWaitForInvite,
        wireToBackend: true,
      ),
    ),
    GoRoute(
      path: AppRoutes.workerWaitForInvite,
      builder: (context, state) => const WaitForInviteScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerProfile,
      builder: (context, state) => const WorkerProfileScreen(),
    ),
  ],
);
