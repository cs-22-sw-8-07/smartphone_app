import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_sdk/models/track.dart';

import '../../../../localization/localization_helper.dart';

part 'quack_classes.g.dart';

enum QuackLocationType {
  unknown,
  forest,
  beach,
  nightLife,
  urban,
  cemetery,
  education,
  church
}

/// Get the integer representation of a given [QuackLocationType]
int getQuackLocationTypeInt(QuackLocationType qlt) {
  switch (qlt) {
    case QuackLocationType.unknown:
      return 0;
    case QuackLocationType.church:
      return 1;
    case QuackLocationType.education:
      return 2;
    case QuackLocationType.cemetery:
      return 3;
    case QuackLocationType.forest:
      return 4;
    case QuackLocationType.beach:
      return 5;
    case QuackLocationType.urban:
      return 6;
    case QuackLocationType.nightLife:
      return 7;
  }
}

@JsonSerializable()
class QuackResponse {
  @JsonKey(name: "is_successful")
  late bool isSuccessful;
  @JsonKey(name: "error_no")
  late int errorNo;
  @JsonKey(name: "error_message")
  late String? errorMessage;

  QuackResponse(
      {this.isSuccessful = true, this.errorNo = 0, this.errorMessage});

  factory QuackResponse.fromJson(Map<String, dynamic> json) =>
      _$QuackResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuackResponseToJson(this);

  Future<String?> getErrorMessage() async {
    if (!isSuccessful && errorNo != 0) {
      // 1 and 2 points to exceptions and not constant errors
      switch (errorNo) {
        case 1:
        case 2:
          return errorMessage;
      }
      // Get localized error message
      String? quackError = await LocalizationHelper.getInstance()
          .getLocalizedResponseError(errorNo);
      if (quackError != null) return quackError;
      return "Quack error: ${errorNo.toString()}";
    } else if (errorMessage != null) {
      return errorMessage;
    }
    return null;
  }
}

@JsonSerializable()
class GetPlaylistResponse extends QuackResponse {
  @JsonKey(name: "result")
  QuackPlaylist? result;

  GetPlaylistResponse({this.result});

  factory GetPlaylistResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPlaylistResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetPlaylistResponseToJson(this);
}

@JsonSerializable()
// ignore: must_be_immutable
class QuackPlaylist extends Equatable {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "location_type")
  int? locationType;
  @JsonKey(name: "tracks")
  List<QuackTrack>? tracks;
  @JsonKey(name: "offset")
  int? offset;
  @JsonKey(name: "all_offsets")
  List<int>? allOffsets;
  @JsonKey(name: "save_date")
  DateTime? saveDate;

  QuackPlaylist(
      {this.id,
      this.locationType,
      this.tracks,
      this.offset,
      this.allOffsets,
      this.saveDate}) {
    if (offset != null) {
      allOffsets ??= [offset!];
    }
    id ??= "${locationType}_${offset}_${tracks == null ? 0 : tracks.hashCode}";
  }

  factory QuackPlaylist.fromJson(Map<String, dynamic> json) =>
      _$QuackPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$QuackPlaylistToJson(this);

  QuackLocationType? get quackLocationType {
    if (locationType == null) {
      return null;
    }

    for (var qlt in QuackLocationType.values) {
      if (getQuackLocationTypeInt(qlt) == locationType) {
        return qlt;
      }
    }
    return null;
  }

  void appendPlaylist(QuackPlaylist playlist) {
    List<QuackTrack>? newList;
    if (tracks != null) {
      newList = List.of([], growable: true);
      for (var track in tracks!) {
        newList.add(track);
      }
    }

    if (playlist.tracks != null) {
      allOffsets ??= [];
      allOffsets!.addAll(playlist.allOffsets!);
      for (var track in playlist.tracks!) {
        newList!.add(track);
      }
    }

    tracks = newList;
  }

  QuackPlaylist copy() {
    List<QuackTrack>? newList;
    if (tracks != null) {
      newList = List.of([], growable: true);
      for (var track in tracks!) {
        newList.add(track);
      }
    }

    return QuackPlaylist(
        id: id,
        locationType: locationType,
        tracks: newList,
        offset: offset,
        allOffsets: allOffsets,
        saveDate: saveDate);
  }

  @override
  List<Object?> get props => [id, locationType, tracks];
}

@JsonSerializable()
// ignore: must_be_immutable
class QuackTrack extends Equatable {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "artist")
  String? artist;
  @JsonKey(name: "image")
  String? imageUrl;

  @JsonKey(ignore: true)
  Key? key;

  QuackTrack({this.id, this.name, this.artist, this.imageUrl, this.key});

  factory QuackTrack.fromJson(Map<String, dynamic> json) =>
      _$QuackTrackFromJson(json);

  Map<String, dynamic> toJson() => _$QuackTrackToJson(this);

  static QuackTrack? trackToQuackTrack(Track? track) {
    if (track == null) {
      return null;
    }
    String id = track.uri.split(":")[2];
    String name = track.name;
    String artist = track.artist.name!;
    String imageUrl =
        "https://i.scdn.co/image/" + track.imageUri.raw.split(":")[2];
    return QuackTrack(id: id, name: name, artist: artist, imageUrl: imageUrl);
  }

  @override
  List<Object?> get props => [id, key];
}
