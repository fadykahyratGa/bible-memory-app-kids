import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'appTitle': 'تحدي الحفظ الكتابي',
      'loading': 'جاري التحضير...',
      'profileQuestion': 'ما اسمك؟',
      'displayNameLabel': 'الاسم الظاهر',
      'continue': 'متابعة',
      'homeGreeting': 'مرحبًا',
      'createRoom': 'أنشئ غرفة',
      'joinRoom': 'انضم إلى غرفة',
      'settings': 'الإعدادات',
      'legacyMode': 'التجربة الفردية السابقة',
      'gameMode': 'نمط اللعب',
      'judgeMode': 'وضع الحكم',
      'individualMode': 'فردي',
      'teamsMode': 'فرق',
      'judgeNone': 'بدون حكم',
      'judgeHost': 'صاحب الغرفة حكم',
      'judgeDedicated': 'حكم مخصص',
      'teamCount': 'عدد الفرق',
      'createRoomAction': 'إنشاء الغرفة',
      'roomCode': 'كود الغرفة',
      'nickname': 'الاسم داخل الغرفة',
      'joinRoomAction': 'دخول الغرفة',
      'copyCode': 'نسخ الكود',
      'players': 'اللاعبون',
      'teams': 'الفرق',
      'startGame': 'ابدأ اللعبة',
      'leaveRoom': 'مغادرة الغرفة',
      'host': 'صاحب الغرفة',
      'judge': 'الحكم',
      'ready': 'جاهز',
      'currentChallenge': 'التحدي الحالي',
      'submitAnswer': 'إرسال الإجابة',
      'advanceChallenge': 'التحدي التالي',
      'scoreboard': 'لوحة النتائج',
      'results': 'النتائج',
      'returnHome': 'العودة للرئيسية',
      'copied': 'تم نسخ الكود',
      'roomCreated': 'تم إنشاء الغرفة',
      'roomJoined': 'تم الانضمام إلى الغرفة',
      'nameRequired': 'من فضلك اكتب الاسم.',
      'codeRequired': 'من فضلك اكتب كود الغرفة.',
      'invalidRoomCode': 'كود الغرفة يجب أن يكون 5 أو 6 أحرف كبيرة.',
      'waitingPlayers': 'في انتظار بقية اللاعبين...',
      'trueOption': 'صح',
      'falseOption': 'خطأ',
      'noChallengeYet': 'لم يبدأ التحدي بعد.',
      'connectedAsGuest': 'تم الدخول كضيف',
      'missingConfig': 'إعدادات Supabase غير مكتملة.',
      'retry': 'إعادة المحاولة',
      'roomLobby': 'لوبي الغرفة',
      'multiplayerHomeSubtitle': 'اختر طريقة اللعب الجماعي',
      'gameInProgress': 'اللعبة قيد التقدم',
      'teamLabel': 'الفريق',
      'points': 'نقطة',
      'gameFinished': 'انتهت اللعبة',
      'answerSubmitted': 'تم إرسال الإجابة',
      'noProfileYet': 'أكمل اسمك قبل اللعب.',
    },
    'en': {
      'appTitle': 'Bible Memory Challenge',
      'loading': 'Preparing...',
      'profileQuestion': 'What is your name?',
      'displayNameLabel': 'Display name',
      'continue': 'Continue',
      'homeGreeting': 'Hello',
      'createRoom': 'Create room',
      'joinRoom': 'Join room',
      'settings': 'Settings',
      'legacyMode': 'Previous solo experience',
      'gameMode': 'Game mode',
      'judgeMode': 'Judge mode',
      'individualMode': 'Individual',
      'teamsMode': 'Teams',
      'judgeNone': 'No judge',
      'judgeHost': 'Host judge',
      'judgeDedicated': 'Dedicated judge',
      'teamCount': 'Team count',
      'createRoomAction': 'Create room',
      'roomCode': 'Room code',
      'nickname': 'Nickname',
      'joinRoomAction': 'Join room',
      'copyCode': 'Copy code',
      'players': 'Players',
      'teams': 'Teams',
      'startGame': 'Start game',
      'leaveRoom': 'Leave room',
      'host': 'Host',
      'judge': 'Judge',
      'ready': 'Ready',
      'currentChallenge': 'Current challenge',
      'submitAnswer': 'Submit answer',
      'advanceChallenge': 'Next challenge',
      'scoreboard': 'Scoreboard',
      'results': 'Results',
      'returnHome': 'Back home',
      'copied': 'Code copied',
      'roomCreated': 'Room created',
      'roomJoined': 'Joined room',
      'nameRequired': 'Please enter your name.',
      'codeRequired': 'Please enter the room code.',
      'invalidRoomCode': 'Room code must be 5 or 6 uppercase characters.',
      'waitingPlayers': 'Waiting for the other players...',
      'trueOption': 'True',
      'falseOption': 'False',
      'noChallengeYet': 'The challenge has not started yet.',
      'connectedAsGuest': 'Connected as guest',
      'missingConfig': 'Supabase configuration is missing.',
      'retry': 'Retry',
      'roomLobby': 'Room lobby',
      'multiplayerHomeSubtitle': 'Choose how to play together',
      'gameInProgress': 'Game in progress',
      'teamLabel': 'Team',
      'points': 'points',
      'gameFinished': 'Game finished',
      'answerSubmitted': 'Answer submitted',
      'noProfileYet': 'Complete your name before playing.',
    },
  };

  String _value(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['ar']![key] ?? key;
  }

  String get appTitle => _value('appTitle');
  String get loading => _value('loading');
  String get profileQuestion => _value('profileQuestion');
  String get displayNameLabel => _value('displayNameLabel');
  String get continueLabel => _value('continue');
  String get homeGreeting => _value('homeGreeting');
  String get createRoom => _value('createRoom');
  String get joinRoom => _value('joinRoom');
  String get settings => _value('settings');
  String get legacyMode => _value('legacyMode');
  String get gameMode => _value('gameMode');
  String get judgeMode => _value('judgeMode');
  String get individualMode => _value('individualMode');
  String get teamsMode => _value('teamsMode');
  String get judgeNone => _value('judgeNone');
  String get judgeHost => _value('judgeHost');
  String get judgeDedicated => _value('judgeDedicated');
  String get teamCount => _value('teamCount');
  String get createRoomAction => _value('createRoomAction');
  String get roomCode => _value('roomCode');
  String get nickname => _value('nickname');
  String get joinRoomAction => _value('joinRoomAction');
  String get copyCode => _value('copyCode');
  String get players => _value('players');
  String get teams => _value('teams');
  String get startGame => _value('startGame');
  String get leaveRoom => _value('leaveRoom');
  String get host => _value('host');
  String get judge => _value('judge');
  String get ready => _value('ready');
  String get currentChallenge => _value('currentChallenge');
  String get submitAnswer => _value('submitAnswer');
  String get advanceChallenge => _value('advanceChallenge');
  String get scoreboard => _value('scoreboard');
  String get results => _value('results');
  String get returnHome => _value('returnHome');
  String get copied => _value('copied');
  String get roomCreated => _value('roomCreated');
  String get roomJoined => _value('roomJoined');
  String get nameRequired => _value('nameRequired');
  String get codeRequired => _value('codeRequired');
  String get invalidRoomCode => _value('invalidRoomCode');
  String get waitingPlayers => _value('waitingPlayers');
  String get trueOption => _value('trueOption');
  String get falseOption => _value('falseOption');
  String get noChallengeYet => _value('noChallengeYet');
  String get connectedAsGuest => _value('connectedAsGuest');
  String get missingConfig => _value('missingConfig');
  String get retry => _value('retry');
  String get roomLobby => _value('roomLobby');
  String get multiplayerHomeSubtitle => _value('multiplayerHomeSubtitle');
  String get gameInProgress => _value('gameInProgress');
  String get teamLabel => _value('teamLabel');
  String get points => _value('points');
  String get gameFinished => _value('gameFinished');
  String get answerSubmitted => _value('answerSubmitted');
  String get noProfileYet => _value('noProfileYet');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
