import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:railtime/styles/themes.dart';
import 'package:railtime/view/widgets/top_bar.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('TopBar with only title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: TopBar(title: 'Test Title')));

    final Finder titleFinder = find.text('Test Title');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('TopBar with title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: TopBar(
          title: 'Test Title',
          subtitle: const Text('Test Subtitle'),
        ),
      ),
    );

    final Finder titleFinder = find.text('Test Title');
    final Finder subtitleFinder = find.text('Test Subtitle');
    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
  });

  testWidgets('TopBar with title and back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: TopBar(title: 'Test Title', backVisible: true),
      ),
    );

    final Finder titleFinder = find.text('Test Title');
    final Finder backButtonFinder = find.byIcon(Icons.arrow_back);
    expect(titleFinder, findsOneWidget);
    expect(backButtonFinder, findsOneWidget);
  });

  testWidgets('TopBar with title and back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: TopBar(
          title: 'Test Title',
          backVisible: true,
          subtitle: const Text('Test Subtitle'),
        ),
      ),
    );

    final Finder titleFinder = find.text('Test Title');
    final Finder backButtonFinder = find.byIcon(Icons.arrow_back);
    final Finder subtitleFinder = find.text('Test Subtitle');
    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(backButtonFinder, findsOneWidget);
  });
}
