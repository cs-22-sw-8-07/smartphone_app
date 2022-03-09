import 'package:json_annotation/json_annotation.dart';

part 'spotify_classes.g.dart';

@JsonSerializable()
class SpotifyResponse {

  SpotifyResponse();

  factory SpotifyResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyResponseToJson(this);
}