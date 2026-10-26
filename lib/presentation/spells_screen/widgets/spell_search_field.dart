import 'package:flutter/material.dart';

class SpellSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  /// Текст поиска, если им владеет экран; иначе поле создаёт свой.
  final TextEditingController? controller;

  const SpellSearchField({
    super.key,
    required this.onChanged,
    this.focusNode,
    this.controller,
  });

  @override
  State<SpellSearchField> createState() => _SpellSearchFieldState();
}

class _SpellSearchFieldState extends State<SpellSearchField> {
  TextEditingController? _ownController;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      // Нажатие мимо поля закрывает клавиатуру, и экран поиска возвращается к обычному виду.
      onTapOutside: (_) => widget.focusNode?.unfocus(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Поиск по названию',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}
