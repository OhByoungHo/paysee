import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get_mac/get_mac.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

var globalContext;
String selectedInOut = '';

class GoogleMap_Location extends StatelessWidget {
  final String TransInOut;
  GoogleMap_Location(this.TransInOut);
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    selectedInOut = TransInOut;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google_Map 출/퇴근 체크',
      home: GoogleMap_page(),
    );
  }
}

class GoogleMap_page extends StatefulWidget {
  @override
  State<GoogleMap_page> createState() => GoogleMap_pageState();
}

class GoogleMap_pageState extends State<GoogleMap_page> {
  bool insFirst = true;
  Position position;
  List<dynamic> jijumGPSList = [];
  double distance = 0.0;
//  String jijumAddress = '';
  String getMacAddress = '';
  Location _location = Location();
  MapType googleMapType = MapType.normal;
  static final DateTime now = DateTime.now();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;
//  static double jijumLatitude = 36.635829;
//  static double jijumLongitude = 127.474817;
  static double jijumLatitude = 0.0, currentlat = 0.0;
  static double jijumLongitude = 0.0, currentlng = 0.0;
  Set<Marker> addmarkers = Set();
  BitmapDescriptor pinLocationIcon;
  static LatLng JejumLocation = LatLng(jijumLatitude, jijumLongitude);

  void initstate() {
    checkGPSAvailability();
    super.initState();
  }

  //GPS가 가능여부 체크
  void checkGPSAvailability() async {
    print('checkGPSAvailability');
    GeolocationStatus geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();

    if (geolocationStatus != GeolocationStatus.granted) {
      showDialog(
          barrierDismissible:  false,
          context: context,
          builder: (ctx){
            title: Text('GPS 사용불가');
            context: Text('GPS 사용불가로 Google Map의 사용이 불가능 합니다.');
            actions: <Widget> [
              FlatButton(child: Text('OK'), onPressed: () {Navigator.pop(ctx);
              }, )
            ];
          }
      ).then((_) => Navigator.pop(context));
    } else {
      setCustomMapPin ();
      initPlatformState();
    }
  }


