// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/send_mode.dart';
import 'package:localsend_app/pages/device_details_page.dart';
import 'package:localsend_app/pages/selected_files_page.dart';
import 'package:localsend_app/pages/tabs/send_tab_vm.dart';
import 'package:localsend_app/pages/troubleshoot_page.dart';
import 'package:localsend_app/provider/animation_provider.dart';
import 'package:localsend_app/provider/file_transfer_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/scan_facade.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/favorites.dart';
import 'package:localsend_app/util/native/file_picker.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/widget/custom_icon_button.dart';
import 'package:localsend_app/widget/dialogs/add_file_dialog.dart';
import 'package:localsend_app/widget/dialogs/send_mode_help_dialog.dart';
import 'package:localsend_app/widget/file_thumbnail.dart';
import 'package:localsend_app/widget/list_tile/device_list_tile.dart';
import 'package:localsend_app/widget/neardock/screen_header.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_app/widget/rotating_widget.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/session_status.dart';
import 'package:localsend_isolates/util/file_size_helper.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

final pickerOptions = FilePickerOption.getOptionsForPlatform();

class SendTab extends StatefulWidget {
  const SendTab();
  @override
  State<SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  String? _targetFingerprint;

  @override
  Widget build(BuildContext context) => ViewModelBuilder(
    provider: (ref) => sendTabVmProvider,
    init: (context) async => context.global.dispatchAsync(SendTabInitAction(context)),
    builder: (context, vm) {
      final ref = context.ref;
      final target = vm.nearbyDevices.where((d) => d.fingerprint == _targetFingerprint).firstOrNull;
      Future<void> addFiles() async => AddFileDialog.open(context: context, options: pickerOptions);
      return ResponsiveListView(
        maxWidth: 840,
        padding: const EdgeInsets.all(24),
        tabletPadding: const EdgeInsets.all(32),
        children: [
          ScreenHeader(title: t.sendTab.title, subtitle: t.neardockUI.sendSubtitle),
          Row(
            children: [
              Expanded(child: Text(t.sendTab.nearbyDevices, style: Theme.of(context).textTheme.titleMedium)),
              _ScanButton(ips: vm.localIps),
              IconButton(tooltip: t.sendTab.manualSending, onPressed: () => vm.onTapAddress(context), icon: const Icon(Icons.add_link)),
              IconButton(tooltip: t.dialogs.favoriteDialog.title, onPressed: () => vm.onTapFavorite(context), icon: const Icon(Icons.star_outline)),
              _SendModeButton(onSelect: (mode) async => vm.onTapSendMode(context, mode)),
            ],
          ),
          if (vm.nearbyDevices.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.sendTab.help),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => context.push(() => const TroubleshootPage()), child: Text(t.troubleshootPage.title)),
                  ],
                ),
              ),
            ),
          for (final device in vm.nearbyDevices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: vm.sendMode == SendMode.multiple
                  ? _MultiSendDeviceListTile(
                      device: device,
                      isFavorite: vm.favoriteDevices.findDevice(device) != null,
                      nameOverride: vm.favoriteDevices.findDevice(device)?.alias,
                      vm: vm,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _targetFingerprint == device.fingerprint ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        ),
                      ),
                      child: DeviceListTile(
                        device: device,
                        isFavorite: vm.favoriteDevices.findDevice(device) != null,
                        nameOverride: vm.favoriteDevices.findDevice(device)?.alias,
                        onDetailsTap: () => context.push(() => DeviceDetailsPage(device: device)),
                        onTap: () => setState(() => _targetFingerprint = device.fingerprint),
                      ),
                    ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(t.sendTab.selection.files(files: vm.selectedFiles.length), style: Theme.of(context).textTheme.titleMedium),
              ),
              if (vm.selectedFiles.isNotEmpty)
                TextButton(onPressed: () => context.push(() => const SelectedFilesPage()), child: Text(t.general.edit)),
              if (vm.selectedFiles.isNotEmpty)
                IconButton(
                  tooltip: t.general.delete,
                  onPressed: () => ref.redux(selectedSendingFilesProvider).dispatch(ClearSelectionAction()),
                  icon: const Icon(Icons.clear_all),
                ),
            ],
          ),
          if (vm.selectedFiles.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (var index = 0; index < vm.selectedFiles.length; index++)
                    ListTile(
                      leading: SmartFileThumbnail.fromCrossFile(vm.selectedFiles[index]),
                      title: Text(vm.selectedFiles[index].name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(vm.selectedFiles[index].size.asReadableFileSize),
                      trailing: IconButton(
                        tooltip: t.general.delete,
                        onPressed: () => ref.redux(selectedSendingFilesProvider).dispatch(RemoveSelectedFileAction(index)),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: addFiles, icon: const Icon(Icons.add), label: Text(t.general.add)),
          const SizedBox(height: 20),
          if (vm.sendMode == SendMode.single)
            FilledButton.icon(
              onPressed: target != null && vm.selectedFiles.isNotEmpty ? () => vm.onTapDevice(context, target) : null,
              icon: const Icon(Icons.send),
              label: Text(t.sendTab.title),
            ),
          const SizedBox(height: 20),
          if (checkPlatformCanReceiveShareIntent()) Text(t.sendTab.shareIntentInfo, style: Theme.of(context).textTheme.bodySmall),
          Center(
            child: TextButton(onPressed: () => context.push(() => const TroubleshootPage()), child: Text(t.troubleshootPage.title)),
          ),
        ],
      );
    },
  );
}

