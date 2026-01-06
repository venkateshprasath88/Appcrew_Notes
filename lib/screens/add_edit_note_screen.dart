import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final service = NotesService();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleCtrl.text = widget.note!.title;
      contentCtrl.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.note == null ? "Add Note" : "Edit Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration:
              const InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: contentCtrl,
              decoration:
              const InputDecoration(labelText: "Content"),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.note == null) {
                  await service.addNote(
                    titleCtrl.text,
                    contentCtrl.text,
                    user.uid,
                  );
                } else {
                  await service.updateNote(
                    widget.note!.id,
                    titleCtrl.text,
                    contentCtrl.text,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
