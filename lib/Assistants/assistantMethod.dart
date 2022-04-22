
import 'dart:math';
import 'package:driver_app/Models/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/Assistants/requestAssistant.dart';
// import 'package:provider/provider.dart';
// import 'package:rider_app/AllScreens/registerationScreen.dart';
// import 'package:rider_app/Assistants/requestAssistant.dart';
// import 'package:rider_app/DataHandler/appData.dart';
// import 'package:rider_app/Models/address.dart';
// import 'package:rider_app/Models/allUsers.dart';
// import 'package:rider_app/Models/directDetails.dart';
// import 'package:rider_app/Models/history.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:driver_app/DataHandler/appData.dart';
import 'package:driver_app/Models/address.dart';
import 'package:driver_app/Models/allUsers.dart';
import 'package:driver_app/Models/directionDetails.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/configMaps.dart';


class AssistantMethods
{
  // static Future<String> searchCoordinateAddress(Position position, context) async
  // {
  //   String placeAddress = "";
  //   String st1, st2, st3, st4;
  //   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  //
  //   var response = await RequestAssistant.getRequest(url);
  //
  //   if(response != 'failed')
  //   {
  //     placeAddress = response["results"][0]["formatted_address"];
  //     // st1 = response["results"][0]["address_components"][1]["long_name"];
  //     // st2 = response["results"][0]["address_components"][2]["long_name"];
  //     // // st3 = response["results"][0]["address_components"][5]["long_name"];
  //     // // st4 = response["results"][0]["address_components"][6]["long_name"];
  //     // placeAddress = st1 + ", " + st2 ;
  //     print("Helo my address "+placeAddress);
  //
  //      Address userPickUpAddress = new Address();
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.placeName = placeAddress;
  //
  //     Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //   }
  //
  //
  //   return placeAddress;
  // }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed")
    {
       return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }




  static int calculateFares(DirectionDetails directionDetails)
  {
    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;
    if(rideType == "uber-x")
    {
      double result = (totalFareAmount.truncate()) * 2.0;
      return result.truncate();
    }
    else if(rideType == "uber-go")
    {
      return totalFareAmount.truncate();
    }
    else if(rideType == "bike")
    {
      double result = (totalFareAmount.truncate()) / 2.0;
      return result.truncate();
    }
    else
    {
      return totalFareAmount.truncate();
    }
  }

  static void disableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static void enableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void retrieveHistoryInfo(context)
  {

    //retrieve and display Ratings



    //retrieve and display Earnings
    driversRef.child(currentfirebaseUser!.uid).child("earnings").once().then((DataSnapshot dataSnapshot)
    {
      if(dataSnapshot.value != null)
      {
        String earnings = dataSnapshot.value.toString();
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });

    //retrieve and display Trip History
    driversRef.child(currentfirebaseUser!.uid).child("history").once().then((DataSnapshot dataSnapshot)
    {
      if(dataSnapshot.value != null)
      {
        //update total number of trip counts to provider
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false).updateTripsCounter(tripCounter);

        //update trip keys to provider
        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
        obtainTripRequestsHistoryData(context);
      }
    });
  }

  static void obtainTripRequestsHistoryData(context)
  {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for(String key in keys)
    {
      newRequestsRef.child(key).once().then((DataSnapshot snapshot) {
        if(snapshot.value != null)
        {
          var history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
        }
      });
    }
  }

  static String formatTripDate(String date)
  {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }






















  // static void getCurrentOnlineUserInfo() async
  // {
  //   firebaseUser = FirebaseAuth.instance.currentUser!;
  //   String userId = firebaseUser.uid;
  //   DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);
  //
  //   reference.once().then((DataSnapshot dataSnapShot)
  //   {
  //     if(dataSnapShot.value != null)
  //     {
  //       userCurrentInfo = Users.fromSnapshot(dataSnapShot);
  //     }
  //   });
  // }

  static double createRandomNumber(int num)
  {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

   static String  currency(String fareAmount ){
    if(fareAmount != null){
      NumberFormat.simpleCurrency(
        name: "NGN",
      ).format(fareAmount);

    }
    return fareAmount;
  }

  // static sendNotificationToDriver(String token, context, String ride_request_id) async
  // {
  //   var destionation = Provider.of<AppData>(context, listen: false).dropOffLocation;
  //   Map<String, String> headerMap =
  //   {
  //     'Content-Type': 'application/json',
  //     'Authorization': serverToken,
  //   };
  //
  //   Map notificationMap =
  //   {
  //     'body': 'DropOff Address, ${destionation.placeName}',
  //     'title': 'New Ride Request'
  //   };
  //
  //   Map dataMap =
  //   {
  //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //     'id': '1',
  //     'status': 'done',
  //     'ride_request_id': ride_request_id,
  //   };
  //
  //   Map sendNotificationMap =
  //   {
  //     "notification": notificationMap,
  //     "data": dataMap,
  //     "priority": "high",
  //     "to": token,
  //   };
  //
  //   var res = await http.post(
  //     'https://fcm.googleapis.com/fcm/send',
  //     headers: headerMap,
  //     body: jsonEncode(sendNotificationMap),
  //   );
  // }


  //history

  // static void retrieveHistoryInfo(context)
  // {
  //   //retrieve and display Trip History
  //   rideRequestRef.orderByChild("rider_name").once().then((DataSnapshot dataSnapshot)
  //   {
  //     if(dataSnapshot.value != null)
  //     {
  //       //update total number of trip counts to provider
  //       Map<dynamic, dynamic> keys = dataSnapshot.value;
  //       int tripCounter = keys.length;
  //       Provider.of<AppData>(context, listen: false).updateTripsCounter(tripCounter);
  //
  //       //update trip keys to provider
  //       List<String> tripHistoryKeys = [];
  //       keys.forEach((key, value)
  //       {
  //         tripHistoryKeys.add(key);
  //       });
  //       Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
  //       obtainTripRequestsHistoryData(context);
  //     }
  //   });
  // }
  //
  // static void obtainTripRequestsHistoryData(context)
  // {
  //   var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;
  //
  //   for(String key in keys)
  //   {
  //     rideRequestRef.child(key).once().then((DataSnapshot snapshot) {
  //       if(snapshot.value != null)
  //       {
  //         rideRequestRef.child(key).child("rider_name").once().then((DataSnapshot snap)
  //         {
  //           String name = snap.value.toString();
  //           if(name == userCurrentInfo.name)
  //           {
  //             var history = History.fromSnapshot(snapshot);
  //             Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
  //           }
  //         });
  //       }
  //     });
  //   }
  // }


}