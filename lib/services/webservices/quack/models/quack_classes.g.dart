// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quack_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuackResponse _$QuackResponseFromJson(Map<String, dynamic> json) =>
    QuackResponse(
      isSuccessful: json['is_successful'] as bool? ?? true,
      errorNo: json['error_no'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$QuackResponseToJson(QuackResponse instance) =>
    <String, dynamic>{
      'is_successful': instance.isSuccessful,
      'error_no': instance.errorNo,
      'error_message': instance.errorMessage,
    };

GetPlaylistResponse _$GetPlaylistResponseFromJson(Map<String, dynamic> json) =>
    GetPlaylistResponse(
      result: json['result'] == null
          ? null
          : QuackPlaylist.fromJson(json['result'] as Map<String, dynamic>),
    )
      ..isSuccessful = json['is_successful'] as bool
      ..errorNo = json['error_no'] as int
      ..errorMessage = json['error_message'] as String?;

Map<String, dynamic> _$GetPlaylistResponseToJson(
        GetPlaylistResponse instance) =>
    <String, dynamic>{
      'is_successful': instance.isSuccessful,
      'error_no': instance.errorNo,
      'error_message': instance.errorMessage,
      'result': instance.result,
    };

QuackPlaylist _$QuackPlaylistFromJson(Map<String, dynamic> json) =>
    QuackPlaylist(
      id: json['id'] as String?,
      locationType: json['location_type'] as int?,
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((e) => QuackTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuackPlaylistToJson(QuackPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location_type': instance.locationType,
      'tracks': instance.tracks,
    };

QuackTrack _$QuackTrackFromJson(Map<String, dynamic> json) => QuackTrack(
      id: json['id'] as String?,
      name: json['name'] as String?,
      artist: json['artist'] as String?,
      imageUrl: json['image'] as String?,
    );

Map<String, dynamic> _$QuackTrackToJson(QuackTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artist': instance.artist,
      'image': instance.imageUrl,
    };
