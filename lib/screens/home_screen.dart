import 'package:flutter/material.dart';

import '../data/guest_entry_repository.dart';
import '../data/list_repository.dart';
import '../logic/guestbook.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = DateTime.now, this.repository});

  /// Where entries are stored. Defaults to an in-memory store (tests); the
  /// app passes [deviceGuestEntryRepository].
  final GuestEntryRepository? repository;

  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _message = TextEditingController();
  final List<GuestEntry> _entries = [];

  late final GuestEntryRepository _repository =
      widget.repository ?? InMemoryListRepository<GuestEntry>();
  bool _loading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await _repository.load();
      if (!mounted) return;
      setState(() {
        _entries
          ..clear()
          ..addAll(saved);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _storageError = 'Saved entries could not be read.';
      });
    }
  }

  Future<void> _persist() async {
    try {
      await _repository.save(List.of(_entries));
      if (mounted && _storageError != null) {
        setState(() => _storageError = null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _storageError = 'Could not save entries on this device.');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  void _sign() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _entries.add(
        GuestEntry(
          name: _name.text,
          message: _message.text,
          signedAt: widget.clock(),
        ),
      );
      _message.clear();
    });
    _persist();
  }

  void _delete(GuestEntry entry) {
    setState(() => _entries.remove(entry));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.clock();
    final entries = newestFirst(_entries);
    return Scaffold(
      appBar: AppBar(title: const Text('Guestbook')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_storageError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _storageError!,
                key: const Key('storage-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('name-field'),
                  controller: _name,
                  maxLength: GuestLimits.nameMax,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                  validator: validateName,
                ),
                TextFormField(
                  key: const Key('message-field'),
                  controller: _message,
                  maxLength: GuestLimits.messageMax,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  validator: validateMessage,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('sign'),
                    onPressed: _sign,
                    icon: const Icon(Icons.draw),
                    label: const Text('Sign the guestbook'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Entries are saved only on this device; this is not a shared '
            'online guestbook.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty) const Text('No signatures yet. Be the first!'),
          for (final e in entries)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(initialsOf(e.name))),
                title: Text(e.name),
                subtitle: Text(e.message),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(relativeTime(e.signedAt, now)),
                    IconButton(
                      tooltip: 'Delete entry',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(e),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
