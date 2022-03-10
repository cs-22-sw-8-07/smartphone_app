import 'package:smartphone_app/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/webservices/quack/service/quack_service.dart';

class IQuackFunctions {
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      String? spotifyAccessToken, QuackLocationType qlt) {
    throw UnimplementedError();
  }
}
