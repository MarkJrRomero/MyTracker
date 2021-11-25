import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {


  StreamSubscription _streamSubscription;
  Location _tracker = Location();
  Marker marker;
  GoogleMapController _googleMapController;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(51.511271, -0.1517578),
    zoom: 14.4746,
  );


  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    super.dispose();
  }

  //Funcion para actualizar el marcador en tiempo real
  void updateMarker(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("marcador"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
    await DefaultAssetBundle.of(context).load("assets/images/pin.png", );
    return byteData.buffer.asUint8List();
  }

  //Funcion para cacturar posicion
  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _tracker.getLocation();

      updateMarker(location, imageData);

      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }

      _streamSubscription = _tracker.onLocationChanged.listen((newLocalData) {
        if (_googleMapController != null) {
          _googleMapController
              .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 100,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 18.00)));
          updateMarker(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }





  @override
  Widget build(BuildContext context) {

    getCurrentLocation();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: (Colors.deepPurple),
        title: Text("Your Account"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[

      Expanded(child:
      Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                        image: AssetImage("assets/images/perfil.jpg"),
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Container(
                  margin: EdgeInsets.only(top: 10,left: 10,right:10 ,bottom: 10),
                  child: Center(
                    child: Text("Nombre Apellido"),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                ),

                ),

                Expanded(
                  flex: 6,
                  child: Container(
                  child: Center(
                    child: Text("Otra Informacion"),

                  ),
                  margin: EdgeInsets.only(top: 5,left: 10,right:10 ,bottom: 10),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                ),
                ),
              ],
            ),

          ),


          Expanded(
            child:
          Container(
            child: GoogleMap(
              zoomGesturesEnabled: true,
              initialCameraPosition: initialLocation,
              markers: Set.of((marker != null) ? [marker] : []),
              onMapCreated: (GoogleMapController controller) {
                _googleMapController = controller;
                },
              ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black,width: 4)

            ),
            ),
          ),
        ],
      ),
    );
  }
}