// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quack_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuackResponse _$QuackResponseFromJson(Map<String, dynamic> json) =>
    QuackResponse(
      isSuccessful: json['IsSuccessful'] as bool? ?? true,
      errorNo: json['ErrorNo'] as int? ?? 0,
      errorMessage: json['ErrorMessage'] as String?,
    );

Map<String, dynamic> _$QuackResponseToJson(QuackResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
    };

GetPlaylistResponse _$GetPlaylistResponseFromJson(Map<String, dynamic> json) =>
    GetPlaylistResponse(
      result: json['Result'] == null
          ? null
          : QuackPlaylist.fromJson(json['Result'] as Map<String, dynamic>),
    )
      ..isSuccessful = json['IsSuccessful'] as bool
      ..errorNo = json['ErrorNo'] as int
      ..errorMessage = json['ErrorMessage'] as String?;

Map<String, dynamic> _$GetPlaylistResponseToJson(
        GetPlaylistResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
      'Result': instance.result,
    };

QuackPlaylist _$QuackPlaylistFromJson(Map<String, dynamic> json) =>
    QuackPlaylist(
      id: json['Id'] as String?,
      locationType: json['LocationType'] as String?,
      tracks: (json['Tracks'] as List<dynamic>?)
          ?.map((e) => QuackTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuackPlaylistToJson(QuackPlaylist instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'LocationType': instance.locationType,
      'Tracks': instance.tracks,
    };

QuackTrack _$QuackTrackFromJson(Map<String, dynamic> json) => QuackTrack(
      id: json['Id'] as String?,
      name: json['Name'] as String?,
      artist: json['Artist'] as String?,
      imageUrl: json['ImageUrl'] as String?,
    );

Map<String, dynamic> _$QuackTrackToJson(QuackTrack instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Artist': instance.artist,
      'ImageUrl': instance.imageUrl,
    };
