import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/record/page_record.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserDetail detail = UserAccount.of(context).userDetail;
    if (detail == null) {
      return userNotLogin(context);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: GestureDetector(
      // child: InkWell(
      //   customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId),
          //   ),
          // );
        },
        child: Container(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              // CircleAvatar(
              //   backgroundImage: CachedImage(detail.profile.avatarUrl),
              //   radius: 20,
              // ),
              CheckVersion(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.profile.nickname),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            "Lv.${detail.level}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (UserAccount.of(context, rebuildOnChange: false).isLogin) {
                    context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
                      return RecordPage(uid: UserAccount.of(context, rebuildOnChange: false).userId);
                    }));
                  } else {
                    Navigator.of(context).pushNamed(pageLogin);
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    children: [
                      Text('最近播放', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),),
                      Icon(Icons.play_arrow_rounded, color: Theme.of(context).primaryColor,)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget userNotLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.of(context).pushNamed(pageLogin);
        },
        child: Container(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.person),
                radius: 20,
              ),
              SizedBox(width: 12),
              Text(context.strings["login_right_now"]),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}

class CheckVersion extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CheckVersionState();
  }
}

class CheckVersionState extends State<CheckVersion>{

  bool checkIng = false;

  Future<PackageInfo> _futureBuilderFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureBuilderFuture = _gerData();
  }

  Future<PackageInfo> _gerData() async {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    if(checkIng) {
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
    Color defaultColor = Colors.deepOrange;
    Color randomColor = Color.fromRGBO(Random().nextInt(150), Random().nextInt(150), Random().nextInt(150), 1);
    // TODO: implement build
    return GestureDetector(
      onTap: () async {
        checkIng = true;
        setState(() {});
        // await ApiUtil.updateApi(context, true, mustToast: true);
        Future.delayed(Duration(milliseconds: 1500), () {
          checkIng = false;
          setState(() {});
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 50,
        width: 50,
        alignment: Alignment.center,
        // 左上右下
        decoration: BoxDecoration(color: checkIng ? randomColor : defaultColor, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("版本", style: TextStyle(fontSize: 12, color: Colors.white),),
            FutureBuilder<PackageInfo>(
                future: _futureBuilderFuture,
                builder: (context, sData) {
                  return Text("${sData.data?.version??"12"}", style: TextStyle(fontSize: 12, color: Colors.white),);
                })
          ],
        ),
      ),
    );
  }
}
