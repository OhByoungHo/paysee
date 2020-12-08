import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Login/login_page.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:paysee/Login/custom_setup.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:paysee/Diligence/beacon_location.dart';
import 'package:paysee/Diligence/googlemap_location.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel, WeekdayFormat;

var globalContext;

class Diligence_Page extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Diligence_Display(title: 'Flutter Calendar Carousel'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('ko', 'KR'),],
    );
  }
}

class Diligence_Display extends StatefulWidget {
  Diligence_Display({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Diligence_DisplayState createState() => new _Diligence_DisplayState();
}

class _Diligence_DisplayState extends State<Diligence_Display> {
  List<Map<String, dynamic>> dispSetTime = [];                               //배열에 출근시간/퇴근시간 넣기 위한 변수
  bool   isLoading = false, monthButton = false, dailymagam = false, loadfirst = true;
  String mainMenu = 'menuUser';
  String payMenu = 'payUser';
  String token = 'token';
  String sYear, sMonth;
  String diligence_in_image, diligence_out_image;

  static final DateTime nowdate = DateTime.now();
  DateTime currentDate = DateTime.now();
  DateTime targetDateTimeData = DateTime.now();
  String currentMonth =  DateFormat('yyyy-MM').format(nowdate);

  static Widget _normalIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.amber,
    ),
  );

  final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return Login_Page();
    },
  );

  String toDayInTime = '', clickInTime = '';
  String toDayOutTime = '', clickOutTime = '';

  EventList<Event> markedDateMapData = new EventList<Event>(
    events: {},
  );

  CalendarCarousel calendarCarouselNoHeader;

  @override
  void initState() {
    super.initState();
    DateTime temptargetDate = DateTime(targetDateTimeData.year, targetDateTimeData.month);
    setState(() {
      if(USER_INFO_STSex == 'M') {
        diligence_in_image = 'images/man_diligence_in.png';
        diligence_out_image = 'images/man_diligence_out.png';
      } else {
        diligence_in_image = 'images/woman_diligence_in.png';
        diligence_out_image = 'images/woman_diligence_out.png';
      }

      targetDateTimeData = temptargetDate;
      buildCal(targetDateTimeData);
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

  Future<void> getMagam2Info(String fulldate) async {
    Map<String, String> magam2 = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
      'CDMDate': fulldate, 'CDMJJ': USER_INFO_SUJJCode};
    String url = baseurl + 'comecheck/day/magam2';
    await http.post(url, body: magam2).then((response) async {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        Magam2Info magam2info = Magam2Info.fromJson(json.decode(jsonString));
        if(magam2info.magam2infodata.isNotEmpty && magam2info.magam2infodata[0].cDMGubun == 'Y') {
          showAlertDialogOk(context, '일자별 마감 처리된 상태 입니다.');
          dailymagam = false;
        } else {
          dailymagam = true;
        }
      } else {
        // If that call was not successful, throw an error.
        showAlertDialogOk(context, 'Failed to Magam Data Load');
        dailymagam = false;
      }
    });
  }

  //내 기기 위치 액세스 허용 체크
  static Future<bool> checkAppPermission(BuildContext context)  async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    if(permission!=PermissionStatus.granted && await LocationPermissions().requestPermissions()!=PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);

    calendarCarouselNoHeader = CalendarCarousel<Event>(
      locale: 'ko-KR',
      prevMonthDayBorderColor: Colors.blue,
      nextMonthDayBorderColor: Colors.blue,
      todayBorderColor: Colors.green,
      thisMonthDayBorderColor: Colors.transparent, //Colors.grey,
      selectedDayButtonColor: Color(0xFF30A9B2),
      selectedDayBorderColor: Color(0xFF30A9B2),
      todayButtonColor: Colors.white,
      selectedDayTextStyle: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(35),),
      inactiveDaysTextStyle: TextStyle(color: Colors.tealAccent, fontSize: ScreenUtil().setSp(35),),
      prevDaysTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.grey, ),  //fontWeight: FontWeight.bold
      daysTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.white, ), //fontWeight: FontWeight.bold
      weekdayTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.white, ), //fontWeight: FontWeight.bold
      weekendTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.red, ), //fontWeight: FontWeight.bold
      todayTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.blue, ), //fontWeight: FontWeight.bold)
      nextDaysTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.grey, ), //fontWeight: FontWeight.bold
      weekDayFormat: WeekdayFormat.short,
      firstDayOfWeek: 0,
      showHeader: false,
      isScrollable: false,
      selectedDateTime: currentDate,
