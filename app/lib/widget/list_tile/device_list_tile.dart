// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_app/widget/custom_progress_bar.dart';
import 'package:localsend_app/widget/device_bage.dart';
import 'package:localsend_app/widget/list_tile/custom_list_tile.dart';
import 'package:localsend_isolates/model/device.dart';

class DeviceListTile extends StatelessWidget {
  final Device device;
  final bool isFavorite;

  /// If not null, this name is used instead of [Device.alias].
  /// This is the case when the device is marked as favorite.
  final String? nameOverride;

  final String? info;
  final double? progress;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;

  const DeviceListTile({
    required this.device,
    this.isFavorite = false,
    this.nameOverride,
    this.info,
    this.progress,
    this.onTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = Color.lerp(Theme.of(context).colorScheme.secondaryContainer, Colors.white, 0.3)!;
    return CustomListTile(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
        child: Icon(device.deviceType.icon, size: 28),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              nameOverride ?? device.alias,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (isFavorite) ...[
            const SizedBox(width: 5),
            Icon(Icons.check_circle, size: 16),
          ],
        ],
      ),
      trailing: onDetailsTap != null
          ? IconButton(
              tooltip: t.neardockUI.devices,
              icon: const Icon(Icons.info_outline),
              onPressed: onDetailsTap,
            )
          : null,
      subTitle: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: [
          if (info != null)
            Text(info!, style: const TextStyle(color: Colors.grey))
          else if (progress != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomProgressBar(progress: progress!),
            )
          else ...[
            if (device.ip != null)
              DeviceBadge(
                backgroundColor: badgeColor,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                label: 'HTTP',
              )
            else
              DeviceBadge(
                backgroundColor: badgeColor,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                label: 'WebRTC',
              ),
            if (device.deviceModel != null)
              DeviceBadge(
                backgroundColor: badgeColor,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                label: device.deviceModel!,
              ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
