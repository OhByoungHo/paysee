import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Join/tab_page.dart';
import 'package:paysee/Login/login_page.dart';
import 'package:device_info/device_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Login/custom_picture.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Root_Page extends StatefulWidget {
  @override
  _Root_PageState createState() => _Root_PageState();
}

class _Root_PageState extends State<Root_Page> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool _versionChk = true;
  SharedPreferences _prefs;
  String _loginYN = 'N';
  String _loginID = '', _loginPW = '', _loginDB = '', _loginIP = '', _loginST = '', _loginVS = '';

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      modelName = _deviceData['model'];
      if (Platform.isAndroid) {
        serialNumber = _deviceData['androidId'];
      } else if (Platform.isIOS) {
        serialNumber = _deviceData['identifierForVendor'];
      }
    });
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
      int statusCode = response.statusCode;
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
    _prefs = await SharedPreferences.getInstance(); // 인스턴스 생성
    setState(() {
      _loginYN = _prefs.getString('loginkey');
      _loginID = _prefs.getString('loginid');
      _loginPW = _prefs.getString('loginpw');
      _loginDB = _prefs.getString('logindb');
      _loginIP = _prefs.getString('loginip');
      _loginST = _prefs.getString('loginst');
      _loginVS = _prefs.getString('loginvs');
    });

    if (_loginYN == 'Y') {
      setState(() {
        USER_INFO_SUId = _loginID;
        USER_INFO_SUPw = _loginPW;
        USER_INFO_SCDBName = _loginDB;
        USER_INFO_SCHostIp = _loginIP;
        USER_INFO_SUSTCode = _loginST;
      });

      _versionChk = await getVersionCheck() as bool;
      if (_versionChk == true) {
        Map<String, String> data = {'SUId': _loginID, 'SUPw': _loginPW};

        String url = baseurl + 'user/login/status';
        await http.post(url, body: data).then((response) async {
          String jsonString = response.body;
          if (response.statusCode == 200) {
            CheckStatus checkStatus  = CheckStatus.fromJson(json.decode(jsonString));
            if (checkStatus.code == '00' && checkStatus.type == 'O') {
              if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'Y') {
                USER_INFO_STMobileKey = checkStatus.chekstatusdata.sTMobileKey;
                USER_INFO_SUMyPicYN = checkStatus.chekstatusdata.sUMyPicYN;
                USER_INFO_MyPicURL = checkStatus.chekstatusdata.myPicURL2;

                //-- USER_INFO, STAFF_INFO Data Select
                await getUserInfo(_loginID, _loginPW);
                await getShiftWorker();
                await getStaffInfo();

              } else if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'W') {
                _loginYN = 'N';
                String msg = '입력하신 계정이 승인 대기중 입니다. \n사진을 업로드 하시겠습니까?.';
                String action = await showAlertDialogOkCancel(context, msg);
                if (action == 'OK') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Custom_Picture()),);
                }
              } else if (checkStatus.chekstatusdata.sUStaffAPPUseYN == 'D') {
                showAlertDialogOk(context, '차단중인 아이디 입니다..');
                _loginYN = 'N';
              } else {
                showAlertDialogOk(context, '아이디 또는 패스워드를 확인해 주세요..');
                _loginYN = 'N';
              }
            } else {
              showAlertDialogOk(context, '저장된 ID/PassWord 가 일치하지 않습니다...');
              _loginYN = 'N';
            }
          }
        });
      } else {
        String msg = '앱 버전 정보가 일치하지 않습니다 \n앱 업데이트 이후 사용 가능합니다.';
        String action = await showAlertDialogOkCancel(context, msg);
        if (action == 'OK') {
          if (PlatformOS == 'android') {
            const url = "market://details?id=com.infra.drpayapp";
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
    }
  }

  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      PlatformOS = 'android';
    } else {
      PlatformOS = 'iso';
    }
    print('patformOS ==> $PlatformOS');
    getAutoLoginFromSharedPrefs();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loginYN == "Y" && _versionChk == true) {
      return Tab_Page();
    } else {
      return Login_Page();
    }
  }
}

Future<bool> getVersionCheck() async {
  bool _isversioncheck = false;

  if (USER_INFO_SUId == 'cho.ym') {
    _isversioncheck = true;
  } else {
    Map<String, String> data = {};

    String url = baseurl + 'app/version';
    await http.post(url, body: data).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        AppVersion appversion = AppVersion.fromJson(json.decode(jsonString));
        if (PlatformOS == 'iso') {
          if (APP_VERSION == appversion.appVersiondata.vIiOSVersion ) {
            _isversioncheck = true;
          } else {
            _isversioncheck = false;
          }
        } else {
          if (APP_VERSION == appversion.appVersiondata.vIAndroidVersion ) {
            _isversioncheck = true;
          } else {
            _isversioncheck = false;
          }
        }
      } else {
        _isversioncheck = false;
      }
    });
  }
  return _isversioncheck;
}

