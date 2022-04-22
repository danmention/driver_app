import 'package:driver_app/Assistants/assistantMethod.dart';
import 'package:driver_app/configMaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class CollectFareDialog extends StatelessWidget
{
  final String paymentMethod;
  final int fareAmount;

  CollectFareDialog({required this.paymentMethod,required this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.0,),

            Text("Trip Fare (" + rideType.toUpperCase() + ")",  style: TextStyle(fontSize: 16.0, fontFamily: "Brand Bold"),),

            SizedBox(height: 22.0,),

            Divider(thickness: 4.0,),

            SizedBox(height: 16.0,),

            Text("\ ${ NumberFormat.simpleCurrency(
    name: "NGN", //currencyCode
    ).format(fareAmount)
  } ", style: TextStyle(fontSize: 35.0, fontFamily: "Brand Bold"),),

            SizedBox(height: 16.0,),SizedBox(height: 16.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("This is the total trip amount, it has been charged to the rider.", textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: RaisedButton(
                onPressed: () async
                {
                 // _restartApp();
                  Navigator.pop(context);
                  Navigator.pop(context);

                  AssistantMethods.enableHomeTabLiveLocationUpdates();
                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Collect Cash", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                      Icon(Icons.attach_money, color: Colors.white, size: 26.0,),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }

  void _restartApp() async {
    FlutterRestart.restartApp();
  }
}
