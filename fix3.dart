import 'dart:io';
void main() {
  var file = File('lib/main.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('CardTheme(', 'CardThemeData(');
  content = content.replaceFirst('final messaging = FirebaseMessaging.instance;', 'try { final messaging = FirebaseMessaging.instance;');
  content = content.replaceFirst('logger.info(\' FCM Token: \\');', 'logger.info(\' FCM Token: \\'); } catch(e) { }');
  file.writeAsStringSync(content);
}
