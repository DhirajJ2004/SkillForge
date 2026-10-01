import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devpath/main.dart';
import 'package:devpath/data/services/storage_service.dart';
import 'package:devpath/providers/app_providers.dart';

void main() {
  testWidgets('DevPath app loads and mounts successfully',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: const DevPathApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(DevPathApp), findsOneWidget);
  });
}
