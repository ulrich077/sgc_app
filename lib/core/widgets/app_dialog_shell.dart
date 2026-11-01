import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import 'responsive.dart';

class AppDialogShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final double? maxWidth;

  const AppDialogShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.of(context);
    final widthLimit = maxWidth ??
        (screen == ScreenType.mobile
            ? MediaQuery.sizeOf(context).width - AppSizes.lg * 2
            : AppSizes.dialogMaxWidth);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widthLimit),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSizes.lg),
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