  Future<void> getCurrentLocation() async {
    position  = await Geolocator().getCurrentPosition();

    LatLng latlatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition (target: latlatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    if (gsJijum == true && gsSTGPSYN != 'B'){
      if (USER_INFO_SUJJCode == "") {
        showAlertDialogOk(context, '등록된 지점이 존재하지 않습니다.\n지점을 등록하시고 다시 시도하세요!');
        Navigator.pop(context);
      } else {
        if (gsSTGPSYN == 'A'){
          //--지점을 관리하므로 전체지점을 기준으로 거리를 계산
          await getJijumLocate();
          double mindinstance = 999999999999.0;
          double tempinstance = 0.0;
          String minLocation = '';
          for (int i = 0; i < jijumGPSList.length; i++) {
            if (jijumGPSList[i]['JJCoordinate'] != '' && jijumGPSList[i]['JJCoordinate'] != null) {
              var sscoordinate = jijumGPSList[i]['JJCoordinate'].split('/');
              jijumLatitude = double.parse(sscoordinate[0]);
              jijumLongitude = double.parse(sscoordinate[1]);
              JejumLocation = LatLng(jijumLatitude, jijumLongitude);
              tempinstance = await Geolocator().distanceBetween(position.latitude, position.longitude, jijumLatitude,jijumLongitude);
              if (mindinstance > tempinstance) {
                mindinstance = tempinstance;
                minLocation =jijumGPSList[i]['JJCoordinate'];
              }
            }
          }

          for (int i = 0; i < jijumGPSList.length; i++) {
            if (jijumGPSList[i]['JJCoordinate'] != '' && jijumGPSList[i]['JJCoordinate'] != null) {
              if (minLocation == jijumGPSList[i]['JJCoordinate']) {
                var sscoordinate = jijumGPSList[i]['JJCoordinate'].split('/');
                jijumLatitude = double.parse(sscoordinate[0]);
                jijumLongitude = double.parse(sscoordinate[1]);
                JejumLocation = LatLng(jijumLatitude, jijumLongitude);
                distance = await Geolocator().distanceBetween(position.latitude, position.longitude, jijumLatitude,jijumLongitude);
                double fixdistace = double.parse(distance.toStringAsFixed(0));
                int loadJJRadius = jijumGPSList[i]['JJRadius'];
                if (loadJJRadius == null ) {
                  loadJJRadius = 0;
                }
                int jjRadius = loadJJRadius;
                if (jjRadius <= 0) {
                   jjRadius = 30;
                }
                print('selectedInOut ===> $selectedInOut');
                print('distance ===> $distance');
                print('fixdistace ===> $fixdistace');
                bool breakChk = false;
                if (insFirst == true) {
                  if (fixdistace < jjRadius) {
                    //--각 지점별 허용거리 이상이여서 근태등록 처리 되지 않음
                    String latlon = position.latitude.toString() + '/' + position.longitude.toString();
                    await setDiligenceTime('G', latlon);
                    breakChk = true;
                    break;
                  } else {
                    showAlertDialogOk(context,
                        '등록지점과의 거리가 $fixdistace 이상 이여서 근태등록이 불가능 합니다.');
                  }
                  insFirst = false;
                }
                if (breakChk == true) {
                  Navigator.pop(globalContext);
//                Navigator.push(context, MaterialPageRoute(builder: (context) => Diligence_Page()),);
                }
              }
            }
          }
          //-marker  위치변경으로 인한 재표시
          addmarkers.add(Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(JejumLocation.toString()),
            position: JejumLocation,
            infoWindow: InfoWindow(title: '지점 위치',), //--, snippet: jijumAddress
            icon : pinLocationIcon,
          ));
          setState(() {
            googleMapType = MapType.normal;
          });
        }
      }
    } else {
      if (USER_INFO_SCCoordinate.length > 0) {  //-지점관리를 하지 않는 회사는 syscompany에서 좌표를 가져온다.
        var sscoordinate = USER_INFO_SCCoordinate.split('/');
        jijumLatitude = sscoordinate[0] as double;
        jijumLongitude = sscoordinate[1] as double;
        JejumLocation = LatLng(jijumLatitude, jijumLongitude);
        //-marker  위치변경으로 인한 재표시
        addmarkers.add(Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(JejumLocation.toString()),
          position: JejumLocation,
          infoWindow: InfoWindow(title: '지점 위치', ), //-- snippet: jijumAddress
          icon : pinLocationIcon,
        ));

//        jijumAddress = await getAddressFromLocation(jijumLatitude, jijumLongitude);
        distance = await Geolocator().distanceBetween(position.latitude, position.longitude, jijumLatitude, jijumLongitude);
        double fixdistace = double.parse(distance.toStringAsFixed(0));
        print('distance ===> $distance');
        print('fixdistace ===> $fixdistace');
        bool breakChk = false;
        if (insFirst == true){
          if (fixdistace < 30) {
            //--지점과 거리가 30m 이상이여서 근태등록 처리 되지 않음
            String latlon = position.latitude.toString() + '/' +  position.longitude.toString();
            await setDiligenceTime('G', latlon);
            breakChk = true;
          } else {
            showAlertDialogOk(context, '등록지점과의 거리가 $fixdistace 이상 이여서 근태등록이 불가능 합니다.');
          }
          insFirst = false;
        }
        setState(() async {
          googleMapType = MapType.normal;
        });
        if (breakChk == true) {
          Navigator.pop(globalContext);
//        Navigator.push(context, MaterialPageRoute(builder: (context) => Diligence_Page()),);
        }
      } else {
        if (gsSTGPSYN == 'A') {
          showAlertDialogOk(context, '회사 좌표가 등록되어 있지않아 거리를 측정할 수 없습니다.!');
        } else {
          //--지점을 관리하지 않으면서 'B' 인 경우 해당 위치를 넣어줌.
          String latlon = position.latitude.toString() + '/' +  position.longitude.toString();
          await setDiligenceTime('G', latlon);
          Navigator.pop(globalContext);
//        Navigator.push(context, MaterialPageRoute(builder: (context) => Diligence_Page()),);
        }
      }
    }
  }

  //--지점위치 검색
  Future<void> getJijumLocate() async {
    GetJijumGPS getjijumgps = new GetJijumGPS();
    getjijumgps.isjijum = gsJijum;
    Dbinfo dbinfo = new Dbinfo(SCDBName: USER_INFO_SCDBName, SCHostIp: USER_INFO_SCHostIp);
    Map jijumdb = dbinfo.toJson();
    getjijumgps.dbinfo = jijumdb;
    getjijumgps.jijum = '';

    String url = baseurl + 'setup/getGps';
    Map jijum = getjijumgps.toJson();
    var body = 'parm=' + json.encode(jijum);

    await http.post(url, body: body).then((response) {
      String jsonString = response.body;

      if (response.statusCode == 200) {
        //지점에 좌표가 전부다 있는지 체크
//        GetJijumPosition getjijumposition = GetJijumPosition.fromJson(json.decode(jsonString));
        List<dynamic> resdate = json.decode(jsonString);
        int jijumCnt = 0;
        if (resdate.length > 0) {
          for(int i = 0; i < resdate.length; i++) {
            if (resdate[i]['JJCoordinate'] != '' && resdate[i]['JJCoordinate'] != null) {
              jijumCnt ++;
            }
          }
          if (gsSTGPSYN == 'A') {
            if (jijumCnt == 0) {
              showAlertDialogOk(context, '좌표가 등록된 지점이 없어 거리를 측정할 수 없습니다.');
              return;
            }
          }
          setState(() {
            jijumGPSList = resdate;
          });
        }
      } else {
        print('지점 검색 Failed !!!!');
      }
    });
  }

  Future<void> setDiligenceTime(String gubun, String bigo) async {
    String url = '';
    String identify = modelName + ':' + serialNumber;
    print('identify ===> $identify');
    print('identify ===> $getMacAddress');
    Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
      'STCode': USER_INFO_SUSTCode, 'SUCode': USER_INFO_SUCode,
      'CBLastGubun': gubun, 'CBBigo':bigo, 'MacAdr': identify};        //-- 'MacAdr': getMacAddress
    if (selectedInOut == 'IN') {
      url = baseurl + 'comecheck/come';
      await http.post(url, body: data).then((response) {
        String jsonString = response.body;
        print('setDiligenceTime jsonString ==> $jsonString');
        if (response.statusCode == 200) {
          SetInTime setintime = SetInTime.fromJson(json.decode(jsonString));
          if (setintime.message == 'true') {
            String ccStrTime = setintime.setintimedata.cCStrTime.toString();
            showAlertDialogOk(context, '$USER_INFO_SUName 님 $ccStrTime 출근 처리가 되었습니다.\n오늘도 수고하세요.');
          } else {
            String message = setintime.message;
            showAlertDialogOk(context, '$message \n 관리자에게 문의하세요.\n 앱을 한번 재시작해 주세요.');
          }
        }
      });
    } else if (selectedInOut == 'OUT') {
      url = baseurl + 'comecheck/out';
      await http.post(url, body: data).then((response) {
        String jsonString = response.body;
        print('setDiligenceTime out jsonString ==> $jsonString');
        if (response.statusCode == 200) {
          SetOutTime setouttime = SetOutTime.fromJson(json.decode(jsonString));
          if (setouttime.message == 'true') {
            String ccDate = setouttime.setouttimedata.cCDate.toString();
            String ccEndTime = setouttime.setouttimedata.cCEndTime.toString();
            showAlertDialogOk(context, '$USER_INFO_SUName 님 $ccDate  $ccEndTime 퇴근 처리가 되었습니다.');
            DateTime targetDateTime = DateTime.now();
//            setState(() {
//              buildCal(targetDateTime);
//            });
          } else {
            String message = setouttime.message;
            showAlertDialogOk(context, '$message \n 관리자에게 문의하세요.\n 앱을 한번 재시작해 주세요.');
          }
        }
      });
    } else {
      showAlertDialogOk(context, '알수 없는 에러 입니다.\n관리자에게 문의하세요.');
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }
    if (!mounted) return;
    setState(() {
      getMacAddress = platformVersion;
    });
    print('getMacAddress ===> $getMacAddress');
  }

  //--지점 주소 가져오기
  static Future<String> getAddressFromLocation(double lat, double lng) async {
    final String addressUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
    String url = '$addressUrl?latlng=$lat,$lng&key=$GOOGLE_API_KEY&language=ko';

    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);
    final formattedAddr = responseData['results'][0]['formatted_address'];

    return formattedAddr;
  }


  //--marker icon 재설정
  void setCustomMapPin () async {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, 'images/map_marker.png').then((icon) {
      setState(() {
        pinLocationIcon = icon;
      });
    });
    pinLocationIcon = await BitmapDescriptor.fromAssetImage (
        ImageConfiguration (devicePixelRatio : 2.5),
        'images/map_marker.png');
  }

  //--initialCameraPosition 설정
  CameraPosition _initalCamerPosition = CameraPosition(
    target:  LatLng(36.635829, 127.474817),
    zoom: 14,
  );

  //--onMapCreated 설정
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      newGoogleMapController = controller;
      checkGPSAvailability();
      getCurrentLocation();
    });
