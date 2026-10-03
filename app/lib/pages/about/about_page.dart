// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/provider/version_provider.dart';
import 'package:localsend_app/util/i18n.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

part 'contributors.dart';

part 'packagers.dart';

part 'translators.dart';

final _translatorWithGithubRegex = RegExp(r'(.+) \(@([\w\-_]+)\)');

class AboutPage extends StatelessWidget {
  const AboutPage();
  @override
  Widget build(BuildContext context) {
    final version = context.watch(versionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.aboutPage.title)),
      body: ResponsiveListView(
        maxWidth: 760,
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          Center(child: Image.asset('assets/img/logo-128.png', width: 88, height: 88)),
          const SizedBox(height: 20),
          Text(
            'Neardock',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(t.neardockUI.byYazeMedia, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          version.maybeWhen(
            data: (v) => Text('Version ${v.version}', textAlign: TextAlign.center),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          Text(t.neardockUI.purpose, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(t.neardockUI.website),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse('https://yazekt.github.io/Neardock/')),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(t.changelogPage.title),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse('https://github.com/YazeKT/Neardock/releases')),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(t.neardockUI.sourceCode),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse('https://github.com/YazeKT/Neardock')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.neardockUI.acknowledgements, style: TextStyle(fontWeight: FontWeight.w700)),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(t.neardockUI.basedOnLocalSend),
                  subtitle: Text(t.neardockUI.upstreamCredits),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(() => const UpstreamAcknowledgementsPage()),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(t.neardockUI.apacheLicense),
                  subtitle: Text(t.neardockUI.codeCopyright),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse('https://www.apache.org/licenses/LICENSE-2.0')),
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(t.neardockUI.thirdPartyLicences),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Neardock',
                    applicationIcon: Image.asset('assets/img/logo-128.png', width: 72, height: 72),
                    applicationLegalese: 'Copyright 2026 Yaze Media',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copyright_outlined),
                  title: Text(t.neardockUI.brandTerms),
                  subtitle: Text(t.neardockUI.brandAssets),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(t.neardockUI.brandTerms),
                      content: SingleChildScrollView(child: SelectableText(t.neardockUI.brandTermsText)),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.general.close))],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('© 2026 Yaze Media', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class UpstreamAcknowledgementsPage extends StatelessWidget {
  const UpstreamAcknowledgementsPage();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          const LocalSendLogo(withText: true),
          Text(
            'Neardock by Yaze Media\nBased on LocalSend · © 2022–2026 Tien Do Nam',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse('https://yazekt.github.io/Neardock'));
              },
              child: const Text('yazekt.github.io/Neardock'),
            ),
          ),
          const SizedBox(height: 10),
          Text(t.aboutPage.description.join('\n\n')),
          const SizedBox(height: 20),
          Text('LocalSend author', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text.rich(
            _buildContributor(
              label: 'Tien Do Nam (@Tienisto)',
              primaryColor: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(t.aboutPage.contributors, style: const TextStyle(fontWeight: FontWeight.bold)),
          ..._contributors.map((contributor) {
            return Text.rich(
              _buildContributor(
                label: contributor,
                primaryColor: primaryColor,
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(t.aboutPage.packagers, style: const TextStyle(fontWeight: FontWeight.bold)),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              ..._packagers.entries.map(
                (e) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(e.key),
                    ),
                    Text.rich(
                      TextSpan(
                        children: e.value.mapIndexed(
                          (index, translator) {
                            return _buildContributor(
                              label: translator,
                              primaryColor: primaryColor,
                              newLine: index != 0,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(t.aboutPage.translators, style: const TextStyle(fontWeight: FontWeight.bold)),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              ..._translators.entries.map(
                (e) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(e.key.getLocaleName()),
                    ),
                    Text.rich(
                      TextSpan(
                        children: e.value.mapIndexed(
                          (index, translator) {
                            return _buildContributor(
                              label: translator,
                              primaryColor: primaryColor,
                              newLine: index != 0,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://yazekt.github.io/Neardock'));
                },
                child: const Text('Homepage'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://github.com/YazeKT/Neardock'), mode: LaunchMode.externalApplication);
                },
                child: const Text('Source Code (Github)'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://codeberg.org/localsend/localsend'), mode: LaunchMode.externalApplication);
                },
                child: const Text('Upstream source (Codeberg)'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://www.apache.org/licenses/LICENSE-2.0'));
                },
                child: Text(t.neardockUI.apacheLicense),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const LicensePage());
                },
                child: const Text('License Notices'),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const DebugPage());
                },
                child: const Text('Debugging'),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

/// Displays the contributor name and links to their github profile.
InlineSpan _buildContributor({required String label, required Color primaryColor, bool newLine = false}) {
  final newLineStr = newLine ? '\n' : '';

  if (label.startsWith('@')) {
    // Only github name
    return TextSpan(
      text: '$newLineStr$label',
      style: TextStyle(color: primaryColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          await launchUrl(Uri.parse('https://github.com/${label.substring(1)}'), mode: LaunchMode.externalApplication);
        },
    );
  }

  final match = _translatorWithGithubRegex.firstMatch(label);
  if (match != null) {
    // Full name and github name
    final fullName = match.group(1)!;
    final githubName = match.group(2)!;
    return TextSpan(
      children: [
        TextSpan(text: '$newLineStr$fullName'),
        const TextSpan(text: ' '),
        TextSpan(
          text: '@$githubName',
          style: TextStyle(color: primaryColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await launchUrl(Uri.parse('https://github.com/$githubName'), mode: LaunchMode.externalApplication);
            },
        ),
      ],
    );
  }

  // Only full name
  return TextSpan(text: '$newLineStr$label');
}
