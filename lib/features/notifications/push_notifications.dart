import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/messenger.dart';
import 'package:konofrontend/core/network/jwt_claims.dart';
import 'package:konofrontend/core/network/token_refresher.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/features/notifications/device_repository.dart';
import 'package:konofrontend/features/worker/data/invite_repository.dart';
import 'package:konofrontend/features/worker/data/menu_sync.dart';

// Registers this device for pushes and handles them while a worker screen watches it.
// Only foreground messages are handled; missed ones are caught up when the worker home resumes.
//
// getToken/onTokenRefresh are deprecated in favour of register/onRegistered, but those return a
// Firebase Installation ID, while the backend sends to FCM registration tokens.
// ignore_for_file: deprecated_member_use
final pushNotificationsProvider = FutureProvider.autoDispose<void>((ref) async {
  final messaging = FirebaseMessaging.instance;
  final deviceRepository = ref.read(deviceRepositoryProvider);

  final subscriptions = [
    messaging.onTokenRefresh.listen(deviceRepository.register),
    FirebaseMessaging.onMessage.listen((message) => _handleMessage(ref, message)),
  ];
  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  });

  await messaging.requestPermission();
  final token = await messaging.getToken();
  if (token != null) await deviceRepository.register(token);
});

void _handleMessage(Ref ref, RemoteMessage message) {
  // Android only shows notification messages itself while the app is in the background.
  final notification = message.notification;
  if (notification != null) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notification.body ?? notification.title ?? '')));
  }

  switch (message.data['type']) {
    case 'restaurant_invite':
      ref.invalidate(myInvitesProvider);
    case 'kicked_from_restaurant':
      // The refreshed token is unemployed, which sends the app to the invites screen.
      ref.read(tokenRefresherProvider).refresh();
    case 'menu_updated':
      if (ref.exists(menuSyncProvider) &&
          ref.read(menuSyncProvider).value != message.data['menuHash']) {
        ref.read(menuSyncProvider.notifier).checkForUpdates();
      }
  }
}

// Stops pushes to this device for the user who is signing out. Owners never register a device.
Future<void> unregisterDevice(WidgetRef ref) async {
  final claims = decodeJwtPayload(await ref.read(tokenStorageProvider).getAccessToken());
  if (claims == null || claims['accountType'] == 'owner') return;

  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await ref.read(deviceRepositoryProvider).remove(token);
  } on FirebaseException {
    return;
  }
}