//    _location.onLocationChanged.listen((l) async {
//      currentlat = l.latitude;
//      currentlng = l.longitude;
//      newGoogleMapController.animateCamera(
//        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),),
//      );
//      jijumAddress = await getAddressFromLocation(jijumLatitude, jijumLongitude);
//      if(mounted)
//        setState(() async {
//          googleMapType = MapType.normal ;
//        });
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
          children: <Widget> [
            GoogleMap(
              mapType: MapType.normal,   //--- _googleMapType,
              initialCameraPosition: _initalCamerPosition,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: this.jijumMarker(),
//            compassEnabled: true,
            ),
//            Container(
//              child: Column(
//                children: [
//                  SizedBox(height: 400,),
//                  Card(
//                    child: ListTile(
//                      title: Text('지점 위치: $jijumAddress'),
//                      subtitle: Text('거리: ${distance}'),
//                    ),
//                  ),
//                ],),
//            ),
          ],)
    );
  }

  Set<Marker> jijumMarker() {
    setState(() {
      addmarkers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(JejumLocation.toString()),
        position: JejumLocation,
        infoWindow: InfoWindow(title: '지점 위치',), //-- snippet: jijumAddress
        icon : pinLocationIcon,
      ));
    });
    return addmarkers;
  }
}


class SetInTime {
  String code, type, message;
  SetInTimeData setintimedata;

