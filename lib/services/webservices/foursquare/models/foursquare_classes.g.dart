// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foursquare_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoursquareResponse _$FoursquareResponseFromJson(Map<String, dynamic> json) =>
    FoursquareResponse();

Map<String, dynamic> _$FoursquareResponseToJson(FoursquareResponse instance) =>
    <String, dynamic>{};

GetNearbyPlacesResponse _$GetNearbyPlacesResponseFromJson(
        Map<String, dynamic> json) =>
    GetNearbyPlacesResponse(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => FoursquarePlace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetNearbyPlacesResponseToJson(
        GetNearbyPlacesResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

FoursquarePlace _$FoursquarePlaceFromJson(Map<String, dynamic> json) =>
    FoursquarePlace(
      id: json['fsq_id'] as String,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => FoursquareCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      distance: json['distance'] as int?,
      geocodes: (json['geocodes'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, FoursquareLatLng.fromJson(e as Map<String, dynamic>)),
      ),
      location: json['location'] == null
          ? null
          : FoursquareLocation.fromJson(
              json['location'] as Map<String, dynamic>),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$FoursquarePlaceToJson(FoursquarePlace instance) =>
    <String, dynamic>{
      'fsq_id': instance.id,
      'categories': instance.categories,
      'distance': instance.distance,
      'geocodes': instance.geocodes,
      'location': instance.location,
      'name': instance.name,
    };

FoursquareLocation _$FoursquareLocationFromJson(Map<String, dynamic> json) =>
    FoursquareLocation(
      address: json['address'] as String?,
      country: json['country'] as String?,
      crossStreet: json['cross_street'] as String?,
      formattedAddress: json['formatted_address'] as String?,
      locality: json['locality'] as String?,
      postcode: json['postcode'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$FoursquareLocationToJson(FoursquareLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'country': instance.country,
      'cross_street': instance.crossStreet,
      'formatted_address': instance.formattedAddress,
      'locality': instance.locality,
      'postcode': instance.postcode,
      'region': instance.region,
    };

FoursquareLatLng _$FoursquareLatLngFromJson(Map<String, dynamic> json) =>
    FoursquareLatLng(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FoursquareLatLngToJson(FoursquareLatLng instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

FoursquareCategory _$FoursquareCategoryFromJson(Map<String, dynamic> json) =>
    FoursquareCategory(
      id: json['id'] as int,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$FoursquareCategoryToJson(FoursquareCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
