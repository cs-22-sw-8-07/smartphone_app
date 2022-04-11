
import 'package:json_annotation/json_annotation.dart';

part 'position_helper_classes.g.dart';


enum PositionType{
  mock,
  udp, //default
}

@JsonSerializable()
class MockLatLng {
  @JsonKey(name: "Latitude")
  double? latitude;
  @JsonKey(name: "Longitude")
  double? longitude;

  MockLatLng({this.latitude, this.longitude});

  factory MockLatLng.fromJson(Map<String, dynamic> json) =>
      _$MockLatLngFromJson(json);

  Map<String, dynamic> toJson() => _$MockLatLngToJson(this);
}