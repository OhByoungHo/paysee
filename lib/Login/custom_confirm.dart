import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';

var globalContext;

class Custom_Confirm extends StatelessWidget {
  // This widget is the root of your application.
  final int selectedPage;
  Custom_Confirm(this.selectedPage);

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '아이디/비밀번호 찾기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        initialIndex:selectedPage,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: getColorFromHex('303C4A'),
            centerTitle: true,
            title: Text("아이디/비밀번호 찾기", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,)),
            bottom: TabBar(
              indicatorColor: getColorFromHex('303C4A'),
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.blueAccent),
//                  color: Colors.redAccent),
              tabs: <Widget>[
                Tab(text: "아이디 찾기"),
                Tab(text: "비밀번호 찾기")
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              TabID(),
              TabPW()
            ],
          ),
        ),
      ),
    );
  }
}

class TabID extends StatefulWidget{
  @override
  _TabIDState createState() => _TabIDState();
}

class _TabIDState extends State<TabID> {
  final TextEditingController _nmController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _auController = TextEditingController();
  FocusNode _nmFocusNode = FocusNode();
  FocusNode _hpFocusNode = FocusNode();
  FocusNode _auFocusNode = FocusNode();
  String transNumber = "";

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    // TODO: implement build
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(3),
            child: ListView(
              children: [
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _nmController, focusNode: _nmFocusNode,
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: '이름', contentPadding: EdgeInsets.all(8),), //labelStyle: TextStyle(fontSize:20)
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: Stack(
                    children: [
                      Container(
                        width: 220,
                        child: TextField(
                          controller: _hpController, focusNode: _hpFocusNode,
                          decoration: InputDecoration(border: OutlineInputBorder(),labelText: '핸드폰 번호', hintText: '- 없이 숫자만 입력',contentPadding: EdgeInsets.all(8),),
                          inputFormatters: [MultiMaskedTextInputFormatter(masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'], separator: '-')],
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      Container(
                          height: ScreenUtil().setHeight(93),
                          padding: EdgeInsets.only(top: 0, left: 230, right: 0, bottom: 0),
                          child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                            child: Text('인증번호 전송',style: TextStyle(fontSize: 15, color: Colors.white) ),
                            onPressed: () {
                              String suname = _nmController.text.toString();
                              String suhp = _hpController.text.toString();

                              Map<String, String> data = {'SUName': suname,'SUHp': suhp};
                              String url = baseurl + 'user/find/id';
                              http.post(url, body: data).then((response) {
                                String jsonString = response.body;
                                if (response.statusCode == 200) {
                                  UserFind userfind = UserFind.fromJson(json.decode(jsonString));
                                  if (userfind.code == '00') {
                                    if (userfind.type == "O") {
                                      int min = 100000, max = 999999;
                                      while (transNumber.length != 6) {
                                        var max = 999999;
                                        transNumber = (min + Random().nextInt(max - min)).toString();
                                      }

                                      String phonnum = _hpController.text.toString();
                                      Future<String> msg = callSMSService(context, phonnum, transNumber);           //-- SMS 인증번호 전송처리
                                    } else {
                                      showAlertDialogOk(context,'이름과 전화번호가 일치하는 사원정보가 없습니다.');
                                    }
                                  }
                                }
                              });
                            },
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _auController, focusNode: _auFocusNode,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '인증번호',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                    height: ScreenUtil().setHeight(95),
                    padding: EdgeInsets.only(left: 3, top: 3, right: 3, ),
                    child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                      child: Text('아이디 확인',style: TextStyle(fontSize: 19, color: Colors.white) ),
                      onPressed: () {
                        var matchNumber = _auController.text.toString();
                        if (transNumber == matchNumber) {
                          String suname = _nmController.text.toString();
                          String suhp = _hpController.text.toString();

                          if (suname == '' || suname == Null ) {
                            FocusScope.of(context).requestFocus(_nmFocusNode);
                            showAlertDialog(context, '이름을 확인해 주세요');
                            return;
                          }
                          if (suhp == '' || suhp == Null) {
                            FocusScope.of(context).requestFocus(_hpFocusNode);
                            showAlertDialog(context, '휴대폰 번호를 확인해 주세요');
                            return;
                          }

                          Map<String, String> data = { 'SUName': suname, 'SUHp': suhp };
                          String url = baseurl + 'user/find/id';
                          http.post(url, body: data).then((response) {
                            String jsonString = response.body;
                            if (response.statusCode == 200) {
                              UserFind userfind = UserFind.fromJson(json.decode(jsonString));
                              if (userfind.code == '00' && userfind.type == "O") {
                                final suid = userfind.data.sUId;
                                String suidsub = suid.substring(0, suid.length - 2) + '**';
                                String suidmsg = '귀하의 아이디는 [$suidsub]입니다';
                                showAlertDialogOk(context, suidmsg);
                              } else {
                                showAlertDialogOk(context, '입력하신 정보와 일치하는 회원이 없습니다.');
                              }
                            } else {
                              showAlertDialogOk(context, '사원정보의 Server Connect Select 오류 발생.');
                            }
                          });
                        } else {
                          FocusScope.of(context).requestFocus(_auFocusNode);
                          showAlertDialogOk(context, '입력하신 인증번호가 전송된 인증번호와 일치하지 않습니다.');
                        }
                      },
                    )
                ),
              ],
            )
        )
    );
  }
}

class TabPW extends StatefulWidget{
  @override
  _TabPWState createState() => _TabPWState();
}

class _TabPWState extends State<TabPW> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nmController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _auController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pkController = TextEditingController();

