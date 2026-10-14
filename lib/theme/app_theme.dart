import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color sage = Color(0xFF6E9075);
  static const Color sageDeep = Color(0xFF44624C);
  static const Color sageSoft = Color(0xFFDDE9DC);
  static const Color cream = Color(0xFFF8F5EC);
  static const Color creamSoft = Color(0xFFFDFCF7);
  static const Color sand = Color(0xFFE9E0CB);
  static const Color charcoal = Color(0xFF23261F);
  static const Color charcoalSoft = Color(0xFF2B2F27);
  static const Color charcoalDeep = Color(0xFF15170F);
  static const Color clay = Color(0xFFB0764D);
}

abstract class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.sage,
          brightness: brightness,
        ).copyWith(
          surface: isDark ? AppColors.charcoalSoft : AppColors.creamSoft,
          onSurface: isDark ? const Color(0xFFE9EDE4) : AppColors.charcoal,
          secondaryContainer: isDark ? AppColors.sageDeep : AppColors.sageSoft,
          onSecondaryContainer: isDark
              ? const Color(0xFFDCEBDD)
              : AppColors.sageDeep,
          outlineVariant: isDark
              ? const Color(0xFF3D443A)
              : const Color(0xFFE5E0D0),
        );

    final ThemeData base = ThemeData(colorScheme: scheme);
    final TextTheme text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.5),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? AppColors.charcoalDeep
          : AppColors.cream,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.charcoalDeep : AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.charcoalSoft : Colors.white,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.charcoalSoft : Colors.white,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.charcoalSoft : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        thumbColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
        circularTrackColor: scheme.outlineVariant,
      ),
    );
  }
}
