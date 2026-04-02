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
  /// **'How It Works'**
  String get howtoplay_button;

  /// No description provided for @credits_button.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits_button;

  /// No description provided for @about_button.
  ///
  /// In en, this message translates to:
  /// **'About the Game'**
  String get about_button;

  /// No description provided for @exit_button.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit_button;

  /// No description provided for @main_tagline.
  ///
  /// In en, this message translates to:
  /// **'Turn any screen into a playful indoor hunt.'**
  String get main_tagline;

  /// No description provided for @home_kicker.
  ///
  /// In en, this message translates to:
  /// **'Made for curious cats'**
  String get home_kicker;

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

  /// No description provided for @home_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s hunt setup'**
  String get home_setup_title;

  /// No description provided for @home_setup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick snapshot of the current timer, difficulty, sound, and play mat.'**
  String get home_setup_subtitle;

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

  /// No description provided for @home_muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get home_muted;

  /// No description provided for @home_sound_on.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get home_sound_on;

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

  /// No description provided for @onboarding_subtitle_track.
  ///
  /// In en, this message translates to:
  /// **'Review daily taps, misses, and accuracy in the hunt journal.'**
  String get onboarding_subtitle_track;

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

  /// No description provided for @howtoplay_title.
  ///
  /// In en, this message translates to:
  /// **'Keep the hunt clear and exciting'**
  String get howtoplay_title;

  /// No description provided for @howtoplay_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Three quick tips to help your cat enjoy the round without extra setup.'**
  String get howtoplay_subtitle;

  /// No description provided for @howtoplay_label_forhuman.
  ///
  /// In en, this message translates to:
  /// **'Set up the round'**
  String get howtoplay_label_forhuman;

  /// No description provided for @howtoplay_text_forhuman.
  ///
  /// In en, this message translates to:
  /// **'Choose a timer, adjust the difficulty, and pick a bright background if you want a custom play mat. Then start the round and hand the screen to your cat.'**
  String get howtoplay_text_forhuman;

  /// No description provided for @howtoplay_label_forcats.
  ///
  /// In en, this message translates to:
  /// **'Tap the moving critters'**
  String get howtoplay_label_forcats;

  /// No description provided for @howtoplay_text_forcats.
  ///
  /// In en, this message translates to:
  /// **'Mice and bugs both count as successful taps. Misses are tracked separately, so keeping your paws on target leads to cleaner hunts.'**
  String get howtoplay_text_forcats;

  /// No description provided for @howtoplay_label_forstreaks.
  ///
  /// In en, this message translates to:
  /// **'Build a purr streak'**
  String get howtoplay_label_forstreaks;

  /// No description provided for @howtoplay_text_forstreaks.
  ///
  /// In en, this message translates to:
  /// **'Every successful tap grows the streak. Misses reset it. The round summary shows accuracy, best streak, and your cat\'s overall mood.'**
  String get howtoplay_text_forstreaks;

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
  /// **'Pause the hunt?'**
  String get exit_validation;

  /// No description provided for @this_will_close_automatically_in_seconds.
  ///
  /// In en, this message translates to:
  /// **'Return to the menu or keep the round going.'**
  String get this_will_close_automatically_in_seconds;

  /// No description provided for @i_am_cat.
  ///
  /// In en, this message translates to:
  /// **'Keep hunting'**
  String get i_am_cat;

  /// No description provided for @i_am_human.
  ///
  /// In en, this message translates to:
  /// **'End round'**
  String get i_am_human;

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

  /// No description provided for @credits_share_title.
  ///
  /// In en, this message translates to:
  /// **'Share the game'**
  String get credits_share_title;

  /// No description provided for @credits_share_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Send the game to another cat-loving human.'**
  String get credits_share_subtitle;

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

  /// No description provided for @about_story_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A simple idea shaped into a more polished experience over time.'**
  String get about_story_subtitle;

  /// No description provided for @about_story_body.
  ///
  /// In en, this message translates to:
  /// **'Mice and Paws was built as an original cat game focused on bright motion, quick rounds, and a setup flow that stays light. It started as a first app and grew into a more intentional product with local history, customization, and a clearer visual identity.'**
  String get about_story_body;

  /// No description provided for @about_highlights_title.
  ///
  /// In en, this message translates to:
  /// **'What makes it distinct'**
  String get about_highlights_title;

  /// No description provided for @about_highlights_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A few things this build now emphasizes.'**
  String get about_highlights_subtitle;

  /// No description provided for @about_highlight_one.
  ///
  /// In en, this message translates to:
  /// **'Game-first home screen with the hunt setup surfaced before utility screens.'**
  String get about_highlight_one;

  /// No description provided for @about_highlight_two.
  ///
  /// In en, this message translates to:
  /// **'Custom play mat backgrounds so each device can feel a little different.'**
  String get about_highlight_two;

  /// No description provided for @about_highlight_three.
  ///
  /// In en, this message translates to:
  /// **'Round summaries with streaks, accuracy, and a playful cat mood grade.'**
  String get about_highlight_three;

  /// No description provided for @about_info_title.
  ///
  /// In en, this message translates to:
  /// **'Build details'**
  String get about_info_title;

  /// No description provided for @about_info_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Version and product notes for the installed build.'**
  String get about_info_subtitle;

  /// No description provided for @about_platform_label.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get about_platform_label;

  /// No description provided for @about_release_model_label.
  ///
  /// In en, this message translates to:
  /// **'App model'**
  String get about_release_model_label;

  /// No description provided for @about_release_model_value.
  ///
  /// In en, this message translates to:
  /// **'Local-only, no backend required'**
  String get about_release_model_value;

  /// No description provided for @store_links_title.
  ///
  /// In en, this message translates to:
  /// **'Store Links'**
  String get store_links_title;

  /// No description provided for @store_links_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the published listing for this game.'**
  String get store_links_subtitle;

  /// No description provided for @google_play_button.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get google_play_button;

  /// No description provided for @app_store_button.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get app_store_button;

  /// No description provided for @connectivity_title.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity_title;

  /// No description provided for @connectivity_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Current network reachability state for the device.'**
  String get connectivity_subtitle;

  /// No description provided for @connectivity_status_online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get connectivity_status_online;

  /// No description provided for @connectivity_status_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connectivity_status_offline;

  /// No description provided for @connectivity_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get connectivity_status_unknown;

  /// No description provided for @offline_banner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. The game still works, but online services are paused.'**
  String get offline_banner;

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

  /// No description provided for @activity_empty.
  ///
  /// In en, this message translates to:
  /// **'No play sessions logged yet. Start a round to track activity!'**
  String get activity_empty;

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

  /// No description provided for @activity_legend_total.
  ///
  /// In en, this message translates to:
  /// **'Total taps'**
  String get activity_legend_total;

  /// No description provided for @activity_legend_miss.
  ///
  /// In en, this message translates to:
  /// **'Miss taps'**
  String get activity_legend_miss;

  /// No description provided for @activity_total_label.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get activity_total_label;

  /// No description provided for @activity_miss_label.
  ///
  /// In en, this message translates to:
  /// **'Misses'**
  String get activity_miss_label;

  /// No description provided for @activity_accuracy_label.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get activity_accuracy_label;

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

  /// No description provided for @cat_mood_warming_up.
  ///
  /// In en, this message translates to:
  /// **'Warming up'**
  String get cat_mood_warming_up;

  /// No description provided for @cat_mood_curious.
  ///
  /// In en, this message translates to:
  /// **'Curious paws'**
  String get cat_mood_curious;

  /// No description provided for @cat_mood_playful.
  ///
  /// In en, this message translates to:
  /// **'Playful hunter'**
  String get cat_mood_playful;

  /// No description provided for @cat_mood_hunt_legend.
  ///
  /// In en, this message translates to:
  /// **'Hunt legend'**
  String get cat_mood_hunt_legend;

  /// No description provided for @background_title.
  ///
  /// In en, this message translates to:
  /// **'Background Image'**
  String get background_title;

  /// No description provided for @background_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo for the playfield or reset to default.'**
  String get background_subtitle;

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

  /// No description provided for @mute_toggle_label.
  ///
  /// In en, this message translates to:
  /// **'Tap to mute/unmute'**
  String get mute_toggle_label;

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

  /// No description provided for @lowpower_toggle_label.
  ///
  /// In en, this message translates to:
  /// **'Lower motion & power'**
  String get lowpower_toggle_label;

  /// No description provided for @share_app_button.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get share_app_button;

  /// No description provided for @share_app_text.
  ///
  /// In en, this message translates to:
  /// **'I am playing {gameName} on version {version}. Catch the mice, dodge the bugs, make kitty proud!'**
  String share_app_text(Object gameName, Object version);
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
