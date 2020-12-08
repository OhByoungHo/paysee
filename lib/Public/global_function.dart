import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Join/root_page.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';

//SMS전송 처리
Future<String> callSMSService(BuildContext context, String handphone, String value) async{
  var msg = "(주) 라이페이롤 서비스 _ [인증번호] $value";
  String url = 'http://14.63.172.72/lineWeb/REST/SendSMS.php?ReceivePhone=$handphone&TextValue=$msg';
  http.get(url).then((response) {
    if(response.statusCode == 200){
      showAlertDialogOk(context, '$handphone 로 인증번호를 전송하였습니다.');
      return 'OK';
    } else {
      showAlertDialogOk(context, '$handphone 로 인증번호를 전송에 실패하였습니다. 잠시후 다시 시도해 주시기 바랍니다.');
      return 'XX';
    }
  });
}

Future wait(int seconds) {
  return new Future.delayed(Duration(seconds: seconds), () => {});
}

Future<void> globalValueSet(UserInfo userinfo) async {
  USER_INFO_SCCode = userinfo.SCCode;
  USER_INFO_SCHostIp = userinfo.SCHostIp;
  USER_INFO_SCDBName = userinfo.SCDBName;
  USER_INFO_SUJJCode = userinfo.SUJJCode;
  USER_INFO_SCGroupwareYN = userinfo.SCGroupwareYN;
  USER_INFO_SCPayAdminSUCode = userinfo.SCPayAdminSUCode;
  USER_INFO_SCPayAdminSUName = userinfo.SCPayAdminSUName;
  USER_INFO_SCAccountAdminSUName = userinfo.SCAccountAdminSUName;
  USER_INFO_SCAccountAdminSUCode = userinfo.SCAccountAdminSUCode;
  USER_INFO_SCBeaconMajor = userinfo.SCBeaconMajor;
  USER_INFO_SCBeaconUUID = userinfo.SCBeaconUUID;
  USER_INFO_SCMobileOpenTime = userinfo.SCMobileOpenTime;
  USER_INFO_SCBeaconYN = userinfo.SCBeaconYN;
  USER_INFO_SCGpsYN = userinfo.SCGpsYN;
  USER_INFO_SUSTCode = userinfo.SUSTCode;
  USER_INFO_SUCode = userinfo.SUCode;
  USER_INFO_SUName = userinfo.SUName;
  USER_INFO_SULevel = userinfo.SULevel;
  USER_INFO_Token = userinfo.Token;
  USER_INFO_SCCoordinate = userinfo.SCCoordinate;
  USER_INFO_SCYenchaGubun = userinfo.SCYenchaGubun;
  USER_INFO_SWYenchaBase = userinfo.SWYenchaBase;
//  String USER_INFO_STSex = userinfo.

  print('USER_INFO_SCPayAdminSUCode ==> $USER_INFO_SCPayAdminSUCode');
  print('USER_INFO_SCPayAdminSUName ==> $USER_INFO_SCPayAdminSUName');
  print('USER_INFO_SCAccountAdminSUName ==> $USER_INFO_SCAccountAdminSUName');
  print('USER_INFO_SCAccountAdminSUCode ==> $USER_INFO_SCAccountAdminSUCode');

  print('USER_INFO_SUName ==> $USER_INFO_SUName');
  print('USER_INFO_SCDBName ==> $USER_INFO_SCDBName');
  print('USER_INFO_SCHostIp ==> $USER_INFO_SCHostIp');
  print('USER_INFO_SCCode ==> $USER_INFO_SCCode');
  print('USER_INFO_SUJJCode ==> $USER_INFO_SUJJCode');
  print('USER_INFO_SUSTCode ==> $USER_INFO_SUSTCode');
  print('USER_INFO_SCCoordinate ==> $USER_INFO_SCCoordinate');
  print('USER_INFO_SCBeaconUUID ==> $USER_INFO_SCBeaconUUID');
  print('USER_INFO_SCBeaconMajor ==> $USER_INFO_SCBeaconMajor');

  if (USER_INFO_SUSTCode == '' || USER_INFO_SCDBName == '') {
    //사원코드가 없는 경우 신규 회원가입으로 간주
    USER_INFO_newSignUp = true;
  } else {
    if (USER_INFO_SUSTCode != '') {
      gsNoSTCode = true;
    } else {
      gsNoSTCode = false;
    }

    if (USER_INFO_SCCode == '0500000000') {
      if (USER_INFO_SULevel == '0' || USER_INFO_SULevel == '100' ||
          USER_INFO_SULevel == '120') {
        gsUser = false; //--매니저
      } else {
        gsUser = true;
      }
    } else {
      if (USER_INFO_SULevel == '1010') {
        gsUser = true; //-- 일반사원
      } else {
        gsUser = false; //-- 매니저
        if (USER_INFO_SULevel == '1003' || USER_INFO_SULevel == '1006' || USER_INFO_SULevel == '903') {
          gsPayMgr = false;
        } else {
          gsPayMgr = true;
        }
      }
      //--일반사원을 제외한 계정 GPS 설정 오픈
      if (USER_INFO_SULevel == '900'  || USER_INFO_SULevel == '901'  || USER_INFO_SULevel == '902'  ||
          USER_INFO_SULevel == '903'  || USER_INFO_SULevel == '904'  || USER_INFO_SULevel == '905'  ||
          USER_INFO_SULevel == '906'  || USER_INFO_SULevel == '907'  ||
          USER_INFO_SULevel == '1000' || USER_INFO_SULevel == '1001' || USER_INFO_SULevel == '1002' ||
          USER_INFO_SULevel == '1003' || USER_INFO_SULevel == '1004' || USER_INFO_SULevel == '1005' ||
          USER_INFO_SULevel == '1006' || USER_INFO_SULevel == '1007' ) { //--GPS 지점설정만 가능한 계정(사원정보 X)

        gsGpsMrg = true;
      }
    }

    //--직책기초코드
    Map<String, String> jikcheckdata = {'SCDBName': USER_INFO_SCDBName , 'SCHostIp': USER_INFO_SCHostIp };
    String url = baseurl + 'list/jikcheck';
    gsjikcheck.clear();
    await http.post(url, body: jikcheckdata).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        JikcheckList jikchecklist = JikcheckList.fromJson(json.decode(jsonString));
        if (jikchecklist.message != 'Result is Empty') {
           int listCnt = jikchecklist.jikchecklistdata.length;
           if (listCnt > 0) {
             for (int i = 0; i < listCnt; i++) {
               gsjikcheck.add({'JCode': jikchecklist.jikchecklistdata[i].JCode , 'JName':jikchecklist.jikchecklistdata[i].JName});  //직책데이터를 배열에 넣어 처리해야 함.
             }
           }
        }
      }
    });

    Map<String, String> jijumdata = {'SCDBName': USER_INFO_SCDBName , 'SCHostIp': USER_INFO_SCHostIp };
    url = baseurl + 'list/jijum';
    gsjijum.clear();
    await http.post(url, body: jijumdata).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        JijumList jijumlist = JijumList.fromJson(json.decode(jsonString));
        if (jijumlist.message != 'Result is Empty') {
          int listCnt = jijumlist.jijumlistdata.length;
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              gsjijum.add({'JJCode': jijumlist.jijumlistdata[i].JJCode ,
                           'JJName':jijumlist.jijumlistdata[i].JJName,
                           'JJSTCode': jijumlist.jijumlistdata[i].JJSTCode});  //지점데이터를 배열에 넣어 처리해야 함.
            }
          }
          gsJijum = true;
        } else {
          gsJijum = false;
        }
      }
    });

    //-- 매니져 지점 검색
    Map<String, String> mjijumdata = {'SUCode': USER_INFO_SUCode};
    url = baseurl + 'manager/jijum';
    await http.post(url, body: mjijumdata).then((response) async {
      String jsonString = response.body;
      print('manager jijum===> $jsonString');
      if (response.statusCode == 200) {
        MJijumList mjijumlist = MJijumList.fromJson(json.decode(jsonString));
        if (mjijumlist.message != 'Result is Empty') {
          //-- 매니저 지점데이터를 배열에 넣어 처리해야 함.
        }
      }
    });

    //--부서
    Map<String, String> buseodata = {'SCDBName': USER_INFO_SCDBName , 'SCHostIp': USER_INFO_SCHostIp };
    url = baseurl + 'list/buseo';
    gsbueso.clear();
    await http.post(url, body: buseodata).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        BuseoList buseolist = BuseoList.fromJson(json.decode(jsonString));
        if (buseolist.message != 'Result is Empty') {
          int listCnt = buseolist.buseolistdata.length;
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              gsbueso.add({'BCode': buseolist.buseolistdata[i].BCode , 'BName':buseolist.buseolistdata[i].BName});  //부서데이터를 배열에 넣어 처리해야 함.
            }
          }
        }
      }
    });

    //--국적적
    Map<String, String> countryodata = {};
    url = baseurl + 'list/country';
    gscountry.clear();
    await http.post(url, body: countryodata).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        CountryList counrylist = CountryList.fromJson(json.decode(jsonString));
        if (counrylist.message != 'Result is Empty') {
          int listCnt = counrylist.countrylistdata.length;
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              gscountry.add({'CCode': counrylist.countrylistdata[i].CCode , 'CName':counrylist.countrylistdata[i].CName});  //부서데이터를 배열에 넣어 처리해야 함.
            }
          }
        }
      }
    });

    Map<String, String> staydata = {};
    url = baseurl + 'list/stay';
    gsstay.clear();
    await http.post(url, body: staydata).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        StayList staylist = StayList.fromJson(json.decode(jsonString));
        if (staylist.message != 'Result is Empty') {
          int listCnt = staylist.staylistdata.length;
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              gsbueso.add({'SSCode': staylist.staylistdata[i].SSCode , 'SSName':staylist.staylistdata[i].SSName});  //부서데이터를 배열에 넣어 처리해야 함.
            }
          }
        }
      }
    });

    Map<String, String> worktypedata = {'SCDBName': USER_INFO_SCDBName , 'SCHostIp': USER_INFO_SCHostIp };
    url = baseurl + 'list/work/type';
    gsworktype.clear();
    await http.post(url, body: worktypedata).then((response) async {
      String jsonString = response.body;
      print('worktype ===> $jsonString');
      if (response.statusCode == 200) {
        WorkTypeList worktypelist = WorkTypeList.fromJson(json.decode(jsonString));
        if (worktypelist.message != 'Result is Empty') {
          int listCnt = worktypelist.worktypelistdata.length;
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              gsbueso.add({'STMobileComeCheckType': worktypelist.worktypelistdata[i].STMobileComeCheckType ,
                           'SWGubun': worktypelist.worktypelistdata[i].SWGubun,
                           'SWName': worktypelist.worktypelistdata[i].SWName,
                           'SWType': worktypelist.worktypelistdata[i].SWType});  //부서데이터를 배열에 넣어 처리해야 함.
            }
          }
        }
      }
    });

  }
}

