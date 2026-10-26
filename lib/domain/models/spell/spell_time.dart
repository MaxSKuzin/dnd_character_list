enum SpellTime {
  action,
  bonusAction,
  reaction,
  minute,
  hour;

  /// Значение фильтра `filter_casttime` на dnd.su.
  static SpellTime? fromDndSu(String value) => switch (value) {
        'action' => SpellTime.action,
        'bonus_action' => SpellTime.bonusAction,
        'reaction' => SpellTime.reaction,
        'minute' => SpellTime.minute,
        'hour' => SpellTime.hour,
        _ => null,
      };
}
