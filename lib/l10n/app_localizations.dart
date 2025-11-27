import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @game_name.
  ///
  /// In en, this message translates to:
  /// **'Mice and Paws: Cat Game'**
  String get game_name;

  /// No description provided for @start_button.
  ///
  /// In en, this message translates to:
  /// **'Start The Game!'**
  String get start_button;

  /// No description provided for @settings_button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_button;

  /// No description provided for @howtoplay_button.
  ///
  /// In en, this message translates to:
  /// **'How To Play?'**
  String get howtoplay_button;

  /// No description provided for @credits_button.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits_button;

  /// No description provided for @exit_button.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit_button;

  /// No description provided for @main_tagline.
  ///
  /// In en, this message translates to:
  /// **'Catch the mice, dodge the bugs, make kitty proud!'**
  String get main_tagline;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @select_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get select_difficulty;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get select_time;

  /// No description provided for @select_musicvolume.
  ///
  /// In en, this message translates to:
  /// **'Game Music Volume'**
  String get select_musicvolume;

  /// No description provided for @select_charactervolume.
  ///
  /// In en, this message translates to:
  /// **'Characters Volume'**
  String get select_charactervolume;

  /// No description provided for @save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_button;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Time Left: '**
  String get countdown;

  /// No description provided for @game_over.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get game_over;

  /// No description provided for @tryagain_button.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryagain_button;

  /// No description provided for @return_mainmenu_button.
  ///
  /// In en, this message translates to:
  /// **'Return to MainMenu'**
  String get return_mainmenu_button;

  /// No description provided for @howtoplay_label_forhuman.
  ///
  /// In en, this message translates to:
  /// **'How To Play? (For Humans)'**
  String get howtoplay_label_forhuman;

  /// No description provided for @howtoplay_text_forhuman.
  ///
  /// In en, this message translates to:
  /// **'Game is soo simple!, Select time for play from settings, then press Start!, If you want no time limit, select sandbox from settings!'**
  String get howtoplay_text_forhuman;

  /// No description provided for @howtoplay_label_forcats.
  ///
  /// In en, this message translates to:
  /// **'How To Play? (For Cats)'**
  String get howtoplay_label_forcats;

  /// No description provided for @howtoplay_text_forcats.
  ///
  /// In en, this message translates to:
  /// **'Meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow'**
  String get howtoplay_text_forcats;

  /// No description provided for @micetap_count.
  ///
  /// In en, this message translates to:
  /// **'Tapped Mice:'**
  String get micetap_count;

  /// No description provided for @bugtap_count.
  ///
  /// In en, this message translates to:
  /// **'Tapped Bug:'**
  String get bugtap_count;

  /// No description provided for @wrongtap_count.
  ///
  /// In en, this message translates to:
  /// **'Tapped Outside:'**
  String get wrongtap_count;

  /// No description provided for @save_complete_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Task Succesfully Complete!'**
  String get save_complete_snackbar;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @credits_creators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get credits_creators;

  /// No description provided for @credits_creators_text.
  ///
  /// In en, this message translates to:
  /// **'Buğra Kaan Sağlam'**
  String get credits_creators_text;

  /// No description provided for @exit_validation.
  ///
  /// In en, this message translates to:
  /// **'Who Wants to Exit? \nCat or Human?'**
  String get exit_validation;

  /// No description provided for @this_will_close_automatically_in_seconds.
  ///
  /// In en, this message translates to:
  /// **'This Will Close Automatically \nin 2 Seconds...'**
  String get this_will_close_automatically_in_seconds;

  /// No description provided for @i_am_cat.
  ///
  /// In en, this message translates to:
  /// **'Meow??'**
  String get i_am_cat;

  /// No description provided for @i_am_human.
  ///
  /// In en, this message translates to:
  /// **'I am Human, Close the Game'**
  String get i_am_human;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @settings_header_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust timers, languages and volumes for the purr-fect hunt.'**
  String get settings_header_subtitle;

  /// No description provided for @settings_language_hint.
  ///
  /// In en, this message translates to:
  /// **'Show menus in the language your human prefers.'**
  String get settings_language_hint;

  /// No description provided for @settings_time_hint.
  ///
  /// In en, this message translates to:
  /// **'Short sprint or endless sandbox? Pick the purr-fect timer.'**
  String get settings_time_hint;

  /// No description provided for @settings_music_hint.
  ///
  /// In en, this message translates to:
  /// **'Turn the meows into a dance party!'**
  String get settings_music_hint;

  /// No description provided for @settings_character_hint.
  ///
  /// In en, this message translates to:
  /// **'Squeaks & squeals volume.'**
  String get settings_character_hint;

  /// No description provided for @credits_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A tiny team with giant love for cats and colors.'**
  String get credits_subtitle;

  /// No description provided for @credits_special_thanks.
  ///
  /// In en, this message translates to:
  /// **'Special Thanks'**
  String get credits_special_thanks;

  /// No description provided for @settings_difficulty_hint.
  ///
  /// In en, this message translates to:
  /// **'Control spawn speed, speed curve and active critters.'**
  String get settings_difficulty_hint;

  /// No description provided for @difficulty_easy.
  ///
  /// In en, this message translates to:
  /// **'Kitten (Easy)'**
  String get difficulty_easy;

  /// No description provided for @difficulty_medium.
  ///
  /// In en, this message translates to:
  /// **'Playful (Medium)'**
  String get difficulty_medium;

  /// No description provided for @difficulty_hard.
  ///
  /// In en, this message translates to:
  /// **'Hunter (Hard)'**
  String get difficulty_hard;

  /// No description provided for @difficulty_sandbox.
  ///
  /// In en, this message translates to:
  /// **'Sandbox / Free Play'**
  String get difficulty_sandbox;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
