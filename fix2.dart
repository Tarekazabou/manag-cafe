import 'dart:io';
void main() {
  var file = File('lib/main.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '''  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  final token = await messaging.getToken();''',
    '''  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    logger.info('FCM Token: \');
  } catch (e) {
    logger.error('Ignoring FCM error on web', error: e);
  }'''
  );
  file.writeAsStringSync(content);
}
