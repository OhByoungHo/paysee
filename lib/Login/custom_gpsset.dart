import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:paysee/Login/custom_setup.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:paysee/Diligence/diligence_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

var globalContext;

class Custom_GpsSet extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Custom_GpsSetPage(),
    );
  }
}

class Custom_GpsSetPage extends StatefulWidget {
  @override
  _Custom_GpsSetPageState createState() => _Custom_GpsSetPageState();
}

class _Custom_GpsSetPageState extends State<Custom_GpsSetPage> {
  bool delflag = false;
  String jjcodeSelect = '', delMarkid = '';
  String jijumchoiceName = '지점선택';
  Position position;
  Set<Marker> addmarkers = Set();
  BitmapDescriptor pinLocationIcon;
  MapType googleMapType = MapType.normal;
  GoogleMapController newGoogleMapController;
  static double jijumLatitude = 0.0, currentlat = 0.0;
  static double jijumLongitude = 0.0, currentlng = 0.0;
  static LatLng JejumLocation = LatLng(jijumLatitude, jijumLongitude);
  List<Map<String, dynamic>> jijumGPSList = [];

  @override
  void initState() {
    checkGPSAvailability();
    super.initState();
  }

  //GPS가 가능여부 체크
  void checkGPSAvailability() async {
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
    }
  }

  Future<void> getCurrentLocation() async {
    position = await Geolocator().getCurrentPosition();

    LatLng latlatPosition = LatLng(position.latitude, position.longitude);
    currentlat = position.latitude;
    currentlng = position.longitude;
    CameraPosition cameraPosition = new CameraPosition (target: latlatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  //--marker icon 재설정
  void setCustomMapPin() async {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, 'images/map_marker.png').then((icon) {
      setState(() {
        pinLocationIcon = icon;
      });
    });
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/map_marker.png');
  }

  //--initialCameraPosition 설정
  CameraPosition _initalCamerPosition = CameraPosition(
    target:  LatLng(36.635829, 127.474817),
    zoom: 14,
  );

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      newGoogleMapController = controller;
      getCurrentLocation();
    });
  }

  void showJijumDialog(BuildContext context) async{
    showDialog( context: context,
        builder: (BuildContext context) {
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10);
          return AlertDialog(
            titlePadding: EdgeInsets.all(10.0),
//            contentPadding: EdgeInsets.all(0.0),
            contentPadding: EdgeInsets.fromLTRB(1, 0, 1, 0),
            title: Text("지점 목록"),
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
//                            children: getJijumList()
                            children: [
                              for(int index = 0; index < jijumGPSList.length; index++)
                                GestureDetector(
                                    onTap: () async {
                                      String jijumName = jijumGPSList[index]['JJNAME'];
                                      String msg = '', moveSave = '';
                                      jjcodeSelect = jijumGPSList[index]['JJCODE'];
                                      if (jijumGPSList[index]['JJCoordinate'] != '' && jijumGPSList[index]['JJCoordinate'] != null) {
                                        msg = '$jijumName 을 선택하셨습니다.\n선택하신 지점으로 이동 하시겠습니까?';
                                        moveSave = 'MOVE';
                                      } else {
                                        msg = '선택하신 $jijumName 지점은 위치 미등록 지점 입니다.\n현재 위치를 저장 하시겠습니까?';
                                        moveSave = 'SAVE';
                                      }
                                      String action = await showAlertDialogOkCancel(context, msg);
                                      if (action == 'OK') {
                                        if (moveSave == 'MOVE') {

                                          String temp = jijumGPSList[index]['JJCoordinate'];
                                          if (jijumGPSList[index]['JJCoordinate'] != '' && jijumGPSList[index]['JJCoordinate'] != null) {
                                            var sscoordinate = jijumGPSList[index]['JJCoordinate'].split('/');
                                            setState(() {
                                              delflag = true;
                                              jijumchoiceName = jijumName;
                                              jijumLatitude = double.parse(sscoordinate[0]);
                                              jijumLongitude = double.parse(sscoordinate[1]);
                                              JejumLocation = LatLng(jijumLatitude, jijumLongitude);
                                              newGoogleMapController.animateCamera( CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(jijumLatitude,jijumLongitude),zoom: 15),),
                                              );
                                            });
                                            //-marker  위치변경으로 인한 재표시
                                            delMarkid = JejumLocation.toString();
                                            addmarkers.clear();
                                            addmarkers.add(Marker(markerId: MarkerId(JejumLocation.toString()),
                                              position: JejumLocation,
                                              infoWindow: InfoWindow(title: '지점 위치',),
                                              //--, snippet: jijumAddress
                                              icon: pinLocationIcon,
                                            ));
                                            setState(() {
                                              googleMapType = MapType.normal;
                                            });
                                          } else {
                                            setState(() {
                                              jijumLatitude = 0;
                                              jijumLongitude = 0;
                                            });
                                          }
                                          Navigator.pop(context);
                                        } else {
                                          //-- 지점이 없을경우 등록 처리 하도록
                                          String posdata = currentlat.toString() + '/' + currentlng.toString();
                                          SetJijumGPS setjijumgps = new SetJijumGPS();
                                          SetJijumGPSDbinfo dbinfo = new SetJijumGPSDbinfo(SCDBName: USER_INFO_SCDBName,
                                              SCHostIp: USER_INFO_SCHostIp);
                                          Map jijumdb = dbinfo.toJson();
                                          SetJijumGPSUserinfo userinfo = new SetJijumGPSUserinfo(SCCode: USER_INFO_SCCode,
                                              sccoordinate: posdata,
                                              stcode: USER_INFO_SUSTCode,
                                              jjcode: jjcodeSelect);
                                          Map jijumuser = userinfo.toJson();

                                          setjijumgps.isjijum = gsJijum;
                                          setjijumgps.dbinfo = jijumdb;
                                          setjijumgps.userinfo = jijumuser;
                                          Map jijum = setjijumgps.toJson();
                                          var body = 'parm=' + json.encode(jijum);

                                          String url = baseurl + 'setup/setGps';
                                          await http.post(url, body: body).then((response) {
                                            String jsonString = response.body;
                                            if (response.statusCode == 200) {
                                              GetGPSData getgpsdata = GetGPSData.fromJson(json.decode(jsonString));
                                              if (getgpsdata.result == 1) {
                                                showToast("GPS 정보가 현재위치로 저장 처리 되었습니다.", context, duration: 3, gravity: Toast.CENTER);
                                                setState(() {
                                                  delflag = true;
                                                  jijumLatitude = currentlat;
                                                  jijumLongitude = currentlng;
                                                  JejumLocation = LatLng(jijumLatitude, jijumLongitude);
                                                  newGoogleMapController.animateCamera( CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(jijumLatitude,jijumLongitude),zoom: 15),),);
                                                });
                                                //-marker  위치변경으로 인한 재표시
                                                addmarkers.clear();
                                                addmarkers.add(Marker(markerId: MarkerId(JejumLocation.toString()),
                                                  position: JejumLocation,
                                                  infoWindow: InfoWindow(title: '지점 위치',),
                                                  icon: pinLocationIcon,
                                                ));
                                                setState(() {
                                                  googleMapType = MapType.normal;
                                                });
                                                Navigator.pop(context);
                                              } else {
                                                showAlertDialog(context, 'GPS 정보 저장중 오류가 발생했습니다. \n잠시 후 다시 시도해 주시기 바랍니다.');
                                              }
                                            }
                                          });
                                        }
                                      }
                                    },
                                    child: Card(
                                        child: Container(height: 25, color: Colors.white38, alignment: Alignment.centerLeft,
                                            child: Text('  ' + jijumGPSList[index]['JJNAME']))
                                    )
                                )
                            ]
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
                              child: Text("종료"),
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

  Future<bool> deleteCoordinate() async {
    String posdata = '';
    SetJijumGPS setjijumgps = new SetJijumGPS();
    SetJijumGPSDbinfo dbinfo = new SetJijumGPSDbinfo(SCDBName: USER_INFO_SCDBName,
        SCHostIp: USER_INFO_SCHostIp);
    Map jijumdb = dbinfo.toJson();
    SetJijumGPSUserinfo userinfo = new SetJijumGPSUserinfo(SCCode: USER_INFO_SCCode,
        sccoordinate: posdata,
        stcode: USER_INFO_SUSTCode,
        jjcode: jjcodeSelect);
    Map jijumuser = userinfo.toJson();

    setjijumgps.isjijum = gsJijum;
    setjijumgps.dbinfo = jijumdb;
    setjijumgps.userinfo = jijumuser;
    Map jijum = setjijumgps.toJson();
    var body = 'parm=' + json.encode(jijum);

    String url = baseurl + 'setup/setGps';
    await http.post(url, body: body).then((response) {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        GetGPSData getgpsdata = GetGPSData.fromJson(json.decode(jsonString));
        if (getgpsdata.result == 1) {
          showToast("GPS 정보가 삭제 되었습니다.", context, duration: 3, gravity: Toast.CENTER);
          setState(() {
            jijumLatitude = 0.0;
            jijumLongitude = 0.0;
            getCurrentLocation();
            delflag = false;
          });
          //-marker  위치변경으로 인한 재표시
          // addmarkers.clear();
          // addmarkers.add(Marker(markerId: MarkerId(JejumLocation.toString()),
          //           position: JejumLocation,
          //           infoWindow: InfoWindow(title: '지점 위치',),
          //           icon: pinLocationIcon,
          //           ));
          Marker marker = addmarkers.firstWhere((marker) => marker.markerId.value == delMarkid,orElse: () => null);
          setState(() {
            addmarkers.clear();
            addmarkers.remove(marker);        //--Marker가 안지워짐.(확인 사항)
            googleMapType = MapType.normal;
          });
        } else {
          showAlertDialog(context, 'GPS 정보 삭제중 오류가 발생했습니다. \n잠시 후 다시 시도해 주시기 바랍니다.');
        }
      }
    });
  }

  Future<void> jijumDataSelect() async {
    GetJijumGPS getjijumgps = new GetJijumGPS();
    GetJijumGPSDbinfo dbinfo = new GetJijumGPSDbinfo(SCDBName: USER_INFO_SCDBName,
        SCHostIp: USER_INFO_SCHostIp);
    Map jijumdb = dbinfo.toJson();
    getjijumgps.isjijum = gsJijum;
    getjijumgps.dbinfo = jijumdb;
    getjijumgps.jijum = '';
    Map jijum = getjijumgps.toJson();
    var body = 'parm=' + json.encode(jijum);

    String url = baseurl + 'setup/getGps';
    await http.post(url, body: body).then((response) {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        List<dynamic> resdate = json.decode(jsonString);
        jijumGPSList.clear();
        if (resdate.length > 0) {
          for (int i = 0; i < resdate.length; i++) {
            //지점코드/지점명/위도,경도 처리
            jijumGPSList.add({'JJCODE': resdate[i]['JJCODE'], 'JJNAME':resdate[i]['JJNAME'], 'JJCoordinate':resdate[i]['JJCoordinate']});
          }
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
          appBar: new AppBar(
            backgroundColor: getColorFromHex('303C4A'),
            elevation: 0,
            centerTitle: true,
            title: Text("GPS 설정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
          body: new Column(
              children: <Widget>[
                Container( height: 30, color: Colors.black12 , alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 0),
                    child: Text('지점', style: TextStyle(color: Colors.black26 , fontSize: 17, fontWeight: FontWeight.bold )),
                  ),),
                Container( height: 30, color: Colors.white, alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                        child: Text('GPS 설정', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await jijumDataSelect();
                          showJijumDialog(context);
                        },
                        child : Padding(
                          padding: const EdgeInsets.only(left: 55, right: 0, top: 0, bottom: 0),
                          child: Text(jijumchoiceName, style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold )),
                        ),),
                      Padding(
                        padding: const EdgeInsets.only(left: 90, right: 0, top: 0, bottom: 0),
                        child: Text('☜', style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.bold )),
                      )
                    ],
                  )
                  ,),
                Container( height: 3, color: Colors.black12),
                Container( height: 30, color: Colors.black12 , alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 0),
                    child: Text('GPS 정보 설정', style: TextStyle(color: Colors.black26 , fontSize: 17, fontWeight: FontWeight.bold )),
                  ),),

                Row(children: [
                  Container( height: 30, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('위도', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                  Container( height: 30, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('$jijumLatitude', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                ]
                ),
                Container( height: 3, color: Colors.black12),
                Row(children: [
                  Container( height: 30, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('경도', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),
                  Container( height: 30, color: Colors.white, alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0, top: 0, bottom: 0),
                      child: Text('$jijumLongitude', style: TextStyle(color: Colors.black45, fontSize: 17, fontWeight: FontWeight.bold )),
                    ),),]
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container( //width: double.infinity,  height: 340,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _initalCamerPosition,
                            onMapCreated: _onMapCreated,
                            myLocationEnabled: true,
                            markers: this.jijumMarker(),
                          )
                      ),
                      delflag ? Container(
                        alignment:  Alignment.bottomCenter, //padding: EdgeInsets.only(left: 150.0, right: 0.0, top: 260),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.black,
                          child: Text("위치삭제"),
                          onPressed: () async {
                            await deleteCoordinate();
                          },
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(60.0),
                          ),
                        ),
                      ) : Container()
                    ],
                  ),
                )
              ]
          )
      ),
    );
  }

  Set<Marker> jijumMarker() {
    setState(() {
      addmarkers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(JejumLocation.toString()),
        position: JejumLocation,
        infoWindow: InfoWindow(title: '지점 위치',), //-- snippet: jijumAddress
        icon: pinLocationIcon,
      ));
    });
    return addmarkers;
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

