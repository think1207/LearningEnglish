import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/sorting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final testWords = [
    WordCard(
      id: '1',
      text: 'Word 1',
      meaning: 'Meaning 1',
      category: 'test',
      partOfSpeech: 'Noun',
    ),
    WordCard(
      id: '2',
      text: 'Word 2',
      meaning: 'Meaning 2',
      category: 'test',
      partOfSpeech: 'Noun',
    ),
  ];

  // Helper function to reliably perform a swipe gesture for the test.
  Future<void> swipeCard(
    WidgetTester tester,
    Finder card,
    Offset offset,
  ) async {
    // Simulate the drag gesture.
    await tester.drag(card, offset);
    // Pump a few frames to ensure the drag animation completes and the
    // onDragEnd callback is properly processed.
    await tester.pumpAndSettle();
  }

  testWidgets('SortingScreen shows cards and completes session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final wordsForTest = testWords.map((e) => e.copyWith()).toList();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        home: SortingScreen(initialQueue: wordsForTest),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('1')), findsOneWidget);

    // Swipe the first card right.
    // Use a larger offset to exceed 30% of screen width (standard test width is 800)
    await swipeCard(
      tester,
      find.byKey(const ValueKey('1')),
      const Offset(400, 0),
    );

    // Verify the second card is now the active card.
    expect(find.byKey(const ValueKey('2')), findsOneWidget);

    // Swipe the second card right.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('2')),
      const Offset(400, 0),
    );

    // Verify the completion screen is shown.
    expect(find.text('本日の学習終了！'), findsOneWidget);
  });

  testWidgets('SortingScreen goes to review phase', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final wordsForTest = testWords.map((e) => e.copyWith()).toList();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        home: SortingScreen(initialQueue: wordsForTest),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('1')), findsOneWidget);

    // Swipe left to mark for review.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('1')),
      const Offset(-400, 0),
    );

    // Verify the second card is now active.
    expect(find.byKey(const ValueKey('2')), findsOneWidget);

    // Swipe the second card right.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('2')),
      const Offset(400, 0),
    );

    // Verify the review ready screen is shown.
    expect(find.text('復習の準備ができました'), findsOneWidget);
    expect(find.text('苦手な 1語を復習します'), findsOneWidget);

    // Start the review.
    await tester.tap(find.text('スタート'));
    await tester.pumpAndSettle();

    // Verify the card for review is shown again.
    expect(find.byKey(const ValueKey('1')), findsOneWidget);

    // Swipe the card right to master it.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('1')),
      const Offset(400, 0),
    );

    // Verify the completion screen is shown.
    expect(find.text('本日の学習終了！'), findsOneWidget);
  });
}
