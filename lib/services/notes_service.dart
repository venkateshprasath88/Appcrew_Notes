import 'package:cloud_firestore/cloud_firestore.dart';

class NotesService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> notesStream(String userId) {
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> addNote(String title, String content, String userId) async {
    await _db.collection('notes').add({
      'title': title,
      'content': content,
      'userId': userId,
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    await _db.collection('notes').doc(id).update({
      'title': title,
      'content': content,
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}
