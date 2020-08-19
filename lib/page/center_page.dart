import 'package:flutter/material.dart';
import 'package:pixivic/data/common.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bot_toast/bot_toast.dart';

import '../data/texts.dart';
import '../sidepage/spotlight_page.dart';
import '../sidepage/setting_page.dart';
import '../sidepage/guess_like.dart';

class CenterPage extends StatefulWidget {
  @override
  _CenterPageState createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {
  TextZhCenterPage texts = TextZhCenterPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage('image/background.png'), fit: BoxFit.fitWidth)),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              cell(texts.spotlight, FontAwesomeIcons.solidImages,
                  Colors.green[300], _routeToSpotlightPage),
              cell(texts.community, FontAwesomeIcons.solidComments,
                  Colors.deepOrange[200], () {
                _openUrl('https://discuss.pixivic.com/');
              }),
              // cell(texts.about, FontAwesomeIcons.infoCircle,
              //     Colors.blueGrey[400], _routeToAboutPage),
              cell(texts.frontend, FontAwesomeIcons.githubAlt, Colors.blue[400],
                  () {
                _openUrl('https://github.com/cheer-fun/pixivic-mobile');
              }),
              cell(
                  texts.rearend, FontAwesomeIcons.githubAlt, Colors.orange[300],
                  () {
                _openUrl('https://github.com/cheer-fun/pixivic-web-backend');
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              cell(texts.mobile, FontAwesomeIcons.githubAlt, Colors.red[400],
                  () {
                _openUrl('https://github.com/cheer-fun/pixivic-flutter');
              }),
              cell(texts.friendUrl, FontAwesomeIcons.paperclip,
                  Color(0xFFfbd46d), () {
                _openUrl('https://m.pixivic.com/friends?VNK=d6d42013');
              }),
              cell(texts.albumn, FontAwesomeIcons.boxes, Color(0xFF764ba2),
                  () {}),
              cell(texts.guessLike, FontAwesomeIcons.gratipay, Colors.pink[200],
                  () {
                if (prefs.getString('auth') == '')
                  BotToast.showSimpleNotification(title: texts.pleaseLogin);
                else 
                  _routeToGuessLikePage();
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              cell(texts.setting, FontAwesomeIcons.cog, Color(0xFF086972), () {
                _routeToSettingPage();
              }),
              cell(texts.safety, FontAwesomeIcons.lock, Color(0xFF01a9b4), () {
                _openSafetySetting();
              }),
              cell(texts.policy, FontAwesomeIcons.userSecret, Colors.black38,
                  () {
                _openUrl('https://pixivic.com/policy/');
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget cell(
      String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
          width: ScreenUtil().setWidth(81),
          child: Column(
            children: <Widget>[
              FaIcon(
                icon,
                color: iconColor,
                size: ScreenUtil().setWidth(30),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(5),
              ),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }

  // _routeToAboutPage() {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => AboutPage()));
  // }

  _routeToSpotlightPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SpotlightPage()));
  }

  _routeToSettingPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingPage()));
  }

  _routeToGuessLikePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GuessLikePage()));
  }

  _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openSafetySetting() {
    if (Theme.of(context).platform == TargetPlatform.iOS)
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(texts.safetyTitle),
              content: Text(texts.safetyWarniOS),
              actions: <Widget>[
                FlatButton(
                  child: Text(texts.safetyLevelHigh),
                  onPressed: () {
                    prefs.setInt('sanityLevel', 3);
                    Navigator.of(context).pop();
                  }, //关闭对话框
                ),
                FlatButton(
                  child: Text(texts.safetyLevelLowHigh),
                  onPressed: () {
                    prefs.setInt('sanityLevel', 6);
                    Navigator.of(context).pop(true); //关闭对话框
                  },
                ),
              ],
            );
          });
    else if (Theme.of(context).platform == TargetPlatform.android)
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(texts.safetyTitle),
              content: Text(texts.safetyWarnAndroid),
              actions: <Widget>[
                FlatButton(
                  child: Text(texts.safetyLevelHigh),
                  onPressed: () {
                    prefs.setInt('sanityLevel', 3);
                    Navigator.of(context).pop();
                  }, //关闭对话框
                ),
                FlatButton(
                  child: Text(
                    texts.safetyLevelLowHigh,
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {},
                ),
              ],
            );
          });
  }
}
