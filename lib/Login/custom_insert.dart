import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Login/custom_picture.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

int _tabIndex = 0;
TabController _tabController;
String set_SUId = '', set_SUPw = '', set_STNameKor = '', set_SUHp = '', set_STJuso = '', set_STEMail = '', set_SCDBName = '';
String set_SCHostIp = '', set_STMobileKey = '', set_SCCode = '', set_CCode = '', set_SSCode = '', set_STJJCode = '';
String set_STJCode = '', set_STBCode = '', set_STCode = '', set_STSex = '', set_SCName = '';
String findhpSave = '', findSTCodeSave = '', findJusoSave = '', findEmailSave = '';

void initVariable() {
  findhpSave = '';
  findSTCodeSave = '';
  findJusoSave = '';
  findEmailSave = '';
}

class Custom_Insert extends StatefulWidget {
  @override
  _Custom_InsertState createState() => _Custom_InsertState();
}

class _Custom_InsertState extends State<Custom_Insert> with SingleTickerProviderStateMixin {
  bool isActive = true;

  void initState() {
    super.initState();
    initVariable();
    _tabController = new TabController(vsync: this, length: 2, initialIndex: 0);
  }


  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '회원가입',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        initialIndex:_tabIndex,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: getColorFromHex('303C4A'),
              elevation: 0,
              centerTitle: true,
              title: Text('회원가입', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,)),
            ),
            body: Column(
                children: [
                  Container(
                    height: 40,
                    color: getColorFromHex('303C4A'),
                    child: TabBar(
                        controller: _tabController,
                        unselectedLabelColor: Colors.blueAccent,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.blueAccent),
                        onTap: (index) {
                          setState(() {
                           _tabController.index = _tabIndex;
                          });
                        },
                        tabs: [
                          Tab( child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.blueAccent, width: 1)),
                            child: Align(alignment: Alignment.center,
                              child: Text("정보 조회", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),),),),
                          Tab(child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.blueAccent, width: 1)),
                            child: Align(alignment: Alignment.center,
                              child: Text("정보 입력", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),),),),
                        ]),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: <Widget>[
                        InfSearch(),
                        InfInsert(),
                      ],
                    ),
                  ),
                ]
            )
        ),
      ),
    );
  }
}

//--정보 저장
class InfInsert extends StatefulWidget {
  @override
  _InfInsertState createState() => _InfInsertState();
}

