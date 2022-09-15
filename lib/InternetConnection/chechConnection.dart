// ignore: file_names
import "dart:io";
import "dart:async";
import "package:connectivity/connectivity.dart";
import 'package:gdsc_app/Controller/app_controller.dart';
import 'package:get/get.dart';

class ConnectionStatusSingleton {
  final controller = Get.put(AppController());
    //This creates the single instance by calling the `_internal` constructor specified below
    static final ConnectionStatusSingleton _singleton = ConnectionStatusSingleton._internal();
    ConnectionStatusSingleton._internal();

    //This is what's used to retrieve the instance through the app
    static ConnectionStatusSingleton getInstance() => _singleton;

    //This tracks the current connection status


    //This is how we'll allow subscribing to connection changes
    StreamController connectionChangeController = StreamController.broadcast();

    //flutter_connectivity
    final Connectivity _connectivity = Connectivity();

    //Hook into flutter_connectivity's Stream to listen for changes
    //And check the connection status out of the gate
    void initialize() {
        _connectivity.onConnectivityChanged.listen(_connectionChange);
        checkConnection();
    }

    Stream get connectionChange => connectionChangeController.stream;

    //A clean up method to close our StreamController
    //   Because this is meant to exist through the entire application life cycle this isn't
    //   really an issue
    void dispose() {
        connectionChangeController.close();
    }

    //flutter_connectivity's listener
    void _connectionChange(ConnectivityResult result) {
        checkConnection();
    }

    //The test to actually see if there is a connection
    Future<bool> checkConnection() async {
        bool previousConnection = controller.hasConnection.value;

        try {
            final result = await InternetAddress.lookup('google.com');
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                controller.hasConnection.value = true;
            } else {
                controller.hasConnection.value = false;
            }
        } on SocketException catch(_) {
            controller.hasConnection.value = false;
        }

        //The connection status changed send out an update to all listeners
        if (previousConnection != controller.hasConnection.value) {
            connectionChangeController.add(controller.hasConnection.value);
        }

        return controller.hasConnection.value;
    }
}
