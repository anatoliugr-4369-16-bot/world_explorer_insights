import 'package:flutter_test/flutter_test.dart';
import 'package:world_explorer_insights/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldExplorerApp());
    expect(find.text('World Explorer\nInsights'), findsOneWidget);
  });
}
