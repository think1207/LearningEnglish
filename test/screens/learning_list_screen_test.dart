import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/screens/learning_list_screen.dart';
import 'package:banexy/models/word.dart';

void main() {
  final testWords = [
    WordCard(
      id: '1',
      text: 'Agile',
      meaning: '俊敏な / アジャイル開発',
      category: 'Technology',
      partOfSpeech: 'Noun',
      example: 'We use Agile methodology.',
      exampleTranslation: '私たちはアジャイル手法を使っています。',
      synonyms: ['Nimble', 'Quick'],
    ),
    WordCard(
      id: '2',
      text: 'Consensus',
      meaning: '合意 / 総意',
      category: 'Business',
      partOfSpeech: 'Noun',
    ),
  ];

  Widget createLearningListScreen() {
    return MaterialApp(home: LearningListScreen(wordsToLearn: testWords));
  }

  testWidgets('LearningListScreen displays correct number of words', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLearningListScreen());

    expect(find.text("Today's New Words"), findsOneWidget);
    expect(find.text('2 words to learn'), findsOneWidget);
    expect(find.text('Agile'), findsOneWidget);
    expect(find.text('Consensus'), findsOneWidget);
  });

  testWidgets('Tapping a word expands its details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLearningListScreen());

    // 最初は意味や例文が表示されていないことを確認（isExpandedがfalseの状態）
    expect(find.text('俊敏な / アジャイル開発'), findsNothing);
    expect(find.text('Example'), findsNothing);

    // Agileのカードをタップして展開
    await tester.tap(find.text('Agile'));
    await tester.pumpAndSettle();

    // 展開後の詳細が表示されていることを確認
    expect(find.text('俊敏な / アジャイル開発'), findsOneWidget);
    expect(find.text('Example'), findsOneWidget);
    expect(find.text('We use Agile methodology.'), findsOneWidget);
    expect(find.text('私たちはアジャイル手法を使っています。'), findsOneWidget);
    expect(find.text('Nimble'), findsOneWidget);
    expect(find.text('Quick'), findsOneWidget);

    // もう一度タップして閉じる
    await tester.tap(find.text('Agile'));
    await tester.pumpAndSettle();

    expect(find.text('俊敏な / アジャイル開発'), findsNothing);
  });

  testWidgets('Start Check button displays SnackBar when pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLearningListScreen());

    final startCheckButton = find.text('Start Check');
    expect(startCheckButton, findsOneWidget);

    await tester.tap(startCheckButton);
    await tester.pump(); // SnackBarの表示を待つ

    expect(find.text('チェックテスト機能は今後実装予定です！'), findsOneWidget);
  });

  testWidgets('Back button pops the screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LearningListScreen(wordsToLearn: testWords),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.byType(LearningListScreen), findsOneWidget);

    // AppHeaderの戻るボタンをタップ
    // デフォルトは Icons.arrow_back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(LearningListScreen), findsNothing);
    expect(find.text('Go'), findsOneWidget);
  });
}
