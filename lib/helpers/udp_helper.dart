import 'dart:async';
import 'dart:io';

class UdpHelper {
  ///
  /// VARIABLES
  ///
  //region Variables

  RawDatagramSocket? _socket;
  int inPort;
  String ipAddress;
  final StreamController<String> _inDataController =
      StreamController<String>.broadcast();
  InternetAddress? _internetAddress;

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  Stream<String> get onDataReceived => _inDataController.stream;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  UdpHelper({required this.ipAddress, required this.inPort}) {
    _internetAddress = InternetAddress.tryParse(ipAddress);
  }

//endregion

  ///
  /// METHODS
  ///
  //region Methods

  void start() {
    RawDatagramSocket.bind(_internetAddress, inPort).then((value) {
      _socket = value;

      _socket!.listen((event) {
        Datagram? dg = _socket!.receive();
        if (dg == null) {
          return;
        }
        String strData = String.fromCharCodes(dg.data);
        _inDataController.add(strData);
      });
    });
  }

  void stop() {
    if (_socket != null) {
      _socket!.close();
    }
  }

  void dispose() {
    stop();
  }

//endregion

}
