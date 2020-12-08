import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:paysee/Login/custom_gpsset.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Login/custom_picture.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:paysee/Diligence/diligence_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_permissions/location_permissions.dart';

var globalContext;

class Custom_Setup extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Custom_SetupPage(),
    );
  }
}

class Custom_SetupPage extends StatefulWidget {
  @override
  _Custom_SetupPageState createState() => _Custom_SetupPageState();
}

class _Custom_SetupPageState extends State<Custom_SetupPage> {
  bool gpsVisible = false;

  @override
  void initState() {
    if (( USER_INFO_SCGpsYN == 'Y') && (gsGpsMrg == true)) {
      setState(() {
        gpsVisible = true;
      });
    } else {
      setState(() {
        gpsVisible = false;
      });
    }
  }

  //내 기기 위치 액세스 허용 체크
  static Future<bool> checkAppPermission(BuildContext context)  async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    if(permission!=PermissionStatus.granted && await LocationPermissions().requestPermissions()!=PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  Future<void> delAutoLoginFromSharedPrefs() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance(); // 인스턴스 생성
    setState(() {
      _prefs.remove("loginkey");
      _prefs.remove("loginid");
      _prefs.remove("loginpw");
      _prefs.remove("logindb");
      _prefs.remove("loginip");
      _prefs.remove("loginst");
      _prefs.remove("loginvs");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: getColorFromHex('303C4A'),
          elevation: 0,
          centerTitle: true,
          title: Text("설정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {Navigator.pop(globalContext);},
          ),
          actions: <Widget>[
            // overflow menu
//            IconButton(icon: Icon(Icons.more_vert, color: Colors.black,)),
            PopupMenuButton<Choice>(
              onSelected: (Choice choice) async {
                if(choice.title == '로그아웃') {
                  String msg = '현재 계정의 정보가 초기화 됩니다. \n 로그아웃 하시겠습니까?';
                  String action = await showAlertDialogOkCancel(context, msg);
                  if (action == 'OK') {
                    delAutoLoginFromSharedPrefs(); //--Local DB 삭제
                    globalValuClear();  //Global 변수 초기화 처리
                    //-- 종료 처리
//                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    //재실행 처리(기존 push 되어있는 widget 삭제를 위해)
                    Phoenix.rebirth(context);     //-재시행
//                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute( builder: (BuildContext context) =>
//                        Tab_Page()), (route) => false);
                  }
                } else if (choice.title == '설정') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Setup()),);
                };
              },
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: WillPopScope(
            onWillPop: () async => false,
            child: new Column(
                children: <Widget>[
                  Container( height: 50, color: Colors.black12 , alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 0),
                      child: Text('앱 설정', style: TextStyle(color: Colors.black26 , fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                  gpsVisible ?  GestureDetector(
                    onTap: () async {
                      bool chkpermission = await checkAppPermission(context);
                      if (chkpermission == true) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_GpsSet()),);
                      } else {
                        showToast("Google Map을 정상적으로 실행하기 위해 권한이 필요합니다..", context, duration: 5, gravity: Toast.CENTER);
                      }
                    },
                    child: Container( height: 50, color: Colors.white, alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                        child: Text('GPS 설정', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )
                        ),
                      ),),
                  ) : Container(),
                  Container( height: 3, color: Colors.black12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Picture()),);
                    },
                    child: Container( height: 50, color: Colors.white, alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                        child: Text('사진 수정/등록', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                      ),),
                  ),
//              Container( height: 3, color: Colors.black12),
//              Container( height: 50, color: Colors.white, alignment: Alignment.centerLeft,
//                child: Padding(
//                  padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
//                  child: Text('출퇴근 알림 설정', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
//                ),),
                  Container( height: 50, color: Colors.black12 , alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 0),
                      child: Text('급여박사', style: TextStyle(color: Colors.black26 , fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                  Container( height: 50, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('청주 본사      043-277-8668', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                  Container( height: 3, color: Colors.black12),
                  Container( height: 50, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('대표 전화      1588-1965', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),

                ]
            )
        )
    );
  }
}