/// A button that opens a popup menu to select [T].
/// This is used for the scan button and the send mode button.
class _CircularPopupButton<T> extends StatelessWidget {
  final String tooltip;
  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final Widget child;

  const _CircularPopupButton({
    required this.tooltip,
    required this.onSelected,
    required this.itemBuilder,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: Material(
        type: MaterialType.transparency,
        child: DividerTheme(
          data: DividerThemeData(
            color: Theme.of(context).brightness == Brightness.light ? Colors.teal.shade100 : Colors.grey.shade700,
          ),
          child: PopupMenuButton(
            offset: const Offset(0, 40),
            onSelected: onSelected,
            tooltip: tooltip,
            itemBuilder: itemBuilder,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The scan button that uses [_CircularPopupButton].
class _ScanButton extends StatelessWidget {
  final List<String> ips;

  const _ScanButton({
    required this.ips,
  });

  @override
  Widget build(BuildContext context) {
    final (scanningFavorites, scanningIps) = context.ref.watch(nearbyDevicesProvider.select((s) => (s.runningFavoriteScan, s.runningIps)));
    final animations = context.ref.watch(animationProvider);

    final spinning = (scanningFavorites || scanningIps.isNotEmpty) && animations;
    final iconColor = !animations && scanningIps.isNotEmpty ? Theme.of(context).colorScheme.warning : null;

    if (ips.length <= StartSmartScan.maxInterfaces) {
      return Tooltip(
        message: t.sendTab.scan,
        child: RotatingWidget(
          duration: const Duration(seconds: 2),
          spinning: spinning,
          reverse: true,
          child: CustomIconButton(
            onPressed: () async {
              context.redux(nearbyDevicesProvider).dispatch(ClearFoundDevicesAction());
              await context.global.dispatchAsync(StartSmartScan());
            },
            child: Icon(Icons.sync, color: iconColor),
          ),
        ),
      );
    }

    return _CircularPopupButton(
      tooltip: t.sendTab.scan,
      onSelected: (ip) async {
        context.redux(nearbyDevicesProvider).dispatch(ClearFoundDevicesAction());
        await context.global.dispatchAsync(StartLegacySubnetScan(subnets: [ip]));
      },
      itemBuilder: (_) {
        return [
          ...ips.map(
            (ip) => PopupMenuItem(
              value: ip,
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RotatingSyncIcon(ip),
                  const SizedBox(width: 10),
                  Text(ip),
                ],
              ),
            ),
          ),
        ];
      },
      child: RotatingWidget(
        duration: const Duration(seconds: 2),
        spinning: spinning,
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.sync, color: iconColor),
        ),
      ),
    );
  }
}

/// A separate widget, so it gets the latest data from provider.
class _RotatingSyncIcon extends StatelessWidget {
  final String ip;

  const _RotatingSyncIcon(this.ip);

  @override
  Widget build(BuildContext context) {
    final scanningIps = context.ref.watch(nearbyDevicesProvider.select((s) => s.runningIps));
    return RotatingWidget(
      duration: const Duration(seconds: 2),
      spinning: scanningIps.contains(ip),
      reverse: true,
      child: const Icon(Icons.sync),
    );
  }
}

class _SendModeButton extends StatelessWidget {
  final void Function(SendMode mode) onSelect;

  const _SendModeButton({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _CircularPopupButton<int>(
      tooltip: t.sendTab.sendMode,
      onSelected: (mode) async {
        switch (mode) {
          case 0:
            onSelect(SendMode.single);
            break;
          case 1:
            onSelect(SendMode.multiple);
            break;
          case 2:
            onSelect(SendMode.link);
            break;
          case -1:
            await showDialog(context: context, builder: (_) => const SendModeHelpDialog());
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref) {
                  final sendMode = ref.watch(settingsProvider.select((s) => s.sendMode));
                  return Visibility(
                    visible: sendMode == SendMode.single,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: const Icon(Icons.check_circle),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(t.sendTab.sendModes.single),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref) {
                  final sendMode = ref.watch(settingsProvider.select((s) => s.sendMode));
                  return Visibility(
                    visible: sendMode == SendMode.multiple,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: const Icon(Icons.check_circle),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(t.sendTab.sendModes.multiple),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Icon(Icons.check_circle),
              ),
              const SizedBox(width: 10),
              Text(t.sendTab.sendModes.link),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: -1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(Icons.help),
              ),
              const SizedBox(width: 10),
              Text(t.sendTab.sendModeHelp),
            ],
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.settings),
      ),
    );
  }
}

/// An advanced list tile which shows the progress of the file transfer.
class _MultiSendDeviceListTile extends StatelessWidget {
  final Device device;
  final bool isFavorite;
  final String? nameOverride;
  final SendTabVm vm;

  const _MultiSendDeviceListTile({
    required this.device,
    required this.isFavorite,
    required this.nameOverride,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final session = ref.watch(sendProvider).values.firstWhereOrNull((s) => s.target.ip == device.ip);
    final String? info;
    final double? progress;
    if (session != null) {
      final files = session.files.values.where((f) => f.token != null);
      final transferNotifier = ref.watch(fileTransferProvider);
      final currBytes = files.fold<int>(
        0,
        (prev, curr) => prev + ((transferNotifier.getProgress(sessionId: session.sessionId, fileId: curr.file.id) * curr.file.size).round()),
      );
      final totalBytes = files.fold<int>(0, (prev, curr) => prev + curr.file.size);
      progress = totalBytes == 0 ? 0 : currBytes / totalBytes;
      info = session.hashedFileCount < session.files.length
          ? t.sendPage.calculatingChecksum(curr: session.hashedFileCount, n: session.files.length)
          : session.status.humanString;
    } else {
      progress = null;
      info = null;
    }
    return DeviceListTile(
      device: device,
      info: info,
      progress: progress,
      isFavorite: isFavorite,
      nameOverride: nameOverride,
      onDetailsTap: () async => await context.push(() => DeviceDetailsPage(device: device)),
      onTap: () async => await vm.onTapDeviceMultiSend(context, device),
    );
  }
}

extension on SessionStatus {
  String? get humanString {
    switch (this) {
      case SessionStatus.waiting:
        return t.sendPage.waiting;
      case SessionStatus.recipientBusy:
        return t.sendPage.busy;
      case SessionStatus.declined:
        return t.sendPage.rejected;
      case SessionStatus.tooManyAttempts:
        return t.sendPage.tooManyAttempts;
      case SessionStatus.sending:
        return null;
      case SessionStatus.finished:
        return t.general.finished;
      case SessionStatus.finishedWithErrors:
        return t.progressPage.total.title.finishedError;
      case SessionStatus.canceledBySender:
        return t.progressPage.total.title.canceledSender;
      case SessionStatus.canceledByReceiver:
        return t.progressPage.total.title.canceledReceiver;
    }
  }
}
