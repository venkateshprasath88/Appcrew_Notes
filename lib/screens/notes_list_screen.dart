import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../services/notes_service.dart';
import '../models/note_model.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  //  Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.yellow,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(
                                color: Colors.grey.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,   // ✅ App theme color
                            foregroundColor: Colors.black,    // ✅ Text color
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await FirebaseAuth.instance.signOut();
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final notesService = NotesService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),
      body: Column(
        children: [
          //  Elevated Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Material(
              elevation: 6,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade900,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TextField(
                  onChanged: (value) {
                    context.read<NotesProvider>().search(value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search notes",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.yellow,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),


          //  Notes List
          Expanded(
            child: StreamBuilder(
              stream: notesService.notesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No notes yet"),
                  );
                }

                final notes = snapshot.data!.docs.map((doc) {
                  return NoteModel.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context
                      .read<NotesProvider>()
                      .setNotes(notes);
                });

                return Consumer<NotesProvider>(
                  builder: (_, provider, __) {
                    return ListView.builder(
                      padding:
                      const EdgeInsets.only(bottom: 80),
                      itemCount: provider.filteredNotes.length,
                      itemBuilder: (_, i) {
                        final note =
                        provider.filteredNotes[i];

                        return Card(
                          margin:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.all(16),
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.yellow,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.only(top: 8),
                              child: Text(
                                note.content,
                                maxLines: 3,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                  Colors.grey.shade300,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  notesService.deleteNote(
                                      note.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditNoteScreen(
                                          note: note),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFEB3B), // Yellow
              Color(0xFFFFC107), // Amber
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditNoteScreen(),
                ),
              );
            },
            child: const Center(
              child: Icon(
                Icons.add,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),

    );
  }
}
