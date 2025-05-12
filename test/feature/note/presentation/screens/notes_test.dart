import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_event.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_state.dart';
import 'package:kayko_challenge/feature/notes/presentation/screens/notes.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/bottom_nav.dart';
import 'package:mocktail/mocktail.dart';

class MockNoteBloc extends Mock implements NoteBloc {}

class MockBox<E> extends Mock implements Box<E> {}

class MockHiveInterface extends Mock implements HiveInterface {}

class FakeNoteEvent extends Fake implements NoteEvent {}

class FakeNoteState extends Fake implements NoteState {}

void main() {
  late MockNoteBloc mockNoteBloc;
  late MockBox<NoteModel> mockBox;

  setUpAll(() {
    registerFallbackValue(FakeNoteEvent());
    registerFallbackValue(FakeNoteState());
  });

  setUp(() {
    mockNoteBloc = MockNoteBloc();
    mockBox = MockBox<NoteModel>();

    when(() => mockBox.values).thenReturn([]);
    when(() => mockBox.watch()).thenAnswer((_) => const Stream.empty());

    when(() => Hive.isBoxOpen('notes')).thenReturn(true);
    when(() => Hive.box<NoteModel>('notes')).thenReturn(mockBox);
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<NoteBloc>(
      create: (context) => mockNoteBloc,
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('shows loading indicator when Hive box is not open',
        (tester) async {
      when(() => Hive.isBoxOpen('notes')).thenReturn(false);
      when(() => mockNoteBloc.state).thenReturn(NoteLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows loading indicator when in NoteLoading state',
        (tester) async {
      when(() => mockNoteBloc.state).thenReturn(NoteLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "No notes yet" when notes list is empty',
        (tester) async {
      when(() => mockNoteBloc.state).thenReturn(NotesLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('displays notes in grid when NotesLoaded state',
        (tester) async {
      final testNotes = [
        NoteModel(
          id: '1',
          title: 'Test Note 1',
          description: 'Description 1',
          syncStatus: SyncStatus.synced,
        ),
        NoteModel(
          id: '2',
          title: 'Test Note 2',
          description: 'Description 2',
          syncStatus: SyncStatus.pending,
        ),
      ];

      when(() => mockNoteBloc.state).thenReturn(NotesLoaded(testNotes));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Test Note 1'), findsOneWidget);
      expect(find.text('Test Note 2'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows search field and allows text input', (tester) async {
      when(() => mockNoteBloc.state).thenReturn(NotesLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'search query');
      expect(find.text('search query'), findsOneWidget);
    });

    testWidgets('shows error SnackBar when NoteFailure state occurs',
        (tester) async {
      when(() => mockNoteBloc.state).thenReturn(NoteFailure('Test error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      when(() => mockNoteBloc.state).thenReturn(NotesLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('dispatches DeleteNoteEvent when delete button is pressed',
        (tester) async {
      final testNote = NoteModel(
        id: '1',
        title: 'Test Note',
        description: 'Test Description',
        syncStatus: SyncStatus.synced,
      );

      when(() => mockNoteBloc.state).thenReturn(NotesLoaded([testNote]));
      when(() => mockNoteBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);

      verify(() => mockNoteBloc.add(DeleteNoteEvent(id: '1'))).called(1);
    });

    testWidgets('displays correct sync status widgets', (tester) async {
      final testNotes = [
        NoteModel(
          id: '1',
          title: 'Synced Note',
          description: 'Description',
          syncStatus: SyncStatus.synced,
        ),
        NoteModel(
          id: '2',
          title: 'Pending Note',
          description: 'Description',
          syncStatus: SyncStatus.pending,
        ),
        NoteModel(
          id: '3',
          title: 'Failed Note',
          description: 'Description',
          syncStatus: SyncStatus.failed,
        ),
      ];

      when(() => mockNoteBloc.state).thenReturn(NotesLoaded(testNotes));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });
  });
}
