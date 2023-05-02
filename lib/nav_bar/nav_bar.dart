import 'package:bob_app/nav_bar/service/navBarNotifier.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../rooms/presentation/pages/RoomsHome.dart';
import '../contact_screen/contactes_screen.dart';
import '../home_screen/home_screen.dart';

class BottomTapBar extends StatefulWidget {
  const BottomTapBar({Key? key}) : super(key: key);

  @override
  State<BottomTapBar> createState() => _BottomTapBarState();
}

class _BottomTapBarState extends State<BottomTapBar> {
  final List _widgetOptions = [
    HomeScreen(),
    AddGroup(),
    const ContactScreen(),
  ];
  @override
  void initState() {
    Permission.contacts.request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavBarNotifier>(
      builder: (context, value, child) {
        return Scaffold(
          body: _widgetOptions[value.pageIndex],
          bottomNavigationBar: bottomNavigationBar(),
        );
      },
    );
  }

  Widget bottomNavigationBar() {
    return Consumer<NavBarNotifier>(
      builder: (context, value, child) {
        return Container(
          height: 65,
          child: BottomNavigationBar(
            unselectedItemColor: Colors.black,
            selectedItemColor: Color.fromARGB(255, 227, 132, 227),
            selectedFontSize: 2,
            items: const [
              BottomNavigationBarItem(
                  label: "",
                  icon: Icon(
                    Icons.home_outlined,
                    size: 22,
                  )),
              BottomNavigationBarItem(
                  label: "",
                  icon: Icon(
                    Icons.group_add_outlined,
                    size: 22,
                  )),
              BottomNavigationBarItem(
                  label: "",
                  icon: Icon(
                    Icons.perm_contact_cal,
                    size: 22,
                  )),
            ],
            currentIndex: value.pageIndex,
            onTap: (val) async{
              // await Permission.contacts.request();

              if(await Permission.contacts.isGranted){
                value.setIndex(val);
              }else{
                await Permission.contacts.request();
              }
            },
          ),
        );
      },
    );
  }
}