  bool _pwChange = false;
  String transNumber = "";

  Future<void> delAutoLoginFromSharedPrefs() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance(); // 인스턴스 생성
    setState(() {
      _prefs.remove("loginkey");
      _prefs.remove("loginid");
      _prefs.remove("loginpw");
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    // TODO: implement build
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(3),
            child: ListView(
              children: [
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: '아이디',contentPadding: EdgeInsets.all(8),  ),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _nmController,
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: '이름',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: Stack(
                    children: [
                      Container(
                        width: 220,
                        child: TextField(
                          controller: _hpController,
                          decoration: InputDecoration(border: OutlineInputBorder(),labelText: '핸드폰 번호',hintText: '- 없이 숫자만 입력',contentPadding: EdgeInsets.all(8),),
                          inputFormatters: [MultiMaskedTextInputFormatter(masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'], separator: '-')],
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      Container(
                          height: ScreenUtil().setHeight(93),
                          padding: EdgeInsets.only(top: 0, left: 230, right: 0, bottom: 0),
                          child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                            child: Text('인증번호 전송',style: TextStyle(fontSize: 15, color: Colors.white) ),
                            onPressed: () {
                              String suname = _nmController.text.toString();
                              String suhp = _hpController.text.toString();
                              String suid = _idController.text.toString();

                              Map<String, String> data = {'SUName': suname,'SUHp': suhp, 'SUId': suid};
                              String url = baseurl + 'user/find';
                              http.post(url, body: data).then((response) {
                                String jsonString = response.body;
                                if (response.statusCode == 200) {
                                  UserFind userfind = UserFind.fromJson(json.decode(jsonString));
                                  if (userfind.code == '00') {
                                    if (userfind.type == "O") {
                                      int min = 100000, max = 999999;
                                      while (transNumber.length != 6) {
                                        var max = 999999;
                                        transNumber = (min + Random().nextInt(max - min)).toString();
                                      }

                                      String phonnum = _hpController.text.toString();
                                      Future<String> msg = callSMSService(context, phonnum, transNumber);   //SMS 인증번호 전송처리
                                    } else {
                                      showAlertDialogOk(context,'이름과 전화번호가 일치하는 사원정보가 없습니다.');
                                    }
                                  }
                                }
                              });
                            },
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _auController,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '인증번호',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                    height: ScreenUtil().setHeight(95),
                    padding: EdgeInsets.only(left: 4, top: 3, right: 4, ),
                    child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                      child: Text('비밀번호 확인',style: TextStyle(fontSize: 19, color: Colors.white) ),
                      onPressed: () {
                        setState(() { _pwChange = false; });
                        var matchNumber = _auController.text.toString();
                        if (transNumber == matchNumber) {
                          String usid = _idController.text.toString();
                          String suname = _nmController.text.toString();
                          String suhp = _hpController.text.toString();

                          Map<String, String> data = {'SUName': suname,'SUHp': suhp, 'SUId':usid};
                          String url = baseurl + 'user/find';
                          http.post(url, body: data).then((response) {
                            if(response.statusCode == 200) {
                              final result = json.decode(response.body);
                              if (result['code'] == '00' && result['type'] == 'O') {
                                setState(() { _pwChange = true;});
                              } else {
                                showAlertDialogOk(context, '입력하신 정보와 일치하는 회원이 없습니다.');
                              }
                            } else {
                              showAlertDialogOk(context, '사원정보의 Server Connect Select 오류 발생.');
                            }
                          });
                        } else {
                          showAlertDialogOk(context, '입력하신 인증번호가 전송된 인증번호와 일치하지 않습니다.');
                        }
                      },
                    )
                ),
                _pwChange ? Container(height: 10,color: Colors.white,) : SizedBox(),
                _pwChange ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 4, top: 3, right: 4, ),
                  height: ScreenUtil().setHeight(95), color: Colors.white, //getColorFromHex('303C4A'),
                  child:
                  Text("비밀번호 수정 화면", style: TextStyle(fontSize: 19, color: Colors.red, fontWeight: FontWeight.bold)),
                ) : SizedBox(),
                _pwChange ? Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _pwController, obscureText: true,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '새비밀번호',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.number,
                  ),
                ) : SizedBox(),
                _pwChange ? Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _pkController, obscureText: true,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '비밀번호 확인',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.number,
                  ),
                ) : SizedBox(),
                _pwChange ? Container(
                    height: ScreenUtil().setHeight(95),
                    padding: EdgeInsets.only(left: 4, top: 3, right: 4, ),
                    child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                        child: Text('비밀번호 변경',style: TextStyle(fontSize: 19, color: Colors.white) ),
                        onPressed: () {
                          if (_pwController.text.toString() != _pkController.text.toString()) {
                            showAlertDialogOk(context, '비밀번호가 일치하지 않습니다.');
                          } else {
                            String suid = _idController.text.toString();
                            String supw = _pwController.text.toString();
                            String sunewpw = _pkController.text.toString();

                            Map<String, String> data = {'SUId': suid, 'SUPw': supw,'SUNewPw': sunewpw, 'findPwYN':'Y'};
                            String url = baseurl + 'user/new/pw';
                            http.post(url, body: data).then((response) async {
                              String jsonString = response.body;
                              if (response.statusCode == 200) {
                                UserNewPw usernewpw = UserNewPw.fromJson(json.decode(jsonString));
                                if (usernewpw.code == '00' && usernewpw.type == 'O') {
                                  if (usernewpw.data.result == 'Y') {

                                    String msg = '비밀번호가 변경 되었습니다. \n 초기화면으로 이동합니다.';
                                    String action = await showAlertDialogOkConfirm(context, msg);
                                    if (action == 'OK') {
                                      delAutoLoginFromSharedPrefs(); //--Local DB 삭제
                                      globalValuClear();  //Global 변수 초기화 처리
                                      Phoenix.rebirth(context);     //재실행 처리(기존 push 되어있는 widget 삭제를 위해)
                                    }
                                  } else {
                                    showAlertDialogOk(context, usernewpw.message );
                                  }
                                } else {
                                  showAlertDialogOk(context, usernewpw.message );
                                }
                              }
                            });
                          }
                        }
                    )
                ) : SizedBox(),
              ],
            )
        )
    );
  }
}

class UserFind {
  String code;
  String type;
  String message;
  UserFindData data;

  UserFind({this.code, this.type, this.message, this.data});

  UserFind.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    data = json['data'] != null ? new UserFindData.fromJson(json['data']) : null;
  }
}
class UserFindData {
  String sUId;
  String sUStaffAPPUseYN;

  UserFindData({this.sUId, this.sUStaffAPPUseYN});

  UserFindData.fromJson(Map<String, dynamic> json) {
    sUId = json['SUId'];
    sUStaffAPPUseYN = json['SUStaffAPPUseYN'];
  }
}


class UserNewPw {
  String code;
  String type;
  String message;
  UserNewPwData data;

  UserNewPw({this.code, this.type, this.message, this.data});
  UserNewPw.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    data = json['data'] != null ? new UserNewPwData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['type'] = this.type;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}
class UserNewPwData {
  String result;
  UserNewPwData({this.result});

  UserNewPwData.fromJson(Map<String, dynamic> json) {
    result = json['Result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Result'] = this.result;
    return data;
  }
}