class _InfInsertState extends State<InfInsert> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pkController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _emController = TextEditingController();
  final TextEditingController _jsController = TextEditingController();

  FocusNode _idFocusNode = FocusNode();
  FocusNode _pwFocusNode = FocusNode();
  FocusNode _pkFocusNode = FocusNode();
  FocusNode _hpFocusNode = FocusNode();

  String transNumber = "0";
  bool _btnVisible = false, _idchkmsg = false, _pwmatchkmsg = true;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    // TODO: implement build
    if (findSTCodeSave != null && findSTCodeSave != '' && findSTCodeSave.length > 0) {
      set_STCode = findSTCodeSave;
    }
    if (findhpSave != null && findhpSave != '' && findhpSave.length > 0) {
      _hpController.text = findhpSave;
    }
    if (findJusoSave != null && findJusoSave != '' && findJusoSave.length > 0) {
      _jsController.text = findJusoSave;
    }
    if (findEmailSave != null && findEmailSave != '' && findEmailSave.length > 0) {
      _emController.text = findEmailSave;
    }
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(3),
            child: ListView(
              children: [
                _idinputForm(context),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField( controller: _pwController, focusNode: _pwFocusNode, obscureText: true,
                    decoration: InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.star , color: Colors.red, size: 14,),
                      labelText: '비밀번호',hintText: '비밀번호(최대16자)', contentPadding: EdgeInsets.all(8),  ),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: Stack(
                      children: [
                        TextField( controller: _pkController, focusNode: _pkFocusNode, obscureText: true,
                            decoration: InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.star , color: Colors.red, size: 14,),
                              labelText: '비밀번호 확인',contentPadding: EdgeInsets.all(8),  ),
                            keyboardType: TextInputType.name,
                            onChanged: (text) {
                              if (_pwController.text.toString() == _pkController.text.toString()) {
                                setState(() { _pwmatchkmsg = false; });
                              } else {
                                FocusScope.of(context).requestFocus(_pkFocusNode);
                                setState(() { _pwmatchkmsg = true; });
                              }
                            }
                        ),
                        Container( alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(top: 20, left: 170, right: 2, bottom: 1),
                            child: _pwmatchkmsg ? Text('비밀번호가 일치하지 않습니다.', style: TextStyle(color: Colors.red),): Text('')
                        )
                      ]
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _hpController, focusNode: _hpFocusNode,
                    decoration: InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.star , color: Colors.red, size: 14,),
                      labelText: '휴대폰 번호',hintText: '- 없이 숫자만 입력',contentPadding: EdgeInsets.all(8),),
                    inputFormatters: [MultiMaskedTextInputFormatter(
                        masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'], separator: '-')],
                    keyboardType: TextInputType.number,
                    onTap: () {
                      setState(() {
                        int hpLength = _hpController.text.toString().trim().length;
                        if(hpLength > 6) {
                          _btnVisible = true;
                        }
                      });
                    },
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _emController,
                    decoration: InputDecoration(border: OutlineInputBorder(),
                      labelText: '이메일',hintText: '이메일',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.all(3),
                  child: TextField(
                    controller: _jsController,
                    decoration: InputDecoration(border: OutlineInputBorder(),
                      labelText: '거주지 주소',hintText: '주소입력',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(height: ScreenUtil().setHeight(95),
                    padding: EdgeInsets.only(top: 3, left: 3, right: 3, ),
                    child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                      child: Text('확인',style: TextStyle(fontSize: 18, color: Colors.white) ),
                      onPressed: () async {
                        //--입력 데이터 체크 처리
                        String idinput = _idController.text.toString().trim();
                        String pwinput = _pwController.text.toString().trim();
                        String hpinput = _hpController.text.toString().trim();

                        if (idinput == '' || idinput == Null || _idchkmsg == true) {
                          FocusScope.of(context).requestFocus(_idFocusNode);
                          showAlertDialogOk(context, '아이디를 확인해 주세요');
                        } else if (pwinput == '' || pwinput == Null || _pwmatchkmsg == true) {
                          FocusScope.of(context).requestFocus(_pwFocusNode);
                          showAlertDialogOk(context, '비밀번호를 확인해 주세요');
                        } else if (hpinput == '' || hpinput == Null) {
                          FocusScope.of(context).requestFocus(_hpFocusNode);
                          showAlertDialogOk(context, '휴대폰 번호를 확인해 주세요');
                        } else {
                          String msg = '회원가입을 완료하시겠습니까?';
                          String action = await showAlertDialogOkCancel(context, msg);
                          if (action == 'OK') {
                            //--신규직원 사원등록
                            set_SUId = idinput;
                            set_SUPw = pwinput;
                            set_SUHp = hpinput;
                            set_STJuso = _jsController.text.toString();
                            set_STEMail = _emController.text.toString();

//                          set_CCode(국적), set_SSCode(체류자격), set_STJJCode(지점), set_STJCode(직급), set_STBCode(부서)

                            DateTime now = DateTime.now();
                            final DateFormat formatter = DateFormat('yyyy-MM-dd');
                            final String todayformat = formatter.format(now);
                            print(todayformat);

                            Map<String, String> data = {
                              "SUId" : set_SUId, "SUPw" : set_SUPw, "STNameKor" : set_STNameKor,
                              "SUHp" : set_SUHp, "STJuso" : set_STJuso, "STEMail" : set_STEMail,
                              "SCDBName" : set_SCDBName, "SCHostIp" : set_SCHostIp,  "STMobileKey" : set_STMobileKey,
                              "SCCode" : set_SCCode, "CCode" : set_CCode, "SSCode" : set_SSCode,
                              "STInDate" : todayformat, "STJJCode" : set_STJJCode, "STJCode" : set_STJCode,
                              "STBCode" : set_STBCode, "STCode" : set_STCode, "STSex" : set_STSex};

                            String url = baseurl + 'user/new';
                            http.post(url, body: data).then((response) async {
                              String jsonString = response.body;
                              print(response.statusCode);
//                              showAlertDialogOk(context, '신규가입 /사원정보 매칭은 현재 처리되지 않습니다.');
                              if (response.statusCode == 200) {
                                print(jsonString);
                                CustomJoin customjoin = CustomJoin.fromJson(json.decode(jsonString));
                                if (customjoin.code == '00' && customjoin.type == 'O') {
                                  if (customjoin.data.result == '11') {         //신규가입 일경우
                                    String msg = '회원가입이 완료되었습니다. \n사진을 업로드 하시겠습니까?.';
                                    String action = await showAlertDialogOkCancel(context, msg);
                                    if (action == 'OK') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Picture()),);
                                    } else {
                                      Phoenix.rebirth(context);     //-재시행
                                    }
                                  } else if (customjoin.data.result == '21') {  //기존가입자 일경우
                                    // showAlertDialogOk(context, '사원정보 매칭이 완료되었습니다. \n 가입 승인 후 로그인 가능합니다.');
                                    //--사진저장으로 이동
                                    // _tabIndex = _tabController.index + 1;
                                    // _tabController.animateTo(_tabIndex);
                                    String msg = '사원정보 매칭이 완료되었습니다. \n사진을 업로드 하시겠습니까?.';
                                    String action = await showAlertDialogOkCancel(context, msg);
                                    if (action == 'OK') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Picture()),);
                                    } else {
                                      Phoenix.rebirth(context);     //-재시행
                                    }
                                  } else {
                                    String tempMsg = customjoin.message;
                                    showAlertDialogOk(context, tempMsg);
                                  }
                                } else {
                                  String tempMsg = customjoin.message;
                                  showAlertDialogOk(context, tempMsg);
                                }
                              }
                            });
                          }
                        }
                      },)
                ),
              ],
            )
        )
    );
  }

  Widget _idinputForm(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(95),
      padding: EdgeInsets.all(3),
      child: Stack(
          children: [
            TextField(
              controller: _idController,
              focusNode: _idFocusNode,
              decoration: InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.star , color: Colors.red, size: 14,),
                labelText: '아이디',hintText: '아이디 범위(3 ~ 16자)',contentPadding: EdgeInsets.all(6),),
              keyboardType: TextInputType.name,
              onChanged: (text) {
                if (text == null || text.isEmpty) {
                  FocusScope.of(context).requestFocus(_idFocusNode);
                  showAlertDialogOk(context, '아이디를 확인해 주세요');
                } else if (text.length.toString().trim().length > 15) {
                  FocusScope.of(context).requestFocus(_idFocusNode);
                  showAlertDialogOk(context, '아이디는 최대 16자 입니다.');
                } else {
                  Map<String, String> data = {'SUId': text};
                  String url = baseurl + 'user/valid';
                  http.post(url, body: data).then((response) {
                    String jsonString = response.body;
                    print(response.statusCode);
                    if (response.statusCode == 200) {
                      print(jsonString);
                      IdCheck idcheck = IdCheck.fromJson(json.decode(
                          jsonString));
                      if (idcheck.code == '00') {
                        if (idcheck.type == 'N'){
                          if (idcheck.message != "true"){
                            setState(() { _idchkmsg = true;});
                          } else {
                            setState(() { _idchkmsg = false;});
                            return null;
                          }
                        }
                      }
                    }
                  });
                }
              },
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 20, left: 220, right: 2, bottom: 1),
                child: _idchkmsg ? Text('이미 사용중인 아이디 입니다.', style: TextStyle(fontSize: 11, color: Colors.red),): Text('')
            )
          ]
      ),
    );
  }
}

