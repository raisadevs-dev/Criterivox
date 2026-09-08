import 'package:flutter/material.dart';

@immutable
class CriterivoxTheme extends ThemeExtension<CriterivoxTheme> {
  final Color page;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color text;
  final Color mutedText;
  final Color primary;
  final Color success;
  final Color warning;

  const CriterivoxTheme({
    required this.page,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.text,
    required this.mutedText,
    required this.primary,
    required this.success,
    required this.warning,
  });

  static const dark = CriterivoxTheme(
    page: Color(0xFF070A18),
    surface: Color(0xCC0E1328),
    surfaceStrong: Color(0xF0151933),
    border: Color(0x302F3860),
    text: Color(0xFFF5F4FB),
    mutedText: Color(0xFF969DB8),
    primary: Color(0xFF8065F6),
    success: Color(0xFF49D7A4),
    warning: Color(0xFFFFB454),
  );

  static const light = CriterivoxTheme(
    page: Color(0xFFF5F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceStrong: Color(0xFFF0F1F8),
    border: Color(0xFFDDE0EA),
    text: Color(0xFF171A2A),
    mutedText: Color(0xFF687087),
    primary: Color(0xFF684EEA),
    success: Color(0xFF15966A),
    warning: Color(0xFFB86B00),
  );

  static CriterivoxTheme of(BuildContext context) =>
      Theme.of(context).extension<CriterivoxTheme>() ?? CriterivoxTheme.dark;

  @override
  CriterivoxTheme copyWith({
    Color? page,
    Color? surface,
    Color? surfaceStrong,
    Color? border,
    Color? text,
    Color? mutedText,
    Color? primary,
    Color? success,
    Color? warning,
  }) => CriterivoxTheme(
        page: page ?? this.page,
        surface: surface ?? this.surface,
        surfaceStrong: surfaceStrong ?? this.surfaceStrong,
        border: border ?? this.border,
        text: text ?? this.text,
        mutedText: mutedText ?? this.mutedText,
        primary: primary ?? this.primary,
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  CriterivoxTheme lerp(ThemeExtension<CriterivoxTheme>? other, double t) {
    if (other is! CriterivoxTheme) return this;
    return CriterivoxTheme(
      page: Color.lerp(page, other.page, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