Future<void> getUserInfo(String suid, String supw) async {
  Map<String, String> data = {'SUId': suid,'SUPw': supw};
  String url = baseurl + 'user/login';
  await http.post(url, body: data).then((response) async {
    String jsonString = response.body;
    if (response.statusCode == 200) {
      UserInfo userinfo = UserInfo.fromJson(json.decode(jsonString));
      await globalValueSet(userinfo);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load ');
    }
  });
}

Future<void> getStaffInfo() async {
  Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
                              'STCode': USER_INFO_SUSTCode, 'SCCode': USER_INFO_SCCode};
  String url = baseurl + 'manager/staff/info';
  await http.post(url, body: data).then((response) {
    String jsonString = response.body;
    print('$jsonString');
    if (response.statusCode == 200) {
      StaffInfo staffinfo = StaffInfo.fromJson(json.decode(jsonString));
      if (staffinfo.code == '00') {
        if (staffinfo.type == 'O') {
          USER_INFO_STSex = staffinfo.staffinfodata.sTSex;
          print('USER_INFO_STSex ===> $USER_INFO_STSex');
          gsSTGPSYN = staffinfo.staffinfodata.sTGPSYN ;      //-- GPS 사용여부
          gsSTBeaconYN = staffinfo.staffinfodata.sTBeaconYN; //-- Beacon 사용여부
        }
      }
    } else {
      throw Exception('Failed to load ');
    }
  });
}


class AppVersion {
  String code, type, message;
  AppVersionData appVersiondata;

  AppVersion({this.code, this.type, this.message, this.appVersiondata});

  AppVersion.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    appVersiondata = json['data'] != null ? new AppVersionData.fromJson(json['data']) : null;
  }
}

class AppVersionData {
  String vISeq;
  String vIDate;
  String vIAndroidUpdate;
  String vIAndroidVersion;
  String vIiOSUpdate;
  String vIiOSVersion;

  AppVersionData({this.vISeq, this.vIDate, this.vIAndroidUpdate, this.vIAndroidVersion, this.vIiOSUpdate, this.vIiOSVersion});

  AppVersionData.fromJson(Map<String, dynamic> json) {
    vISeq = json['VISeq'];
    vIDate = json['VIDate'];
    vIAndroidUpdate = json['VIAndroidUpdate'];
    vIAndroidVersion = json['VIAndroidVersion'];
    vIiOSUpdate = json['VIiOSUpdate'];
    vIiOSVersion = json['VIiOSVersion'];
  }
}

//-- UserInfo jseon Load Class
class UserInfo {
  String SCCode, SCHostIp, SCDBName, SUJJCode, SCGroupwareYN, SCPayAdminSUCode;
  String SCPayAdminSUName, SCAccountAdminSUName, SCAccountAdminSUCode, SCBeaconMajor;
  String SCBeaconUUID, SCMobileOpenTime, SCBeaconYN, SCGpsYN, SUSTCode, SUCode;
  String SUName, SULevel, Token, SCCoordinate, SCYenchaGubun, SWYenchaBase;

  UserInfo({this.SCCode, this.SCHostIp, this.SCDBName, this.SUJJCode, this.SCGroupwareYN, this.SCPayAdminSUCode,
    this.SCPayAdminSUName, this.SCAccountAdminSUName, this.SCAccountAdminSUCode, this.SCBeaconMajor,
    this.SCBeaconUUID, this.SCMobileOpenTime, this.SCBeaconYN, this.SCGpsYN, this.SUSTCode, this.SUCode,
    this.SUName, this.SULevel, this.Token, this.SCCoordinate, this.SCYenchaGubun, this.SWYenchaBase});

  factory UserInfo.fromJson(Map<String, dynamic> jsonMap){
    return UserInfo(
        SCCode: jsonMap['data']['SCCode'],
        SCHostIp: jsonMap['data']['SCHostIp'],
        SCDBName: jsonMap['data']['SCDBName'],
        SUJJCode: jsonMap['data']['SUJJCode'],
        SCGroupwareYN: jsonMap['data']['SCGroupwareYN'],
        SCPayAdminSUCode: jsonMap['data']['SCPayAdminSUCode'],
        SCPayAdminSUName: jsonMap['data']['SCPayAdminSUName'],
        SCAccountAdminSUName: jsonMap['data']['SCAccountAdminSUName'],
        SCAccountAdminSUCode: jsonMap['data']['SCAccountAdminSUCode'],
        SCBeaconMajor: jsonMap['data']['SCBeaconMajor'],
        SCBeaconUUID: jsonMap['data']['SCBeaconUUID'],
        SCMobileOpenTime: jsonMap['data']['SCMobileOpenTime'],
        SCBeaconYN: jsonMap['data']['SCBeaconYN'],
        SCGpsYN: jsonMap['data']['SCGpsYN'],
        SUSTCode: jsonMap['data']['SUSTCode'],
        SUCode: jsonMap['data']['SUCode'],
        SUName: jsonMap['data']['SUName'],
        SULevel: jsonMap['data']['SULevel'],
        Token: jsonMap['data']['Token'],
        SCCoordinate: jsonMap['data']['SCCoordinate'],
        SCYenchaGubun: jsonMap['data']['SCYenchaGubun'],
        SWYenchaBase: jsonMap['data']['SWYenchaBase']);
  }
}