//    daysHaveCircularBorder: true,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      showOnlyCurrentMonthDate: false,
      weekFormat: false,
      markedDatesMap: markedDateMapData,
//      markedDateIconBuilder: (CalendarItem c) => Container(color: Colors.orange, height: 1.0),
      markedDateMoreCustomDecoration: BoxDecoration(shape: BoxShape.circle),
//      height: 280.0,
      targetDateTime: targetDateTimeData,
//      markedDateCustomShapeBorder: CircleBorder(side: BorderSide(color: Colors.yellow)),
      markedDateCustomTextStyle: TextStyle(fontSize: ScreenUtil().setSp(35), color: Colors.blue, ),
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() {
          clickInTime = '';
          clickOutTime = '';
          currentDate = date;
          String clickDate = DateFormat('yyyy-MM-dd').format(date);
          for (int i = 0; i < dispSetTime.length; i++){
            if(clickDate == dispSetTime[i]['date']) {
              setState(() {
                clickInTime = dispSetTime[i]['stime'];
                clickOutTime = dispSetTime[i]['etime'];
              });
            }
          }
        });
      },
      onCalendarChanged: (DateTime date) {
        targetDateTimeData = date;
        if (monthButton == true) {
          this.setState(() {
            buildCal(targetDateTimeData);
            clickInTime = '';
            clickOutTime = '';
          });
        }
        monthButton = false;
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );

    return new Scaffold(
        backgroundColor: getColorFromHex('303C4A'),
        appBar: PreferredSize( preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: getColorFromHex('303C4A'),
            elevation: 0,
            centerTitle: true,
            title:Text("페이씨 APP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            leading: IconButton(
              icon: Icon(Icons.arrow_back), color: getColorFromHex('303C4A'),
              onPressed: () {Navigator.pop(globalContext);},
            ),
            actions: <Widget>[
              // overflow menu
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
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //custom icon
              Container(
                height: ScreenUtil().setHeight(48),
                width:  ScreenUtil().setWidth(750),
                color: getColorFromHex('303C4A'),
                child: new Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                      child: FlatButton(
                        highlightColor: getColorFromHex('303C4A'),
                        child: Icon( Icons.arrow_back_ios_sharp, color: Colors.white, ),
                        onPressed: () {
                          DateTime _temptargetDate = DateTime(targetDateTimeData.year, targetDateTimeData.month -1);
                          setState(() {
                            monthButton = true;
                            targetDateTimeData = _temptargetDate;
                            currentMonth =  DateFormat('yyyy-MM').format(targetDateTimeData);
                            //                        buildCal(targetDateTimeData);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(70)),
                      child: Text(currentMonth, style: TextStyle( color: Colors.white , fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(45),),),
                    ) ,
                    Padding(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(70)),
                      child: FlatButton(
                        highlightColor: getColorFromHex('303C4A'),
                        child: Icon( Icons.arrow_forward_ios_sharp, color: Colors.white ),
                        onPressed: () {
                          setState(() {
                            monthButton = true;
                            targetDateTimeData = DateTime(targetDateTimeData.year, targetDateTimeData.month +1);
                            currentMonth =  DateFormat('yyyy-MM').format(targetDateTimeData);
                            //                        buildCal(targetDateTimeData);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(height: ScreenUtil().setHeight(10),color: getColorFromHex('303C4A'),),
              Container(
                  height: ScreenUtil().setHeight(630),
                  width:  ScreenUtil().setWidth(850),
                  margin: EdgeInsets.symmetric(horizontal: 35.0),
                  color: getColorFromHex('303C4A'),
                  child: calendarCarouselNoHeader
              ), //
              Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        //-- 출근체크
                        DateTime lastDayOfMonth = new DateTime(targetDateTimeData.year, targetDateTimeData.month + 1, 0);  //--마지막일자 (XXXX-XX-XX 00:00:00.000)
                        String tempYear = lastDayOfMonth.year.toString();
                        String tempMonth = lastDayOfMonth.month.toString();
                        String tempday = lastDayOfMonth.day.toString();

                        Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
                          'CCYear': tempYear, 'CCMonth':tempMonth};

                        String url = baseurl + 'comecheck/month/magam';
                        http.post(url, body: data).then((response) async {
                          String jsonString = response.body;
                          if (response.statusCode == 200) {
                            MonthMagam monthmagam = MonthMagam.fromJson(json.decode(jsonString));
                            if (monthmagam.code == '00') {
                              if (monthmagam.type == 'O') {
                                if (monthmagam.monthmagamdata.pMCloseYN == 'N') {
                                  if (gsJijum == true && gsSTGPSYN != 'B') {
                                    if (USER_INFO_SUJJCode == '') {
                                      showAlertDialogOk(context, '지점이 등록되어 있지 않습니다.\n지점을 등록하신 후 다시 시도하세요!'
                                          '\n(재로그인이 필요합니다)');
                                      return;
                                    }
                                  }

                                  String fulldate = tempYear + '-' + tempMonth + '-' + nowdate.day.toString();
                                  await getMagam2Info(fulldate);

                                  if (dailymagam == true) {
                                    if(toDayInTime != '' && toDayInTime != null ) {
                                      showAlertDialogOk(context, '이미 출근 기록이 있습니다.'); //-- 당일 출근기록이 있을 경우
                                    } else {
                                      if (toDayOutTime != '' && toDayOutTime != null ) {
                                        showAlertDialogOk(context, '이미 퇴근기록이 있어 출근 체크가 제한 됩니다..'); //-- 당일 퇴근기록이 있을 경우
                                      } else {
                                        if (gsSTGPSYN != 'N') {
                                          bool chkpermission = await checkAppPermission(context);
                                          if (chkpermission == true) {
                                            await Navigator.push(context, MaterialPageRoute( builder: (context) => GoogleMap_Location('IN')),);
                                          } else {
                                            showToast("Google Map을 정상적으로 실행하기 위해 권한이 필요합니다..", context, duration: 5, gravity: Toast.CENTER);
                                          }
                                        } else {
                                          showToast("Beacon 화면 이동 중입니다.", context, gravity: Toast.CENTER);
                                          await Navigator.push(context, MaterialPageRoute( builder: (context) => Beacon_Location('IN')),);
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  showAlertDialogOk(context, '해당 달은 마감처리되어 근태 등록 및 수정이 불가합니다.\n관리자에게 문의하세요');
                                }
                              } else {
                                showAlertDialogOk(context, 'SERVER CONNECTION ERROR...\n관리자에게 문의하세요');
                              }
                            }
                          }
                        });
                      },
                      child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(80)),
                              child: Container( decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
                                child: ClipRRect( borderRadius: BorderRadius.circular(20.0),
                                  child: Image.asset(diligence_in_image, height: ScreenUtil().setHeight(380), width: ScreenUtil().setWidth(280)),
                                ),
                              ),
                            ),
                            Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(170), top: ScreenUtil().setHeight(30)),
                                child: Text('$clickInTime', style: new TextStyle( color: Colors.blue, fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(35), ) )
                            ),
                          ]
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        //--퇴근 체크
                        DateTime lastDayOfMonth = new DateTime(targetDateTimeData.year, targetDateTimeData.month + 1, 0);  //--마지막일자 (XXXX-XX-XX 00:00:00.000)
                        String tempYear = lastDayOfMonth.year.toString();
                        String tempMonth = lastDayOfMonth.month.toString();
                        String tempday = lastDayOfMonth.day.toString();

                        Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
                          'CCYear': tempYear, 'CCMonth':tempMonth};

                        String url = baseurl + 'comecheck/month/magam';
                        http.post(url, body: data).then((response) async {
                          String jsonString = response.body;
                          if (response.statusCode == 200) {
                            MonthMagam monthmagam = MonthMagam.fromJson(json.decode(jsonString));
                            if (monthmagam.code == '00') {
                              if (monthmagam.type == 'O') {
                                if (monthmagam.monthmagamdata.pMCloseYN == 'N') {
                                  if (gsJijum == true && gsSTGPSYN != 'B') {
                                    if (USER_INFO_SUJJCode == '') {
                                      showAlertDialogOk(context, '지점이 등록되어 있지 않습니다.\n지점을 등록하신 후 다시 시도하세요!'
                                          '\n(재로그인이 필요합니다)');
                                      return;
                                    }
                                  }

                                  String fulldate = tempYear + '-' + tempMonth + '-' + nowdate.day.toString();
                                  await getMagam2Info(fulldate);

                                  if (dailymagam == true) {
                                    // if(toDayOutTime != '' && toDayOutTime != null ) {
                                    //   showAlertDialogOk(context, '이미 퇴근 기록이 있습니다.'); //-- 당일 퇴근기록이 있을 경우
                                    // } else {
                                    if (gsSTGPSYN != 'N') {
                                      bool chkpermission = await checkAppPermission(context);
                                      if (chkpermission == true) {
                                        await Navigator.push(context, MaterialPageRoute( builder: (context) => GoogleMap_Location('OUT')),);
                                      } else {
                                        showToast("Google Map을 정상적으로 실행하기 위해 권한이 필요합니다..", context, duration: 5, gravity: Toast.CENTER);
                                      }
                                    } else {
                                      await Navigator.push(context, MaterialPageRoute( builder: (context) => Beacon_Location('OUT')),);
                                    }
                                    //                                        }
                                  }
                                } else {
                                  showAlertDialogOk(context, '해당 달은 마감처리되어 근태 등록 및 수정이 불가합니다.\n관리자에게 문의하세요');
                                }
                              } else {
                                showAlertDialogOk(context, 'SERVER CONNECTION ERROR...\n관리자에게 문의하세요');
                              }
                            }
                          }
                        });
                      },
                      child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                              child: Container(decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10.0)),
                                child: Image.asset(diligence_out_image, height: ScreenUtil().setHeight(380), width: ScreenUtil().setWidth(280),
                                ),
                              ),
                            ),
                            Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(120), top: ScreenUtil().setHeight(30)),
                                child: Text('$clickOutTime', style: new TextStyle( color: Colors.blue, fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(35), ) )
                            ),
                          ]
                      ),
                    )
                  ]
              ),
            ],
          ),
        )
    );
  }

  void buildCal(DateTime targetDateTime) {
    DateTime lastDayOfMonth = new DateTime(targetDateTimeData.year, targetDateTimeData.month + 1, 0);  //--마지막일자 (XXXX-XX-XX 00:00:00.000)
    String tempYear = lastDayOfMonth.year.toString();
    String tempMonth = lastDayOfMonth.month.toString();
    String lastday = lastDayOfMonth.day.toString();

    markedDateMapData.clear();

    Map<String, String> data = {'SCDBName': USER_INFO_SCDBName,'SCHostIp': USER_INFO_SCHostIp,
      'STCode': USER_INFO_SUSTCode, 'CCYear': tempYear, 'CCMonth': tempMonth };

    String url = baseurl + 'comecheck/month';
    http.post(url, body: data).then((response) {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        SelecDilgencetMonth dilgenctmonth = SelecDilgencetMonth.fromJson(json.decode(jsonString));
        if ( dilgenctmonth.message == "Result is Empty" ||  dilgenctmonth.message == "Parameter is Null") {
          //-- 출근기록 없음.
        } else {
          //--근태 표시 처리
          String ccdate = '', tempdate = '';
          dispSetTime.clear();
          for (int i = 0; i < dilgenctmonth.selectdilgencetmonthdata.length; i++){
            String ccdate = dilgenctmonth.selectdilgencetmonthdata[i].cCDate;
            for(var j = 0; j < int.parse(lastday) ; j++){
              int day = j + 1;
              String tempday = day.toString();
              if (tempday.length == 1) {tempday = '0' + tempday;}
              String tempdate = tempYear + '-' + tempMonth + '-' + tempday;
              if (ccdate == tempdate) {
                dispSetTime.add({'date': tempdate, 'stime':dilgenctmonth.selectdilgencetmonthdata[i].cCStrTime, 'etime':dilgenctmonth.selectdilgencetmonthdata[i].cCEndTime});  //배열에 출근시간/퇴근시간 넣기
                DateTime markdate = DateTime(int.parse(tempYear),int.parse(tempMonth), day);
                if ((dilgenctmonth.selectdilgencetmonthdata[i].cCStrTime != "" && dilgenctmonth.selectdilgencetmonthdata[i].cCEndTime == "") ||
                    (dilgenctmonth.selectdilgencetmonthdata[i].cCStrTime == "" && dilgenctmonth.selectdilgencetmonthdata[i].cCEndTime != "")){
                  setState(() {
                    markedDateMapData.add(markdate, new Event(date: markdate, icon: _normalIcon,
                      dot: Container(margin: EdgeInsets.symmetric(horizontal: 1.0),color: Colors.red, height: 6.0, width: 6.0,),));
                  });
                } else if (dilgenctmonth.selectdilgencetmonthdata[i].cCStrTime != "" && dilgenctmonth.selectdilgencetmonthdata[i].cCEndTime != "") {
                  setState(() {
                    markedDateMapData.add(markdate, new Event(date: markdate, icon: _normalIcon,
                      dot: Container(margin: EdgeInsets.symmetric(horizontal: 1.0),color: Colors.blue, height: 6.0, width: 6.0,),));
                  });
                } else {
                  //--
                }
              }
            }
          }

          // markedDateWidget: Container(
          //   height: 20,
          //   width: 20,
          //   decoration: new BoxDecoration(
          //     shape: BoxShape.rectangle,
          //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
          //   ),
          // ),

          if (loadfirst == true) {
            var now = DateTime.now();
            print('now ===> $now');
            String clickDate = DateFormat('yyyy-MM-dd').format(now);
            print('clickDate ===> $clickDate');
            for (int i = 0; i < dispSetTime.length; i++){
              if(clickDate == dispSetTime[i]['date']) {
                toDayInTime = dispSetTime[i]['stime'];    //-- 출근 체크를 위해 당일 자료 저장
                toDayOutTime = dispSetTime[i]['etime'];   //-- 퇴근 체크를 위해 당일 자료 저장

                clickInTime = toDayInTime;                //-- 처음로딩시 출근시간을 표시해 주기 위해
                clickOutTime = toDayOutTime;              //-- 처음로딩시 퇴근시간을 표시해 주기 위해
              }
            }
            loadfirst = false;
          }
        }
      }
    });
  }
}

