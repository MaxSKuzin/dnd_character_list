import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/create_character_flow/create_character_steps.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_class_screen/class_info_dialog.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectClassScreen extends StatefulWidget {
  const SelectClassScreen({super.key});

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  ClassKind? _selectedClass;
  bool _isLoading = false;

  /// Загружает описание класса с dnd.su, если оно есть. Ошибка показывается пользователю.
  Future<ClassInfo?> _loadInfo(ClassKind classKind) async {
    final link = classKind.dndSuLink;
    if (link == null) return null;
    setState(() => _isLoading = true);
    try {
      return await getIt<RulesRepository>().getClass(link);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить описание класса с dnd.su: $e')),
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Класс',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Expanded(
                child: GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  children: ClassKind.values
                      .map(
                        (e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedClass == e) {
                                _selectedClass = null;
                              } else {
                                _selectedClass = e;
                              }
                            });
                          },
                          child: ImageFiltered(
                            imageFilter: ColorFilter.mode(
                              _selectedClass == e ? Colors.transparent : Colors.black45,
                              BlendMode.srcATop,
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClassImage(classType: e),
                                ),
                                if (e.dndSuLink != null)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      onPressed: _isLoading ? null : () => _showInfo(e),
                                      icon: const Icon(Icons.info),
                                    ),
                                  ),
                                DecoratedBox(
                                  decoration: const ShapeDecoration(
                                    shape: CircleBorder(
                                      side: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          e.localizedName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedClass != null && !_isLoading ? _continue : null,
                child: _isLoading
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
