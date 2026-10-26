import 'package:dnd_master/data/ttg/ttg_bestiary.dart';
import 'package:dnd_master/data/ttg/ttg_monster_mapper.dart';
import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_master/presentation/monsters/monster_stat_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Выбор монстра: встроенный бестиарий и поиск на ttg.club. `null` — закрыто без выбора.
Future<MonsterTemplate?> pickMonster(BuildContext context) {
  final bestiary = context.read<TtgBestiary>();
  return showModalBottomSheet<MonsterTemplate>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => MonsterPicker(bestiary: bestiary, controller: controller),
      ),
    ),
  );
}

class MonsterPicker extends StatefulWidget {
  final TtgBestiary bestiary;
  final ScrollController? controller;

  const MonsterPicker({super.key, required this.bestiary, this.controller});

  @override
  State<MonsterPicker> createState() => _MonsterPickerState();
}

class _MonsterPickerState extends State<MonsterPicker> {
  /// Поиск на сайте — с этой длины запроса, иначе совпадений сотни.
  static const _minQuery = 2;
  static const _maxResults = 50;

  /// Список с сайта начинает загружаться сразу, пока мастер вводит название.
  late var _list = widget.bestiary.list();
  var _query = '';

  /// Ссылка монстра, чей статблок загружается.
  String? _loading;
  String? _error;

  /// Статблок с сайта; ошибка показывается под полем поиска.
  Future<MonsterTemplate?> _load(MonsterSummary summary) async {
    setState(() {
      _loading = summary.url;
      _error = null;
    });
    try {
      return await widget.bestiary.monster(summary.url);
    } on Object catch (e) {
      if (mounted) setState(() => _error = 'Не удалось загрузить «${summary.name}»: $e');
      return null;
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _pick(MonsterSummary summary) async {
    final monster = await _load(summary);
    if (monster != null && mounted) Navigator.pop(context, monster);
  }

  Future<void> _showStatBlock(MonsterSummary summary) async {
    final monster = await _load(summary);
    if (monster != null && mounted) await showMonsterStatBlock(context, monster);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = TtgMonsterMapper.normalize(_query);
    final local = Bestiary.monsters.where((e) => TtgMonsterMapper.normalize(e.name).contains(query)).toList();

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Название: гоблин, owlbear',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ),
        Expanded(
          child: ListView(
            controller: widget.controller,
            children: [
              if (local.isNotEmpty) header('Бестиарий'),
              for (final monster in local)
                ListTile(
                  title: Text(monster.name),
                  subtitle: Text('ПО ${monster.challenge} · КД ${monster.armorClass} · хиты ${monster.averageHits}'),
                  onTap: () => Navigator.pop(context, monster),
                  trailing: IconButton(
                    tooltip: 'Статблок',
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showMonsterStatBlock(context, monster),
                  ),
                ),
              header('ttg.club'),
              if (query.length < _minQuery)
                const ListTile(subtitle: Text('Введите название, чтобы найти монстра на сайте'))
              else
                FutureBuilder(
                  future: _list,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return ListTile(
                        subtitle: Text('Не удалось загрузить бестиарий: ${snapshot.error}'),
                        trailing: TextButton(
                          onPressed: () => setState(() => _list = widget.bestiary.list()),
                          child: const Text('Повторить'),
                        ),
                      );
                    }
                    final list = snapshot.data;
                    if (list == null) return const Center(child: CircularProgressIndicator());
                    final found = list.where((e) => e.matches(query)).toList()
                      ..sort((a, b) => (a.isOfficial ? 0 : 1).compareTo(b.isOfficial ? 0 : 1));
                    if (found.isEmpty) return const ListTile(subtitle: Text('Ничего не найдено'));
                    return Column(
                      children: [
                        for (final summary in found.take(_maxResults)) _summaryTile(summary),
                        if (found.length > _maxResults)
                          ListTile(subtitle: Text('Ещё ${found.length - _maxResults} — уточните название')),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(MonsterSummary summary) => ListTile(
    enabled: _loading == null,
    title: Text(summary.name),
    subtitle: Text(
      [
        'ПО ${summary.challenge}',
        summary.type,
        if (summary.isOfficial) summary.book else '${summary.book}, неофициальный',
      ].where((e) => e.isNotEmpty).join(' · '),
    ),
    onTap: () => _pick(summary),
    trailing: _loading == summary.url
        ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
        : IconButton(
            tooltip: 'Статблок',
            icon: const Icon(Icons.info_outline),
            onPressed: _loading == null ? () => _showStatBlock(summary) : null,
          ),
  );
}
