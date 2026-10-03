// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? icon;
  final Widget title;
  final Widget subTitle;
  final Widget? trailing;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const CustomListTile({
    this.icon,
    required this.title,
    required this.subTitle,
    this.trailing,
    this.padding = const EdgeInsets.all(15),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 15),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    const SizedBox(height: 5),
                    subTitle,
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
