import 'package:dnd_character_list/presentation/common/widgets/class_choice_card.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:collection/collection.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/create_character_flow/create_character_steps.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_class_screen/class_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SelectClassScreen extends StatefulWidget {
  const SelectClassScreen({super.key});

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  ClassKind? _selectedClass;
  bool _isLoading = false;

  /// Загружает описание класса с ttg.club, если оно есть. Ошибка показывается пользователю.
  Future<ClassInfo?> _loadInfo(ClassKind classKind) async {
    final link = classKind.ttgLink;
    if (link == null) return null;
    setState(() => _isLoading = true);
    try {
      return await getIt<RulesRepository>().getClass(link);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить описание класса с ttg.club: $e')),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showInfo(ClassKind classKind) async {
    final info = await _loadInfo(classKind);
    if (info == null || !mounted) return;
    await showDialog(
      context: context,
      builder: (_) => ClassInfoDialog(info: info),
    );
  }

  Future<void> _continue() async {
    final classKind = _selectedClass!;
    final ClassInfo? info;
    try {
      info = await _loadInfo(classKind);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    context.read<CreateCharacterCubit>().setClass(classKind, info);
    CreateCharacterSteps.next(context, CreateCharacterStep.classKind);
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Класс',
      description: 'Класс определяет хиты, владения, снаряжение и умения. Подробности — по «i».',
      isBusy: _isLoading,
      onAction: _selectedClass != null ? _continue : null,
      body: ClassChoiceGrid(
        // Доступные классы — первыми.
        children: [
          for (final classKind in ClassKind.values.sortedBy<num>((e) => e.canCreate ? 0 : 1))
            ClassChoiceCard(
              classKind: classKind,
              isSelected: classKind == _selectedClass,
              subtitle: classKind.canCreate ? null : 'Пока недоступен',
              onTap: classKind.canCreate
                  ? () => setState(() => _selectedClass = classKind == _selectedClass ? null : classKind)
                  : null,
              onInfo: classKind.ttgLink == null || _isLoading ? null : () => _showInfo(classKind),
            ),
        ],
      ),
    );
  }
}
