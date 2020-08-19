import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class FavProvider extends State<StatefulWidget>
    with ChangeNotifier, TickerProviderStateMixin {
  //登录按钮动画
  Animation<double> _favAnimation;
  AnimationController animationController;
  CurvedAnimation curvedAnimation;
  double _iconSize = ScreenUtil().setWidth(30);
  double get iconSize => _iconSize;
  Animation<double> get favAnimation => _favAnimation;
  clickFunc() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInBack);
    _favAnimation = Tween(begin: 30.0, end: 10.0).animate(curvedAnimation)
      ..addListener(() {
        _iconSize = _favAnimation.value;
//        print(_favAnimation.value);
        notifyListeners();
      });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
        notifyListeners();
      }
    });
    animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

  @override
  void dispose() {
//    animationController.dispose();
    super.dispose();
  }
}