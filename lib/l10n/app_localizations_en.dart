// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Love Sync';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get general => 'General';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get editDisplayName => 'Edit Display Name';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get locationSharing => 'Location Sharing';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get unpair => 'Unpair';

  @override
  String get logout => 'Log Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get unpairConfirmationTitle => 'Unpair?';

  @override
  String get unpairConfirmationContent =>
      'Are you sure you want to leave this relationship? This action cannot be undone.';

  @override
  String get unpairAction => 'Unpair';

  @override
  String get daysTogether => 'Days';

  @override
  String get together => 'Together';

  @override
  String get anniversary => 'Anniversary';

  @override
  String get tapToPickDate => 'Tap to pick date';

  @override
  String get partnerFeeling => 'Partner is feeling:';

  @override
  String get didntSayAnything => '(Didn\'t say anything)';

  @override
  String get yourFeeling => 'How are you feeling?';

  @override
  String get whyFeeling => 'Why do you feel this way?';

  @override
  String get updateMood => 'Update Mood';

  @override
  String get sending => 'Sending...';

  @override
  String get moodUpdated => 'Mood updated!';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get enterCode => 'Enter pairing code';

  @override
  String get waitingForPartner => 'Waiting for partner...';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get decisionTournament => 'Decision Tournament';

  @override
  String get helpUsDecide => 'Help us Decide!';

  @override
  String get decisionWon => 'Decision Made!';

  @override
  String get decisionRejected => 'Decision Rejected!';

  @override
  String get weWill => 'We will: ';

  @override
  String get reason => 'Reason: ';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAngry => 'Angry';

  @override
  String get moodTired => 'Tired';

  @override
  String get moodLoved => 'Loved';

  @override
  String get connectWithPartner => 'Connect with your partner';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get googleSignInError => 'Google Sign-In Error';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signInAnonymously => 'Sign in Anonymously';

  @override
  String get pairingTitle => 'Pairing';

  @override
  String get yourPairingCode => 'Your Pairing Code';

  @override
  String get enterPartnerCode => 'Enter Partner Code';

  @override
  String get connect => 'Connect';

  @override
  String get copied => 'Copied!';

  @override
  String get generateCode => 'Generate Code';

  @override
  String get generateCodeError => 'Failed to generate code';

  @override
  String loginError(Object error) {
    return 'Error: $error';
  }

  @override
  String get weHaveBeenTogether => 'We have been together';

  @override
  String daysCount(Object count) {
    return '$count Days';
  }

  @override
  String sinceDate(Object date) {
    return 'Since: $date';
  }

  @override
  String get partnerIsFeeling => 'Partner is feeling...';

  @override
  String get youArePaired => 'You are Paired!';

  @override
  String get howAreYouToday => 'How are you feeling today?';

  @override
  String get whyDoYouFeelThisWay => 'Why do you feel this way?';

  @override
  String get needAtLeastTwoOptions => 'Need at least 2 options!';

  @override
  String get createTournament => 'Create Tournament';

  @override
  String get enterOptionsForPartner =>
      'Enter options for your partner to choose!';

  @override
  String get quantity => 'Quantity: ';

  @override
  String optionIndex(Object index) {
    return 'Option $index';
  }

  @override
  String get send => 'Send!';

  @override
  String get connectionError => 'Connection error or room deleted';

  @override
  String get goBack => 'Go Back';

  @override
  String get or => 'OR';

  @override
  String partnerFeelingMessage(Object desc, Object mood) {
    return 'Partner feels $mood: $desc';
  }

  @override
  String decisionResult(Object result) {
    return 'Decision: $result!';
  }

  @override
  String decisionRejectedReason(Object reason) {
    return 'Rejected: $reason';
  }

  @override
  String get unknownReason => 'Unknown reason';

  @override
  String get invitationSent => 'Invitation sent!';

  @override
  String get editName => 'Edit Name';

  @override
  String get yourName => 'Your Name';

  @override
  String get unpairWarning =>
      'Are you sure you want to unpair? This cannot be undone.';
}
