import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Variantes de bouton de la maquette.
enum AppButtonVariant {
  /// Action principale : fond orange énergie (logo), texte blanc, halo orangé.
  primary,

  /// Action forte neutre : fond vert profond, texte blanc.
  dark,

  /// Action secondaire : contour gris, fond transparent.
  outline,
}

/// Tailles de bouton : normale (54 px) ou petite (44 px, ex. « Code SMS »).
enum AppButtonSize { normal, small }

/// Bouton pleine largeur, arrondi, utilisé dans toute l'app.
///
/// - [loading] remplace le contenu par un indicateur et bloque le clic.
/// - Pour un bouton carré avec seulement une icône, utiliser [AppButton.icon].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  /// Bouton carré 54 x 54 contenant une icône seule.
  const AppButton.icon({
    super.key,
    required IconData this.icon,
    required this.onPressed,
    this.variant = AppButtonVariant.outline,
  })  : label = null,
        size = AppButtonSize.normal,
        loading = false,
        expand = false;

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = size == AppButtonSize.small;
    final height = small ? 44.0 : 54.0;
    final radius = BorderRadius.circular(small ? 12 : AppRadius.md);

    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (AppColors.accent, Colors.white, null),
      AppButtonVariant.dark => (AppColors.primary, Colors.white, null),
      AppButtonVariant.outline => (
          Colors.transparent,
          theme.colorScheme.onSurfaceVariant,
          BorderSide(color: theme.colorScheme.outline, width: 1.5),
        ),
    };
    final enabled = onPressed != null && !loading;
    final isIconOnly = label == null;

    Widget content;
    if (loading) {
      content = SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
      );
    } else if (isIconOnly) {
      content = Icon(icon, size: 20, color: fg);
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 16 : 19, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: fg, fontSize: small ? 13 : null),
            ),
          ),
        ],
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      // Pendant le chargement on garde l'opacité pleine (ce n'est pas un état désactivé).
      opacity: onPressed == null ? .45 : 1,
      child: Container(
        height: height,
        width: isIconOnly ? height : (expand ? double.infinity : null),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: variant == AppButtonVariant.primary ? AppColors.orangeGradient : null,
          // Halo orangé sous le bouton principal.
          boxShadow: variant == AppButtonVariant.primary && enabled
              ? [
                  BoxShadow(
                    color: AppColors.orangeDeep.withValues(alpha: .55),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ]
              : null,
        ),
        child: Material(
          // Le dégradé orange est porté par le Container : Material reste transparent.
          color: variant == AppButtonVariant.primary ? Colors.transparent : bg,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: border ?? BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 16),
              // widthFactor 1 : le bouton non étiré garde la largeur de son contenu.
              child: Center(widthFactor: expand ? null : 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}