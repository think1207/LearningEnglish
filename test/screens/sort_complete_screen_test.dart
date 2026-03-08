import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/sort_complete_screen.dart';
import 'package:banexy/screens/learning_list_screen.dart';

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

  Future<void> setSurfaceSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
  }

  testWidgets('SortCompleteScreen displays correct count and limited chips', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget(testWords));

    // AppHeaderのタイトルの確認
    expect(find.text('Sort Complete'), findsOneWidget);
    // サブタイトルの確認
    expect(find.text('仕分け完了'), findsOneWidget);

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

  testWidgets('Start Learning button navigates to LearningListScreen', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget(testWords));

    // Start Learning ボタンをタップ
    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();

    // LearningListScreen に遷移したことを確認
    expect(find.byType(LearningListScreen), findsOneWidget);
    expect(find.text("Today's New Words"), findsOneWidget);
    // AppHeader内のsubtitleWidgetに含まれるテキストを確認
    expect(find.text('7 words to learn'), findsOneWidget);
  });

  testWidgets('SortCompleteScreen pops when clicking close icon', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
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

    // AppHeader内の閉じるボタンをタップ
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SortCompleteScreen), findsNothing);
  });

  testWidgets('SortCompleteScreen pops when clicking Later button', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
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
