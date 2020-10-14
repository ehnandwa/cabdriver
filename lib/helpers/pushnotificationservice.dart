import 'dart:io';

import 'package:cab_driver/datamodels/tripdetails.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService{

  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(context) async{
    if(Platform.isIOS){
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);
        //getRideID(message);
        /*
        print("onMessage: $message");

        if(Platform.isAndroid){
          String rideID = message['data']['ride_id'];
          print('ride_id: $rideID');
        }
        else{
          String rideID = message['ride_id'];
          print('ride_id: $rideID');
        }*/
      },
      onLaunch: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);
        //getRideID(message);
        /*
        print("onLaunch: $message");

        if(Platform.isAndroid) {
          String rideID = message['data']['ride_id'];
          print('ride_id: $rideID');
        }
        else{
          String rideID = message['ride_id'];
          print('ride_id: $rideID');
        }*/
      },
      onResume: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message),context);
        //getRideID(message);

      },
    );
  }

  Future<String> getToken() async{
    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
  }
  String getRideID(Map<String, dynamic> message){

    String rideID = '';

    if(Platform.isAndroid) {
      rideID = message['data']['ride_id'];
      print('ride_id: $rideID');
    }
    else{
      rideID = message['ride_id'];
      print('ride_id: $rideID');
    }
    return rideID;

  }
  void fetchRideInfo(String rideID, context){
    //show dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:(BuildContext context)=>ProgressDialog(status:'fetching details',),
    );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/ $rideID');

    rideRef.once().then((DataSnapshot snapshot){

      Navigator.pop(context);

      if(snapshot.value != null){
        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());

        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat = double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng = double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress = snapshot.value['destination_address'];
        String paymentMethod = snapshot.value['payment_method'];

        TripDetails tripDetails = TripDetails();
        tripDetails.rideID = rideID;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;

        print(tripDetails.destinationAddress);

      }

    });

  }
}