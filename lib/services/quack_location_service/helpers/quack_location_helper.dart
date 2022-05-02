import 'package:flutter/foundation.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

class QuackLocationTypeCategories {
  final QuackLocationType quackLocationType;
  final List<int> categories;

  QuackLocationTypeCategories(
      {required this.quackLocationType, required this.categories});
}

class QuackLocationHelper {
  static List<QuackLocationTypeCategories>? _allQuackLocationTypeCategoriesList;

  /// Get a list where each item specifies a [QuackLocationType] and its
  /// related Foursquare category ids
  static List<QuackLocationTypeCategories> getAllCategoriesAsList() {
    if (_allQuackLocationTypeCategoriesList != null) {
      return _allQuackLocationTypeCategoriesList!;
    }
    _allQuackLocationTypeCategoriesList = [];
    List<int> categories = [];
    // Night life
    categories.addAll(_getIntRange(13003, 13025)); // Various Bars
    categories.add(10008); // Casino
    categories.add(10032); // Night Club
    categories.add(14005); // Music Festival
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.nightLife,
        categories: categories));
    // Church
    categories = [];
    categories.addAll(
        _getIntRange(12098, 12112)); // Church + Various Spiritual centers
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.church, categories: categories));
    // Education
    categories = [];
    categories.addAll(_getIntRange(12009, 12063)); // Various Education Centers
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.education,
        categories: categories));
    // Cemetery
    categories = [];
    categories.add(12003); // Cemetery
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.cemetery, categories: categories));
    // Forest
    categories = [];
    categories.add(16004); // Bike trail
    categories.add(16005); // Botanical Garden
    categories.add(16015); // Forest
    categories.add(16019); // Hiking Trail
    categories.add(16027); // Mountain
    categories.add(16028); // Nature Preserve
    categories.add(16032); // Park
    categories.add(16042); // Reservoir
    categories.add(16043); // River
    categories.add(16046); // Scenic Lookout
    categories.add(16052); // Waterfall
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.forest, categories: categories));
    // Beach
    categories = [];
    categories.addAll(_getIntRange(16001, 16003)); // Bathing Area, Bay, Beach
    categories.add(13005); // Beach Bar
    categories.add(16009); // Canal
    categories.add(16013); // Dive Spot
    categories.add(16018); // Harbor/Marina
    categories.addAll(_getIntRange(16021, 16023)); // Hot Spring, Island, Lake
    categories.add(16029); // Nudist Beach ;)
    categories.add(16049); // Surf Spot
    categories.add(16053); // Waterfront
    categories.add(19005); // Cruise
    categories.add(19021); // Pier
    categories.add(19023); // Port
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.beach, categories: categories));
    // Urban
    categories = [];
    categories.addAll(_getIntRange(10035, 10043)); // Arts & Entertainment
    categories.addAll(_getIntRange(12064, 12075)); // Community & Government
    categories.addAll(_getIntRange(14009, 14014)); // Events - Marketplaces
    categories
        .addAll(_getIntRange(17023, 17027)); // Retail - Computers & Electronics
    categories.addAll(_getIntRange(17039, 17052)); // Retail - Fashion
    categories.addAll(_getIntRange(19030, 19050)); // Transport Hubs
    _allQuackLocationTypeCategoriesList!.add(QuackLocationTypeCategories(
        quackLocationType: QuackLocationType.urban, categories: categories));
    return _allQuackLocationTypeCategoriesList!;
  }

  /// Get a list which specifies a range of integers from [start] to [end] with
  /// [end] included
  static List<int> _getIntRange(int start, int end) {
    return [for (var i = start; i <= end; i++) i];
  }

  ///
  /// Convert a supplied [FoursquarePlace]'s category into a [QuackLocationType]
  ///
  static QuackLocationType getQuackLocationType(FoursquarePlace place) {
    // If a place has no categories return the QuackLocationType 'Unknown'
    if (place.categories == null || place.categories!.isEmpty) {
      return QuackLocationType.unknown;
    }
    for (FoursquareCategory foursquareCategory in place.categories!) {
      for (var quackLocationTypeCategories in getAllCategoriesAsList()) {
        for (var category in quackLocationTypeCategories.categories) {
          if (category == foursquareCategory.id) {
            if (kDebugMode) {
              print("Category: " + category.toString());
            }
            return quackLocationTypeCategories.quackLocationType;
          }
        }
      }
    }
    return QuackLocationType.unknown;
  }
}
