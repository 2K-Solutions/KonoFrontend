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
  static const workerCurrentOrder = '/worker/order';
  static const workerTables = '/worker/tables';
  static const workerEditOrder = '/worker/orders/:orderId';

  static String workerEditOrderFor(String orderId) => '/worker/orders/$orderId';

  // A menu route ([workerDrinks] or [workerFood]) that adds items to the given order being edited
  // instead of the order currently being taken.
  static String workerMenuFor(String menuRoute, {required String orderId}) =>
      Uri(path: menuRoute, queryParameters: {'order': orderId}).toString();

  static String homeFor(String? accountType) {
    return switch (accountType) {
      'owner' => restaurantSelection,
      'worker' => workerHome,
      _ => workerInvites,
    };
  }
}
