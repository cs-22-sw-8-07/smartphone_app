import '../models/quack_classes.dart';
import '../services/quack_service.dart';

class IQuackFunctions {
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      {required QuackLocationType qlt, required List<QuackPlaylist> playlists}) {
    throw UnimplementedError();
  }
}
