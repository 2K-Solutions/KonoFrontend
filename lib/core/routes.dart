class AppRoutes {
  const AppRoutes._();

  static const startup = '/startup';
  static const roleSelection = '/';
  static const ownerLogin = '/owner/login';
  static const restaurantSelection = '/owner/restaurants';
  static const ownerHome = '/owner/home';
  static const ownerInviteWorker = '/owner/invite';
  static const workerChoice = '/worker';
  static const workerRegister = '/worker/register';
  static const workerLogin = '/worker/login';
  static const workerInvites = '/worker/invites';
  static const workerProfile = '/worker/profile';
  static const workerHome = '/worker/home';
  static const workerDrinks = '/worker/menu/drinks';
  static const workerFood = '/worker/menu/food';

  static String homeFor(String? accountType) {
    return switch (accountType) {
      'owner' => restaurantSelection,
      'worker' => workerHome,
      _ => workerInvites,
    };
  }
}
