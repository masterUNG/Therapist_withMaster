import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/notifications_list_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import '../main.dart';
import 'no_internet_connection_page.dart';

class NotificationsPageWidget extends StatefulWidget {
  const NotificationsPageWidget({Key key}) : super(key: key);

  @override
  _NotificationsPageWidgetState createState() =>
      _NotificationsPageWidgetState();
}

class _NotificationsPageWidgetState extends State<NotificationsPageWidget> {
  var subscription;
  bool internetIsConnected;
  String userDocumentID;
  List<NotificationsListModel> notificationsListModel = [];
  bool readDataIsFinished;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    checkInternetConnectionInitState();
    checkInternetConnectionRealTime();
    findUserDocumentID();
    readNotifications();
    initializeDateFormatting();
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

  // ดึงค่า userDocumentID ใน sharedPreferences
  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
  }

  Future<Null> readNotifications() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('notifications')
          .get()
          .then((value) async {
        for (var item in value.docs) {
          PatientNotificationsModel patientNotificationsModel =
              PatientNotificationsModel.fromMap(item.data());

          NotificationsListModel model = NotificationsListModel(
              notificationID: item.id,
              image: patientNotificationsModel.image,
              title: patientNotificationsModel.title,
              body: patientNotificationsModel.body,
              category: patientNotificationsModel.category,
              readAt: patientNotificationsModel.readAt,
              createdAt: patientNotificationsModel.createdAt);
          notificationsListModel.add(model);
        }
      });
    });
    notificationsListModel.sort((a, b) {
      return b.createdAt.toDate().compareTo(a.createdAt.toDate());
    });
    setState(() {
      readDataIsFinished = true;
    });
  }

  Future<Null> refreshPage() async {
    notificationsListModel.clear();
    await readNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: readDataIsFinished == true
            ? notificationsListModel.length == 0
                ? Center(
                    child: Text(
                      'ยังไม่มีการแจ้งเตือน',
                      style: GoogleFonts.getFont(
                        'Kanit',
                        color: Color(0xFFA7A8AF),
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshPage,
                    child: notificationsList(),
                  )
            : Center(
                child: SmallProgressIndicator(),
              ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetAppBarContainerHeight)
          : Size.fromHeight(appbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: primaryColor,
            size: 24,
          ),
          iconSize: 24,
        ),
        title: Text(
          'การแจ้งเตือน',
          style: GoogleFonts.getFont(
            'Kanit',
            color: primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        bottom: internetIsConnected == false
            ? PreferredSize(
                preferredSize: Size.fromHeight(noInternetAppBarContainerHeight),
                child: Container(
                  height: noInternetAppBarContainerHeight,
                  color: snackBarRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
                        style: GoogleFonts.getFont(
                          'Kanit',
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget notificationsList() {
    return ListView.builder(
      itemCount: notificationsListModel.length,
      itemBuilder: (context, index) =>
          notificationContainer(context, notificationsListModel[index]),
    );
  }

  Widget notificationContainer(
      BuildContext context, NotificationsListModel notificationsListModel) {
    double imageSize = 70.0;
    String createdAtDate =
        DateFormat.yMd('th').format(notificationsListModel.createdAt.toDate());
    String createdAtTime =
        DateFormat.Hm().format(notificationsListModel.createdAt.toDate());

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              showDialog(
                barrierDismissible: false,
                barrierColor: Colors.transparent,
                context: context,
                builder: (context) => Center(
                  child: SmallProgressIndicator(),
                ),
              );
              if (notificationsListModel.readAt == null) {
                await updateReadAt(notificationsListModel.notificationID,
                    notificationsListModel.category);
              } else {
                await goToNextPage(notificationsListModel.category);
              }
            }
          },
          child: Container(
            color: notificationsListModel.readAt == null
                ? primaryColor.withOpacity(0.1)
                : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                    child: CachedNetworkImage(
                      imageUrl: notificationsListModel.image,
                      placeholder: (context, url) => Container(
                        width: imageSize,
                        height: imageSize,
                        color: loadingImageBG,
                      ),
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notificationsListModel.title,
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              notificationsListModel.body,
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$createdAtDate - $createdAtTime น.',
                          style: GoogleFonts.getFont(
                            'Kanit',
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E5E5),
        ),
      ],
    );
  }

  Future<Null> updateReadAt(String notificationID, String category) async {
    await Firebase.initializeApp().then((value) async {
      Map<String, dynamic> data = {};
      data['readAt'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('notifications')
          .doc(notificationID)
          .update(data)
          .then((value) async {
        await goToNextPage(category);
      });
    });
  }

  Future<Null> goToNextPage(String category) async {
    if (category == exerciseResult) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavBarPage(initialPage: 'Treatments_page'),
        ),
        (r) => false,
      );
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
