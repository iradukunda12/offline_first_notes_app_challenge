import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kayko_challenge/core/services/bloc/connectivity_cubit.dart';
import 'package:kayko_challenge/core/services/connectivity_services.dart';
import 'package:kayko_challenge/core/services/firestore_sync.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/appbar.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockConnectivityCubit cubit;

  setUp(() {
    cubit = MockConnectivityCubit();
    when(() => cubit.state).thenReturn(ConnectivityState.initial());
  });

  group('AppBars Widget Tests', () {
    testWidgets('renders correctly with initial state',
        (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(ConnectivityState.initial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Kayko Challenge'), findsOneWidget);
      expect(find.text('Checking connection...'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('displays correct online state', (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(ConnectivityState.online());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Online'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.circle));
      expect(icon.color, Colors.green);
    });

    testWidgets('displays correct offline state', (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(ConnectivityState.offline());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Offline'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.circle));
      expect(icon.color, Colors.red);
    });

    testWidgets('shows sync indicator when syncing',
        (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(ConnectivityState.syncing());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Syncing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows synced state correctly', (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(ConnectivityState.synced());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Synced'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      when(() => cubit.state)
          .thenReturn(ConnectivityState.error('Connection failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ConnectivityCubit>(
            create: (context) => cubit,
            child: Scaffold(
              appBar: AppBars(),
            ),
          ),
        ),
      );

      expect(find.text('Connection failed'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.circle));
      expect(icon.color, Colors.red);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const appBar = AppBars();
      expect(appBar.preferredSize, const Size.fromHeight(90));
    });
  });
}

// Simple mock cubit that extends your actual ConnectivityCubit
class MockConnectivityCubit extends ConnectivityCubit {
  MockConnectivityCubit()
      : super(
          ConnectivityState.initial() as ConnectivityService,
          ConnectivityService() as FirestoreService,
        );

  @override
  void emit(ConnectivityState state) {
    super.emit(state);
  }
}
