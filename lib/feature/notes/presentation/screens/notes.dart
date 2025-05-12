import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_event.dart';
import 'package:kayko_challenge/feature/notes/presentation/bloc/note_state.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/bottom_nav.dart';
import 'package:kayko_challenge/feature/notes/presentation/widget/cards.dart';

import '../widget/appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';
  late Box<NoteModel> noteBox;
  String? _initialImagePath;
  StreamSubscription<BoxEvent>? _hiveSubscription;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    context.read<NoteBloc>().add(LoadNotesEvent());
  }

  Future<void> _initializeHive() async {
    noteBox = await Hive.openBox<NoteModel>('notes');
    _setupHiveListener();
    setState(() {});
  }

  void _setupHiveListener() {
    _hiveSubscription = noteBox.watch().listen((event) {
      context.read<NoteBloc>().add(LoadNotesEvent());
    });
  }

  @override
  void dispose() {
    _hiveSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('notes')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBars(),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteLoading && state is! NotesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes =
              state is NotesLoaded ? state.notes : noteBox.values.toList();

          return Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search....",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: notes.isEmpty
                    ? const Center(child: Text("No notes yet"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return NoteCard(
                            note: note,
                            syncStatus: _getSyncStatusWidget(note.syncStatus),
                            onEdit: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CustomBottomNav(
                                    initialTitle: note.title,
                                    initialDescription: note.description,
                                    initialImagePath: note.imagePath,
                                    onSave: ({
                                      required title,
                                      required description,
                                      String? imagePath,
                                    }) {
                                      context
                                          .read<NoteBloc>()
                                          .add(UpdateNoteEvent(
                                            id: note.id,
                                            title: title,
                                            description: description,
                                            imagePath: imagePath,
                                          ));
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              context
                                  .read<NoteBloc>()
                                  .add(DeleteNoteEvent(id: note.id));
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Operation successful")),
            );
          } else if (state is NoteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: CustomBottomNav(
          initialImagePath: _initialImagePath,
          onSave: ({required title, required description, imagePath}) {
            context.read<NoteBloc>().add(
                  AddNoteEvent(
                    title: title,
                    description: description,
                    imagePath: imagePath,
                  ),
                );
          },
        ),
      ),
    );
  }

  Widget _getSyncStatusWidget(SyncStatus status) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        text = 'Synced';
        break;
      case SyncStatus.pending:
        icon = Icons.cloud_upload;
        color = Colors.orange;
        text = 'Pending';
        break;
      case SyncStatus.failed:
        icon = Icons.cloud_off;
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
