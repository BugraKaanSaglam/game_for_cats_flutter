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
  /// **'Start Hunt'**
  String get start_button;

  /// No description provided for @settings_button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_button;

  /// No description provided for @howtoplay_button.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howtoplay_button;

  /// No description provided for @about_button.
  ///
  /// In en, this message translates to:
  /// **'About the Game'**
  String get about_button;

  /// No description provided for @home_headline.
  ///
  /// In en, this message translates to:
  /// **'A bright, fast indoor hunt built for paw taps.'**
  String get home_headline;

  /// No description provided for @home_subheadline.
  ///
  /// In en, this message translates to:
  /// **'Set the hunt, start the round, and track how your cat played today.'**
  String get home_subheadline;

  /// No description provided for @home_customize_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune difficulty, timer, sound, and play mat.'**
  String get home_customize_subtitle;

  /// No description provided for @home_journal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review recent taps, misses, and accuracy.'**
  String get home_journal_subtitle;

  /// No description provided for @home_guide_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick rules before the hunt starts.'**
  String get home_guide_subtitle;

  /// No description provided for @home_default_playmat.
  ///
  /// In en, this message translates to:
  /// **'Default play mat'**
  String get home_default_playmat;

  /// No description provided for @home_custom_playmat_ready.
  ///
  /// In en, this message translates to:
  /// **'Custom play mat ready'**
  String get home_custom_playmat_ready;

  /// No description provided for @home_feature_paw_first.
  ///
  /// In en, this message translates to:
  /// **'Paw-first play'**
  String get home_feature_paw_first;

  /// No description provided for @onboarding_title_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Cat Playground'**
  String get onboarding_title_welcome;

  /// No description provided for @onboarding_subtitle_welcome.
  ///
  /// In en, this message translates to:
  /// **'Set up your space and let your cat chase the action.'**
  String get onboarding_subtitle_welcome;

  /// No description provided for @onboarding_title_play.
  ///
  /// In en, this message translates to:
  /// **'Tap, Chase, Celebrate'**
  String get onboarding_title_play;

  /// No description provided for @onboarding_subtitle_play.
  ///
  /// In en, this message translates to:
  /// **'Mice and bugs both count. Fast paws build a streak.'**
  String get onboarding_subtitle_play;

  /// No description provided for @onboarding_title_track.
  ///
  /// In en, this message translates to:
  /// **'Track the Fun'**
  String get onboarding_title_track;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Start Playing'**
  String get onboarding_start;

  /// No description provided for @select_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get select_difficulty;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @language_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app.'**
  String get language_hint;

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

  /// No description provided for @return_mainmenu_button.
  ///
  /// In en, this message translates to:
  /// **'Return to MainMenu'**
  String get return_mainmenu_button;

  /// No description provided for @howtoplay_title.
  ///
  /// In en, this message translates to:
  /// **'A quick guide for humans and cats'**
  String get howtoplay_title;

  /// No description provided for @howtoplay_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Humans start the game. Cats take over with their paws.'**
  String get howtoplay_subtitle;

  /// No description provided for @howtoplay_label_forhuman.
  ///
  /// In en, this message translates to:
  /// **'For humans'**
  String get howtoplay_label_forhuman;

  /// No description provided for @howtoplay_text_forhuman.
  ///
  /// In en, this message translates to:
  /// **'Choose a timer and difficulty, then tap Start Hunt. Put the phone in front of your cat and let the paws do the work. The game tracks taps and streaks for you.'**
  String get howtoplay_text_forhuman;

  /// No description provided for @howtoplay_label_forcats.
  ///
  /// In en, this message translates to:
  /// **'For cats'**
  String get howtoplay_label_forcats;

  /// No description provided for @howtoplay_text_forcats.
  ///
  /// In en, this message translates to:
  /// **'Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow! Meow!'**
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

  /// No description provided for @pause_hunt_title.
  ///
  /// In en, this message translates to:
  /// **'Pause the hunt?'**
  String get pause_hunt_title;

  /// No description provided for @pause_hunt_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to the menu or keep the round going.'**
  String get pause_hunt_subtitle;

  /// No description provided for @resume_hunt_button.
  ///
  /// In en, this message translates to:
  /// **'Keep hunting'**
  String get resume_hunt_button;

  /// No description provided for @end_round_button.
  ///
  /// In en, this message translates to:
  /// **'End round'**
  String get end_round_button;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @settings_header_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune the timer, sound, difficulty, and play mat for the next hunt.'**
  String get settings_header_subtitle;

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

  /// No description provided for @credits_version_label.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get credits_version_label;

  /// No description provided for @credits_version_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading app details...'**
  String get credits_version_loading;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About the Game'**
  String get about_title;

  /// No description provided for @about_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A small, colorful hunting toy built for cats and their humans.'**
  String get about_subtitle;

  /// No description provided for @about_story_title.
  ///
  /// In en, this message translates to:
  /// **'Why this game exists'**
  String get about_story_title;

  /// No description provided for @about_story_body.
  ///
  /// In en, this message translates to:
  /// **'Mice and Paws is an original cat game focused on bright motion, quick rounds, and a setup flow that stays light. Local history and flexible playfield settings help each hunt feel easy to start and satisfying to revisit.'**
  String get about_story_body;

  /// No description provided for @about_info_title.
  ///
  /// In en, this message translates to:
  /// **'Build details'**
  String get about_info_title;

  /// No description provided for @about_platform_label.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get about_platform_label;

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

  /// No description provided for @activity_title.
  ///
  /// In en, this message translates to:
  /// **'Hunt Journal'**
  String get activity_title;

  /// No description provided for @activity_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent rounds, daily taps, and miss patterns from local play sessions.'**
  String get activity_subtitle;

  /// No description provided for @activity_button.
  ///
  /// In en, this message translates to:
  /// **'Hunt Journal'**
  String get activity_button;

  /// No description provided for @activity_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load activity. Pull to refresh.'**
  String get activity_error;

  /// No description provided for @current_streak_label.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get current_streak_label;

  /// No description provided for @best_streak_label.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get best_streak_label;

  /// No description provided for @background_change_button.
  ///
  /// In en, this message translates to:
  /// **'Change Background'**
  String get background_change_button;

  /// No description provided for @background_reset_button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get background_reset_button;

  /// No description provided for @background_hint.
  ///
  /// In en, this message translates to:
  /// **'Choosing a bright, high-contrast image keeps kitty engaged.'**
  String get background_hint;

  /// No description provided for @background_selected_snackbar.
  ///
  /// In en, this message translates to:
  /// **'New background selected. Tap Save to apply.'**
  String get background_selected_snackbar;

  /// No description provided for @mute_title.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute_title;

  /// No description provided for @mute_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Silence all music and sound effects instantly.'**
  String get mute_subtitle;

  /// No description provided for @lowpower_title.
  ///
  /// In en, this message translates to:
  /// **'Low Performance Mode'**
  String get lowpower_title;

  /// No description provided for @lowpower_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce creature count and speed for smoother play on older devices.'**
  String get lowpower_subtitle;

  /// No description provided for @hunt_ready.
  ///
  /// In en, this message translates to:
  /// **'Field ready'**
  String get hunt_ready;

  /// No description provided for @hunt_ready_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Give the field a moment, then let the paws lead.'**
  String get hunt_ready_subtitle;

  /// No description provided for @hunt_record_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Hunt record'**
  String get hunt_record_eyebrow;

  /// No description provided for @hunt_record_proud.
  ///
  /// In en, this message translates to:
  /// **'A proud little hunt'**
  String get hunt_record_proud;

  /// No description provided for @hunt_record_complete.
  ///
  /// In en, this message translates to:
  /// **'Hunt complete'**
  String get hunt_record_complete;

  /// No description provided for @hunt_record_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet note from this round.'**
  String get hunt_record_subtitle;

  /// No description provided for @hunt_record_accuracy.
  ///
  /// In en, this message translates to:
  /// **'target accuracy'**
  String get hunt_record_accuracy;

  /// No description provided for @hunt_record_hits.
  ///
  /// In en, this message translates to:
  /// **'Successful taps'**
  String get hunt_record_hits;

  /// No description provided for @hunt_record_misses.
  ///
  /// In en, this message translates to:
  /// **'Misses'**
  String get hunt_record_misses;

  /// No description provided for @hunt_record_details.
  ///
  /// In en, this message translates to:
  /// **'Field notes'**
  String get hunt_record_details;

  /// No description provided for @hunt_record_manual_end.
  ///
  /// In en, this message translates to:
  /// **'The hunt was ended early.'**
  String get hunt_record_manual_end;

  /// No description provided for @hunt_record_timer_end.
  ///
  /// In en, this message translates to:
  /// **'The timer closed the hunt.'**
  String get hunt_record_timer_end;

  /// No description provided for @hunt_again.
  ///
  /// In en, this message translates to:
  /// **'Hunt again'**
  String get hunt_again;

  /// No description provided for @hunt_view_journal.
  ///
  /// In en, this message translates to:
  /// **'View journal'**
  String get hunt_view_journal;

  /// No description provided for @hunt_adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust hunt'**
  String get hunt_adjust;

  /// No description provided for @reduced_motion_title.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion'**
  String get reduced_motion_title;

  /// No description provided for @reduced_motion_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep transitions and field feedback calm.'**
  String get reduced_motion_subtitle;

  /// No description provided for @high_contrast_title.
  ///
  /// In en, this message translates to:
  /// **'Stronger contrast'**
  String get high_contrast_title;

  /// No description provided for @high_contrast_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Make targets and controls easier to distinguish.'**
  String get high_contrast_subtitle;

  /// No description provided for @larger_targets_title.
  ///
  /// In en, this message translates to:
  /// **'Larger targets'**
  String get larger_targets_title;

  /// No description provided for @larger_targets_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Give moving targets more room to be found.'**
  String get larger_targets_subtitle;

  /// No description provided for @haptics_title.
  ///
  /// In en, this message translates to:
  /// **'Touch response'**
  String get haptics_title;

  /// No description provided for @haptics_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use gentle touch feedback for human-facing controls.'**
  String get haptics_subtitle;

  /// No description provided for @playfield_title.
  ///
  /// In en, this message translates to:
  /// **'Playfield'**
  String get playfield_title;

  /// No description provided for @playfield_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the surface your next hunt will use.'**
  String get playfield_subtitle;

  /// No description provided for @hunt_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Prepare the next hunt'**
  String get hunt_setup_title;

  /// No description provided for @hunt_setup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the pace, field, and feedback before handing over the screen.'**
  String get hunt_setup_subtitle;

  /// No description provided for @journal_records_title.
  ///
  /// In en, this message translates to:
  /// **'Recent records'**
  String get journal_records_title;

  /// No description provided for @journal_records_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A local trail of the hunts played on this device.'**
  String get journal_records_subtitle;

  /// No description provided for @journal_personal_best.
  ///
  /// In en, this message translates to:
  /// **'Personal bests'**
  String get journal_personal_best;

  /// No description provided for @journal_best_accuracy.
  ///
  /// In en, this message translates to:
  /// **'Best accuracy'**
  String get journal_best_accuracy;

  /// No description provided for @journal_best_streak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get journal_best_streak;

  /// No description provided for @journal_hunts_completed.
  ///
  /// In en, this message translates to:
  /// **'Hunts completed'**
  String get journal_hunts_completed;

  /// No description provided for @guide_practice.
  ///
  /// In en, this message translates to:
  /// **'Practice the field'**
  String get guide_practice;

  /// No description provided for @guide_practice_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try the gestures yourself before inviting curious paws.'**
  String get guide_practice_subtitle;

  /// No description provided for @about_local_note.
  ///
  /// In en, this message translates to:
  /// **'Your settings and hunt records stay on this device.'**
  String get about_local_note;

  /// No description provided for @state_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get state_retry;

  /// No description provided for @state_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get state_empty_title;

  /// No description provided for @state_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a hunt and your first field note will appear here.'**
  String get state_empty_subtitle;

  /// No description provided for @accessibility_title.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility_title;

  /// No description provided for @accessibility_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the human-facing controls comfortable and the field readable.'**
  String get accessibility_subtitle;
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
