import 'package:flutter/material.dart';
import 'package:paysee/Payment/pay_manage.dart';
import 'package:paysee/Public/global_utils.dart';
import 'package:paysee/Diligence/diligence_page.dart';

class Tab_Page extends StatefulWidget {
  @override
  _Tab_PageState createState() => _Tab_PageState();
}

class _Tab_PageState extends State<Tab_Page> {
  int _selectTabPageIndex = 0;
  List _page = [
    Diligence_Page(),
    Pay_Manage(),
    Text('페이지 작업중 입니다. - ^^'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: _page[_selectTabPageIndex]
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onItemTapped,
          currentIndex: _selectTabPageIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: getColorFromHex('303C4A'),
          selectedItemColor: Colors.white,
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), title:Text('HOME'), ),
            BottomNavigationBarItem(icon: Icon(Icons.addchart),  title:Text('급여'), ),
            BottomNavigationBarItem(icon: Icon(Icons.app_registration), title:Text('문서'), ),
          ],
        )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectTabPageIndex = index;
    });
  }
}


