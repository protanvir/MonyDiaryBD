import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final modeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    if (modeIndex >= ThemeMode.values.length) return ThemeMode.system;
    return ThemeMode.values[modeIndex];
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(sharedPreferencesProvider).setInt('themeMode', state.index);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

extension ThemeModeToggle on WidgetRef {
  void toggleTheme() {
    read(themeModeProvider.notifier).toggle();
  }
}
