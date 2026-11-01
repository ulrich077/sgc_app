import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class DialogOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  const DialogOption({required this.label, required this.value, this.icon});
}

class AppDialogs {
  AppDialogs._();

  static Future<void> success(BuildContext context, String message,
      {String title = 'Éxito'}) async {
    return _basic(context, title, message, Icons.check_circle, AppColors.success);
  }

  static Future<void> error(BuildContext context, String message,
      {String title = 'Error'}) async {
    return _basic(context, title, message, Icons.error, AppColors.danger);
  }

  static Future<void> warning(BuildContext context, String message,
      {String title = 'Atención'}) async {
    return _basic(context, title, message, Icons.warning_amber, AppColors.warning);
  }

  static Future<void> info(BuildContext context, String message,
      {String title = 'Información'}) async {
    return _basic(context, title, message, Icons.info, AppColors.info);
  }

  static Future<void> _basic(BuildContext context, String title,
      String message, IconData icon, Color color) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
        title: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSizes.sm),
          Text(title),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<bool> confirm(BuildContext context, String message,
      {String title = 'Confirmar',
      String confirmLabel = 'Sí',
      String cancelLabel = 'Cancelar'}) async {
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<T?> choose<T>({
    required BuildContext context,
    required String title,
    required String message,
    required List<DialogOption<T>> options,
  }) async {
    if (!context.mounted) return null;
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: AppSizes.lg),
            ...options.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(opt.icon ?? Icons.chevron_right),
                      label: Text(opt.label),
                      onPressed: () => Navigator.of(ctx).pop(opt.value),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