class StaffInfo {
  String code, type, message;
  StaffInfoData staffinfodata;

  StaffInfo({this.code, this.type, this.message, this.staffinfodata});

  StaffInfo.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    staffinfodata = json['data'] != null ? new StaffInfoData.fromJson(json['data']) : null;
  }
}

class StaffInfoData {
  String sTMobileComeCheckType, sTNameKor, sTMobileKey, sTSex, sTTel, sTJJCode, sTBCode;
  String sTJCode, sTInDate, sTCCode, sTState, sTJuso, sTEMail, sWGubun, sTSUStaffAPPUseYN;
  String sWTimeStr, sWTimeEnd, sUMyPicYN, sTWKMonth, sWHoliPayWeek;
  String sWLTimeStr1, sWLTimeStr2, sWLTimeStr3, sWLTimeStr4, sWLTimeStr5;
  String sWLTimeEnd1, sWLTimeEnd2, sWLTimeEnd3, sWLTimeEnd4, sWLTimeEnd5;
  String sTBeaconYN, sTGPSYN, sUId, sUCode;

  StaffInfoData({this.sTMobileComeCheckType,  this.sTNameKor, this.sTMobileKey,  this.sTSex, this.sTTel,
    this.sTJJCode, this.sTBCode, this.sTJCode, this.sTInDate, this.sTCCode,
    this.sTState,  this.sTJuso, this.sTEMail, this.sWGubun, this.sTSUStaffAPPUseYN,
    this.sWTimeStr, this.sWTimeEnd, this.sUMyPicYN, this.sTWKMonth, this.sWHoliPayWeek,
    this.sWLTimeStr1, this.sWLTimeEnd1, this.sWLTimeStr2, this.sWLTimeEnd2, this.sWLTimeStr3,
    this.sWLTimeEnd3, this.sWLTimeStr4, this.sWLTimeEnd4, this.sWLTimeStr5, this.sWLTimeEnd5,
    this.sTBeaconYN, this.sTGPSYN, this.sUId, this.sUCode});

  StaffInfoData.fromJson(Map<String, dynamic> json) {
    sTMobileComeCheckType = json['STMobileComeCheckType'];
    sTNameKor = json['STNameKor'];
    sTMobileKey = json['STMobileKey'];
    sTSex = json['STSex'];
    sTTel = json['STTel'];
    sTJJCode = json['STJJCode'];
    sTBCode = json['STBCode'];
    sTJCode = json['STJCode'];
    sTInDate = json['STInDate'];
    sTCCode = json['STCCode'];
    sTState = json['STState'];
    sTJuso = json['STJuso'];
    sTEMail = json['STEMail'];
    sWGubun = json['SWGubun'];
    sTSUStaffAPPUseYN = json['STSUStaffAPPUseYN'];
    sWTimeStr = json['SWTimeStr'];
    sWTimeEnd = json['SWTimeEnd'];
    sUMyPicYN = json['SUMyPicYN'];
    sTWKMonth = json['STWKMonth'];
    sWHoliPayWeek = json['SWHoliPayWeek'];
    sWLTimeStr1 = json['SWLTimeStr1'];
    sWLTimeEnd1 = json['SWLTimeEnd1'];
    sWLTimeStr2 = json['SWLTimeStr2'];
    sWLTimeEnd2 = json['SWLTimeEnd2'];
    sWLTimeStr3 = json['SWLTimeStr3'];
    sWLTimeEnd3 = json['SWLTimeEnd3'];
    sWLTimeStr4 = json['SWLTimeStr4'];
    sWLTimeEnd4 = json['SWLTimeEnd4'];
    sWLTimeStr5 = json['SWLTimeStr5'];
    sWLTimeEnd5 = json['SWLTimeEnd5'];
    sTBeaconYN = json['STBeaconYN'];
    sTGPSYN = json['STGPSYN'];
    sUId = json['SUId'];
    sUCode = json['SUCode'];
  }
}

class SendShiftWorker {
  String stcode;
  String sCDBName;
  String sCHostIp;

  SendShiftWorker({this.stcode, this.sCDBName, this.sCHostIp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stcode'] = this.stcode;
    data['SCDBName'] = this.sCDBName;
    data['SCHostIp'] = this.sCHostIp;
    return data;
  }
}

class RespShiftWorker {
  String code, type, message;
  RespShiftWorkerData respshiftworkerdata;

  RespShiftWorker({this.code, this.type, this.message, this.respshiftworkerdata});

  RespShiftWorker.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    respshiftworkerdata = json['data'] != null ? new RespShiftWorkerData.fromJson(json['data']) : null;
  }
}

class RespShiftWorkerData {
  String data;

  RespShiftWorkerData({this.data});

  RespShiftWorkerData.fromJson(Map<String, dynamic> json) {
    data = json['data'];
  }
}