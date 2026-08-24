import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/datasources/quran_local_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/bookmark_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await QuranLocalDataSource.init();
  await BookmarkRepository.init();

  // See AuthRepository.isFirebaseSupportedOnThisPlatform: firebase_options.dart
  // has no Linux configuration, so Firebase is skipped there entirely and
  // bookmarks stay device-local (Hive-only) on that platform.
  if (isFirebaseSupportedOnThisPlatform) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await AuthRepository().ensureSignedIn();
  }

  runApp(const ProviderScope(child: HolyQuranApp()));
}
