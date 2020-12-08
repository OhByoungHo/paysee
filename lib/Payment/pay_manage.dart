import 'dart:math';
import 'package:flutter/material.dart';
import 'package:paysee/Payment/member_search.dart';
import 'package:paysee/Public/global_function.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Public/global_variable.dart';

var globalContext;

class Pay_Manage extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Pay_CategoryPage(),
    );
  }
}

class Pay_CategoryPage extends StatefulWidget {
  @override
  _Pay_CategoryPageState createState() => _Pay_CategoryPageState();
}

class _Pay_CategoryPageState extends State<Pay_CategoryPage> {
  final _titles = gsPayMgr ? ['사원 관리', '사원별 근태 관리', '일자별 근태 관리', '월별 근태 확정', '급여대장', '근태 현황 보기', '연차휴가 관리', '급여 명세서' ]
      : [ '근태 현황 보기', '연차휴가 관리', '급여 명세서' ];

  String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(
        length,
            (index){
          return rand.nextInt(33)+89;
        }
    );
    return new String.fromCharCodes(codeUnits);
  }

  @override
  void initState() {
//
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: getColorFromHex('303C4A'),
          elevation: 0,
          centerTitle: true,
          title: Center(child: Text("급여", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), color: Colors.white,
            onPressed: () {Navigator.pop(globalContext);},
          ),
          actions: <Widget>[
            // overflow menu
            PopupMenuButton<Custom_Menu>(
              onSelected: (Custom_Menu choice) async {
                if(choice.title == '로그아웃') {
                  String msg = '현재 계정의 정보가 초기화 됩니다. \n 로그아웃 하시겠습니까?';
                  String action = await showAlertDialogOkCancel(context, msg);
                  if (action == 'OK') {
                  }
                } else if (choice.title == '설정') {
                };
              },
              itemBuilder: (BuildContext context) {
                return gsPayMgr ? mchoices.map((Custom_Menu choice) {return PopupMenuItem<Custom_Menu>(value: choice,child: Text(choice.title),);}).toList()
                    : schoices.map((Custom_Menu choice) {return PopupMenuItem<Custom_Menu>(value: choice,child: Text(choice.title),);}).toList();
              },
            ),
          ],
        ),
        body: new Column(
            children: <Widget>[
              Container( height: 40, color: Colors.black12 , alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 0),
                  child: Text('내정보', style: TextStyle(color: Colors.black45 , fontSize: 15, fontWeight: FontWeight.bold )),
                ),),
              Row(
                children: [
                  Container(child: Image.asset('images/pay_manage.png')),
                  Container( height: 40, color: Colors.white38, alignment: Alignment.centerLeft,
                    child: Text(USER_INFO_SUName, style: TextStyle(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold )),),
                  Container( height: 40, color: Colors.white38, alignment: Alignment.centerRight,
                    child: Text('계발팀 팀장', style: TextStyle(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold )),),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return
                      Card( // <-- Card widget
                        child: ListTile( leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('images/icon/pic_image1.png'),
                        ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            title: Text(_titles[index]),
                            onTap: () {
                              String indexName = _titles[index];
                              switch (indexName) {
                                case '사원 관리': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '사원별 근태 관리': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '일자별 근태 관리': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '월별 근태 확정': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '급여대장': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '근태 현황 보기': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '연차휴가 관리': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                                case '급여 명세서': Navigator.push(context, MaterialPageRoute(builder: (context) => Member_Search()),);
                                break;
                              }
                            }
                        ),
                      );
                  },
                  itemExtent: 55.0,
                  itemCount: _titles.length,
                ),
              ),
            ]
        )
    );
  }
}


