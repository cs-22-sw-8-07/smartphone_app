import '../models/quack_classes.dart';
import '../service/quack_service.dart';

class IQuackFunctions {
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      String? spotifyAccessToken, QuackLocationType qlt) {
    throw UnimplementedError();
  }
}
