import 'package:flutter_test/flutter_test.dart';

import 'package:cinematic_camera_app/app/app.dart';

void main() {
  testWidgets('app renders the cinematic camera shell', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Cinematic Camera'), findsOneWidget);
    expect(find.text('16:9'), findsOneWidget);
    expect(find.byType(App), findsOneWidget);
  });
}