void globalValuClear() {
  gsjikcheck.clear();
  gsbueso.clear();
  gsjijum.clear();

  gsUser = false;
  gsGpsMrg = false;
  gsPayMgr = false;
  gsNoSTCode = false;
  gsJijum = false;
  USER_INFO_newSignUp = false; //--신규회원 가입유저

  modelName = '';
  serialNumber = 'Unknown';
  gsSTGPSYN = 'N';    //-- GPS 사용여부
  gsSTBeaconYN = 'N'; //-- Beacon 사용여부
  gsShiftWorker = '';
  PlatformOS = '';
  USER_INFO_SUId = '';
  USER_INFO_SUPw = '';

  USER_INFO_SUMyPicYN = '';
  USER_INFO_MyPicURL = '';

  USER_INFO_SCCode = "";
  USER_INFO_SCHostIp = "";
  USER_INFO_SCDBName = "";
  USER_INFO_SUJJCode = "";
  USER_INFO_SCGroupwareYN = "";
  USER_INFO_SCPayAdminSUCode = "";
  USER_INFO_SCPayAdminSUName = "";
  USER_INFO_SCAccountAdminSUName = "";
  USER_INFO_SCAccountAdminSUCode = "";
  USER_INFO_SCBeaconMajor = "";
  USER_INFO_SCBeaconUUID = "";
  USER_INFO_SCMobileOpenTime = "";
  USER_INFO_SCBeaconYN = "";
  USER_INFO_SCGpsYN = "";
  USER_INFO_SUSTCode = "";
  USER_INFO_SUCode = "";
  USER_INFO_SUName = "";
  USER_INFO_STMobileKey = '';
  USER_INFO_SULevel = "";
  USER_INFO_Token = "";
  USER_INFO_SCCoordinate = "";
  USER_INFO_SCYenchaGubun = "";
  USER_INFO_SWYenchaBase = "";
  USER_INFO_STSex = 'M';
}

