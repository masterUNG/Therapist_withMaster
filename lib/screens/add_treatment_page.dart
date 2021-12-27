import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/models/patient_users_model.dart';
import 'package:therapist_buddy/models/treatments_model.dart';
import 'package:therapist_buddy/models/patients_list_model.dart';
import 'package:therapist_buddy/models/patient_notifications_model.dart';
import 'package:therapist_buddy/models/therapists_model.dart';
import 'package:therapist_buddy/models/tokens_model.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'package:therapist_buddy/widgets/progress_dialog.dart';
import 'notifications_page.dart';
import 'no_internet_connection_page.dart';

class AddTreatmentPageWidget extends StatefulWidget {
  AddTreatmentPageWidget({Key key}) : super(key: key);

  @override
  _AddTreatmentPageWidgetState createState() => _AddTreatmentPageWidgetState();
}

class _AddTreatmentPageWidgetState extends State<AddTreatmentPageWidget> {
  var subscription;
  bool internetIsConnected;
  TextEditingController patientUserIDTextController;
  TextEditingController patientNameTextController;
  String userDocumentID;
  bool readDataIsFinished;
  int searchTypeValue;
  bool searchTypeOneOnSubmitted;
  bool availablePatientUserID;
  String patientID;
  String patientUserID;
  String patientUserProfileImage;
  String patientUserFirstName;
  String patientUserLastName;
  bool findPatientUserIDIsFinished;
  bool treatmentWasAdded;
  List<PatientsListModel> patientsListModel = [];
  List<PatientsListModel> filteredPatientsListModel = [];
  bool readPatientsListIsFinished;
  double radioButtonsAreaHeight = 70.0;
  double searchTextFieldHeight = 41.0;
  int notificationNumber;

  @override
  void initState() {
    super.initState();
    readDataIsFinished = false;
    patientUserIDTextController = TextEditingController();
    patientNameTextController = TextEditingController();
    searchTypeValue = 1;
    findUserDocumentID();
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

  Future<Null> findUserDocumentID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userDocumentID = sharedPreferences.getString('userDocumentID');
    setState(() {
      readDataIsFinished = true;
    });
    await readNotifications();
  }

