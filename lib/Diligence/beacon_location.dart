import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:paysee/Diligence/googlemap_location.dart';

var globalContext;
String selectedInOut = '';

class Beacon_Location extends StatelessWidget {
  final String TransInOut;
  Beacon_Location(this.TransInOut);
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    selectedInOut = TransInOut;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beacon 출/퇴근 체크',
      home: BeaconLocation_page(),
    );
  }
}

class BeaconLocation_page extends StatefulWidget {
  @override
  State<BeaconLocation_page> createState() => Beacon_LocationState();
}

class Beacon_LocationState extends State<BeaconLocation_page> with WidgetsBindingObserver {
  int scMajor = -1;
  int scMiner = -1;
  String scBeaconUUID = '';
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;
  final _beacons = <Beacon>[];
  StreamSubscription<RangingResult> _streamRanging;
  StreamSubscription<BluetoothState> _streamBluetooth;
  final StreamController<BluetoothState> streamController = StreamController();
  bool isDisposed = false, loading = true;
  Timer timer;
  int startTimeCount = 0;

  @override
  void initState() {
    scBeaconUUID = USER_INFO_SCBeaconUUID.substring(1, USER_INFO_SCBeaconUUID.length - 1);
    scMajor = int.parse(USER_INFO_SCBeaconMajor);
//    scBeaconUUID = 'fda50693-a4e2-4fb1-afcf-c6eb07647825';
//    scMajor = 10005;
//    scMajor = 10004;

    WidgetsBinding.instance.addObserver(this);
    super.initState();
    startTimer();
    listeningState();
  }

  void startTimer() {
    // Start the periodic timer which prints something every 1 seconds
    timer =  new Timer.periodic(new Duration(seconds: 1), (time) {
      if(!isDisposed) {
        setState(() {
          startTimeCount ++;
          if (startTimeCount > 10) {
            loading = false;
            exitStateCall();
          }
        });
      }
    });
  }

  void exitStateCall() {
    if (loading == false) {
      WidgetsBinding.instance.removeObserver(this);
      streamController?.close();
      _streamRanging?.cancel();
      _streamBluetooth?.cancel();
      flutterBeacon.close;
      timer.cancel();
      sleep(const Duration(seconds:1));
      String msg = '근태 장비를 검색하지 못하였습니다.';
      showToast(msg, context, duration: 10, gravity: Toast.CENTER,);
//      Navigator.push(context, MaterialPageRoute(builder: (context) => Diligence_Page()),);
      Navigator.pop(globalContext); //저장시 자동으로 화면 종료 처리
    }
  }

  Future<void> setDiligenceTime(String gubun, String bigo) async {
    String url = '';
    Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
      'STCode': USER_INFO_SUSTCode, 'SUCode': USER_INFO_SUCode,
      'CBLastGubun': gubun, 'CBBigo':bigo, 'MacAdr': scMiner.toString()};
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

  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon.bluetoothStateChanged().listen((BluetoothState state) async {
      streamController.add(state);

      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;                //Bluetooth상태
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;      //Permission
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||  authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =  await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk || !locationServiceEnabled ||   !bluetoothEnabled) {
      //--Permission/위치정보 서비스/Bluetooth 상태 불량
      return;
    }
    final regions = <Region>[ Region(identifier: 'GemTot for iOS', proximityUUID: scBeaconUUID, ), ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
          if (result != null && result.beacons.isNotEmpty) {
            result.beacons.forEach((beacon) async {
              String temp1 = beacon.proximityUUID.toLowerCase();
              String temp2 = beacon.major.toString();
              if (beacon.proximityUUID.toLowerCase() == scBeaconUUID.toLowerCase()) {
                if (beacon.major == scMajor) {
                  String msg = '';
                  if (selectedInOut == 'IN') {
                    msg = '출근 등록을 위한 Bluetooth 감지 하였습니다.';
                  } else {
                    msg = '퇴근 등록을 위한 Bluetooth 감지 하였습니다.';
                  }
                  showToast(msg, context, duration: 5, gravity: Toast.CENTER, );
                  timer.cancel();
                  setState(() {
                    scMiner = beacon.minor;
                  });
                  await setDiligenceTime('B', "");

                  loading = false;
                  exitStateCall();
                }
              }
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Beacon 위치검색'),
            centerTitle: true,
            actions: <Widget>[
              if (!authorizationStatusOk)
                IconButton(icon: Icon(Icons.portable_wifi_off), color: Colors.red,
                    onPressed: () async {
                      await flutterBeacon.requestAuthorization;
                    }),
              if (!locationServiceEnabled)
                IconButton(icon: Icon(Icons.location_off), color: Colors.red,
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        await flutterBeacon.openLocationSettings;
                      } else if (Platform.isIOS) {
                      }
                    }),
              StreamBuilder<BluetoothState>(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final state = snapshot.data;

                    if (state == BluetoothState.stateOn) {
                      return IconButton( icon: Icon(Icons.bluetooth_connected), color: Colors.lightBlueAccent,
                        onPressed: () {},
                      );
                    }
                    if (state == BluetoothState.stateOff) {
                      return IconButton( icon: Icon(Icons.bluetooth), color: Colors.red,
                        onPressed: () async {
                          if (Platform.isAndroid) {
                            try {
                              await flutterBeacon.openBluetoothSettings;
                            } on PlatformException catch (e) {
                              print(e);
                            }
                          } else if (Platform.isIOS) {
                            //--ISO 설정처리 부분
                          }
                        },
                      );
                    }

                    return IconButton(
                      icon: Icon(Icons.bluetooth_disabled), color: Colors.grey,
                      onPressed: () {},
                    );
                  }

                  return SizedBox.shrink();
                },
                stream: streamController.stream,
                initialData: BluetoothState.stateUnknown,
              ),
            ],
          ),
          body: Stack(
              children: [
                Container(
                  child: Center(
                    child: loading ? CircularProgressIndicator(strokeWidth: 10,): Container(),
//            child: TimeoutCheck == false ? CircularProgressIndicator() : CallMessage(),
                  ),
                ),
                Column(
                  children: [
                    Container(height: size.height * 0.6),
                    Container(
                        child :
                        Text("근태 장비를 검색 중입니다 : $startTimeCount", style: TextStyle(fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))
                    ),
                    Container(height: 65,
                        padding: EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 4),
                        child: RaisedButton(textColor: Colors.white, color: getColorFromHex('303C4A'),
                            child: Text('취소',style: TextStyle(fontSize: 18, color: Colors.white) ),
                            onPressed: () {
                              loading = false;
                              exitStateCall();
                            }
                        )
                    )
                  ],
                ),
              ]
          )
      ),
    );
  }
}