//------------------------------직책 Class Start
class JikcheckList {
  String code;
  String type;
  String message;
  List<JikcheckListData> jikchecklistdata;

  JikcheckList({this.code, this.type, this.message, this.jikchecklistdata});

  JikcheckList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      jikchecklistdata = new List<JikcheckListData>();
      json['data'].forEach((v) {
        jikchecklistdata.add(new JikcheckListData.fromJson(v));
      });
    }
  }
}

class JikcheckListData {
  String JCode;
  String JName;

  JikcheckListData({this.JCode, this.JName});

  JikcheckListData.fromJson(Map<String, dynamic> json) {
    JCode = json['JCode'];
    JName = json['JName'];
  }
}
//------------------------------직책 Class End

//------------------------------지점 Class Start
class JijumList {
  String code;
  String type;
  String message;
  List<JijumListData> jijumlistdata;

  JijumList({this.code, this.type, this.message, this.jijumlistdata});


  JijumList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      jijumlistdata = new List<JijumListData>();
      json['data'].forEach((v) {
        jijumlistdata.add(new JijumListData.fromJson(v));
      });
    }
  }
}

class JijumListData {
  String JJCode;
  String JJName;
  String JJSTCode;

  JijumListData({this.JJCode, this.JJName, this.JJSTCode});