class GetJijumGPSDbinfo {
  String SCDBName;
  String SCHostIp;

  GetJijumGPSDbinfo({this.SCDBName, this.SCHostIp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SCDBName'] = this.SCDBName;
    data['SCHostIp'] = this.SCHostIp;
    return data;
  }
}

class SetJijumGPS {
  bool isjijum;
  Map dbinfo;
  Map userinfo;

  SetJijumGPS({this.isjijum, this.dbinfo, this.userinfo});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isjijum'] = this.isjijum;
    data['dbinfo'] = this.dbinfo;
    data['userinfo'] = this.userinfo;
    return data;
  }
}

class SetJijumGPSDbinfo {
  String SCDBName;
  String SCHostIp;

  SetJijumGPSDbinfo({this.SCDBName, this.SCHostIp});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SCDBName'] = this.SCDBName;
    data['SCHostIp'] = this.SCHostIp;
    return data;
  }
}

class SetJijumGPSUserinfo {
  String SCCode;
  String sccoordinate;
  String stcode;
  String jjcode;

  SetJijumGPSUserinfo({this.SCCode, this.sccoordinate, this.stcode, this.jjcode});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SCCode'] = this.SCCode;
    data['sccoordinate'] = this.sccoordinate;
    data['stcode'] = this.stcode;
    data['jjcode'] = this.jjcode;
    return data;
  }
}

class GetGPSData {
  int result;

  GetGPSData({this.result});

  GetGPSData.fromJson(Map<String, dynamic> json) {
    result = json['result'];
  }
}