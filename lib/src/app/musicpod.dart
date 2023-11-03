import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:yaru/yaru.dart';

import '../l10n/l10n.dart';
import 'app.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaruThemeData, child) {
        return GtkApplication(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: yaruThemeData.theme,
            darkTheme: yaruThemeData.darkTheme?.copyWith(
              // TODO: port to yaru.dart
              dividerTheme: const DividerThemeData(
                color: Color.fromARGB(255, 60, 60, 60),
                space: 1.0,
                thickness: 0.0,
              ),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: supportedLocales,
            onGenerateTitle: (context) => 'MusicPod',
            home: App.create(),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
                PointerDeviceKind.trackpad,
              },
            ),
          ),
        );
      },
    );
  }
}