  SetInTime({this.code, this.type, this.message, this.setintimedata});

  SetInTime.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    setintimedata = json['data'] != null ? new SetInTimeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['type'] = this.type;
    data['message'] = this.message;
    if (this.setintimedata != null) {
      data['data'] = this.setintimedata.toJson();
    }
    return data;
  }
}

class SetInTimeData {
  String cCDate;
  String cCStrTime;

  SetInTimeData({this.cCDate, this.cCStrTime});

  SetInTimeData.fromJson(Map<String, dynamic> json) {
    cCDate = json['CCDate'];
    cCStrTime = json['CCStrTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CCDate'] = this.cCDate;
    data['CCStrTime'] = this.cCStrTime;
    return data;
  }
}

class SetOutTime {
  String code;
  String type;
  String message;
  SetOutTimeData setouttimedata;

  SetOutTime({this.code, this.type, this.message, this.setouttimedata});

  SetOutTime.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    setouttimedata = json['data'] != null ? new SetOutTimeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['type'] = this.type;
    data['message'] = this.message;
    if (this.setouttimedata != null) {
      data['data'] = this.setouttimedata.toJson();
    }
    return data;
  }
}

class SetOutTimeData {
  String cCDate;
  String cCEndTime;

  SetOutTimeData({this.cCDate, this.cCEndTime});

  SetOutTimeData.fromJson(Map<String, dynamic> json) {
    cCDate = json['CCDate'];
    cCEndTime = json['CCEndTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CCDate'] = this.cCDate;
    data['CCStrTime'] = this.cCEndTime;
    return data;
  }
}




class GetJijumGPS {
  bool isjijum;
  Map dbinfo;
  String jijum;

  GetJijumGPS({this.isjijum, this.dbinfo, this.jijum});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isjijum'] = this.isjijum;
    data['dbinfo'] = this.dbinfo;
    data['jijum'] = this.jijum;
    return data;
  }
}

class Dbinfo {
  String SCDBName;
  String SCHostIp;

  Dbinfo({this.SCDBName, this.SCHostIp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SCDBName'] = this.SCDBName;
    data['SCHostIp'] = this.SCHostIp;
    return data;
  }
}

class GetJijumPosition {
  int jJRadius;
  String jJCODE, jJNAME, jJSTCODE, jJCoordinate;
  String jJCoordinateSUCode, jJSaupNum, jJSaupGubun, jJJuso, jJPhone;

  GetJijumPosition({this.jJCODE, this.jJNAME, this.jJSTCODE, this.jJCoordinate, this.jJRadius,
    this.jJCoordinateSUCode, this.jJSaupNum, this.jJSaupGubun, this.jJJuso, this.jJPhone});

  GetJijumPosition.fromJson(Map<String, dynamic> json) {
    jJCODE = json['JJCODE'];
    jJNAME = json['JJNAME'];
    jJSTCODE = json['JJSTCODE'];
    jJCoordinate = json['JJCoordinate'];
    jJRadius = json['JJRadius'];
    jJCoordinateSUCode = json['JJCoordinateSUCode'];
    jJSaupNum = json['JJSaupNum'];
    jJSaupGubun = json['JJSaupGubun'];
    jJJuso = json['JJJuso'];
    jJPhone = json['JJPhone'];
  }
}

class ResJijumPosition {
  int jJRadius;
  String jJCODE, jJNAME, jJSTCODE, jJCoordinate;
  String jJCoordinateSUCode, jJSaupNum, jJSaupGubun, jJJuso, jJPhone;

  ResJijumPosition({this.jJCODE, this.jJNAME, this.jJSTCODE, this.jJCoordinate, this.jJRadius,
    this.jJCoordinateSUCode, this.jJSaupNum, this.jJSaupGubun, this.jJJuso, this.jJPhone});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['JJCODE'] = this.jJCODE;
    data['JJNAME'] = this.jJNAME;
    data['JJSTCODE'] = this.jJSTCODE;
    data['JJCoordinate'] = this.jJCoordinate;
    data['JJRadius'] = this.jJRadius;
    data['JJCoordinateSUCode'] = this.jJCoordinateSUCode;
    data['JJSaupNum'] = this.jJSaupNum;
    data['JJSaupGubun'] = this.jJSaupGubun;
    data['JJJuso'] = this.jJJuso;
    data['JJPhone'] = this.jJPhone;
  }
}