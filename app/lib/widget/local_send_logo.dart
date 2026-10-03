// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/assets.gen.dart';

class LocalSendLogo extends StatelessWidget {
  final bool withText;

  const LocalSendLogo({required this.withText});

  @override
  Widget build(BuildContext context) {
    final logo = Assets.img.logo512.image(
      width: 200,
      height: 200,
    );

    if (withText) {
      return Column(
        children: [
          logo,
          const Text(
            'Neardock',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return logo;
    }
  }
}
