import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class ResponsiveKpisRow extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  const ResponsiveKpisRow({
    super.key,
    required this.children,
    this.minItemWidth = 220,
    this.spacing = AppSizes.md,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns =
            (width / (minItemWidth + spacing)).floor().clamp(1, children.length);
        final itemWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
