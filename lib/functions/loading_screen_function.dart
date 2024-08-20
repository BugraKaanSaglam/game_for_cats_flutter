import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_for_cats_flutter/main.dart';

Widget loadingScreen(BuildContext context) {
  return Scaffold(
    backgroundColor: MainAppState().gameTheme.colorScheme.surface.withAlpha(200),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(child: CircularProgressIndicator(strokeWidth: 6, valueColor: AlwaysStoppedAnimation<Color>(MainAppState().gameTheme.colorScheme.surface))),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.loading, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