//--정보 입력
class InfSearch extends StatefulWidget {
  @override
  _InfSearchState createState() => _InfSearchState();
}

class _InfSearchState extends State<InfSearch> {
  var maskSaupJang = new MaskTextInputFormatter(mask: '###-##-#####', filter: { "#": RegExp(r'[0-9]') });
  final TextEditingController _saupController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  FocusNode _saupFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _birthFocusNode = FocusNode();

  int _groupValue = -1;
  bool _checkValue = false, _btnVisible = false, _saupEqual = true, _hpChoiceVisible = false, _hpChoiceValue = false;
  bool _existCustomer = false;
  String findhandphone = '', findSTCode = '', findjuso = '', findEmail  = '';
  DateTime _date = DateTime.now();

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1920),
      lastDate: DateTime(2200),);
    if (picked != null && picked != _date ) {
      setState(() {
        _date = picked;
        _birthController.text = picked.toString().substring(0, 10 );
        String temp = _birthController.text.toString().trim();
        temp = temp.substring(2, 4) + temp.substring(5, 7) + temp.substring(8, 10);
        set_STMobileKey = temp;
        USER_INFO_STMobileKey = set_STMobileKey;
      });
    }
  }

  Future<void> _handleRadioValueChanged(int value) async {
    setState(() {this._groupValue = value;});
    if (value == '0') {
      set_STSex = 'M';
    } else {
      set_STSex = 'W';
    }
    USER_INFO_STSex = set_STSex;

    set_STNameKor = _nameController.text.toString().trim();
    if (set_STNameKor == '' || set_STNameKor == null) {
      return;
    }
    USER_INFO_SUName = set_STNameKor;

    String tempBirthday = _birthController.text.toString().trim();
    if (tempBirthday == '' || tempBirthday == null) {
      return;
    }

    // set_STMobileKey= '900909';
    // USER_INFO_STMobileKey = '900909';

    Map<String, String> data = {
      'STNameKor': set_STNameKor,
      'STMobileKey': set_STMobileKey,
      'SCDBName': set_SCDBName,
      'SCHostIp': set_SCHostIp,
      'STSex': set_STSex,
      'SCCode': set_SCCode
    };

    String url = baseurl + 'staff/valid';
    _hpChoiceVisible = false;
    _existCustomer = false;
    print('data ===> $data');
    await http.post(url, body: data).then((response) {
      String jsonString = response.body;
      print('jsonString ===> $jsonString');
      if (response.statusCode == 200) {
        StaffJoinCheck staffjoincheck = StaffJoinCheck.fromJson(json.decode(jsonString));

        if (staffjoincheck.code == '00') {
          if (staffjoincheck.message == 'Result is Empty') {
            //-- 조회된 데이터가 없는 경우 SKIP
          } else {
            if (staffjoincheck.data.length > 0) {
              if (staffjoincheck.data[0].sTTel != 'undefined') {
                setState(() {
                  _hpChoiceVisible = true;
                }); //-- 있으면 핸드폰 번호가 보이도록 처리
                findSTCode = staffjoincheck.data[0].sTCode;
                findhandphone = staffjoincheck.data[0].sTTel;
                findjuso = staffjoincheck.data[0].sTJuso;
                findEmail = staffjoincheck.data[0].sTEMail;
              }
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    final Size size = MediaQuery.of(context).size;
    // _nameController.text = '홍길동';
    // _birthController.text = '1990-09-09';
    return Scaffold(
        body: Padding(padding: EdgeInsets.all(3),
            child: ListView(
              children: [
                _saupjangInputForm(context),
                Container(padding: EdgeInsets.all(3),
                  height: ScreenUtil().setHeight(95),
                  child: TextField(
                    controller: _nameController, focusNode: _nameFocusNode,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '이름',contentPadding: EdgeInsets.all(8),),
                    keyboardType: TextInputType.name,
                  ),
                ),
                Container(padding: EdgeInsets.all(3),
                  height: ScreenUtil().setHeight(95),
                  child: TextFormField(
                    controller: _birthController, focusNode: _birthFocusNode,
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: '생년 월일',contentPadding: EdgeInsets.all(8),),
//                  inputFormatters: [MultiMaskedTextInputFormatter(masks: ['xx.xx.xx', 'xxxx.xx.xx'], separator: '.')],
                    keyboardType: TextInputType.datetime,
                    onTap: () {
                      selectDate(context);
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    validator: ((val) {
                      if (val.trim().isEmpty) {
                        return "Select Brith Date";
                      }
                      return null;
                    }),
                  ),
                ),
                Container(
                    width: size.width / 0.1,
                    height: 30,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    padding: EdgeInsets.only(top: 0, left: 20, right: 0, bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Text('성별', style: TextStyle(fontSize: 16.0, ), ), //fontWeight: FontWeight.bold
                        Container(width: 27,),
                        Transform.scale(scale: 1.4,child: Radio( value: 0, groupValue: _groupValue, onChanged: _handleRadioValueChanged)),
                        Text( "남성", style: TextStyle( fontSize: 18.0,),),
                        Transform.scale(scale: 1.4,child: Radio( value: 1,  groupValue: _groupValue,  onChanged: _handleRadioValueChanged)),
                        Text( "여성", style: TextStyle( fontSize: 18.0,),),
                      ],
                    )
                ),
                _hpChoiceVisible ? Container(
                  alignment: Alignment.center,
                  height: ScreenUtil().setHeight(95), color: Colors.white, //getColorFromHex('303C4A'),
//                  padding: EdgeInsets.fromLTRB(150, 0, 10, 0),  //left, top, right, bottom
                  child:
                  Text("등록된 휴대폰 번호 선택", style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                ) : SizedBox(),
                _hpChoiceVisible ? Container(
                  height: ScreenUtil().setHeight(95), color: getColorFromHex('303C4A'),
                  padding: EdgeInsets.only(left: 4, top: 3, right: 4,),
                  alignment: Alignment.center,
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularCheckBox(
                          value: _hpChoiceValue,
                          activeColor: Colors.red,
                          inactiveColor: Colors.white,
                          hoverColor: Colors.red,
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          onChanged: (bool x) {
                            setState(() {_hpChoiceValue = !_hpChoiceValue;});
                            print("_hpChoiceValue ==> $_hpChoiceValue");
                            if(_hpChoiceValue == true) {
                              //-- 핸드폰 번호 선택시 처리
                              findSTCodeSave = findSTCode;
                              findhpSave = findhandphone;
                              findJusoSave = findjuso;
                              findEmailSave = findEmail;

                              String suName = _nameController.text.toString().trim();
                              Map<String, String> data = {"SUName": suName, "SUHp": findhandphone};
                              String url = baseurl + 'user/find/id';
                              http.post(url, body: data).then((response) {
                                String jsonString = response.body;
                                print(jsonString);
                                if (response.statusCode == 200) {
                                  UserFind userfind = UserFind.fromJson(json.decode(jsonString));
                                  if (userfind.type != 'N') {
                                    showAlertDialogOk(context, '이미 아이디가 존재합니다. \n아이디 찾기를 이용해 주세요.');
                                    _existCustomer = true;
                                  }
                                }
                              });
                            } else {
                              initVariable();
                            }
                          }),
                      Text(findhandphone, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ) ,
                ): SizedBox(),
                Container(
                  height: ScreenUtil().setHeight(95),
                  padding: EdgeInsets.fromLTRB(5, 0, 10, 0),  //left, top, right, bottom
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularCheckBox(
                        value: _checkValue,
                        activeColor: getColorFromHex('303C4A'),
                        inactiveColor: getColorFromHex('303C4A'),
                        hoverColor: getColorFromHex('303C4A'),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onChanged: (bool x) {
                          setState(() {
                            _checkValue = !_checkValue;
                            if(_checkValue == true) {
                              showConsentDialog(context);
                              _btnVisible = true;
                            }
                          });
                        }
                    ),
                      Text("개인 정보 제공 동의[내용보기]", style: TextStyle(fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                Container(height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 4),
                    child: _btnVisible ? RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                      child: _hpChoiceValue ? Text('기존사원 가입',style: TextStyle(fontSize: 18, color: Colors.white)) :
                      Text('신규사원 가입',style: TextStyle(fontSize: 18, color: Colors.white)),
                      onPressed: () {
                        //--입력 데이터 체크 처리
                        String saupjang = _saupController.text.toString().trim();
                        String custname = _nameController.text.toString().trim();
                        String birtyday = _birthController.text.toString().trim();
                        if (saupjang == '' || saupjang == Null || _saupEqual == true) {
                          FocusScope.of(context).requestFocus(_saupFocusNode);
                          showAlertDialogOk(context, '사업장을 확인해 주세요');
                        } else if (custname == '' || custname == Null) {
                          FocusScope.of(context).requestFocus(_nameFocusNode);
                          showAlertDialogOk(context, '이름을 확인해 주세요');
                        } else if(_groupValue == -1) {
                          showAlertDialogOk(context, '성별을 확인해 주세요');
                        } else if (birtyday == '' || birtyday == Null) {
                          FocusScope.of(context).requestFocus(_birthFocusNode);
                          showAlertDialogOk(context, '생년월일을 확인해 주세요');  //남성:M, 여성:W
                        } else if (_checkValue == false) {
                          showAlertDialogOk(context, '개인정보 수집 동의를 확인해 주세요');
                        } else if (_existCustomer == true) {
                          showAlertDialogOk(context, '이미 아이디가 존재합니다. \n아이디 찾기를 이용해 주세요.');
                        } else {
                          //--정보입력으로 이동
                          _tabIndex = _tabController.index + 1;
                          _tabController.animateTo(_tabIndex);
                        }
                      },) : SizedBox()
                ),
                _btnVisible ? Container(
                  alignment: Alignment.center,
                  height: ScreenUtil().setHeight(95), color: Colors.transparent,
//                  padding: EdgeInsets.fromLTRB(150, 0, 10, 0),  //left, top, right, bottom
                  child:
                  Text("아이디/비밀번호설정 후 로그인 가능합니다.", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                ) : SizedBox(),
              ],
            )
        )
    );
  }

  Widget _saupjangInputForm(BuildContext context) {
    return Container(padding: EdgeInsets.all(3),
      height: ScreenUtil().setHeight(95),
      child: Stack (
          children : [
            TextField(
                controller: _saupController, focusNode: _saupFocusNode,
                decoration: InputDecoration(border: OutlineInputBorder(),
                  labelText: '사업자 번호',hintText: '- 없이 숫자만 입력', contentPadding: EdgeInsets.all(8),),
                inputFormatters: [maskSaupJang,LengthLimitingTextInputFormatter(30)],
                keyboardType: TextInputType.number,
                onChanged:(text) {
                  var saupjang = _saupController.text.toString();
                  print(" 사업장 == > $saupjang");
                  if (saupjang.length == 12 ){
                    Map<String, String> data = {'SCSaupNum': saupjang};
                    String url = baseurl + 'company/valid';
                    http.post(url, body: data).then((response) {
                      String jsonString = response.body;
                      print(response.statusCode);
                      if (response.statusCode == 200) {
                        print(jsonString);
                        SaupJangCheck saupjangchk = SaupJangCheck.fromJson(json.decode(jsonString));
                        if (saupjangchk.code == '00' && saupjangchk.type == 'O') {
                          setState(() { _saupEqual = false; });
                          set_SCCode = saupjangchk.data.sCCode;
                          set_SCName = saupjangchk.data.sCName;
                          set_SCHostIp = saupjangchk.data.sCHostIp;
                          set_SCDBName = saupjangchk.data.sCDBName;

                          USER_INFO_SCCode = set_SCCode;
                          USER_INFO_SCHostIp = set_SCHostIp;
                          USER_INFO_SCDBName = set_SCDBName;

                        } else {
                          FocusScope.of(context).requestFocus(_saupFocusNode);
                          setState(() { _saupEqual = true; });
                        }
                      }
                    });
                  } else {
                    setState(() { _saupEqual = true; });
                  }
                }
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 20, left: 200, right: 2, bottom: 1),
                child: _saupEqual ? Text('일치하는 사업장이 없습니다.', style: TextStyle(fontSize: 11, color: Colors.red),): Text('')
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 20, left: 200, right: 2, bottom: 1),
                child: _saupEqual ? Text(''): Text(set_SCName, style: TextStyle(color: Colors.blue),)
            )
          ]
      ),
    );
  }

  List<Widget> getConsent(){
    return consentList.map((x){
//      return Padding(padding: EdgeInsets.all(8.0),
      return Padding(padding: EdgeInsets.only(top: 10, left: 5, right: 0, bottom: 10),
        child: Row(children: <Widget>[
//             Icon(Icons.supervisor_account),
          Text(x, style: TextStyle(fontSize: 12),)
        ]),
      );
    }).toList();
  }

  void showConsentDialog(BuildContext context) async{
    showDialog( context: context,
        builder: (BuildContext context) {
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10);
          return AlertDialog(
            titlePadding: EdgeInsets.all(10.0),
//            contentPadding: EdgeInsets.all(0.0),
            contentPadding: EdgeInsets.fromLTRB(1, 0, 1, 0),
            title: Text("개인정보 이용 안내"),
            content: Container(
              width: MediaQuery.of(context).size.width ,
//          width = device width minus insetPadding = deviceWidth - 20  (left:10, right:10 = 20)
              height: MediaQuery.of(context).size.height,
//          height = device height minus insetPadding = deviceHeight - 20  (top:10, bottom:
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(height: 1.0, color: Colors.grey, ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getConsent()
                        ),
                      ),
                    ),

                    Divider(color: Colors.grey,height: 1.0,),
                    Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 5.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              color: getColorFromHex('303C4A'),
                              textColor: Colors.white,
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0), topLeft: Radius.circular(4.0))),
                              child: Text("OK"),
                              onPressed: () { Navigator.pop(context); },
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
              ),
            ),
          );
        }
    );
  }

  final List<String> consentList = [
    '''본인은 [(주)다옴아이티](이하 ‘회사’라 합니다)가 
제공하는 본인확인서비스(이하 ‘서비스’라 합니다)를 
이용하기 위해, 다음과 같이 ‘회사’가 본인의 개인정보를 
수집/이용하고, 개인정보의 취급을 위탁하는 것에 
동의합니다.\n''',
    '''1. 수집항목 이용자의 성명, 이동전화번호,가입한 
이동전화 고유관리번호, 생년월일, 성별, 주소, 
내외국인 여부\n''',
    '''본인은 [(주)다옴아이티](이하 ‘회사’라 합니다)가 
제공하는 본인확인서비스(이하 ‘서비스’라 합니다)를 
이용하기 위해, 다음과 같이 ‘회사’가 본인의 개인정보를 
수집/이용하고, 개인정보의 취급을 위탁하는 것에 
동의합니다.\n''',
    '''2. 이용목적 이용자가 웹사이트 또는 Application에 
입력한 본인확인정보의 정확성 여부 확인(본인확인
서비스 제공) 해당 웹사이트 또는 Application에 연계 
정보(CI)/ 중복가입확인정보(DI) 전송 서비스 관련 상담
및 불만 처리 등 이용 웹사이트/Application 정보 등에
대한 분석 및 세분화를 통한, 이용자의 서비스 이용 
선호도 분석\n''',
    '''3. 개인정보의 보유기간 및 이용기간 이용자가 서비스를 
이용하는 기간에 한하여 보유 및 이용. 다만, 아래의 
경우는 제외 법령에서 정하는 경우 해당 기간까지 보유
(상세 사항은 회사의 개인정보취급방침에 기재된 바에 
따름)\n''',
    '''4. 본인확인서비스 제공을 위한 개인정보의 취급 위탁 
수탁자 : (주)다옴아이티, 노무법인 이노컨설팅, 
국세청, 4대보험공단, 취급 위탁 업무 : 
본인확인정보의 정확성 여부 확인(본인확인서비스 제공), 
인사/급여 업무수행을 위한 수탁자의 개인정보 취급방침
및 제3자 제공 동의 방침 등에 따릅니다.\n''',
    '''5. 위 개인정보 수집·이용 및 취급 위탁에 동의하지 
않으실 경우,서비스를 이용하실 수 없습니다. 회사가 
제공하는 서비스와 관련된 개인정보의 취급과 관련된 
사항은, 회사의 개인정보취급방침에 따릅니다.\n''',
    '''6. 개인정보의 보유 및 이용기간 이용자의 개인정보는 
원칙적으로 개인정보의 수집 및 이용목적이 달성되면 
지체없이 파기합니다. 단,다음의 정보에 대해서는 아래의 
이유로 명기한 기간 동안 보유합니다.\n''',
    '''가. 회사 내부 방침에 의한 정보 보유 사유 본인확인 
발생 및 차단 기록, 휴대폰번호 보유 이유 : 
본인확인정보의 정확성 여부 확인(본인확인서비스 제공), 
인사/급여 업무수행.\n\n''',
    '''보유 기간 : 퇴사 후5년까지'''];
}

