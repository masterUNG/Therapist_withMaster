import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

import 'package:therapist_buddy/variables.dart';

class NoInternetConnectionPageWidget extends StatefulWidget {
  const NoInternetConnectionPageWidget({Key key}) : super(key: key);

  @override
  _NoInternetConnectionPageWidgetState createState() =>
      _NoInternetConnectionPageWidgetState();
}

class _NoInternetConnectionPageWidgetState
    extends State<NoInternetConnectionPageWidget> {
  var subscription;
  bool internetIsConnected;

  @override
  void initState() {
    super.initState();
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
  }

  Future<Null> checkInternetConnectionInitState() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        internetIsConnected = false;
      });
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            internetIsConnected = true;
          });
        }
      } on SocketException catch (_) {
        setState(() {
          internetIsConnected = false;
        });
      }
    }
  }

  Future<Null> checkInternetConnectionRealTime() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        setState(() {
          internetIsConnected = false;
        });
      } else {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            setState(() {
              internetIsConnected = true;
            });
          }
        } on SocketException catch (_) {
          setState(() {
            internetIsConnected = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: internetIsConnected == true
              ? internetIsBack(context)
              : noInternet(context),
        ),
      ),
    );
  }

  Widget internetIsBack(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_done_outlined,
          color: primaryColor,
          size: 80,
        ),
        SizedBox(height: 8),
        Text(
          'สัญญานอินเทอร์เน็ต\nกลับมาอีกครั้ง',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: Text(
              'กลับไปหน้าที่แล้ว',
              style: GoogleFonts.getFont(
                'Kanit',
                color: primaryColor,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 2,
              color: primaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off,
          color: Colors.black,
          size: 80,
        ),
        SizedBox(height: 8),
        Text(
          'ไม่มีการเชื่อมต่อกับ\nสัญญานอินเทอร์เน็ต',
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: Text(
              'กลับไปหน้าที่แล้ว',
              style: GoogleFonts.getFont(
                'Kanit',
                color: primaryColor,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 2,
              color: primaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
