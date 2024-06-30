import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Macro {
  final String title;
  final List<String> actions;

  Macro({required this.title, required this.actions});

  Map<String, dynamic> toJson() => {
    'title': title,
    'actions': actions,
  };

  factory Macro.fromJson(Map<String, dynamic> json) {
    return Macro(
      title: json['title'],
      actions: List<String>.from(json['actions']),
    );
  }
}

class MacroService {
  static const String _cachedMacrosKey = 'cached_macros';

  static Future<List<Macro>> getMacros() async {
    final prefs = await SharedPreferences.getInstance();
    final String? macroJson = prefs.getString(_cachedMacrosKey);
    if (macroJson != null) {
      final List<dynamic> macroList = json.decode(macroJson);
      return macroList.map((macro) => Macro.fromJson(macro)).toList();
    }
    return [];
  }

  static Future<void> saveMacro(Macro macro) async {
    List<Macro> macros = await getMacros();
    macros.add(macro);
    await _cacheMacros(macros);
  }

  static Future<void> _cacheMacros(List<Macro> macros) async {
    final prefs = await SharedPreferences.getInstance();
    final String macroJson = json.encode(macros.map((macro) => macro.toJson()).toList());
    await prefs.setString(_cachedMacrosKey, macroJson);
  }

  static Future<void> deleteMacro(String title) async {
    List<Macro> macros = await getMacros();
    macros.removeWhere((m) => m.title == title);
    await _cacheMacros(macros);
  }
}