class SaupJangCheck {
  String code, type, message;
  SaupJangData data;

  SaupJangCheck({this.code, this.type, this.message, this.data});

  SaupJangCheck.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    data = json['data'] != null ? new SaupJangData.fromJson(json['data']) : null;
  }
}

class SaupJangData {
  String sCCode, sCName, sCHostIp, sCDBName;

  SaupJangData({this.sCCode, this.sCName, this.sCHostIp, this.sCDBName});

  SaupJangData.fromJson(Map<String, dynamic> json) {
    sCCode = json['SCCode'];
    sCName = json['SCName'];
    sCHostIp = json['SCHostIp'];
    sCDBName = json['SCDBName'];
  }
}

class IdCheck {
  String code;
  String type;
  String message;

  IdCheck({this.code, this.type, this.message});

  IdCheck.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
  }
}


class StaffJoinCheck {
  String code, type, message;
  List<StaffJsonData> data;

  StaffJoinCheck({this.code, this.type, this.message, this.data});

  StaffJoinCheck.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<StaffJsonData>();
      json['data'].forEach((v) {
        data.add(new StaffJsonData.fromJson(v));
      });
    }
  }
}

class StaffJsonData {
  String sTMobileComeCheckType, sTCode, sTTel, sTJJCode, sTBCode, sTJCode;
  String sTInDate, sTCCode, sTJuso, sTEMail, sUStaffAPPUseYN, viewMessage;

