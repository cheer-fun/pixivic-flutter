import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pixivic/page/pic_page.dart';
import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/common.dart';
import '../data/texts.dart';
import '../widget/papp_bar.dart';

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();

  ArtistPage(this.artistAvatar, this.artistName, this.artistId,
      {this.isFollowed, this.followedRefresh});

  final String artistAvatar;
  final String artistName;
  final String artistId;
  final bool isFollowed;
  final Function(bool) followedRefresh;
}

class _ArtistPageState extends State<ArtistPage> {
  bool loginState = prefs.getString('auth') != '' ? true : false;
  TextZhArtistPage text = TextZhArtistPage();
  bool isFollowed;
  ScrollController scrollController = ScrollController();
  PappBar pappBar;

  TextStyle smallTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(10),
      color: Colors.black,
      decoration: TextDecoration.none);
  TextStyle normalTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(14),
      color: Colors.black,
      decoration: TextDecoration.none);

  String numOfFollower = '';
  String numOfBookmarksPublic = '';
  String numOfIllust = '0';
  String numOfManga = '0';
  String comment = '';
  String urlTwitter = '';
  String urlWebPage = '';
  List<Tab> tabs;
  bool isDataLoaded;

  @override
  void initState() {
    isDataLoaded = false;
    isFollowed = widget.isFollowed;
    _initPappbar();
    _loadArtistData().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: pappBar,
      body: !isDataLoaded
          ? Container(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
              alignment: Alignment.center,
              color: Colors.white,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: widget.artistAvatar,
                      child: CircleAvatar(
                        backgroundImage: AdvancedNetworkImage(
                          widget.artistAvatar,
                          header: {'Referer': 'https://app-api.pixiv.net'},
                          useDiskCache: true,
                          cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                        ),
                      ),
                    ),
                    Lottie.asset('image/loading-box.json'),
                  ],
                ),
              ))
          : Container(
              color: Colors.white,
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: <Widget>[
                  // 头像、名称、关注按钮
                  Container(
                      padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                      margin: EdgeInsets.all(ScreenUtil().setHeight(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Hero(
                            tag: widget.artistAvatar,
                            child: CircleAvatar(
                              backgroundImage: AdvancedNetworkImage(
                                widget.artistAvatar,
                                header: {
                                  'Referer': 'https://app-api.pixiv.net'
                                },
                                useDiskCache: true,
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(20),
                          ),
                          Text(
                            widget.artistName,
                            style: normalTextStyle,
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(25),
                          ),
                          loginState ? _subscribeButton() : Container(),
                        ],
                      )),
                  // 个人网站和 Twitter
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () async {
                              if (await canLaunch(urlWebPage)) {
                                await launch(urlWebPage);
                              } else {
                                BotToast.showSimpleNotification(
                                    title: '唤起网页失败');
                                throw 'Could not launch $urlWebPage';
                              }
                            },
                            child: FaIcon(
                              FontAwesomeIcons.home,
                              color: Colors.blue,
                            )),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        GestureDetector(
                            onTap: () async{
                              if (await canLaunch(urlTwitter)) {
                                await launch(urlTwitter);
                              } else {
                                BotToast.showSimpleNotification(
                                    title: '唤起网页失败');
                                throw 'Could not launch $urlTwitter';
                              }
                            },
                            child: FaIcon(
                              FontAwesomeIcons.twitterSquare,
                              color: Colors.blue,
                            ))
                      ],
                    ),
                  ),
                  // 关注人数
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                    child: (Text(
                      '$numOfFollower 关注',
                      style: smallTextStyle,
                    )),
                  ),
                  // 简介
                  Container(
                    margin: EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: Wrap(
                      children: <Widget>[
                        Text(
                          '$comment',
                          style: smallTextStyle,
                        ),
                      ],
                    ),
                  ),
                  // 相关图片
                  Container(
                    height: ScreenUtil().setHeight(521),
                    width: ScreenUtil().setWidth(324),
                    child: _tabViewer(),
                  )
                ],
              ),
            ),
    );
  }

  _loadArtistData() async {
    String urlId = 'https://api.pixivic.com/artists/${widget.artistId}';
    String urlSummary =
        'https://api.pixivic.com/artists/${widget.artistId}/summary';

    try {
      var requests = await Requests.get(urlId);
      requests.raiseForStatus();
      var jsonList = jsonDecode(requests.content())['data'];
      this.comment = jsonList['comment'].replaceAll("\n", "");
      this.urlTwitter = jsonList['twitterUrl'];
      this.urlWebPage = jsonList['webPage'];
      this.numOfBookmarksPublic = jsonList['totalIllustnumOfBookmarksPublic'];
      this.numOfFollower = jsonList['totalFollowUsers'];

      requests = await Requests.get(urlSummary);
      requests.raiseForStatus();
      jsonList = jsonDecode(requests.content())['data'];
      this.numOfIllust = jsonList['illustSum'].toString();
      this.numOfManga = jsonList['mangaSum'].toString();
      this.tabs = <Tab>[
        Tab(
          text: '插画(${this.numOfIllust})',
        ),
        Tab(
          text: '漫画(${this.numOfManga})',
        ),
      ];
      isDataLoaded = true;
    } catch (error) {
      print('======================');
      print(error);
      print('======================');
      BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
      isDataLoaded = false;
    }

    return ('finished');
  }

  _onTopOfPicpage() {
    double position =
        scrollController.position.extentBefore - ScreenUtil().setHeight(350);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  _onStartOfPicpage() {
    double position =
        scrollController.position.extentBefore + ScreenUtil().setHeight(550);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Widget _tabViewer() {
    // 初始化时 tabs 为 null，获取结果后被赋值
    if (tabs != null) {
      return DefaultTabController(
        length: 2,
        child: Stack(
          children: <Widget>[
            Material(
                child: Container(
                    height: ScreenUtil().setHeight(30),
                    child: TabBar(
                      labelColor: Colors.blueAccent[200],
                      tabs: tabs,
                    ))),
            Positioned(
              top: ScreenUtil().setHeight(30),
              child: Container(
                height: ScreenUtil().setHeight(491),
                width: ScreenUtil().setWidth(324),
                child: TabBarView(
                  children: tabs.map((Tab tab) {
                    return PicPage.artist(
                      artistId: widget.artistId,
                      isManga: tab.text.contains('漫画') ? true : false,
                      onPageTop: _onTopOfPicpage,
                      onPageStart: _onStartOfPicpage,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return (Container());
    }
  }

  Widget _subscribeButton() {
    bool currentFollowedState = isFollowed;
    String buttonText = currentFollowedState ? text.followed : text.follow;

    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Colors.blueAccent[200],
      onPressed: () async {
        String url = 'https://api.pixivic.com/users/followed';
        Map<String, String> body = {
          'artistId': widget.artistId,
          'userId': prefs.getInt('id').toString(),
          'username': prefs.getString('name'),
        };
        Map<String, String> headers = {
          'authorization': prefs.getString('auth')
        };
        try {
          if (currentFollowedState) {
            var r = await Requests.delete(url,
                body: body,
                headers: headers,
                bodyEncoding: RequestBodyEncoding.JSON);
            r.raiseForStatus();
          } else {
            var r = await Requests.post(url,
                body: body,
                headers: headers,
                bodyEncoding: RequestBodyEncoding.JSON);
            r.raiseForStatus();
          }
          setState(() {
            isFollowed = !isFollowed;
          });
          if (widget.followedRefresh != null)
            widget.followedRefresh(isFollowed);
        } catch (e) {
          print(e);
          // print(homePicList[widget.index]['artistPreView']['isFollowed']);
          BotToast.showSimpleNotification(title: text.followError);
        }
      },
      child: Text(
        buttonText,
        style:
            TextStyle(fontSize: ScreenUtil().setWidth(10), color: Colors.white),
      ),
    );
  }

  _initPappbar() {
    String tempTitle = widget.artistName;
    tempTitle.length > 20
        ? tempTitle = tempTitle.substring(0, 20) + '...'
        : tempTitle = tempTitle;
    pappBar = PappBar(title: tempTitle);
  }
}
