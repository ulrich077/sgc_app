import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import 'responsive.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            subtitle!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ],
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.lg,
          AppSizes.pagePadding,
          AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: actions),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.lg,
        AppSizes.pagePadding,
        AppSizes.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleWidget),
          if (actions.isNotEmpty)
            Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: actions),
        ],
      ),
    );
  }
}
