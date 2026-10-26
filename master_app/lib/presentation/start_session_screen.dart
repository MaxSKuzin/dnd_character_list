import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/presentation/session_screen.dart';
import 'package:flutter/material.dart';

/// Создание сессии: название, под которым игроки увидят её в сети.
class StartSessionScreen extends StatefulWidget {
  final MasterSessionSource source;

  const StartSessionScreen({super.key, required this.source});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final _nameController = TextEditingController(text: 'Сессия мастера');
  var _starting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _starting = true);
    try {
      await widget.source.start(name);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SessionScreen(source: widget.source)));
    } catch (error) {
      await widget.source.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось создать сессию: $error')));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DnD Мастер')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название сессии'),
                  onSubmitted: (_) => _start(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _starting ? null : _start, child: const Text('Создать сессию')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
