import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/core/services/bloc/connectivity_cubit.dart';
import 'package:kayko_challenge/core/services/connectivity_services.dart';
import 'package:kayko_challenge/core/services/firestore_sync.dart';
import 'package:kayko_challenge/core/utils/notes.g.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/data/repository/notes_repository_impl.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:kayko_challenge/feature/notes/presentation/screens/notes.dart';
import 'package:kayko_challenge/firebase_options.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final Directory dir = await getApplicationDocumentsDirectory();

  Hive.init(dir.path);

  Hive.registerAdapter(NoteModelAdapter());

  final noteBox = await Hive.openBox<NoteModel>('notes');

  final noteRepository = NoteRepositoryImpl(noteBox);
  final connectivityService = ConnectivityService();
  final firestoreService = FirestoreService();
  final connectivityCubit =
      ConnectivityCubit(connectivityService, firestoreService);
  connectivityCubit.startMonitoring();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>.value(
          value: connectivityCubit,
        ),
        BlocProvider<NoteBloc>(
          create: (_) => NoteBloc(noteRepository, connectivityCubit),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: HomeScreen(),
    );
  }
}
