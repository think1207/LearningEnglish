import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_english/screens/add_word_screen.dart';
import 'package:learning_english/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget createHomeScreen() {
    return const MaterialApp(home: HomeScreen());
  }

  // Helper to set a larger screen size for tests to avoid scrolling.
  Future<void> setLargeScreenSize(WidgetTester tester) async {
    final size = const Size(800, 1200);
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets('HomeScreen shows loading indicator and then content', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await setLargeScreenSize(tester);

    await tester.pumpWidget(createHomeScreen());

    // Initially, loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async operations and animations to settle.
    await tester.pumpAndSettle();

    // After loading, content is shown
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('My Vocab App'), findsOneWidget);
    expect(find.text('Total Progress'), findsOneWidget);

    // Find the button by its text, which is more robust to scrolling.
    expect(find.text('Start Session (10 Words)'), findsOneWidget);
  });

  testWidgets('HomeScreen navigates to AddWordScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await setLargeScreenSize(tester);

    await tester.pumpWidget(createHomeScreen());

    // Wait for the initial loading to complete.
    await tester.pumpAndSettle();

    // Now on the content screen, tap the FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));

    // Wait for the navigation animation to complete.
    await tester.pumpAndSettle();

    expect(find.byType(AddWordScreen), findsOneWidget);
  });
}
