import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Join/tab_page.dart';
import 'package:paysee/Join/root_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paysee/Login/custom_insert.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Login/custom_confirm.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class Login_Page extends StatefulWidget {
  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  FocusNode _idFocusNode = FocusNode();
  FocusNode _pwFocusNode = FocusNode();
  final RoundedLoadingButtonController _btnController = new RoundedLoadingButtonController();
  bool  _autoLoginCheck = false;
  bool _versionChk = true;
  String _loginYN = '', _loginID = '', _loginPW = '', _loginDB = '', _loginIP = '', _loginST = '', _loginVS = '';

  void initState() {
    super.initState();
    globalValuClear();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          onWillPop: onBackPressed,
          child: Scaffold(
              backgroundColor: getColorFromHex('303C4A'),
              resizeToAvoidBottomInset : false,
              resizeToAvoidBottomPadding: false,
              body: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: getColorFromHex('303C4A'),),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(height: size.height * 0.08),
                          Row(
                            children: [

                              Container(
                                  padding: const EdgeInsets.only(left: 150, top: 10),
                                  child: Image.asset('images/title.png')),
                              Container(
                                padding: const EdgeInsets.only(left: 5, top: 45),
                                child: Text('페이씨', style: TextStyle(color: Colors.white , fontSize: 15, fontWeight: FontWeight.bold )),
                              ),
                            ],
                          ),
                          Container(height: size.height * 0.03),
                          Stack(
                            children: <Widget>[
                              _inputForm(size),
                              SizedBox(height: size.height * 0.32),
                              _loginButton(context, size),
                            ],
                          ),
                          _memberButton(context),
                          OrientationBuilder(
                              builder: (context, orientation) {
                                return orientation == Orientation.portrait ?
                                  Container(height: size.height * 0.08):
                                  Container();
                              }
                          ),
                          OrientationBuilder(
                              builder: (context, orientation) {
                                return orientation == Orientation.portrait ?
                                  Container(child: Text('페이씨 DrPay', style: TextStyle(color: Colors.white),),color: getColorFromHex('303C4A'),):
                                  Container();
                              }
                          ),
                        ]
                    ),
                  ],
                ),
              )
          ),
        )
    );
  }

  Widget _inputForm(Size size) {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            Container(
              width: size.width / 1.2,
              height: 45,
              padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
              ),
              child: TextField(
                controller: _idController,
                focusNode: _idFocusNode,
                decoration: InputDecoration(
                  border: InputBorder.none, icon: Icon(Icons.person, color: Color( 0xff6bceff),),hintText: 'ID',
                ),
              ),
            ),

            Container(
              width: size.width / 1.2,
              height: 45,
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(
                          50)),
                  color: Colors.white,
                  boxShadow: [ BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5
                  )
                  ]
              ),
              child: TextField(
                obscureText: true,
                controller: _pwController,
                focusNode: _pwFocusNode,
                decoration: InputDecoration(
                  border: InputBorder.none, icon: Icon(
                  Icons.vpn_key, color: Color(
                    0xff6bceff),),
                  hintText: 'PW',
                ),
              ),
            ),
            Container(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularCheckBox(
                  value: _autoLoginCheck,
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white,
                  hoverColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      this._autoLoginCheck = !this._autoLoginCheck;
                    });
                  },
                ),
                Text("자동 로그인", style: TextStyle(fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context, Size size) {
    return Positioned(
      left: size.width * 0.15,
      right: size.width * 0.15,
      bottom: 0,
      child: RaisedButton(
        child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 23)),
        color: getColorFromHex('303C4A'),
        highlightColor: getColorFromHex('303C4A'),
        splashColor: getColorFromHex('303C4A'),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: () {
          USER_INFO_SUId = _idController.text.toString();
          USER_INFO_SUPw = _pwController.text.toString();
          if (_idController.text.toString().isEmpty) {
            FocusScope.of(context).requestFocus(_idFocusNode);
            showAlertDialog(context, '사용자를 입력해 주세요');
            return;
          }
          if (USER_INFO_SUId == 'cho.ym') {
            //--IOS 심사용 아이디는 버전체크, 비밀번호 패스
          } else {
            if (_pwController.text.toString().isEmpty) {
              FocusScope.of(context).requestFocus(_pwFocusNode);
              showAlertDialog(context, '비밀번호를 입력해 주세요');
              return;
            }
          }

          if (USER_INFO_SUId == 'cho.ym') {
            //ISO 심사용일경우 USER_INFO, STAFF_INFO 기본 데이터 확인
            Navigator.push(context, MaterialPageRoute(builder: (context) => Tab_Page()),);
          } else {
            Map<String, String> data = {'SUId': USER_INFO_SUId,'SUPw': USER_INFO_SUPw};

            String url = baseurl + 'user/login/status';
            http.post(url, body: data).then((response) async {
              String jsonString = response.body;
              print('------------------------------');
              print('$jsonString');
              print('------------------------------');
              _versionChk = await getVersionCheck() as bool;
              if (_versionChk == true) {
                if (response.statusCode == 200) {
                  CheckStatus checkStatus = CheckStatus.fromJson(json.decode(jsonString));
                  if (checkStatus.code == '00' && checkStatus.type == 'O'){
                    if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'Y') {
                      USER_INFO_STMobileKey = checkStatus.chekstatusdata.sTMobileKey;
                      USER_INFO_SUMyPicYN = checkStatus.chekstatusdata.sUMyPicYN;
                      USER_INFO_MyPicURL = checkStatus.chekstatusdata.myPicURL2;

                      //-- USER_INFO, STAFF_INFO Data Select
                      await getUserInfo(USER_INFO_SUId, USER_INFO_SUPw);
                      await getShiftWorker();
                      await getStaffInfo();

                      //--자동 로그인 Local DataBase 저장
                      getAutoLoginFromSharedPrefs();
                      if(_autoLoginCheck == true) {
                        if(_loginYN == "Y" || _loginYN == null) {
                          delAutoLoginFromSharedPrefs();
                          setAutoLoginFromSharedPrefs(USER_INFO_SUId, USER_INFO_SUPw);
                        } else {
                          delAutoLoginFromSharedPrefs();
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Tab_Page()),);
                    } else if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'W') {
                      String msg = '입력하신 계정이 승인 대기중 입니다. \n가입승인 후 로그인이 가능합니다.';
                      await showAlertDialogOk(context, msg);
                    } else if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'D') {
                      showAlertDialogOk(context, '차단중인 아이디 입니다..');
                    } else {
                      showAlertDialogOk(context, '아이디 또는 패스워드를 확인해 주세요..');
                    }
                  } else {
                    showAlertDialogOk(context, '아이디 또는 패스워드를 확인해 주세요..');
                  }
                } else {
                  showAlertDialogOk(context, '사원정보의 Server Connect Select 오류 발생.');
                }
              } else {
                String msg = '앱 버전 정보가 일치하지 않습니다 \n앱 업데이트 이후 사용 가능합니다.';
                String action = await showAlertDialogOkCancel(context, msg);
                if (action == 'OK') {
                  if (PlatformOS == 'android') {
                    const url = "market://details?id=com.infra.drpay";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  } else {
                    const url = "htttps://itunes.apple.com/us/app/%EA%B8%89%EC%97%AC%EB%B0%95%EC%82%AC2/id1444985870?l=ko&ls=1&mt=8";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                }
              }
            });
          }
        },
      ),
    );
  }

  Widget _memberButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          child: Text( "회원가입", style: TextStyle(color: Colors.white, fontSize: 13)),
          color: getColorFromHex('303C4A'),
          highlightColor: getColorFromHex('303C4A'),
          splashColor: getColorFromHex('303C4A'),
          onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => Custom_Insert()),);
          },
        ),
        Container(child: Text('|', style: TextStyle(color: Colors.white, fontSize: 13)),),
        FlatButton(
          child: Text("아이디 찾기", style: TextStyle(color: Colors.white, fontSize: 13)),
          color: getColorFromHex('303C4A'),
          highlightColor: getColorFromHex('303C4A'),
          splashColor: getColorFromHex('303C4A'),
          onPressed: () {
            var selectTab = 0;
            Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Confirm(selectTab)),);
          },
        ),
        Container(child: Text(
            '|', style: TextStyle(color: Colors.white, fontSize: 13)),),
        FlatButton(
          child: Text("패스워드 찾기", style: TextStyle(color: Colors.white, fontSize: 13)),
          color: getColorFromHex('303C4A'),
          highlightColor: getColorFromHex('303C4A'),
          splashColor: getColorFromHex('303C4A'),
          onPressed: () {
            var selectTab = 1;
            Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Confirm(selectTab)),);
          },
        ),
      ],
    );
  }

  Future<void> getShiftWorker() async {
    String url = baseurl + 'company/isshiftwork';

    SendShiftWorker sendshiftworker = new SendShiftWorker();
    sendshiftworker.stcode = USER_INFO_SUSTCode;
    sendshiftworker.sCDBName = USER_INFO_SCDBName;
    sendshiftworker.sCHostIp = USER_INFO_SCHostIp;
    Map data = sendshiftworker.toJson();

//    SendShiftWorker sendshiftworker = new SendShiftWorker(stcode: USER_INFO_SUSTCode, sCDBName: USER_INFO_SCDBName, sCHostIp: USER_INFO_SCHostIp );
//    Map data = sendshiftworker.toJson();

    var body = 'parm=' + json.encode(data);

    await http.post(url, body: body).then((response) {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        RespShiftWorker respshiftworker = RespShiftWorker.fromJson(json.decode(jsonString));
        if (respshiftworker.code == '00') {
          if (respshiftworker.type == 'O') {
            gsShiftWorker = respshiftworker.respshiftworkerdata.data ;      //-- 교대근무자 확인건
          }
        }
      }
    });
  }

  Future<void> getAutoLoginFromSharedPrefs() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance(); // 인스턴스 생성
    setState(() {
      _loginYN = _prefs.getString('loginkey');
      _loginID = _prefs.getString('loginid');
      _loginPW = _prefs.getString('loginpw');
      _loginDB = _prefs.getString('logindb');
      _loginIP = _prefs.getString('loginip');
      _loginST = _prefs.getString('loginst');
      _loginVS = _prefs.getString('loginvs');
    });
  }

  Future<void> setAutoLoginFromSharedPrefs(String suid, String supw) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance(); // 인스턴스 생성
    setState(() {
      _prefs.setString("loginkey", 'Y');
      _prefs.setString("loginid", suid);
      _prefs.setString("loginpw", supw);
      _prefs.setString("logindb", USER_INFO_SCDBName);
      _prefs.setString("loginip", USER_INFO_SCHostIp);
      _prefs.setString("loginst", USER_INFO_SUSTCode);
      _prefs.setString("loginvs", APP_VERSION);
    });
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

  Future<bool> onBackPressed() {
    return showDialog( context: context, builder: (context) => AlertDialog(
      title: Text("프로그램을 종료 하시겠습니까?", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold ),),
      actions: <Widget>[
        FlatButton(
          child: Text("예"),
          onPressed: () => Navigator.pop(context, true),
        ),
        FlatButton( child: Text("아니요"),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
    ) ?? false;
  }
}


//-- login 체크 Class
class CheckStatus {
  String code, type, message;
  CheckStatusData chekstatusdata;

  CheckStatus({this.code, this.type, this.message, this.chekstatusdata});

  CheckStatus.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    chekstatusdata = json['data'] != null ? new CheckStatusData.fromJson(json['data']) : null;
  }
}

class CheckStatusData {
  String sUCode, sUName, sUStaffAPPUseYN, sUSCCode, sTMobileKey, sUMyPicYN, myPicURL, myPicURL2;

  CheckStatusData({this.sUCode, this.sUName, this.sUStaffAPPUseYN, this.sUSCCode, this.sTMobileKey,
    this.sUMyPicYN, this.myPicURL, this.myPicURL2});

  CheckStatusData.fromJson(Map<String, dynamic> json) {
    sUCode = json['SUCode'];
    sUName = json['SUName'];
    sUStaffAPPUseYN = json['SUStaffAPPUseYN'];
    sUSCCode = json['SUSCCode'];
    sTMobileKey = json['STMobileKey'];
    sUMyPicYN = json['SUMyPicYN'];
    myPicURL = json['MyPicURL'];
    myPicURL2 = json['MyPicURL2'];
  }
}


