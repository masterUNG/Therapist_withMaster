import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flutter_flow/flutter_flow_youtube_player.dart';

import 'package:therapist_buddy/variables.dart';
import '../widgets/info_container.dart';

class ExerciseIntroductionPageWidget extends StatefulWidget {
  ExerciseIntroductionPageWidget({Key key}) : super(key: key);

  @override
  _ExerciseIntroductionPageWidgetState createState() =>
      _ExerciseIntroductionPageWidgetState();
}

class _ExerciseIntroductionPageWidgetState
    extends State<ExerciseIntroductionPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              videoArea(context),
              InfoContainer(title: 'ชื่อ', info: 'ยกแขนด้านข้าง'),
              InfoContainer(title: 'ประเภทผู้ป่วย', info: 'Office Syndrome'),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appbarHeight),
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
          'ยกแขนด้านข้าง',
          style: GoogleFonts.getFont(
            'Kanit',
            color: primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
    );
  }

  Widget videoArea(BuildContext context) {
    return FlutterFlowYoutubePlayer(
      url: 'https://www.youtube.com/watch?v=C30hQ0ZSFoM',
      width: MediaQuery.of(context).size.width,
      autoPlay: false,
      looping: false,
      mute: false,
      showControls: true,
      showFullScreen: true,
    );
  }
}
