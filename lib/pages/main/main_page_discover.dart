import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/generated/json/base/json_convert_content.dart';
import 'package:quiet/model/category_entity.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/main/my/_playlists.dart';
import 'package:quiet/pages/main/playlist_tile.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainPageDiscover extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainPageDiscover> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Loader<Map>(
      loadTask: () => neteaseRepository.getPinnedCategoryList(),
      builder: (context, result) {
        List<CategoryEntity> pinnedCategoryList = (result['pinnedCategoryList'] as List).map((e) => JsonConvert.fromJsonAsT<CategoryEntity>(e)).toList();
        pinnedCategoryList.insert(0, JsonConvert.fromJsonAsT<CategoryEntity>({
          'name': '最新',
          'termId': -1
        }));
        pinnedCategoryList.insert(1, JsonConvert.fromJsonAsT<CategoryEntity>({
          'name': '热门',
          'termId': 0
        }));
        _tabController = TabController(length: pinnedCategoryList.length, vsync: this);
        return Column(
          children: [
            _NavigationLine(),
            Container(
              height: 50,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                tabs: pinnedCategoryList.map((e) => Text('${e.name}', softWrap: false, style: Theme.of(context).textTheme.subtitle1,)).toList(),
              ),
            ),
            Expanded(child: TabBarView(
              controller: _tabController,
              children: List.filled(pinnedCategoryList.length, null).asMap().keys.map((e) => SectionNewSongs(category: pinnedCategoryList[e])).toList(),
            ))
          ],
        );
      }
    );
  }
}

class _NavigationLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _ItemNavigator(Icons.radio, "私人电台", () {
            if (context.player.queue.isPlayingFm) {
              context.secondaryNavigator.pushNamed(pageFmPlaying);
              return;
            }
            showLoaderOverlay(context, neteaseRepository.getPersonalFmMusics()).then((musics) {
              context.player.playFm(musics);
              context.secondaryNavigator.pushNamed(pageFmPlaying);
            }).catchError((error, stacktrace) {
              debugPrint("error to play personal fm : $error $stacktrace");
              toast('无法获取私人电台数据');
            });
          }),
          _ItemNavigator(Icons.today, "推荐列表", () {
            context.secondaryNavigator.pushNamed(pageDaily);
          }),
          // _ItemNavigator(Icons.show_chart, "排行榜", () {
          //   context.secondaryNavigator.pushNamed(pageLeaderboard);
          // }),
        ],
      ),
    );
  }
}

///common header for section
class _Header extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 20)),
          Text(
            text,
            style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  _Header(this.text, this.onTap);
}

class _ItemNavigator extends StatelessWidget {
  final IconData icon;

  final String text;

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
              Text(text),
            ],
          ),
        ));
  }

  _ItemNavigator(this.icon, this.text, this.onTap);
}

class SectionPlaylist extends StatelessWidget {
  final int limit;

  const SectionPlaylist({Key key, this.limit}) : super(key: key);

  get musicp => null;
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
  //
  // Future<PlaylistDetail> getPlayListDetail(list) async {
  //   if(musicp[list] != null) {
  //     return Future.value(musicp[list]);
  //   }
  //   return await (await neteaseRepository.playlistDetail(list)).asFuture;
  // }
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
  final CategoryEntity category;

  const SectionNewSongs({Key key, this.category}) : super(key: key);

  Music _mapJsonToMusic(Map json) {
    Map<String, Object> song = json["song"];
    return mapJsonToMusic(song);
  }

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => (category?.termId??0) > 0 ? neteaseRepository.getAudioListCategory(category?.termId??0) : neteaseRepository.getAudioListNew(1),
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
