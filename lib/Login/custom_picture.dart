import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paysee/Login/custom_setup.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Diligence/diligence_page.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

var globalContext;

class Custom_Picture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Picker Demo',
      home: Custom_PicturePage(title: 'Image Picker Example'),
    );
  }
}

class Custom_PicturePage extends StatefulWidget {
  Custom_PicturePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Custom_PicturePageState createState() => _Custom_PicturePageState();
}

class _Custom_PicturePageState extends State<Custom_PicturePage> {
  File _image = null;
  String scName = '', stTel = '', stInDate = '', stJuso = '';

  @override
  void initState() {
    super.initState();
    findSCname();     //--회사명 검색
    findUser();       //--입사일자/전화변호/주소 검색
    imageLoad();      //--Image Load
  }

  Future<void> findUser() async {
    Map<String, String> data = {
      'STNameKor': USER_INFO_SUName,
      'STMobileKey': USER_INFO_STMobileKey,
      'SCDBName': USER_INFO_SCDBName,
      'SCHostIp': USER_INFO_SCHostIp,
      'STSex': USER_INFO_STSex,
      'SCCode': USER_INFO_SCCode
    };

    String url = baseurl + 'staff/valid';
    await http.post(url, body: data).then((response) {
      String jsonString = response.body;
      if (response.statusCode == 200) {
        FindStaff findstaff = FindStaff.fromJson(json.decode(jsonString));
        if (findstaff.code == '00') {
          if (findstaff.message == 'Result is Empty') {
            //-- 조회된 데이터가 없는 경우 SKIP
          } else {
            if (findstaff.data.length > 0) {
              setState(() {
                stTel = findstaff.data[0].sTTel;
                stInDate = findstaff.data[0].sTInDate;
                stJuso = findstaff.data[0].sTJuso;
              }); //-- 있으면 핸드폰 번호가 보이도록 처리
            }
          }
        }
      }
    });
  }

  Future<void> findSCname() async {
    String url = baseurl + 'company/name';
    if (USER_INFO_SCDBName != null) {
      var body = 'SCDBName=' + USER_INFO_SCDBName;
      await http.post(url, body: body).then((response) {
        String jsonString = response.body;
        if (response.statusCode == 200) {
          scCompanyNm sccompanynm = scCompanyNm.fromJson(json.decode(jsonString));
          if (sccompanynm.message == 'true') {
            setState(() {
              scName = sccompanynm.data.sCName;
            });
          }
        }
      });
    }
  }

  Future<int> deleteFile(File file) async {
    try {
      setState(() {
        _image = null;
      });
      imageCache.clear();
      final docDir = await getApplicationDocumentsDirectory();
      docDir.deleteSync(recursive: true);

      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }

      final appDir = await getApplicationSupportDirectory();
      if(appDir.existsSync()){
        appDir.deleteSync(recursive: true);
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> imageLoad() async {
    // String url = baseurl + "file/mypic/thumb";
    // String fileName = USER_INFO_SCCode + '_' + USER_INFO_SUCode + '.png';

    if (USER_INFO_SUMyPicYN == 'Y') {
      String url = imageurl + USER_INFO_MyPicURL;
      String filename = Uri.parse(url).pathSegments.last;
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$filename');
      var isExist = await file.exists();
      print('isExist ===> $isExist');
      if (isExist) {
        // await deleteFile(file);
        imageCache.clear();
      }

      final response = await http.get(url);
      file.writeAsBytesSync(response.bodyBytes);
      setState(() {
        _image = file;
      });
    }
  }

  Future<bool> imageUpload(BuildContext context) async {
    String url = baseurl + "file/mypic/thumb";
    String fileName = USER_INFO_SCCode + '_' + USER_INFO_SUCode + '.png';

    http.MultipartRequest request = new http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('upload',_image.path, filename: fileName,),);
    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> data;
      await for (String s in response.stream.transform(utf8.decoder)) {
        data = jsonDecode(s);
        print('data ====> $data');
        if (data['code'] == "00") {
          if (data['data']['result'] == "true") {
            USER_INFO_SUMyPicYN = data['data']['SUMyPicYN'];
            USER_INFO_MyPicURL = data['data']['MyPicURL2'];
            showToast("사진 등록이 정상적으로 처리 되었습니다.", context, duration: 3, gravity: Toast.CENTER);
          }
        } else {
          showToast("사진등록 ERR.. 관리자에게 문의하세요.", context, duration: 3, gravity: Toast.CENTER);
        }
      }
    }
  }

