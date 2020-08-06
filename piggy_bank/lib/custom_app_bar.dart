import 'package:flutter/material.dart';

import 'custom_functions.dart';

class CustomAppBar extends StatelessWidget {
  final List<BottomNavigationBarItem> buttomBarItems = [];

  CustomAppBar() {
    buttomBarItems.add(BottomNavigationBarItem(
        icon: icon(Icons.home, Colors.black),
        title: Text(
          'Explore',
          style: textStyle(color: Colors.black, fontSize: 14.0), 
        )));
    buttomBarItems.add(BottomNavigationBarItem(
        icon: icon(Icons.calendar_today, Colors.black,),
        title: Text(
          'Week',
          style: textStyle(color: Colors.black, fontSize: 14.0), 
        )));
    buttomBarItems.add(BottomNavigationBarItem(
        icon: icon(Icons.access_time, Colors.black),
        title: Text(
          'Total',
          style: textStyle(color: Colors.black, fontSize: 14.0), 
        )));
    buttomBarItems.add(BottomNavigationBarItem(
        icon: icon(Icons.notifications, Colors.black),
        title: Text(
          'Notifications',
          style: textStyle(color: Colors.black, fontSize: 14.0), 
        )));
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 15.0,
          child: BottomNavigationBar(
        items: buttomBarItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
