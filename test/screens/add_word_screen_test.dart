import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_english/screens/add_word_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AddWordScreen adds a new word', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: AddWordScreen()));

    // Enter text in the fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Word');
    await tester.enterText(find.byType(TextFormField).at(1), 'テスト単語');
    await tester.enterText(find.byType(TextFormField).at(2), 'Test Category');

    // Tap the save button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Snackbar is shown
    expect(find.text('単語を追加しました！'), findsOneWidget);
  });
}
