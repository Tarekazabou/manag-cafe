import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  var content = file.readAsStringSync();
  
  // Replace the generated localization import with custom localized output
  content = content.replaceAll(
    "import 'package:flutter_gen/gen_l10n/app_localizations.dart';",
    "import 'package:coffee_shop_manager/l10n/app_localizations.dart';\nimport 'firebase_options.dart';"
  );
  
  // Update initialization app wrapper
  content = content.replaceAll(
    "await Firebase.initializeApp();", 
    "await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);"
  );
  
  // Wrap messaging inside a try block, completely handling all those variables safely
  content = content.replaceFirst(
    '''  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  final token = await messaging.getToken();
  logger.info(' FCM Token: \');''',
    '''  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    logger.info(' FCM Token: \');
  } catch (e) {
    logger.error('Ignoring web notification permission crash.', error: e);
  }'''
  );

  // Fix the card themes
  content = content.replaceAll('cardTheme: const CardTheme(', 'cardTheme: const CardThemeData(');
  
  file.writeAsStringSync(content);
}
