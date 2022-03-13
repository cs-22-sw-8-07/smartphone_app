import '../../../../helpers/rest_helper.dart';
import '../interfaces/quack_functions.dart';
import '../models/quack_classes.dart';

class QuackServiceResponse<Response extends QuackResponse> {
  String? exception;
  Response? quackResponse;

  QuackServiceResponse.error(this.exception) {
    quackResponse = null;
  }

  QuackServiceResponse.success(this.quackResponse) {
    exception = null;
  }

  bool get isSuccess {
    if (exception != null) return false;
    return quackResponse!.isSuccessful;
  }

  Future<String?> get errorMessage async {
    if (exception != null) return exception;
    if (quackResponse != null) return quackResponse!.getErrorMessage();
    return null;
  }
}

class QuackService implements IQuackFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static IQuackFunctions? _quackFunctions;

  static init(IQuackFunctions quackFunctions) {
    _quackFunctions = quackFunctions;
  }

  static IQuackFunctions getInstance() {
    return _quackFunctions!;
  }

  static const String recommenderControllerPath = "/Quack/Recommender/";

//endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late String url;
  late RestHelper restHelper;

//endregion

  ///
  /// CONSTRUCTOR
  ///
//region Constructor

  QuackService({required this.url}) {
    restHelper = RestHelper(url: url);
  }

//endregion

  ///
  /// OVERRIDE METHODS
  ///
//region Override methods

  @override
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      String? spotifyAccessToken, QuackLocationType qlt) {
    // TODO: implement getPlaylist
    throw UnimplementedError();
  }

//endregion
}
