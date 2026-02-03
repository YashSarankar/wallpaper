import 'package:wallpaper/l10n/app_localizations.dart';

extension L10nCategoryExtension on AppLocalizations {
  String getLocalizedCategory(String categoryName) {
    final name = categoryName.trim().toLowerCase();
    switch (name) {
      case 'nature':
      case 'natural':
        return catNature;
      case 'space':
      case 'galaxy':
        return catSpace;
      case 'game':
      case 'games':
      case 'gaming':
        return catGame;
      case 'anime':
      case 'manga':
        return catAnime;
      case 'minimal':
      case 'minimalist':
      case 'clean':
        return catMinimal;
      case 'abstract':
        return catAbstract;
      case 'technology':
      case 'tech':
      case 'digital':
        return catTechnology;
      case 'cars':
      case 'bike':
      case 'bikes':
      case 'cars & bike':
      case 'cars and bike':
      case 'vehicles':
      case 'auto':
        return catCars;
      case 'top':
      case 'top rated':
      case 'popular':
        return catTop;
      case 'fitness':
      case 'gym':
      case 'workout':
      case 'health':
        return catFitness;
      case 'travel':
      case 'explore':
      case 'wanderlust':
      case 'vacation':
        return catTravel;
      case 'fantasy':
      case 'dream':
      case 'realm':
        return catFantasy;
      case 'festival':
      case 'celebration':
      case 'vibe':
        return catFestival;
      case 'superhero':
      case 'heroes':
      case 'hero':
      case 'marvel':
      case 'dc':
        return catSuperhero;
      case 'romantic':
      case 'love':
      case 'romantic vibe':
      case 'romance':
        return catRomantic;
      case 'god':
      case 'devotional':
      case 'spiritual':
      case 'shiva':
      case 'krishna':
        return catGod;
      case 'stock':
      case 'original':
      case 'stock wallpapers':
        return catStock;
      case 'model':
      case '3d':
      case '3d model':
      case '3d models':
        return catModel;
      case 'text':
      case 'typography':
      case 'quotes':
        return catText;
      case 'amoled':
        return catAmoled;
      case 'black':
      case 'dark':
        return catBlack;
      case 'food':
      case 'drink':
      case 'food and drink':
      case 'food & drink':
        return catFood;
      case 'movies':
      case 'series':
      case 'cinema':
      case 'film':
        return catMovies;
      case 'trending':
        return trending;
      case 'latest':
      case 'new':
      case 'recent':
        return latest;
      default:
        // Attempt to find a partial match or return original
        if (name.contains('nature')) return catNature;
        if (name.contains('space')) return catSpace;
        if (name.contains('game')) return catGame;
        if (name.contains('anime')) return catAnime;
        if (name.contains('minimal')) return catMinimal;
        if (name.contains('abstract')) return catAbstract;
        if (name.contains('tech')) return catTechnology;
        if (name.contains('car')) return catCars;
        if (name.contains('bike')) return catCars;
        if (name.contains('fitness')) return catFitness;
        if (name.contains('travel')) return catTravel;
        if (name.contains('fantasy')) return catFantasy;
        if (name.contains('festival')) return catFestival;
        if (name.contains('superhero')) return catSuperhero;
        if (name.contains('hero')) return catSuperhero;
        if (name.contains('roman')) return catRomantic;
        if (name.contains('love')) return catRomantic;
        if (name.contains('god')) return catGod;
        if (name.contains('devo')) return catGod;
        if (name.contains('stock')) return catStock;
        if (name.contains('model')) return catModel;
        if (name.contains('text')) return catText;
        if (name.contains('typo')) return catText;
        if (name.contains('amoled')) return catAmoled;
        if (name.contains('black')) return catBlack;
        if (name.contains('dark')) return catBlack;
        if (name.contains('food')) return catFood;
        if (name.contains('movie')) return catMovies;

        return categoryName;
    }
  }
}
