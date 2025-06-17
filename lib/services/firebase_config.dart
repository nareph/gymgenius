import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/services/logger_service.dart';

/// Configures the application to use local Firebase emulators.
///
/// This function should be called at app startup during debug mode
/// to redirect all Firebase calls (Auth, Firestore, Functions)
/// to the services running on the development machine.
Future<void> configureFirebaseEmulators() async {
  // --- HOST CONFIGURATION ---
  // The host IP address depends on the testing environment:
  //
  // - For the Android Emulator: use '10.0.2.2'. This is a special alias
  //   that allows the emulator to access the host machine's 'localhost'.
  //
  // - For the iOS Simulator, web, or desktop: 'localhost' usually works.
  //
  // - For a physical device (Android/iOS): you MUST use your machine's
  //   local IP address on the Wi-Fi network (e.g., '192.168.1.15').
  //   Ensure that your device and computer are on the same network.
  //   You can find this IP using 'ipconfig' (Windows) or 'ifconfig' (macOS/Linux).

  // The line below automatically detects the platform to choose the correct address.
  // MODIFY IT if you are testing on a physical device.

  final String host = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';

  // !! FOR PHYSICAL DEVICE TESTING, UNCOMMENT AND ADAPT THE FOLLOWING LINE:
  //final String host = '192.168.8.46'; // Replace with YOUR local IP address

  Log.info('--- CONFIGURING FIREBASE EMULATORS ---');
  Log.info('Debug mode enabled. Connecting to host: $host');

  try {
    // 1. Authentication Emulator
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    Log.debug('-> FirebaseAuth emulator configured on $host:9099');

    // 2. Firestore Emulator
    // Note: Persistence is disabled with the emulator to prevent
    // cache conflicts between testing sessions.
    FirebaseFirestore.instance.settings = Settings(
      host: '$host:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    Log.debug('-> FirebaseFirestore emulator configured on $host:8080');

    // 3. Cloud Functions Emulator
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    Log.debug('-> FirebaseFunctions emulator configured on $host:5001');

    Log.info('--- Firebase emulators configured successfully ---');
  } catch (e, stack) {
    Log.error(
      'An error occurred while configuring Firebase emulators. '
      'Please ensure the emulator suite is running via `firebase emulators:start` '
      'and that the host IP address is correct.',
      error: e,
      stackTrace: stack,
    );
  }
}
