import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_sdk/models/track.dart';

import '../../../localization/localization_helper.dart';

part 'quack_classes.g.dart';

enum QuackLocationType { forest, beach }

@JsonSerializable()
class QuackResponse {
  @JsonKey(name: "IsSuccessful")
  late bool isSuccessful;
  @JsonKey(name: "ErrorNo")
  late int errorNo;
  @JsonKey(name: "ErrorMessage")
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
      String? waspError = await LocalizationHelper.getInstance()
          .getLocalizedResponseError(errorNo);
      if (waspError != null) return waspError;
      return "Quack error: ${errorNo.toString()}";
    } else if (errorMessage != null) {
      return errorMessage;
    }
    return null;
  }
}

@JsonSerializable()
class GetPlaylistResponse extends QuackResponse {
  @JsonKey(name: "Result")
  QuackPlaylist? result;

  GetPlaylistResponse({this.result});

  factory GetPlaylistResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPlaylistResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetPlaylistResponseToJson(this);
}

@JsonSerializable()
class QuackPlaylist {
  @JsonKey(name: "Id")
  String? id;
  @JsonKey(name: "LocationType")
  String? locationType;
  @JsonKey(name: "Tracks")
  List<QuackTrack>? tracks;

  QuackPlaylist({this.id, this.locationType, this.tracks});

  factory QuackPlaylist.fromJson(Map<String, dynamic> json) =>
      _$QuackPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$QuackPlaylistToJson(this);
}

@JsonSerializable()
// ignore: must_be_immutable
class QuackTrack extends Equatable {
  @JsonKey(name: "Id")
  String? id;
  @JsonKey(name: "Name")
  String? name;
  @JsonKey(name: "Artist")
  String? artist;
  @JsonKey(name: "ImageUrl")
  String? imageUrl;

  QuackTrack({this.id, this.name, this.artist, this.imageUrl});

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
  List<Object?> get props => [id];
}
