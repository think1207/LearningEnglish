import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/sorting_screen.dart';
import 'package:banexy/screens/sort_complete_screen.dart';
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

  Future<void> setSurfaceSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
  }

  testWidgets('SortingScreen completes sorting and shows SortCompleteScreen', (
    tester,
  ) async {
    await setSurfaceSize(tester);
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

    // Swipe the first card left (Don't know -> add to retry/learning list).
    await swipeCard(
      tester,
      find.byKey(const ValueKey('1')),
      const Offset(-400, 0),
    );

    // Verify the second card is now the active card.
    expect(find.byKey(const ValueKey('2')), findsOneWidget);

    // Swipe the second card left.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('2')),
      const Offset(-400, 0),
    );

    // Verify SortCompleteScreen is shown.
    expect(find.byType(SortCompleteScreen), findsOneWidget);
    expect(find.text('準備完了'), findsOneWidget);
    expect(find.textContaining('2個の新しい単語を選びました'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
  });

  testWidgets('SortingScreen undo functionality', (tester) async {
    await setSurfaceSize(tester);
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

    // Swipe the first card left.
    await swipeCard(
      tester,
      find.byKey(const ValueKey('1')),
      const Offset(-400, 0),
    );

    // Now Word 2 should be on top.
    expect(find.byKey(const ValueKey('2')), findsOneWidget);
    expect(find.byKey(const ValueKey('1')), findsNothing);

    // Tap Undo.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // Word 1 should be back on top.
    expect(find.byKey(const ValueKey('1')), findsOneWidget);
  });
}
