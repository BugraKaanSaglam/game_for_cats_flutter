// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/global/argumentsender_class.dart';
import '../global/global_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ArgumentSender;

    return Scaffold(appBar: mainAppBar(args.title!, context), body: mainBody(context));
  }

  Widget mainBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(children: [
        Container(
            height: 200,
            decoration: BoxDecoration(border: Border.all(), color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text(AppLocalizations.of(context)!.howtoplay_label_forhuman, style: labelTextStyle()),
              Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(context)!.howtoplay_text_forhuman, style: normalTextStyle())),
            ])),
        const Spacer(flex: 1),
        Container(
            height: 300,
            decoration: BoxDecoration(border: Border.all(), color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.howtoplay_label_forcats, style: labelTextStyle()),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(context)!.howtoplay_text_forcats, style: normalTextStyle())),
              ],
            )),
        const Spacer(flex: 1),
      ]),
    );
  }
}
