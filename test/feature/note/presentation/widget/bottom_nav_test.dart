import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/bottom_nav.dart';

void main() {
  group('CustomBottomNav Widget Tests', () {
    late bool saveCalled;
    late Map<String, dynamic> savedData;

    setUp(() {
      saveCalled = false;
      savedData = {};
    });

    Widget createTestWidget({
      String? initialTitle,
      String? initialDescription,
      String? initialImagePath,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Expanded(child: Container()),
                  CustomBottomNav(
                    onSave: ({required title, required description, imagePath}) {
                      saveCalled = true;
                      savedData = {
                        'title': title,
                        'description': description,
                        'imagePath': imagePath,
                      };
                    },
                    initialTitle: initialTitle,
                    initialDescription: initialDescription,
                    initialImagePath: initialImagePath,
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    testWidgets('renders initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('renders with initial values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        initialTitle: 'Initial Title',
        initialDescription: 'Initial Description',
      ));

      expect(find.text('Initial Title'), findsOneWidget);
      expect(find.text('Initial Description'), findsOneWidget);
    });

    testWidgets('validates empty fields on save', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Title and description are required'), findsOneWidget);
      expect(saveCalled, isFalse);
    });

    testWidgets('calls onSave with correct data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField).at(0), 'Test Title');
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saveCalled, isTrue);
      expect(savedData['title'], 'Test Title');
      expect(savedData['description'], 'Test Description');
      expect(savedData['imagePath'], isNull);
    });

    testWidgets('clears fields after save', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField).at(0), 'Test Title');
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Test Title'), findsNothing);
      expect(find.text('Test Description'), findsNothing);
    });

    testWidgets('shows image when initialImagePath is provided',
        (WidgetTester tester) async {
      
      await tester.pumpWidget(createTestWidget(
        initialImagePath: 'test_resources/test_image.jpg',
      ));

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('handles image upload button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Upload'));
      await tester.pump();

      expect(find.text('Upload'), findsOneWidget);
    });
  });
}