class SelecDilgencetMonth {
  String code;
  String type;
  String message;
  List<SelecDilgencetMonthData> selectdilgencetmonthdata;

  SelecDilgencetMonth({this.code, this.type, this.message, this.selectdilgencetmonthdata});

  SelecDilgencetMonth.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      selectdilgencetmonthdata = new List<SelecDilgencetMonthData>();
      json['data'].forEach((v) {
        selectdilgencetmonthdata.add(new SelecDilgencetMonthData.fromJson(v));
      });
    }
  }
}

class SelecDilgencetMonthData {
  String cCDate;
  String cCStrTime;
  String cCEndTime;
  String cCGubun;

  SelecDilgencetMonthData({this.cCDate, this.cCStrTime, this.cCEndTime, this.cCGubun});

  SelecDilgencetMonthData.fromJson(Map<String, dynamic> json) {
    cCDate = json['CCDate'];
    cCStrTime = json['CCStrTime'];
    cCEndTime = json['CCEndTime'];
    cCGubun = json['CCGubun'];
  }
}

class MonthMagam {
  String code, type, message;
  MonthMagamData monthmagamdata;

  MonthMagam({this.code, this.type, this.message, this.monthmagamdata});

  MonthMagam.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    monthmagamdata = json['data'] != null ? new MonthMagamData.fromJson(json['data']) : null;
  }
}

