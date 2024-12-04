import 'package:dnd_character_list/presentation/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';

extension ContextTheme on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }

  CustomColors? get customColors {
    return Theme.of(this).extension<CustomColors>();
  }
}
