import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:desa_apps/main.dart';
import 'package:desa_apps/state/app_state.dart';

void main() {
  testWidgets('DesaApps smoke test loads main screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const DesaApps(),
      ),
    );

    // Verify app title or core elements exist
    expect(find.text('Desa Apps - RW 05'), findsOneWidget);
  });
}
