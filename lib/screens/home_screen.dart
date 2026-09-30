import 'package:flutter/material.dart';

import '../logic/guestbook.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _message = TextEditingController();
  final List<GuestEntry> _entries = [];

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
            'Entries are stored only on this device for this session.',
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
                trailing: Text(relativeTime(e.signedAt, now)),
              ),
            ),
        ],
      ),
    );
  }
}
