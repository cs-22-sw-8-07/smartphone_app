// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyResponse _$SpotifyResponseFromJson(Map<String, dynamic> json) =>
    SpotifyResponse();

Map<String, dynamic> _$SpotifyResponseToJson(SpotifyResponse instance) =>
    <String, dynamic>{};

GetCurrentUsersProfileResponse _$GetCurrentUsersProfileResponseFromJson(
        Map<String, dynamic> json) =>
    GetCurrentUsersProfileResponse(
      id: json['id'] as String?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetCurrentUsersProfileResponseToJson(
        GetCurrentUsersProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'images': instance.images,
    };

SpotifyImage _$SpotifyImageFromJson(Map<String, dynamic> json) => SpotifyImage(
      url: json['url'] as String?,
    );

Map<String, dynamic> _$SpotifyImageToJson(SpotifyImage instance) =>
    <String, dynamic>{
      'url': instance.url,
    };
