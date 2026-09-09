import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Stream qui écoute la table "notes" en temps réel
  final _notesStream = supabase
      .from('notes')
      .stream(primaryKey: ['id'])
      .order('updated_at', ascending: false);

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    // La redirection vers login se fait automatiquement via AuthGate
  }

  void _openNoteEditor({Map<String, dynamic>? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NoteEditorSheet(note: note),
    );
  }

  Future<void> _deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text('Aucune note. Appuie sur + pour en créer une.'),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: ValueKey(note['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteNote(note['id']),
                child: ListTile(
                  title: Text(
                    note['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    note['content'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openNoteEditor(note: note),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Petit widget interne pour créer/éditer une note dans un bottom sheet
class _NoteEditorSheet extends StatefulWidget {
  final Map<String, dynamic>? note;

  const _NoteEditorSheet({this.note});

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?['title'] ?? '');
    _contentController =
        TextEditingController(text: widget.note?['content'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final userId = supabase.auth.currentUser!.id;

    try {
      if (_isEditing) {
        await supabase.from('notes').update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.note!['id']);
      } else {
        await supabase.from('notes').insert({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'user_id': userId,
        });
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Modifier la note' : 'Nouvelle note',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Contenu'),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }
}