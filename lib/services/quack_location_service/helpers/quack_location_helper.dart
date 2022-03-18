import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

class QuackLocationHelper {
  ///
  /// Convert a supplied [FoursquarePlace]'s category into a [QuackLocationType]
  ///
  static QuackLocationType getQuackLocationType(FoursquarePlace place) {
    QuackLocationType qlt = QuackLocationType.unknown;

    for (var category in place.categories!) {
      int cat = category.id;
      // if (cat >= 10000 && cat < 11000) {
      //   return QuackLocationType.;
      // }
      if (cat >= 13003 && cat <= 13025 || // Various Bars
              cat == 10008 || // Casino
              cat == 10032 || // Night Club
              cat == 14005 // Music Festival
          ) {
        qlt = QuackLocationType.nightLife;
      } else if (cat >= 12098 &&
          cat <= 12112) // Church + Various Spirititual centers
      {
        return QuackLocationType.church;
      } else if (cat >= 12009 && cat <= 12063) // Various Education Centers
      {
        qlt = QuackLocationType.education;
      } else if (cat == 12003) // Cemetery
      {
        qlt = QuackLocationType.cemetery;
      } else if (cat == 16004 ||
          cat == 16005 || // Botanical Garden
          cat == 16015 || // Forest
          cat == 16019 || // Hiking Trail
          cat == 16027 || // Mountain
          cat == 16028 || // Nature Preserve
          cat == 16032 || // Park
          cat == 16042 || // Reservoir
          cat == 16043 || // River
          cat == 16046 || // Scenic Lookout
          cat == 16052) // Waterfall
      {
        qlt = QuackLocationType.forest;
      } else if (cat >= 16001 && cat <= 16003 || // Bathing Area, Bay, Beach
              cat == 13005 || // Beach Bar
              cat == 16006 || // Bridge
              cat == 16029 || // Nudist Beach ;)
              cat == 16053 || // Waterfront
              cat == 16009 || // Canal
              cat == 16013 || // Dive Spot
              cat == 16018 || // Harbor/Marina
              cat == 16021 || // Hot Spring
              cat == 16022 || // Island
              cat == 16023 || // Lake
              cat == 16049 || // Surf Spot
              cat == 19005 || // Cruise
              cat == 16021 || // Pier
              cat == 19023 // Port
          ) {
        qlt = QuackLocationType.beach;
      } else if (cat == 0) {
        // TODO: Mark urban with categories
        qlt = QuackLocationType.urban;
      }
    }
    return qlt;
  }
}
