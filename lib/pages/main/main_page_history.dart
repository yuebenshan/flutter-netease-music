import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/main/playlist_tile.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainPageHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainPageHistory> with AutomaticKeepAliveClientMixin {
  PageController _pageController = PageController(initialPage: 0);

  int activeIndex = 0;

  @override
  bool get wantKeepAlive => true;
  StateSetter _navigationLineState;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        // StatefulBuilder(builder: (context, navigationLineState) {
        //   _navigationLineState = navigationLineState;
        //   return _NavigationLine(
        //       pageCtrl: _pageController,
        //       activeIndex: activeIndex
        //   );
        // }),
        Expanded(child: _secondPage(0))
      ],
    );
  }
}

class _secondPage extends StatefulWidget {
  final int pageType;

  const _secondPage(this.pageType, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _secondPageState();
  }

}
class _secondPageState extends State<_secondPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          height: 50,
          child: TabBar(
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            controller: _tabController,
            tabs: List.filled(10, 0).map((e) => Text('标题', softWrap: false, style: Theme.of(context).textTheme.subtitle1,)).toList(),
          ),
        ),
        Expanded(child: TabBarView(
          controller: _tabController,
          children: List.filled(10, null).map((e) => SectionPlaylist(limit: 16,)).toList(),
        ))
      ],
    );
  }

}
class _NavigationLine extends StatelessWidget {
  final PageController pageCtrl;
  final int activeIndex;


  const _NavigationLine({Key key, this.pageCtrl, this.activeIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int active = activeIndex;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: StatefulBuilder(
        builder: (context, stateSetter) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _ItemNavigator(Icons.today, "所有专辑", () {
                active = 0;
                stateSetter(() {});
                pageCtrl.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                // context.secondaryNavigator.pushNamed(pageDaily);
              }, active: active == 0),
              _ItemNavigator(Icons.show_chart, "所有选集", () {
                active = 1;
                stateSetter(() {});
                pageCtrl.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                // context.secondaryNavigator.pushNamed(pageLeaderboard);
              }, active: active == 1),
            ],
          );
        },
      ),
    );
  }
}

class _ItemNavigator extends StatelessWidget {
  final IconData icon;

  final String text;
  final bool active;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: <Widget>[
              Material(
                shape: CircleBorder(),
                elevation: 5,
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).primaryColor,
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(text, style: TextStyle(color: active ? Theme.of(context).primaryColor : Colors.black),),
            ],
          ),
        ));
  }

  _ItemNavigator(this.icon, this.text, this.onTap, {this.active});
}

class SectionPlaylist extends StatelessWidget {
  final int limit;

  const SectionPlaylist({Key key, this.limit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedPlaylist(limit: limit),
      builder: (context, result) {
        List<Map> list = (result["result"] as List).cast();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 20),
          itemBuilder: (context, index) {
            return PlaylistTile(playlist: PlaylistDetail.fromJson({
              'id': list[index]['id'],
              'musicList': [],
              'creator': null,
              'name': list[index]['name']??"伴儿",
              'coverUrl': list[index]['picUrl'],
              'trackCount': 0,
              'description': list[index]['copywriter']??"介绍",
              'subscribed': false,
              'subscribedCount': 1,
              'commentCount': 1,
              'shareCount': 1,
              'playCount': 2
            }));
          },
          itemCount: list.length,
        );
        // return LayoutBuilder(builder: (context, constraints) {
        //   assert(constraints.maxWidth.isFinite, "can not layout playlist item in infinite width container.");
        //   final parentWidth = constraints.maxWidth - 32;
        //   int count = /* false ? 6 : */ 3;
        //   double width = (parentWidth ~/ count).toDouble().clamp(80.0, 200.0);
        //   double spacing = (parentWidth - width * count) / (count + 1);
        //   return Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16 + spacing.roundToDouble()),
        //     child: Wrap(
        //       spacing: spacing,
        //       direction: Axis.horizontal,
        //       children: list.map<Widget>((p) {
        //         return _PlayListItemView(playlist: p, width: width);
        //       }).toList(),
        //     ),
        //   );
        // }
        // );
      },
    );
  }
}

class _PlayListItemView extends StatelessWidget {
  final Map playlist;

  final double width;

  const _PlayListItemView({
    Key key,
    @required this.playlist,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GestureLongPressCallback onLongPress;

    String copyWrite = playlist["copywriter"];
    if (copyWrite != null && copyWrite.isNotEmpty) {
      onLongPress = () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  playlist["copywriter"],
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () {
        context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(
            playlist["id"],
          );
        }));
      },
      onLongPress: onLongPress,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: <Widget>[
            Container(
              height: width,
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FadeInImage(
                    placeholder: AssetImage("assets/playlist_playlist.9.png"),
                    image: CachedImage(playlist["picUrl"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              playlist["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionNewSongs extends StatelessWidget {
  Music _mapJsonToMusic(Map json) {
    Map<String, Object> song = json["song"];
    return mapJsonToMusic(song);
  }

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedNewSong(),
      builder: (context, result) {
        List<Music> songs = (result["result"] as List).cast<Map>().map(_mapJsonToMusic).toList();
        return MusicTileConfiguration(
          musics: songs,
          token: 'playlist_main_newsong',
          onMusicTap: MusicTileConfiguration.defaultOnTap,
          leadingBuilder: MusicTileConfiguration.coverLeadingBuilder,
          trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
          child: Column(
            children: songs.map((m) => MusicTile(m)).toList(),
          ),
        );
      },
    );
  }
}
