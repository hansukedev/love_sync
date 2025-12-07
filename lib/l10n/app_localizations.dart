import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Love Sync'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit Display Name'**
  String get editDisplayName;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @unpair.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get unpair;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @unpairConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpair?'**
  String get unpairConfirmationTitle;

  /// No description provided for @unpairConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this relationship? This action cannot be undone.'**
  String get unpairConfirmationContent;

  /// No description provided for @unpairAction.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get unpairAction;

  /// No description provided for @daysTogether.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysTogether;

  /// No description provided for @together.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get together;

  /// No description provided for @anniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get anniversary;

  /// No description provided for @tapToPickDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick date'**
  String get tapToPickDate;

  /// No description provided for @partnerFeeling.
  ///
  /// In en, this message translates to:
  /// **'Partner is feeling:'**
  String get partnerFeeling;

  /// No description provided for @didntSayAnything.
  ///
  /// In en, this message translates to:
  /// **'(Didn\'t say anything)'**
  String get didntSayAnything;

  /// No description provided for @yourFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get yourFeeling;

  /// No description provided for @whyFeeling.
  ///
  /// In en, this message translates to:
  /// **'Why do you feel this way?'**
  String get whyFeeling;

  /// No description provided for @updateMood.
  ///
  /// In en, this message translates to:
  /// **'Update Mood'**
  String get updateMood;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @moodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mood updated!'**
  String get moodUpdated;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter pairing code'**
  String get enterCode;

  /// No description provided for @waitingForPartner.
  ///
  /// In en, this message translates to:
  /// **'Waiting for partner...'**
  String get waitingForPartner;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @decisionTournament.
  ///
  /// In en, this message translates to:
  /// **'Decision Tournament'**
  String get decisionTournament;

  /// No description provided for @helpUsDecide.
  ///
  /// In en, this message translates to:
  /// **'Help us Decide!'**
  String get helpUsDecide;

  /// No description provided for @decisionWon.
  ///
  /// In en, this message translates to:
  /// **'Decision Made!'**
  String get decisionWon;

  /// No description provided for @decisionRejected.
  ///
  /// In en, this message translates to:
  /// **'Decision Rejected!'**
  String get decisionRejected;

  /// No description provided for @weWill.
  ///
  /// In en, this message translates to:
  /// **'We will: '**
  String get weWill;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason: '**
  String get reason;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodAngry;

  /// No description provided for @moodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodTired;

  /// No description provided for @moodLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get moodLoved;

  /// No description provided for @connectWithPartner.
  ///
  /// In en, this message translates to:
  /// **'Connect with your partner'**
  String get connectWithPartner;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @googleSignInError.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In Error'**
  String get googleSignInError;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signInAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Sign in Anonymously'**
  String get signInAnonymously;

  /// No description provided for @pairingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pairing'**
  String get pairingTitle;

  /// No description provided for @yourPairingCode.
  ///
  /// In en, this message translates to:
  /// **'Your Pairing Code'**
  String get yourPairingCode;

  /// No description provided for @enterPartnerCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Code'**
  String get enterPartnerCode;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Code'**
  String get generateCode;

  /// No description provided for @generateCodeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate code'**
  String get generateCodeError;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String loginError(Object error);

  /// No description provided for @weHaveBeenTogether.
  ///
  /// In en, this message translates to:
  /// **'We have been together'**
  String get weHaveBeenTogether;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String daysCount(Object count);

  /// No description provided for @sinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since: {date}'**
  String sinceDate(Object date);

  /// No description provided for @partnerIsFeeling.
  ///
  /// In en, this message translates to:
  /// **'Partner is feeling...'**
  String get partnerIsFeeling;

  /// No description provided for @youArePaired.
  ///
  /// In en, this message translates to:
  /// **'You are Paired!'**
  String get youArePaired;

  /// No description provided for @howAreYouToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouToday;

  /// No description provided for @whyDoYouFeelThisWay.
  ///
  /// In en, this message translates to:
  /// **'Why do you feel this way?'**
  String get whyDoYouFeelThisWay;

  /// No description provided for @needAtLeastTwoOptions.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 options!'**
  String get needAtLeastTwoOptions;

  /// No description provided for @createTournament.
  ///
  /// In en, this message translates to:
  /// **'Create Tournament'**
  String get createTournament;

  /// No description provided for @enterOptionsForPartner.
  ///
  /// In en, this message translates to:
  /// **'Enter options for your partner to choose!'**
  String get enterOptionsForPartner;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: '**
  String get quantity;

  /// No description provided for @optionIndex.
  ///
  /// In en, this message translates to:
  /// **'Option {index}'**
  String optionIndex(Object index);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send!'**
  String get send;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error or room deleted'**
  String get connectionError;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @partnerFeelingMessage.
  ///
  /// In en, this message translates to:
  /// **'Partner feels {mood}: {desc}'**
  String partnerFeelingMessage(Object desc, Object mood);

  /// No description provided for @decisionResult.
  ///
  /// In en, this message translates to:
  /// **'Decision: {result}!'**
  String decisionResult(Object result);

  /// No description provided for @decisionRejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Rejected: {reason}'**
  String decisionRejectedReason(Object reason);

  /// No description provided for @unknownReason.
  ///
  /// In en, this message translates to:
  /// **'Unknown reason'**
  String get unknownReason;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent!'**
  String get invitationSent;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @unpairWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unpair? This cannot be undone.'**
  String get unpairWarning;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