class MonthMagamData {
  String pMCloseYN;

  MonthMagamData({this.pMCloseYN});

  MonthMagamData.fromJson(Map<String, dynamic> json) {
    pMCloseYN = json['PMCloseYN'];
  }
}

class Magam2Info {
  String code, type, message;
  List<Magam2InfoData> magam2infodata;

  Magam2Info({this.code, this.type, this.message, this.magam2infodata});

  Magam2Info.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      magam2infodata = new List<Magam2InfoData>();
      json['data'].forEach((v) {
        magam2infodata.add(new Magam2InfoData.fromJson(v));
      });
    }
  }
}

class Magam2InfoData {
  String cDMDate, cDMGubun, cDMSUCode, cDMAddDate, cDMJJCode;

  Magam2InfoData({this.cDMDate,this.cDMGubun, this.cDMSUCode, this.cDMAddDate, this.cDMJJCode});

  Magam2InfoData.fromJson(Map<String, dynamic> json) {
    cDMDate = json['CDMDate'];
    cDMGubun = json['CDMGubun'];
    cDMSUCode = json['CDMSUCode'];
    cDMAddDate = json['CDMAddDate'];
    cDMJJCode = json['CDMJJCode'];
  }
}


class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: '로그아웃', icon: Icons.settings),
  const Choice(title: '설정', icon: Icons.my_location),
];