  Future<Null> readNotifications() async {
    await Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .collection('notifications')
          .where('readAt', isNull: true)
          .snapshots()
          .listen((event) {
        setState(() {
          notificationNumber = event.docs.length;
        });
      });
    });
  }

  final addTreatmentSuccessfullySnackBar = SnackBar(
    content: Text(
      'เพิ่มการรักษาเรียบร้อยแล้ว',
      style: GoogleFonts.getFont(
        'Kanit',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    backgroundColor: defaultGreen,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: readDataIsFinished == true
            ? SingleChildScrollView(
                child: GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).requestFocus(FocusScopeNode()),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        appbarHeight -
                        bottomNavigationBarHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        radioButtonsArea(),
                        searchTypeValue == 1
                            ? searchTypeOneArea()
                            : searchTypeTwoArea(context),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: SmallProgressIndicator(),
              ),
      ),
    );
  }

  Widget appBar() {
    return PreferredSize(
      preferredSize: internetIsConnected == false
          ? Size.fromHeight(appbarHeight + noInternetAppBarContainerHeight)
          : Size.fromHeight(appbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        title: Text(
          'TherapistBuddy',
          style: GoogleFonts.getFont(
            'Raleway',
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () async {
                  if (internetIsConnected == false) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoInternetConnectionPageWidget(),
                      ),
                    );
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPageWidget(),
                      ),
                    );
                  }
                },
                icon: notificationNumber == null
                    ? Icon(
                        Icons.notifications_none,
                        color: primaryColor,
                        size: 25,
                      )
                    : notificationNumber == 0
                        ? Icon(
                            Icons.notifications_none,
                            color: primaryColor,
                            size: 25,
                          )
                        : Stack(
                            alignment: Alignment(0, 0),
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: primaryColor,
                                size: 25,
                              ),
                              Align(
                                alignment: Alignment(1, -1),
                                child: Container(
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: snackBarRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notificationNumber > 9
                                        ? '9+'
                                        : '$notificationNumber',
                                    style: GoogleFonts.getFont(
                                      'Kanit',
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
              );
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget radioButtonsArea() {
    return Container(
      width: double.infinity,
      height: radioButtonsAreaHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: searchTypeValue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    setState(() {
                      searchTypeValue = value;
                      print("searchTypeValue = $searchTypeValue");
                    });
                    patientsListModel.clear();
                    filteredPatientsListModel.clear();
                    readPatientsListIsFinished = false;
                  },
                ),
                Text(
                  'ไอดีผู้ใช้ของคนไข้',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 3,
            ),
            Row(
              children: [
                Radio(
                  value: 2,
                  groupValue: searchTypeValue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) async {
                    if (internetIsConnected == false) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NoInternetConnectionPageWidget(),
                        ),
                      );
                    } else {
                      setState(() {
                        searchTypeValue = value;
                        print("radioButtonValue = $searchTypeValue");
                      });
                      await readPatientsList();
                    }
                  },
                ),
                Text(
                  'คนไข้ที่เคยรักษา',
                  style: GoogleFonts.getFont(
                    'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchTypeOneArea() {
    return Container(
      child: Column(
        children: [
          searchTextFieldTypeOne(),
          searchResultArea(),
        ],
      ),
    );
  }

  Widget searchTextFieldTypeOne() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 30),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: searchTextFieldHeight,
              child: TextFormField(
                onChanged: (value) => setState(() {}),
                controller: patientUserIDTextController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'โปรดใส่ไอดีผู้ใช้ของคนไข้',
                  hintStyle: GoogleFonts.getFont(
                    'Kanit',
                    color: Color(0xFFA7A8AF),
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF0F2F5),
                  contentPadding: EdgeInsets.fromLTRB(18, 5, 0, 10),
                  suffixIcon: patientUserIDTextController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              patientUserIDTextController.clear();
                              searchTypeOneOnSubmitted = false;
                              findPatientUserIDIsFinished = false;
                              availablePatientUserID = null;
                              treatmentWasAdded = null;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.black,
                            size: 22,
                          ),
                        )
                      : null,
                ),
                style: GoogleFonts.getFont(
                  'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: searchTextFieldHeight,
            decoration: BoxDecoration(
              color: Color(0xFFF0F2F5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (internetIsConnected == false) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NoInternetConnectionPageWidget(),
                        ),
                      );
                    } else {
                      setState(() {
                        searchTypeOneOnSubmitted = true;
                        findPatientUserIDIsFinished = false;
                        availablePatientUserID = null;
                        treatmentWasAdded = null;
                      });
                      await findPatient();
                    }
                  },
                  child: Icon(
                    Icons.search_rounded,
                    color: primaryColor,
                    size: 23,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<Null> findPatient() async {
    String patientIDTextField = patientUserIDTextController.text;

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('patientUsers')
          .where('therapyBuddyID', isEqualTo: patientIDTextField)
          .where('deletedAt', isNull: true)
          .get()
          .then((value) async {
        if (value.docs.length != 0) {
          setState(() {
            availablePatientUserID = true;
          });
          for (var item in value.docs) {
            patientUserID = item.id;

            await FirebaseFirestore.instance
                .collection('patientUsers')
                .doc(patientUserID)
                .get()
                .then((value) async {
              PatientUsersModel patientUsersModel =
                  PatientUsersModel.fromMap(value.data());

              setState(() {
                patientID = patientUsersModel.patientID;
                patientUserProfileImage = patientUsersModel.profileImage;
                patientUserFirstName = patientUsersModel.firstName;
                patientUserLastName = patientUsersModel.lastName;
              });
            });
          }
          await checkTreatments();
        } else {
          setState(() {
            availablePatientUserID = false;
            findPatientUserIDIsFinished = true;
          });
        }
      });
    });
  }

  Future<Null> checkTreatments() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .where('therapistID', isEqualTo: userDocumentID)
          .where('patientUserID', isEqualTo: patientUserID)
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        if (value.docs.length == 0) {
          setState(() {
            treatmentWasAdded = false;
          });
        } else {
          setState(() {
            treatmentWasAdded = true;
          });
        }
        setState(() {
          findPatientUserIDIsFinished = true;
        });
      });
    });
  }

  Widget searchResultArea() {
    return searchTypeOneOnSubmitted == true
        ? findPatientUserIDIsFinished == true
            ? availablePatientUserID == true
                ? availablePatient()
                : unavailablePatient()
            : findPatientInProgress()
        : Container();
  }

  Widget findPatientInProgress() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'กำลังค้นหา',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          SmallProgressIndicator(),
        ],
      ),
    );
  }

  Widget unavailablePatient() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Text(
        'ไม่พบคนไข้',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget availablePatient() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 115,
          height: 115,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: patientUserProfileImage == null
              ? Image.asset(
                  'assets/images/profileDefault_circle.png',
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: patientUserProfileImage,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/profileDefault_circle.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(30, 5, 30, 8),
          child: Text(
            '$patientUserFirstName $patientUserLastName',
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 21,
            ),
          ),
        ),
        FFButtonWidget(
          onPressed: () async {
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              if (treatmentWasAdded != true) {
                await showDialog(
                  context: context,
                  builder: (context) => addTreatmentSearchTypeOneConfirmation(),
                );
              }
            }
          },
          text: treatmentWasAdded == true ? 'กำลังรักษา' : 'รักษา',
          options: FFButtonOptions(
            width: 150,
            height: 40,
            color: treatmentWasAdded == true ? secondaryColor : primaryColor,
            textStyle: GoogleFonts.getFont(
              'Kanit',
              color: Colors.white,
              fontSize: 18,
            ),
            borderRadius: 30,
          ),
        )
      ],
    );
  }

  Widget addTreatmentSearchTypeOneConfirmation() {
    return AlertDialog(
      title: Text(
        '$patientUserFirstName $patientUserLastName',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องเพิ่มการรักษานี้',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              await addTreatmentSearchTypeOne();
            }
          },
          child: Text(
            'ยืนยัน',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<Null> addTreatmentSearchTypeOne() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังเพิ่มการรักษา'),
    );

    await Firebase.initializeApp().then((value) async {
      TreatmentsModel treatmentsModel = TreatmentsModel(
          therapistID: userDocumentID,
          patientID: patientID,
          patientUserID: patientUserID,
          startDate: Timestamp.now(),
          finishDate: null,
          isActive: true,
          finishStatus: null);
      Map<String, dynamic> data = treatmentsModel.toMap();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc()
          .set(data)
          .then((value) async {
        await addNotificationSearchTypeOne();
      });
    });
  }

  Future<Null> addNotificationSearchTypeOne() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());
        String therapistProfileImage = therapistsModel.profileImage;
        String therapistName =
            '${therapistsModel.nameTitle}${therapistsModel.firstName} ${therapistsModel.lastName}';

        PatientNotificationsModel patientNotificationsModel =
            PatientNotificationsModel(
                image: therapistProfileImage,
                title: 'การรักษาใหม่',
                body: '$therapistName ได้เพิ่มการรักษาคุณแล้ว',
                category: presentTreatment,
                readAt: null,
                createdAt: Timestamp.now());
        Map<String, dynamic> data = patientNotificationsModel.toMap();

        await FirebaseFirestore.instance
            .collection('patientUsers')
            .doc(patientUserID)
            .collection('notifications')
            .doc()
            .set(data)
            .then((value) async {
          await sendNotificationSearchTypeOne(therapistName);
        });
      });
    });
  }

  Future<Null> sendNotificationSearchTypeOne(String therapistName) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .collection('tokens')
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        List<String> tokens = [];

        for (var item in value.docs) {
          TokensModel tokensModel = TokensModel.fromMap(item.data());
          String token = tokensModel.token;
          tokens.add(token);
        }

        for (var item in tokens) {
          String token = item;
          String title = "มีการรักษาใหม่";
          String body = '$therapistName ได้เพิ่มการรักษาคุณแล้ว';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    setState(() {
      treatmentWasAdded = true;
    });
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(addTreatmentSuccessfullySnackBar);
  }

  Future<Null> readPatientsList() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('treatments')
          .where('therapistID', isEqualTo: userDocumentID)
          .where('isActive', isEqualTo: false)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          TreatmentsModel treatmentModel = TreatmentsModel.fromMap(item.data());

          await FirebaseFirestore.instance
              .collection('treatments')
              .where('therapistID', isEqualTo: userDocumentID)
              .where('patientUserID', isEqualTo: treatmentModel.patientUserID)
              .where('isActive', isEqualTo: true)
              .get()
              .then((value) async {
            if (value.docs.length == 0) {
              if (patientsListModel
                      .where((patientsListModel) => patientsListModel
                          .patientUserID
                          .contains(treatmentModel.patientUserID))
                      .length ==
                  0) {
                await Firebase.initializeApp().then((value) async {
                  await FirebaseFirestore.instance
                      .collection('patientUsers')
                      .doc(treatmentModel.patientUserID)
                      .get()
                      .then((value) async {
                    PatientUsersModel patientUserModel =
                        PatientUsersModel.fromMap(value.data());

                    if (patientUserModel.deletedAt == null) {
                      PatientsListModel model = PatientsListModel(
                          patientID: patientUserModel.patientID,
                          patientUserID: treatmentModel.patientUserID,
                          patientUserProfileImage:
                              patientUserModel.profileImage,
                          patientUserFirstName: patientUserModel.firstName,
                          patientUserLastName: patientUserModel.lastName);
                      patientsListModel.add(model);
                    }
                  });
                });
              }
            }
          });
        }
        setState(() {
          filteredPatientsListModel = patientsListModel;
          readPatientsListIsFinished = true;
        });
      });
    });
  }

  Widget searchTypeTwoArea(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          searchTextFieldTypeTwo(),
          readPatientsListIsFinished == true
              ? patientsListArea(context)
              : patientsListIsLoading(),
        ],
      ),
    );
  }

  Widget searchTextFieldTypeTwo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        height: searchTextFieldHeight,
        child: TextFormField(
          onChanged: (value) {
            setState(() {});
            filteredPatientsListModel = patientsListModel
                .where((patientsListModel) =>
                    '${patientsListModel.patientUserFirstName} ${patientsListModel.patientUserLastName}'
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                .toList();
          },
          controller: patientNameTextController,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'ค้นหา',
            hintStyle: GoogleFonts.getFont(
              'Kanit',
              color: Color(0xFFA7A8AF),
              fontSize: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            filled: true,
            fillColor: Color(0xFFF0F2F5),
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 20,
            ),
            suffixIcon: patientNameTextController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        patientNameTextController.clear();
                      });
                      filteredPatientsListModel = patientsListModel
                          .where((patientsListModel) =>
                              '${patientsListModel.patientUserFirstName} ${patientsListModel.patientUserLastName}'
                                  .toLowerCase()
                                  .contains(patientNameTextController.text
                                      .toLowerCase()))
                          .toList();
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.black,
                      size: 22,
                    ),
                  )
                : null,
          ),
          style: GoogleFonts.getFont(
            'Kanit',
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget patientsListIsLoading() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          appbarHeight -
          radioButtonsAreaHeight -
          42 -
          bottomNavigationBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SmallProgressIndicator(),
          SizedBox(width: 15),
          Text(
            'กำลังโหลดข้อมูล',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget patientsListArea(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          appbarHeight -
          radioButtonsAreaHeight -
          searchTextFieldHeight -
          bottomNavigationBarHeight,
      child: patientsListModel.length == 0 ? noPatients() : patientsList(),
    );
  }

  Widget noPatients() {
    return Center(
      child: Text(
        'ไม่มีคนไข้',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget patientsList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: filteredPatientsListModel.length,
      itemBuilder: (context, index) {
        return patientContainer(
            context, index, filteredPatientsListModel[index]);
      },
    );
  }

  Widget patientContainer(BuildContext context, int index,
      PatientsListModel filteredPatientsListModel) {
    return Column(
      children: [
        index == 0 ? SizedBox(height: 8) : Container(),
        Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: filteredPatientsListModel.patientUserProfileImage,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/profileDefault_circle.png',
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Container(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredPatientsListModel.patientUserFirstName} ${filteredPatientsListModel.patientUserLastName}',
                          style: GoogleFonts.getFont(
                            'Kanit',
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment(1, 0),
                    child: IconButton(
                      onPressed: () async {
                        if (internetIsConnected == false) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoInternetConnectionPageWidget(),
                            ),
                          );
                        } else {
                          await showDialog(
                            context: context,
                            builder: (context) =>
                                addTreatmentConfirmationAlertDialog2(
                              filteredPatientsListModel.patientUserFirstName,
                              filteredPatientsListModel.patientUserLastName,
                              filteredPatientsListModel.patientID,
                              filteredPatientsListModel.patientUserID,
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color: primaryColor,
                        size: 35,
                      ),
                      iconSize: 35,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        index == this.filteredPatientsListModel.length - 1
            ? SizedBox(height: 8)
            : Container(),
      ],
    );
  }

  Widget addTreatmentConfirmationAlertDialog2(String patientUserFirstName,
      String patientUserLastName, String patientID, String patientUserID) {
    return AlertDialog(
      title: Text(
        '$patientUserFirstName $patientUserLastName',
        style: GoogleFonts.getFont(
          'Kanit',
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ว่าต้องเพิ่มการรักษานี้',
        style: GoogleFonts.getFont(
          'Kanit',
          color: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ยกเลิก',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (internetIsConnected == false) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetConnectionPageWidget(),
                ),
              );
            } else {
              await addTreatmentSearchTypeTwo(patientID, patientUserID);
            }
          },
          child: Text(
            'ยืนยัน',
            style: GoogleFonts.getFont(
              'Kanit',
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<Null> addTreatmentSearchTypeTwo(
      String patientID, String patientUserID) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ProgressDialog(title: 'กำลังเพิ่มการรักษา'),
    );

    await Firebase.initializeApp().then((value) async {
      TreatmentsModel treatmentsModel = TreatmentsModel(
          therapistID: userDocumentID,
          patientID: patientID,
          patientUserID: patientUserID,
          startDate: Timestamp.now(),
          finishDate: null,
          isActive: true,
          finishStatus: null);
      Map<String, dynamic> data = treatmentsModel.toMap();

      await FirebaseFirestore.instance
          .collection('treatments')
          .doc()
          .set(data)
          .then((value) async {
        await addNotificationSearchTypeTwo(patientID, patientUserID);
      });
    });
  }

  Future<Null> addNotificationSearchTypeTwo(
      String patientID, String patientUserID) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userDocumentID)
          .get()
          .then((value) async {
        TherapistsModel therapistsModel = TherapistsModel.fromMap(value.data());
        String therapistProfileImage = therapistsModel.profileImage;
        String therapistName =
            '${therapistsModel.nameTitle}${therapistsModel.firstName} ${therapistsModel.lastName}';

        PatientNotificationsModel patientNotificationsModel =
            PatientNotificationsModel(
                image: therapistProfileImage,
                title: 'การรักษาใหม่',
                body: '$therapistName ได้เพิ่มการรักษาคุณแล้ว',
                category: presentTreatment,
                readAt: null,
                createdAt: Timestamp.now());
        Map<String, dynamic> data = patientNotificationsModel.toMap();

        await FirebaseFirestore.instance
            .collection('patientUsers')
            .doc(patientUserID)
            .collection('notifications')
            .doc()
            .set(data)
            .then((value) async {
          await sendNotificationSearchTypeTwo(patientID, therapistName);
        });
      });
    });
  }

  Future<Null> sendNotificationSearchTypeTwo(
      String patientID, String therapistName) async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .collection('tokens')
          .where('isActive', isEqualTo: true)
          .get()
          .then((value) async {
        List<String> tokens = [];

        for (var item in value.docs) {
          TokensModel tokensModel = TokensModel.fromMap(item.data());
          String token = tokensModel.token;
          tokens.add(token);
        }

        for (var item in tokens) {
          String token = item;
          String title = "มีการรักษาใหม่";
          String body = '$therapistName ได้เพิ่มการรักษาคุณแล้ว';
          String url =
              'https://tpbuddyadmin.com/app/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(url);
        }
      });
    });
    setState(() {
      patientNameTextController.clear();
      patientsListModel.clear();
      filteredPatientsListModel.clear();
      readPatientsListIsFinished = false;
      readPatientsList();
    });
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(addTreatmentSuccessfullySnackBar);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}
