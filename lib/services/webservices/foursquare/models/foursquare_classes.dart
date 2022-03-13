import 'package:json_annotation/json_annotation.dart';

part 'foursquare_classes.g.dart';

@JsonSerializable()
class FoursquareResponse {
  FoursquareResponse();

  factory FoursquareResponse.fromJson(Map<String, dynamic> json) =>
      _$FoursquareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquareResponseToJson(this);
}

@JsonSerializable()
class GetNearbyPlacesResponse extends FoursquareResponse {
  List<FoursquarePlace>? results;

  GetNearbyPlacesResponse({this.results});

  factory GetNearbyPlacesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNearbyPlacesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetNearbyPlacesResponseToJson(this);
}

@JsonSerializable()
class FoursquarePlace {
  @JsonKey(name: "fsq_id")
  String id;
  List<FoursquareCategory>? categories;
  int? distance;
  Map<String, FoursquareLatLng>? geocodes;
  FoursquareLocation? location;
  String? name;

  FoursquarePlace(
      {required this.id,
      this.categories,
      this.distance,
      this.geocodes,
      this.location,
      this.name});

  factory FoursquarePlace.fromJson(Map<String, dynamic> json) =>
      _$FoursquarePlaceFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquarePlaceToJson(this);
}

@JsonSerializable()
class FoursquareLocation {
  String? address;
  String? country;
  @JsonKey(name: "cross_street")
  String? crossStreet;
  @JsonKey(name: "formatted_address")
  String? formattedAddress;
  String? locality;
  String? postcode;
  String? region;

  FoursquareLocation(
      {this.address,
      this.country,
      this.crossStreet,
      this.formattedAddress,
      this.locality,
      this.postcode,
      this.region});

  factory FoursquareLocation.fromJson(Map<String, dynamic> json) =>
      _$FoursquareLocationFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquareLocationToJson(this);
}

@JsonSerializable()
class FoursquareLatLng {
  double? latitude;
  double? longitude;

  FoursquareLatLng({this.latitude, this.longitude});

  factory FoursquareLatLng.fromJson(Map<String, dynamic> json) =>
      _$FoursquareLatLngFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquareLatLngToJson(this);
}

@JsonSerializable()
class FoursquareCategory {
  int id;
  String? name;

  FoursquareCategory({required this.id, this.name});

  factory FoursquareCategory.fromJson(Map<String, dynamic> json) =>
      _$FoursquareCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquareCategoryToJson(this);
}