  _imgFromGallery(BuildContext context) async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );
    setState(() {
      _image = image;
    });
    await imageUpload(context);
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
    return Scaffold(
      appBar: PreferredSize( preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.white, //getColorFromHex('303C4A'),
          elevation: 0,
          centerTitle: true,
          title: Text("사진 등록/수정", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), color: Colors.black,
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
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
//          Container(height: ScreenUtil().setHeight(20)),
          Expanded(
            child: Stack(
                children:[ Center(
                  child: GestureDetector(
                    onTap: () { _imgFromGallery(context); },
                    child: Container(
                      height: ScreenUtil().setHeight(300), width: ScreenUtil().setWidth(300) ,
                      child: CircleAvatar( radius: 45, backgroundColor: Color(0xffFDCF09),
                        child: CircleAvatar(
                            radius: 75,
                            child: _image != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(_image, width: 200, height: 200, fit: BoxFit.fitHeight,  ),
                            )
                                : Container(child: Image.asset('images/join_photo.png'))
                        ),
                      ),
                    ),
                  ),
                ),
                  Container(
                    height: ScreenUtil().setHeight(70),
                    width: ScreenUtil().setWidth(150),
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(550), top: ScreenUtil().setHeight(250)),
                    child:FloatingActionButton.extended(onPressed: () async { _imgFromGallery(context);},
                      label:  Text('편집'), icon: Icon(Icons.wrap_text ),),
                  ),
                ]
            ),
          ),
          Container(height: ScreenUtil().setHeight(30)),
          Container(
              alignment: Alignment.center,
              child: Text('$USER_INFO_SUName', style: new TextStyle( color: Colors.black, fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(35), ) )
          ),
          Container(height: ScreenUtil().setHeight(20)),
          ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Card( //                           <-- Card widget
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage('images/icon/pic_image1.png'),),
                    title: Text('회사명'),
                    subtitle: Text(scName), //           <-- subtitle
                  ),),
                Card( //                           <-- Card widget
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage('images/icon/pic_image2.png'),),
                    title: Text('입사일자'),
                    subtitle: Text(stInDate), //           <-- subtitle
                  ),),
                Card( //                           <-- Card widget
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage('images/icon/pic_image3.png'),),
                    title: Text('전화번호'),
                    subtitle: Text(stTel), //           <-- subtitle
                  ),),
                Card( //                           <-- Card widget
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage('images/icon/pic_image4.png'),),
                    title: Text('주소'),
                    subtitle: Text(stJuso), //           <-- subtitle
                  ),),
              ]
          )
        ],
      ),
    );
  }

  void getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image == null) {
      throw Exception('File is not avilable');
    } else {
      setState(() {
        _image = image;
      });
    }
  }
}


class scCompanyNm {
  String code;
  String type;
  String message;
  scCompanyNmData data;

  scCompanyNm({this.code, this.type, this.message, this.data});

  scCompanyNm.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    data = json['data'] != null ? new scCompanyNmData.fromJson(json['data']) : null;
  }
}

class scCompanyNmData {
  String sCCode;
  String sCName;

  scCompanyNmData({this.sCCode, this.sCName});

  scCompanyNmData.fromJson(Map<String, dynamic> json) {
    sCCode = json['SCCode'];
    sCName = json['SCName'];
  }
}

class FindStaff {
  String code, type, message;
  List<FindStaffData> data;

  FindStaff({this.code, this.type, this.message, this.data});

  FindStaff.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<FindStaffData>();
      json['data'].forEach((v) {
        data.add(new FindStaffData.fromJson(v));
      });
    }
  }
}

class FindStaffData {
  String sTMobileComeCheckType, sTCode, sTTel, sTJJCode, sTBCode, sTJCode;
  String sTInDate, sTCCode, sTJuso, sTEMail, sUStaffAPPUseYN, viewMessage;

  FindStaffData({this.sTMobileComeCheckType, this.sTCode, this.sTTel, this.sTJJCode, this.sTBCode,
    this.sTJCode, this.sTInDate, this.sTCCode, this.sTJuso, this.sTEMail,
    this.sUStaffAPPUseYN,  this.viewMessage});

  FindStaffData.fromJson(Map<String, dynamic> json) {
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