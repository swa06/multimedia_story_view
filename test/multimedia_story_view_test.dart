import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimedia_story_view/multimedia_story_view.dart';

void main() {
  const MethodChannel channel = MethodChannel('multimedia_story_view');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
