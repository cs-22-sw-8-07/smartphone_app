import 'package:json_annotation/json_annotation.dart';

part 'spotify_classes.g.dart';

@JsonSerializable()
class SpotifyResponse {

  SpotifyResponse();

  factory SpotifyResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyResponseToJson(this);
}

@JsonSerializable()
class GetCurrentUsersProfileResponse extends SpotifyResponse {
  String? id;
  String? email;
  @JsonKey(name: "display_name")
  String? displayName;
  List<SpotifyImage>? images;

  GetCurrentUsersProfileResponse({this.id, this.email, this.displayName, this.images});

  factory GetCurrentUsersProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCurrentUsersProfileResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetCurrentUsersProfileResponseToJson(this);

}

@JsonSerializable()
class SpotifyImage {
  String? url;

  SpotifyImage({this.url});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyImageToJson(this);
}