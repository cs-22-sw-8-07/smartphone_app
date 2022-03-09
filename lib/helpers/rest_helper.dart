import 'dart:async';
import 'dart:convert' show Encoding, jsonDecode, utf8;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

///
/// CLASSES
///
//region Classes

/// Used as a wrapper for a [http.Response] in this helper
class RestResponse {
  ///
  /// VARIABLES
  ///
  //region Variables

  http.Response? response;
  dynamic jsonResponse;
  bool? timeout;
  String? exception;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  RestResponse(
      {required this.response,
      required this.jsonResponse,
      this.timeout = false});

  RestResponse.timeout({this.timeout = true});

  RestResponse.exception({this.exception});

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  String? get errorMessage {
    if (exception != null) {
      return exception;
    } else if (timeout!) {
      return "HTTP error: Timeout";
    }
    if (response!.statusCode != 200) {
      return "HTTP error: " + response!.statusCode.toString();
    }
    return null;
  }

  bool get isSuccess {
    if (exception != null || timeout!) return false;
    if (response!.statusCode != 200) return false;
    return true;
  }

//endregion
}

/// Used for specifying each parameter in a given the URL
class RestParameter {
  String name;
  String value;

  RestParameter({required this.name, required this.value});
}

//endregion

class RestHelper {
  ///
  /// VARIABLES
  ///
  //region Variables

  late String url;
  late int timeoutInSeconds;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  RestHelper({required this.url, this.timeoutInSeconds = 30});

  //endregion

  ///
  /// PRIVATE METHODS
  ///
  //region Private methods

  _receivedResponse(http.Response response) {
    // Print request and response for debug purposes

    print("Response status: ${response.statusCode}"); // ignore: avoid_print
    print("Response: ${response.body}"); // ignore: avoid_print
  }

  _timeout() {
    print("Response: Timeout"); // ignore: avoid_print
  }

  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "text/json;charset=UTF-8",
      "cache-control": "no-cache"
    };
  }

  String _getParametersString(List<RestParameter>? parameters) {
    if (parameters == null || parameters.isEmpty) return "";
    var tempString = "";
    for (var parameter in parameters) {
      tempString += tempString.isEmpty ? "?" : "&";
      tempString += "${parameter.name}=${parameter.value}";
    }
    return tempString;
  }

  IOClient _getIOClient() {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    return IOClient(httpClient);
  }

  Future<RestResponse> _makeRequest(
      Future<http.Response> Function() requestFunction,
      List<int> okStatusCodes) async {
    http.Response response;
    try {
      // Post request
      response = await requestFunction();
    } on TimeoutException catch (_) {
      _timeout();
      return RestResponse.timeout();
    } on Exception catch (exc) {
      return RestResponse.exception(exception: exc.toString());
    }

    // Check for HTTP error codes
    if (!okStatusCodes.contains(response.statusCode)) {
      // HTTP error code
      return RestResponse(response: response, jsonResponse: null);
    }

    // Decode JSON string
    var jsonDecoded = jsonDecode(response.body);
    // Return response with the underlying action objects
    return RestResponse(response: response, jsonResponse: jsonDecoded);
  }

  //endregion

  ///
  /// PUBLIC METHODS
  ///
  //region Public methods

  Future<RestResponse> sendGetRequest(String function,
      {List<RestParameter>? parameters}) async {
    String urlComplete = url + function + _getParametersString(parameters);

    return await _makeRequest(() async {
      return _getIOClient()
          .get(
            Uri.parse(urlComplete),
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    }, [200]);
  }

  Future<RestResponse> sendPostRequest(String function,
      {List<RestParameter>? parameters, required String? body}) async {
    String urlComplete = url + function + _getParametersString(parameters);
    // Make request
    var bodyString = body == null ? null : utf8.encode(body);
    return await _makeRequest(() async {
      return await _getIOClient()
          .post(Uri.parse(urlComplete),
              headers: _getHeaders(),
              body: bodyString,
              encoding: Encoding.getByName("UTF-8"))
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    }, [200, 202]);
  }

  Future<RestResponse> sendPutRequest(String function,
      {List<RestParameter>? parameters, required String body}) async {
    String urlComplete = url + function + _getParametersString(parameters);
    // Make request
    var bodyString = utf8.encode(body);
    return await _makeRequest(() async {
      return await _getIOClient()
          .put(Uri.parse(urlComplete),
              headers: _getHeaders(),
              body: bodyString,
              encoding: Encoding.getByName("UTF-8"))
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    }, [200, 202]);
  }

  Future<RestResponse> sendDeleteRequest(String function,
      {List<RestParameter>? parameters, required String? body}) async {
    String urlComplete = url + function + _getParametersString(parameters);
    // Make request
    var bodyString = body == null ? null : utf8.encode(body);
    return await _makeRequest(() async {
      return await _getIOClient()
          .delete(Uri.parse(urlComplete),
              headers: _getHeaders(),
              body: bodyString,
              encoding: Encoding.getByName("UTF-8"))
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    }, [200, 202]);

//endregion
  }
}