  JijumListData.fromJson(Map<String, dynamic> json) {
    JJCode = json['JJCode'];
    JJName = json['JJName'];
    JJSTCode = json['JJSTCode'];
  }
}
//------------------------------지점 Class End

//------------------------------매니저 지점 Class Start
class MJijumList {
  String code;
  String type;
  String message;
  List<MJijumListData> mjijumlistdata;

  MJijumList({this.code, this.type, this.message, this.mjijumlistdata});

  MJijumList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      mjijumlistdata = new List<MJijumListData>();
      json['data'].forEach((v) {
        mjijumlistdata.add(new MJijumListData.fromJson(v));
      });
    }
  }
}

class MJijumListData {
  String JJCode;

  MJijumListData({this.JJCode});

  MJijumListData.fromJson(Map<String, dynamic> json) {
    JJCode = json['JJCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['JJCode'] = this.JJCode;
    return data;
  }
}
//------------------------------매니저 지점 Class End

//------------------------------부서 Class Start
class BuseoList {
  String code, type, message;
  List<BuseoListData> buseolistdata;

  BuseoList({this.code, this.type, this.message, this.buseolistdata});

  BuseoList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      buseolistdata = new List<BuseoListData>();
      json['data'].forEach((v) {
        buseolistdata.add(new BuseoListData.fromJson(v));
      });
    }
  }
}

class BuseoListData {
  String BCode, BName;

  BuseoListData({this.BCode, this.BName});

  BuseoListData.fromJson(Map<String, dynamic> json) {
    BCode = json['BCode'];
    BName = json['BName'];
  }
}
//------------------------------부서 Class End

//------------------------------국적 Class Start
class CountryList {
  String code;
  String type;
  String message;
  List<CountryListData> countrylistdata;
  CountryList({this.code, this.type, this.message, this.countrylistdata});

  CountryList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      countrylistdata = new List<CountryListData>();
      json['data'].forEach((v) {
        countrylistdata.add(new CountryListData.fromJson(v));
      });
    }
  }
}

class CountryListData {
  String CCode;
  String CName;

  CountryListData({this.CCode, this.CName});

  CountryListData.fromJson(Map<String, dynamic> json) {
    CCode = json['CCode'];
    CName = json['CName'];
  }
}
//------------------------------국적 Class End

//------------------------------상태 Class End
class StayList{
  String code;
  String type;
  String message;
  List<StayListData> staylistdata;

  StayList({this.code, this.type, this.message, this.staylistdata});

  StayList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      staylistdata = new List<StayListData>();
      json['data'].forEach((v) {
        staylistdata.add(new StayListData.fromJson(v));
      });
    }
  }
}

class StayListData {
  String SSCode;
  String SSName;

  StayListData({this.SSCode, this.SSName});

  StayListData.fromJson(Map<String, dynamic> json) {
    SSCode = json['SSCode'];
    SSName = json['SSName'];
  }
}
//------------------------------상태 Class End

//------------------------------WorkType Class Start
class WorkTypeList {
  String code;
  String type;
  String message;
  List<WorkTypeListData> worktypelistdata;

  WorkTypeList({this.code, this.type, this.message, this.worktypelistdata});

  WorkTypeList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      worktypelistdata = new List<WorkTypeListData>();
      json['data'].forEach((v) {
        worktypelistdata.add(new WorkTypeListData.fromJson(v));
      });
    }
  }
}

class WorkTypeListData {
  String STMobileComeCheckType;
  String SWGubun;
  String SWName;
  String SWType;

  WorkTypeListData({this.STMobileComeCheckType, this.SWGubun, this.SWName, this.SWType});

  WorkTypeListData.fromJson(Map<String, dynamic> json) {
    STMobileComeCheckType = json['STMobileComeCheckType'];
    SWGubun = json['SWGubun'];
    SWName = json['SWName'];
    SWType = json['SWType'];
  }
}
//------------------------------WorkType Class End

class Custom_Menu{
  const Custom_Menu({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Custom_Menu> mchoices = const <Custom_Menu>[
  const Custom_Menu(title: '사원 관리', icon: Icons.settings),
  const Custom_Menu(title: '사원별 근태 관리', icon: Icons.my_location),
  const Custom_Menu(title: '일자별 근태 관리', icon: Icons.my_location),
  const Custom_Menu(title: '월별 근태 확정', icon: Icons.my_location),
  const Custom_Menu(title: '급여 대장', icon: Icons.my_location),
  const Custom_Menu(title: '근태 현황 보기', icon: Icons.my_location),
  const Custom_Menu(title: '급여 명세서', icon: Icons.my_location),
];

const List<Custom_Menu> schoices = const <Custom_Menu>[
  const Custom_Menu(title: '근태 현황 보기', icon: Icons.my_location),
  const Custom_Menu(title: '급여 명세서', icon: Icons.my_location),
];