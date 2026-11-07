import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/messenger.dart';
import 'package:konofrontend/core/network/token_refresher.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/core/router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/features/worker/data/menu_sync.dart';
import 'package:konofrontend/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  runApp(const ProviderScope(child: KonoApp()));
}

class KonoApp extends ConsumerWidget {
  const KonoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A token refresh moved the user to another restaurant, out of one, or signed them out.
    ref.listen(sessionChangesProvider, (_, next) async {
      final change = next.value;
      if (change == null) return;
      await clearLocalMenu(ref);
      ref.invalidate(menuSyncProvider);
      ref.invalidate(accessTokenClaimsProvider);
      appRouter.go(
        change.isSignedOut ? AppRoutes.roleSelection : AppRoutes.homeFor(change.accountType),
      );
    });

    return MaterialApp.router(
      title: 'Kono',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
    );
  }
}
