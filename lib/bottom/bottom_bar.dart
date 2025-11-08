import 'package:aarogya/features/physio_trainer/physio_trainer_page.dart';
import 'package:aarogya/home/home_page.dart';
import 'package:aarogya/medicine/medicine_analyzer.dart';
import 'package:aarogya/medicine/routes/app_pages.dart';

import 'package:flutter/material.dart';
import 'package:animated_botton_navigation/animated_botton_navigation.dart';
import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:get/get.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final _drawerController = AwesomeDrawerBarController();
  int _currentIndex = 0;
    int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: HomeScreen()),
    Center(child: MedicineScanView()),
    PhysioTrainerPage(),
    Center(child: Text("add")),
  ];
    
    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigation(
        height: 70,
        indicatorSpaceBotton: 25,
        icons: [
          Icons.home,
          Icons.medical_services_outlined,
          Icons.person,
          Icons.person,
        ],
        currentIndex: _currentIndex,
        onTapChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
