import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location_permissions/location_permissions.dart';

var globalContext;

class Member_Search extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Member_SearchPage(),
    );
  }
}

class Member_SearchPage extends StatefulWidget {
  @override
  _Member_SearchPageState createState() => _Member_SearchPageState();
}

class _Member_SearchPageState extends State<Member_SearchPage> {
  List<GetMemberData> allMemberData = [];
  String stState = '재직', swGubun = '', stBCode = '', stjjCode = '전체', stJCode = '';
  String strName = '', viewCnt = '10', strNum = '0';

  final TextEditingController _nameController = TextEditingController();

  @override
  Future<void> initState() {
    super.initState();
    getMemberCall();
  }

  //내 기기 위치 액세스 허용 체크
  static Future<bool> checkAppPermission(BuildContext context)  async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    if(permission!=PermissionStatus.granted && await LocationPermissions().requestPermissions()!=PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  Future<String> getMemberCall() async {
    Map<String, String> data = {'SCDBName':USER_INFO_SCDBName, 'SCHostIp': USER_INFO_SCHostIp, 'STState':stState,
                                'SWGubun':swGubun,'STBCode':stBCode, 'STNameKor':strName, 'STJJCode': stjjCode,
                                'STJCode':stJCode,'SCCode':USER_INFO_SCCode, 'ViewCNT':viewCnt, 'StrNum':strNum};

    print('$data');
    String buseoName = '', jikcheckName = '', swGubunName = '';
    String url = baseurl + 'list/manager/staff/find';
    http.post(url, body: data).then((response) async {
      String jsonString = response.body;
      print('jsonString ==> $jsonString');
      if (response.statusCode == 200) {
        GetMemberList getmemberlist = GetMemberList.fromJson(json.decode(jsonString));

        if (getmemberlist.code == '00') {
          int listCnt = getmemberlist.data.length;
          allMemberData.clear();
          if (listCnt > 0) {
            for (int i = 0; i < listCnt; i++) {
              //--부서명칭 검색
              for (int j = 0; j < gsbueso.length; j++) {
                 if(getmemberlist.data[i].STBCode == gsbueso[j]['BCode']) {
                   buseoName = gsbueso[j]['BName'];
                 }
              }
              //--직책명칭 검색
              for (int j = 0; j < gsjikcheck.length; j++) {
                if(getmemberlist.data[i].STJCode == gsjikcheck[j]['JCode']) {
                  jikcheckName = gsjikcheck[j]['JName'];
                }
              }

              for (int j = 0; j < gsworktype.length; j++) {
                if(getmemberlist.data[i].SWGubun == gsworktype[j]['SWGubun']) {
                  swGubunName= gsjikcheck[j]['SWName'] + "제";
                }
              }
              GetMemberData memberdata = GetMemberData(STNameKor: getmemberlist.data[i].STNameKor,
                                                       STBCode: buseoName,
                                                       STJCode: jikcheckName,
                                                       STState: getmemberlist.data[i].STState,
                                                       SWGubun: swGubunName,
                                                       STMobileKey: getmemberlist.data[i].STMobileKey,
                                                       SUMyPicYN: getmemberlist.data[i].SUMyPicYN,
                                                       MyPicURL2: getmemberlist.data[i].MyPicURL2,
                                                       STIConGubun: getmemberlist.data[i].STIConGubun,
                                                       STInDate: getmemberlist.data[i].STInDate,
                                                       STSUStaffAPPUseDate:  getmemberlist.data[i].STSUStaffAPPUseDate,
                                                       STOutDate: getmemberlist.data[i].STOutDate,
                                                       STSUStaffAPPDeUseDate: getmemberlist.data[i].STSUStaffAPPDeUseDate,
                                                       SUStaffAPPUseYN: getmemberlist.data[i].SUStaffAPPUseYN);


              setState(() {
                allMemberData.add(memberdata);
              });
            }
          }
          int temp = allMemberData.length;
          print('temp ===> $temp');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    return new Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: new AppBar(
          backgroundColor: getColorFromHex('303C4A'),
          elevation: 0,
          title: Center(child: Text("사원 관리", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {Navigator.pop(globalContext);},
          ),
          actions: <Widget>[
            // overflow menu
            PopupMenuButton<Custom_Menu>(
              onSelected: (Custom_Menu choice) async {
                if(choice.title == '로그아웃') {
                  //
                } else if (choice.title == '설정') {
                  //
                };
              },
              itemBuilder: (BuildContext context) {
                return gsPayMgr ? mchoices.map((Custom_Menu choice) {return PopupMenuItem<Custom_Menu>(value: choice,child: Text(choice.title),);}).toList()
                    : schoices.map((Custom_Menu choice) {return PopupMenuItem<Custom_Menu>(value: choice,child: Text(choice.title),);}).toList();
              },
            ),
          ],
        ),
        body: WillPopScope(
            onWillPop: () async => false,
            child: new Column(
                children: <Widget>[
                  Container(height: ScreenUtil().setHeight(3),),
                  Container(
                    height: ScreenUtil().setHeight(95),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(border: OutlineInputBorder(),labelText: '이름',contentPadding: EdgeInsets.all(8),),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                 Expanded(
                   child: ListView.builder(
                   scrollDirection: Axis.vertical,
                   shrinkWrap: true,                   
                   itemCount: allMemberData.length,
                     itemBuilder: getItemUI,
                     padding: EdgeInsets.all(0.0),
                   ),
                 ),
                ]
            )
        )
    );
  }

  Widget getItemUI(BuildContext context, int index) {
    return new Card(
        child: new Column(

          children: <Widget>[
            new ListTile(
              // leading: new Image.asset(
              //   "assets/" + _allCities[index].image,
              //   fit: BoxFit.cover,
              //   width: 100.0,
              // ),
              title: new Text('Title',
                style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              subtitle: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(allMemberData[index].STNameKor,
                        style: new TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal)),
                    new Text('Population: ${allMemberData[index].STJCode}',
                        style: new TextStyle(fontSize: 11.0, fontWeight: FontWeight.normal)),
                  ]),
              onTap: () {
                //--
              },
            )
          ],
        ));
  }
}

class GetMemberList {
  String code, type, message;
  List<GetMemberData> data;

  GetMemberList({this.code, this.type, this.message, this.data});

  GetMemberList.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<GetMemberData>();
      json['data'].forEach((v) {
        data.add(new GetMemberData.fromJson(v));
      });
    }
  }
}

class GetMemberData {
  String STMobileComeCheckType, STCode, STNameKor, STMobileKey, STBCode;
  String STJCode, STInDate, STOutDate, STState, SUStaffAPPUseYN, SWGubun;
  String STSUStaffAPPUseDate, STSUStaffAPPDeUseDate, SUMyPicYN, STIConGubun;
  String MyPicURL, MyPicURL2;

  GetMemberData(
      {this.STMobileComeCheckType,  this.STCode, this.STNameKor, this.STMobileKey,
        this.STBCode, this.STJCode, this.STInDate, this.STOutDate, this.STState,
        this.SUStaffAPPUseYN, this.SWGubun, this.STSUStaffAPPUseDate,
        this.STSUStaffAPPDeUseDate, this.SUMyPicYN, this.STIConGubun,
        this.MyPicURL, this.MyPicURL2});

  GetMemberData.fromJson(Map<String, dynamic> json) {
    STMobileComeCheckType = json['STMobileComeCheckType'];
    STCode = json['STCode'];
    STNameKor = json['STNameKor'];
    STMobileKey = json['STMobileKey'];
    STBCode = json['STBCode'];
    STJCode = json['STJCode'];
    STInDate = json['STInDate'];
    STOutDate = json['STOutDate'];
    STState = json['STState'];
    SUStaffAPPUseYN = json['SUStaffAPPUseYN'];
    SWGubun = json['SWGubun'];
    STSUStaffAPPUseDate = json['STSUStaffAPPUseDate'];
    STSUStaffAPPDeUseDate = json['STSUStaffAPPDeUseDate'];
    SUMyPicYN = json['SUMyPicYN'];
    STIConGubun = json['STIConGubun'];
    MyPicURL = json['MyPicURL'];
    MyPicURL2 = json['MyPicURL2'];
  }
}

