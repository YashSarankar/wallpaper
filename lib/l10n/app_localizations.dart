import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';

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
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Amozea'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @gridLayout.
  ///
  /// In en, this message translates to:
  /// **'Grid Layout'**
  String get gridLayout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @automation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get automation;

  /// No description provided for @autoChangeWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Auto Change Wallpaper'**
  String get autoChangeWallpaper;

  /// No description provided for @cyclesFavorites.
  ///
  /// In en, this message translates to:
  /// **'Cycles through your Favorites'**
  String get cyclesFavorites;

  /// No description provided for @addYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Your Photos'**
  String get addYourPhotos;

  /// No description provided for @addPhotosRotation.
  ///
  /// In en, this message translates to:
  /// **'Add gallery images to rotation'**
  String get addPhotosRotation;

  /// No description provided for @changeEvery.
  ///
  /// In en, this message translates to:
  /// **'Change Every'**
  String get changeEvery;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance & Data'**
  String get performance;

  /// No description provided for @dataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data Saver'**
  String get dataSaver;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get support;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noTrending.
  ///
  /// In en, this message translates to:
  /// **'No trending wallpapers yet'**
  String get noTrending;

  /// No description provided for @noWallpapersFound.
  ///
  /// In en, this message translates to:
  /// **'No wallpapers found'**
  String get noWallpapersFound;

  /// No description provided for @serverSleeping.
  ///
  /// In en, this message translates to:
  /// **'LOOKS LIKE THE SERVER IS SLEEPING'**
  String get serverSleeping;

  /// No description provided for @wakeUp.
  ///
  /// In en, this message translates to:
  /// **'WAKE UP'**
  String get wakeUp;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get apply;

  /// No description provided for @setWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Set Wallpaper'**
  String get setWallpaper;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreen;

  /// No description provided for @lockScreen.
  ///
  /// In en, this message translates to:
  /// **'Lock Screen'**
  String get lockScreen;

  /// No description provided for @bothScreens.
  ///
  /// In en, this message translates to:
  /// **'Both Screens'**
  String get bothScreens;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADING'**
  String get downloading;

  /// No description provided for @wallpaperSet.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Set'**
  String get wallpaperSet;

  /// No description provided for @failedToSet.
  ///
  /// In en, this message translates to:
  /// **'Failed to set wallpaper'**
  String get failedToSet;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete! Opening...'**
  String get downloadComplete;

  /// No description provided for @checkOutWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Check out this wallpaper!'**
  String get checkOutWallpaper;

  /// No description provided for @addFavoritesFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add some wallpapers to Favorites first!'**
  String get addFavoritesFirst;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully!'**
  String get cacheCleared;

  /// No description provided for @addedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Added {count} photos to rotation!'**
  String addedPhotos(int count);

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'This will free up storage by removing temporary images. Wallpapers will reload on next view.'**
  String get clearCacheDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @unleashDisplay.
  ///
  /// In en, this message translates to:
  /// **'UNLEASH YOUR DISPLAY'**
  String get unleashDisplay;

  /// No description provided for @preparingExperience.
  ///
  /// In en, this message translates to:
  /// **'PREPARING EXPERIENCE'**
  String get preparingExperience;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @catNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get catNature;

  /// No description provided for @catSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get catSpace;

  /// No description provided for @catGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get catGame;

  /// No description provided for @catAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get catAnime;

  /// No description provided for @catMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get catMinimal;

  /// No description provided for @catAbstract.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get catAbstract;

  /// No description provided for @catTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get catTechnology;

  /// No description provided for @catCars.
  ///
  /// In en, this message translates to:
  /// **'Cars & Bikes'**
  String get catCars;

  /// No description provided for @catTop.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get catTop;

  /// No description provided for @catFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get catFitness;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get catFantasy;

  /// No description provided for @catFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get catFestival;

  /// No description provided for @catSuperhero.
  ///
  /// In en, this message translates to:
  /// **'Superhero'**
  String get catSuperhero;

  /// No description provided for @catRomantic.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get catRomantic;

  /// No description provided for @catGod.
  ///
  /// In en, this message translates to:
  /// **'Devotional'**
  String get catGod;

  /// No description provided for @catStock.
  ///
  /// In en, this message translates to:
  /// **'Stock Wallpapers'**
  String get catStock;

  /// No description provided for @catModel.
  ///
  /// In en, this message translates to:
  /// **'3D Models'**
  String get catModel;

  /// No description provided for @catText.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get catText;

  /// No description provided for @catAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get catAmoled;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get catFood;

  /// No description provided for @catMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies & Series'**
  String get catMovies;

  /// No description provided for @catBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get catBlack;
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
      <String>['en', 'es', 'fr', 'hi', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
