import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/screens/new_words_setup_screen.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/learning_session_screen.dart';

void main() {
  final testWords = [
    WordCard(id: '1', text: 'Apple', meaning: 'りんご', category: 'General'),
    WordCard(id: '2', text: 'Code', meaning: 'コード', category: 'Technology'),
    WordCard(id: '3', text: 'Meeting', meaning: '会議', category: 'Business'),
    WordCard(
      id: '4',
      text: 'Done',
      meaning: '完了',
      category: 'Technology',
      status: WordStatus.mastered,
    ),
  ];

  Widget createTestWidget({List<WordCard>? words}) {
    return MaterialApp(home: NewWordsSetupScreen(allWords: words ?? testWords));
  }

  // テストの画面サイズを大きく設定するユーティリティ
  Future<void> setSurfaceSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
  }

  testWidgets('Should display correct initial state', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('New Words'), findsOneWidget);
    expect(find.text('Technology'), findsWidgets);
    expect(find.text('10'), findsNWidgets(2));
  });

  testWidgets('Should change category when tapping mode card', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final businessButton = find.text('Business');
    await tester.ensureVisible(businessButton);
    await tester.tap(businessButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('Should increment target count via + button', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final addButton = find.byIcon(Icons.add);
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // 成功すれば、中央の大きな数字とチップの「15」の2つが見つかるはず
    expect(find.text('15'), findsNWidgets(2));
  });

  testWidgets('Should decrement target count via - button', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final removeButton = find.byIcon(Icons.remove);
    await tester.ensureVisible(removeButton);
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    // 10 -> 5
    expect(find.text('5'), findsNWidgets(2));
  });

  testWidgets('Should select target count from chips', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 20 のチップをタップ
    final chip20 = find.text('20');
    await tester.ensureVisible(chip20);
    await tester.tap(chip20);
    await tester.pumpAndSettle();

    expect(find.text('20'), findsNWidgets(2));
  });

  testWidgets('Should show snackbar when no words match category', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    final techOnlyWords = [
      WordCard(
        id: '1',
        text: 'Flutter',
        meaning: 'フラッター',
        category: 'Technology',
      ),
    ];

    await tester.pumpWidget(createTestWidget(words: techOnlyWords));
    await tester.pumpAndSettle();

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();

    final startButton = find.text('Start Sorting');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);

    // スナックバーのアニメーション待機
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('General の学習対象単語がありません！'), findsOneWidget);
  });

  testWidgets('Should navigate to LearningSessionScreen on success', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final startButton = find.text('Start Sorting');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);

    await tester.pumpAndSettle();

    expect(find.byType(LearningSessionScreen), findsOneWidget);
  });
}
