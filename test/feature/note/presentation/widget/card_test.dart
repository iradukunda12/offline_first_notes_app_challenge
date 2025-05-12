import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/cards.dart';

void main() {
  final mockNote = NoteModel(
    id: '1',
    title: 'Test Title',
    description: 'Test Description',
    imagePath: null,
  );

  final mockNoteWithImage = NoteModel(
    id: '2',
    title: 'Test Title with Image',
    description: 'Test Description with Image',
    imagePath: 'path/to/image.jpg',
    syncStatus: SyncStatus.notSynced,
  );

  bool editPressed = false;
  bool deletePressed = false;

  Widget createTestWidget(NoteModel note) {
    return MaterialApp(
      home: Scaffold(
        body: NoteCard(
          note: note,
          syncStatus: Icon(Icons.cloud_off, color: Colors.grey),
          onEdit: () {
            editPressed = true;
          },
          onDelete: () {
            deletePressed = true;
          },
        ),
      ),
    );
  }

  group('NoteCard Widget Tests', () {
    testWidgets('renders correctly without image', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(mockNote));

      
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);

     
      expect(find.byType(Image), findsNothing);

     
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);

     
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('renders correctly with image', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(mockNoteWithImage));

      
      expect(find.byType(Image), findsOneWidget);

    
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('triggers edit callback when edit button is pressed',
        (WidgetTester tester) async {
      editPressed = false;
      await tester.pumpWidget(createTestWidget(mockNote));

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(editPressed, isTrue);
    });

    testWidgets('triggers delete callback when delete button is pressed',
        (WidgetTester tester) async {
      deletePressed = false;
      await tester.pumpWidget(createTestWidget(mockNote));

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deletePressed, isTrue);
    });

    testWidgets('displays ellipsis for long text', (WidgetTester tester) async {
      final longNote = NoteModel(
        id: '3',
        title: 'Very very very very very long title that should be truncated',
        description:
            'Very very very very very long description that should be truncated',
        imagePath: null,
        syncStatus: SyncStatus.notSynced,
      );

      await tester.pumpWidget(createTestWidget(longNote));

     
      final titleFinder = find.text(longNote.title);
      final descriptionFinder = find.text(longNote.description);

      final titleWidget = tester.widget<Text>(titleFinder);
      final descriptionWidget = tester.widget<Text>(descriptionFinder);

      expect(titleWidget.overflow, TextOverflow.ellipsis);
      expect(descriptionWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
