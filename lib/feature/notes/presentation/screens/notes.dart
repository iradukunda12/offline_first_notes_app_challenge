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

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load notes asynchronously
  Future<void> _loadNotes() async {
    noteBox = await Hive.openBox<NoteModel>('notes');
    setState(() {}); // Trigger rebuild after loading the notes
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the note box is loaded before accessing it
    if (!Hive.isBoxOpen('notes')) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final notes = noteBox.values.toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBars(),
      body: Column(
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
                      crossAxisCount: 2, // Two cards per row
                      crossAxisSpacing: 10, // Space between columns
                      mainAxisSpacing: 8, // Space between rows
                      childAspectRatio:
                          0.8, // Adjust to control the card height
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
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
                                  context.read<NoteBloc>().add(UpdateNoteEvent(
                                        id: note.id,
                                        title: title,
                                        description: description,
                                        imagePath: imagePath,
                                      ));

                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Note updated')),
                                  );
                                },
                              );
                            },
                          );
                        },
                        onDelete: () {
                          context
                              .read<NoteBloc>()
                              .add(DeleteNoteEvent(id: note.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Note deleted')));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Note saved successfully")),
            );
          } else if (state is NoteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
}
