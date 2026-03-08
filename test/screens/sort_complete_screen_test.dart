import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/sort_complete_screen.dart';

void main() {
  final testWords = List.generate(
    7,
    (i) => WordCard(
      id: '$i',
      text: 'Word $i',
      meaning: 'Meaning $i',
      category: 'test',
      partOfSpeech: 'Noun',
    ),
  );

  Widget createTestWidget(List<WordCard> retryList) {
    return MaterialApp(home: SortCompleteScreen(retryList: retryList));
  }

  testWidgets('SortCompleteScreen displays correct count and limited chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget(testWords));

    // タイトルの確認
    expect(find.text('準備完了'), findsOneWidget);

    // 個数の確認 (7個)
    expect(find.textContaining('7個の新しい単語を選びました'), findsOneWidget);

    // 単語チップの確認 (5個まで表示)
    expect(find.text('Word 0'), findsOneWidget);
    expect(find.text('Word 1'), findsOneWidget);
    expect(find.text('Word 2'), findsOneWidget);
    expect(find.text('Word 3'), findsOneWidget);
    expect(find.text('Word 4'), findsOneWidget);
    expect(find.text('Word 5'), findsNothing); // 6個目は非表示

    // 残り個数の表示 (+2)
    expect(find.text('+2'), findsOneWidget);

    // ボタンの存在確認
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('SortCompleteScreen shows all chips when 5 or fewer words', (
    WidgetTester tester,
  ) async {
    final fewWords = testWords.take(3).toList();
    await tester.pumpWidget(createTestWidget(fewWords));

    expect(find.textContaining('3個の新しい単語を選びました'), findsOneWidget);
    expect(find.text('Word 0'), findsOneWidget);
    expect(find.text('Word 1'), findsOneWidget);
    expect(find.text('Word 2'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('SortCompleteScreen pops when clicking close icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SortCompleteScreen(retryList: [testWords[0]]),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.byType(SortCompleteScreen), findsOneWidget);

    // AppBarの閉じるボタンをタップ
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SortCompleteScreen), findsNothing);
  });

  testWidgets('SortCompleteScreen pops when clicking Later button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SortCompleteScreen(retryList: [testWords[0]]),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    // Laterボタンをタップ
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.byType(SortCompleteScreen), findsNothing);
  });
}
