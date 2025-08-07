// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/database/db_error.dart';
import 'package:game_for_cats_2025/database/db_helper.dart';
import 'package:game_for_cats_2025/database/opc_database_list.dart';
import 'package:game_for_cats_2025/enums/enum_functions.dart';
import 'package:game_for_cats_2025/enums/game_enums.dart';
import 'package:game_for_cats_2025/global/argumentsender_class.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/widgets/cool_animated_buttons.dart';

import '../global/global_functions.dart';
import '../global/global_variables.dart';
import '../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  OPCDataBase? _db;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Animation controller for staggering button appearances
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(AppLocalizations.of(context)!.game_name, context, hasBackButton: false),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/mainscreenbg.png', fit: BoxFit.fill)),
          mainBody(context),
        ],
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    return FutureBuilder<OPCDataBase?>(
      future: DBHelper().getList(databaseVersion),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          if (snapshot.data == null && !snapshot.hasError) {
            OPCDataBase initDataBase = OPCDataBase(ver: databaseVersion, languageCode: Language.english.value, musicVolume: 0.5, characterVolume: 1, time: Time.fifty.value);
            DBHelper().add(initDataBase);
            _db = initDataBase;
          } else {
            return dbError(context);
          }
        }

        _db ??= snapshot.data;

        // Start animation after data is loaded
        _animationController.forward();

        checkGameTime(_db?.time);
        languageCode = getLanguageFromValue(_db?.languageCode);
        Future.delayed(Duration.zero, () => MainApp.of(context)!.setLocale(languageCode.value));

        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  // Animated buttons using the new design
                  _buildStaggeredAnimatedButton(
                    delay: 0.0,
                    child: CoolAnimatedButton(
                      text: AppLocalizations.of(context)!.start_button,
                      icon: const Icon(Icons.arrow_right_alt_sharp),
                      onPressed: () => _navigateTo('/game_screen', AppLocalizations.of(context)!.start_button, dataBase: _db),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  _buildStaggeredAnimatedButton(
                    delay: 0.15,
                    child: CoolAnimatedButton(text: AppLocalizations.of(context)!.settings_button, icon: const Icon(Icons.settings), onPressed: () => _navigateTo('/settings_screen', AppLocalizations.of(context)!.settings_button)),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  _buildStaggeredAnimatedButton(
                    delay: 0.30,
                    child: CoolAnimatedButton(text: AppLocalizations.of(context)!.howtoplay_button, icon: const Icon(Icons.menu_book), onPressed: () => _navigateTo('/howtoplay_screen', AppLocalizations.of(context)!.howtoplay_button)),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  _buildStaggeredAnimatedButton(
                    delay: 0.45,
                    child: CoolAnimatedButton(text: AppLocalizations.of(context)!.credits_button, icon: const Icon(Icons.pest_control_rodent_sharp), onPressed: () => _navigateTo('/credits_screen', AppLocalizations.of(context)!.credits_button)),
                  ),
                  const Spacer(flex: 2),
                  _buildStaggeredAnimatedButton(
                    delay: 0.6,
                    child: CoolAnimatedButton(
                      text: AppLocalizations.of(context)!.exit_button,
                      icon: const Icon(Icons.exit_to_app_outlined),
                      onPressed: () => exit(0),
                      startColor: const Color(0xFFD32F2F), // Red for exit
                      endColor: const Color(0xFFC62828),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Time checkGameTime(int? time) => getTimeFromValue(time);

  // Helper function for staggered animation
  Widget _buildStaggeredAnimatedButton({required Widget child, required double delay}) {
    final animation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _animationController.drive(CurveTween(curve: Curves.easeIn)),
        child: child,
      ),
    );
  }

  // Helper for navigation to keep button code clean
  void _navigateTo(String routeName, String title, {OPCDataBase? dataBase}) {
    ArgumentSender argumentSender = ArgumentSender(title: title, dataBase: dataBase);
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false, arguments: argumentSender);
  }
}
