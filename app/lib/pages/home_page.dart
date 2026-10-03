// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/init.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/home_page_controller.dart';
import 'package:localsend_app/pages/tabs/receive_tab.dart';
import 'package:localsend_app/pages/tabs/send_tab.dart';
import 'package:localsend_app/pages/tabs/settings_tab.dart';
import 'package:localsend_app/pages/tabs/text_tab.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/provider/update_provider.dart';
import 'package:localsend_app/provider/version_provider.dart';
import 'package:localsend_app/util/native/cross_file_converters.dart';
import 'package:localsend_app/widget/neardock/welcome_panel.dart';
import 'package:localsend_app/widget/responsive_builder.dart';
import 'package:refena_flutter/refena_flutter.dart';

enum HomeTab {
  send(Icons.send_outlined),
  receive(Icons.wifi),
  chat(Icons.chat_bubble_outline),
  clipboard(Icons.content_paste_outlined),
  settings(Icons.settings_outlined)
  ;

  const HomeTab(this.icon);
  final IconData icon;
  String get label => switch (this) {
    HomeTab.send => t.sendTab.title,
    HomeTab.receive => t.receiveTab.title,
    HomeTab.chat => t.neardockUI.chat,
    HomeTab.clipboard => t.neardockUI.clipboard,
    HomeTab.settings => t.settingsTab.title,
  };
}

class HomePage extends StatefulWidget {
  final HomeTab initialTab;

  /// It is important for the initializing step
  /// because the first init clears the cache
  final bool appStart;

  const HomePage({
    required this.initialTab,
    required this.appStart,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with Refena {
  bool _dragAndDropIndicator = false;
  bool _welcome = false;

  @override
  void initState() {
    super.initState();

    ensureRef((ref) async {
      ref.redux(homePageControllerProvider).dispatch(ChangeTabAction(widget.initialTab));
      if (widget.appStart && !ref.read(persistenceProvider).getOnboardingCompleted() && mounted) {
        setState(() => _welcome = true);
      }
      await postInit(context, ref, widget.appStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    Translations.of(context); // rebuild on locale change
    final vm = context.watch(homePageControllerProvider);

    if (_welcome) {
      return Scaffold(
        body: SafeArea(
          child: WelcomePanel(
            onComplete: () async {
              await ref.read(persistenceProvider).setOnboardingCompleted(true);
              if (ref.read(persistenceProvider).getAutomaticUpdatesEnabled()) {
                unawaited(ref.notifier(neardockUpdateProvider).check());
              }
              if (mounted) setState(() => _welcome = false);
            },
          ),
        ),
      );
    }
    return DropTarget(
      onDragEntered: (_) {
        setState(() {
          _dragAndDropIndicator = true;
        });
      },
      onDragExited: (_) {
        setState(() {
          _dragAndDropIndicator = false;
        });
      },
      onDragDone: (event) async {
        // the drop may contain a mix of files and directories
        final droppedDirectories = event.files.where((file) => Directory(file.path).existsSync()).toList();
        final droppedFiles = event.files.where((file) => !Directory(file.path).existsSync()).toList();

        for (final directory in droppedDirectories) {
          await ref.redux(selectedSendingFilesProvider).dispatchAsync(AddDirectoryAction(directory.path));
        }

        if (droppedFiles.isNotEmpty) {
          await ref
              .redux(selectedSendingFilesProvider)
              .dispatchAsync(
                AddFilesAction(
                  files: droppedFiles,
                  converter: CrossFileConverters.convertXFile,
                ),
              );
        }
        vm.changeTab(HomeTab.send);
      },
      child: ResponsiveBuilder(
        builder: (sizingInformation) {
          return Scaffold(
            body: Row(
              children: [
                if (!sizingInformation.isMobile) _NeardockSidebar(currentTab: vm.currentTab, onSelect: vm.changeTab),
                Expanded(
                  child: SafeArea(
                    left: sizingInformation.isMobile,
                    child: Stack(
                      children: [
                        PageView(
                          controller: vm.controller,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            SendTab(),
                            ReceiveTab(),
                            TextTab(clipboard: false),
                            TextTab(clipboard: true),
                            SettingsTab(),
                          ],
                        ),
                        if (_dragAndDropIndicator)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.file_download, size: 128),
                                const SizedBox(height: 30),
                                Text(t.sendTab.placeItems, style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            appBar: sizingInformation.isMobile
                ? AppBar(
                    title: Row(
                      children: [
                        Image.asset('assets/img/logo-128.png', width: 28, height: 28),
                        const SizedBox(width: 10),
                        const Text('Neardock', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )
                : null,
            bottomNavigationBar: sizingInformation.isMobile
                ? NavigationBar(
                    selectedIndex: vm.currentTab.index,
                    onDestinationSelected: (index) => vm.changeTab(HomeTab.values[index]),
                    destinations: HomeTab.values.map((tab) {
                      return NavigationDestination(icon: Icon(tab.icon), label: tab.label);
                    }).toList(),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _NeardockSidebar extends StatelessWidget {
  final HomeTab currentTab;
  final ValueChanged<HomeTab> onSelect;
  const _NeardockSidebar({required this.currentTab, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final version = context.watch(versionProvider);
    return Container(
      width: 184,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 12, 28),
              child: Row(
                children: [
                  Image.asset('assets/img/logo-128.png', width: 30, height: 30),
                  const SizedBox(width: 10),
                  const Text('Neardock', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final tab in HomeTab.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          color: tab == currentTab ? theme.colorScheme.primary.withValues(alpha: .10) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: BorderDirectional(
                            start: BorderSide(color: tab == currentTab ? theme.colorScheme.primary : Colors.transparent, width: 3),
                          ),
                        ),
                        child: ListTile(
                          selected: tab == currentTab,
                          selectedColor: theme.colorScheme.primary,
                          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Icon(tab.icon, size: 22),
                          title: Text(tab.label),
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            onSelect(tab);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  version.maybeWhen(
                    data: (v) => Text('Neardock ${v.version}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