  StaffJsonData({this.sTMobileComeCheckType, this.sTCode, this.sTTel, this.sTJJCode, this.sTBCode,
    this.sTJCode, this.sTInDate, this.sTCCode, this.sTJuso, this.sTEMail,
    this.sUStaffAPPUseYN,  this.viewMessage});

  StaffJsonData.fromJson(Map<String, dynamic> json) {
    sTMobileComeCheckType = json['STMobileComeCheckType'];
    sTCode = json['STCode'];
    sTTel = json['STTel'];
    sTJJCode = json['STJJCode'];
    sTBCode = json['STBCode'];
    sTJCode = json['STJCode'];
    sTInDate = json['STInDate'];
    sTCCode = json['STCCode'];
    sTJuso = json['STJuso'];
    sTEMail = json['STEMail'];
    sUStaffAPPUseYN = json['SUStaffAPPUseYN'];
    viewMessage = json['viewMessage'];
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


class CustomJoin {
  String code;
  String type;
  String message;
  CustomJoinData data;

  CustomJoin({this.code, this.type, this.message, this.data});

  CustomJoin.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    data = json['data'] != null ? new CustomJoinData.fromJson(json['data']) : null;
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

class CustomJoinData {
  String result;
  CustomJoinData({this.result});

  CustomJoinData.fromJson(Map<String, dynamic> json) {
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    return data;
  }
}
