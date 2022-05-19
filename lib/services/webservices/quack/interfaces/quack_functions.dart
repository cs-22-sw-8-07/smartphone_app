import '../models/quack_classes.dart';
import '../services/quack_service.dart';

class IQuackFunctions {
  /// Get playlist from Quack API
  ///
  /// [qlt] specifies the [QuackLocationType]
  /// [playlists] is used to specify the previous offsets, which is sent as an
  /// integer list in the body of the HTTP request.
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      {required QuackLocationType qlt,
      required List<QuackPlaylist> playlists}) {
    throw UnimplementedError();
  }
}
