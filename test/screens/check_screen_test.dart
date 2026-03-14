import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banexy/models/word.dart';
import 'package:banexy/screens/check_screen.dart';

void main() {
  final testWords = [
    WordCard(
      id: '1',
      text: 'Apple',
      meanings: ['りんご'],
      category: 'General',
      partOfSpeech: 'Noun',
    ),
    WordCard(
      id: '2',
      text: 'Banana',
      meanings: ['バナナ', '甘い果物'],
      category: 'General',
      partOfSpeech: 'Noun',
    ),
  ];

  Widget createCheckScreen(List<WordCard> words) {
    return MaterialApp(home: CheckScreen(wordsToCheck: words));
  }

  Future<void> setSurfaceSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
  }

  testWidgets('CheckScreen displays the first word', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createCheckScreen(testWords));

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Noun'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('CheckScreen handles a correct answer', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createCheckScreen(testWords));

    await tester.enterText(find.byType(TextField), 'りんご');
    await tester.tap(find.text('Check'));
    await tester.pump();

    expect(find.text('Nice!'), findsOneWidget);
    expect(find.text('Your answer:'), findsOneWidget);
    expect(find.text('りんご'), findsNWidgets(2)); // Input and Your answer
    expect(find.text('Correct meaning:'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('CheckScreen handles an "almost" correct answer', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createCheckScreen(testWords));

    // 'りんご' に対して 'りん' (contained)
    await tester.enterText(find.byType(TextField), 'りん');
    await tester.tap(find.text('Check'));
    await tester.pump();

    expect(find.text('Nice! (惜しい)'), findsOneWidget);
  });

  testWidgets('CheckScreen handles an incorrect answer', (
    WidgetTester tester,
  ) async {
    await setSurfaceSize(tester);
    await tester.pumpWidget(createCheckScreen(testWords));

    await tester.enterText(find.byType(TextField), 'みかん');
    await tester.tap(find.text('Check'));
    await tester.pump();

    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Weak flagged'), findsOneWidget);
    // 画面上に表示されている弱点カウントの '1' を確認
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('CheckScreen navigates to the next word and then exits', (
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
                builder: (_) => CheckScreen(wordsToCheck: [testWords[0]]),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'りんご');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // After the last word, it should pop back to the first screen (using popUntil in implementation)
    expect(find.text('Go'), findsOneWidget);
    expect(find.byType(CheckScreen), findsNothing);
  });

  testWidgets('CheckScreen close button pops the screen', (
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
                builder: (_) => CheckScreen(wordsToCheck: testWords),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Go'), findsOneWidget);
    expect(find.byType(CheckScreen), findsNothing);
  });
}
