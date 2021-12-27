import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:therapist_buddy/variables.dart';
import 'package:therapist_buddy/screens/login_page.dart';
import 'package:therapist_buddy/widgets/small_progress_indicator.dart';
import 'screens/home_page.dart';
import 'screens/treatments_page.dart';
import 'screens/add_treatment_page.dart';
// import 'screens/chats_page.dart';
import 'screens/others_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp().then((value) async {
    print("Handling a background message: ${message.data}");
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool findUserLoggedInIsFinished;
  bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    findUserLoggedInIsFinished = false;
    findUserLoggedIn();
    firebaseMessagingRequestPermission();
  }

  Future<Null> findUserLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userDocumentID = sharedPreferences.getString('userDocumentID');
    print('userDocumentID = $userDocumentID');
    if (userDocumentID == null) {
      setState(() {
        isLoggedIn = false;
      });
    } else {
      setState(() {
        isLoggedIn = true;
      });
    }
    setState(() {
      findUserLoggedInIsFinished = true;
    });
  }

  Future<Null> firebaseMessagingRequestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TherapistBuddy',
      home: findUserLoggedInIsFinished == true
          ? isLoggedIn == true
              ? NavBarPage(initialPage: 'Home_page')
              : LoginPageWidget()
          : Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: SmallProgressIndicator(),
                ),
              ),
            ),
    );
  }
}

class NavBarPage extends StatefulWidget {
  final String initialPage;
  NavBarPage({Key key, this.initialPage}) : super(key: key);

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  String _currentPage = 'Home_page';

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? _currentPage;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Home_page': HomePageWidget(),
      'Treatments_page': TreatmentsPageWidget(),
      'AddTreatment_page': AddTreatmentPageWidget(),
      // 'Chats_page': ChatsPageWidget(),
      'Others_page': OthersPageWidget(),
    };
    return Scaffold(
      body: tabs[_currentPage],
      bottomNavigationBar: Container(
        width: double.infinity,
        height: bottomNavigationBarHeight,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
              activeIcon: Icon(
                Icons.home_sharp,
                color: Color(0xFF0080FF),
                size: 24,
              ),
              label: 'หน้าหลัก',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
              activeIcon: Icon(
                Icons.medical_services,
                color: Color(0xFF0080FF),
                size: 24,
              ),
              label: 'การรักษา',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
              activeIcon: Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF0080FF),
                size: 24,
              ),
              label: 'เพิ่ม',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.chat_outlined,
            //     color: Color(0xFF9E9E9E),
            //     size: 24,
            //   ),
            //   activeIcon: Icon(
            //     Icons.chat,
            //     color: Color(0xFF0080FF),
            //     size: 24,
            //   ),
            //   label: 'แชท',
            // ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dehaze_rounded,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
              activeIcon: Icon(
                Icons.dehaze_rounded,
                color: Color(0xFF0080FF),
                size: 24,
              ),
              label: 'อื่นๆ',
            )
          ],
          backgroundColor: Colors.white,
          currentIndex: tabs.keys.toList().indexOf(_currentPage),
          selectedLabelStyle: TextStyle(fontFamily: 'Kanit'),
          selectedItemColor: Color(0xFF0080FF),
          unselectedLabelStyle: TextStyle(fontFamily: 'Kanit'),
          unselectedItemColor: Color(0xFF7A7A7A),
          onTap: (i) => setState(() => _currentPage = tabs.keys.toList()[i]),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
