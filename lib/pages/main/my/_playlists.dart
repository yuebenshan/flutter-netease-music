import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/Utils.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../playlist_tile.dart';

enum PlayListType { article, album }

class PlayListsGroupHeader extends StatelessWidget {
  final String name;
  final int count;

  const PlayListsGroupHeader({Key key, @required this.name, this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        color: Theme.of(context).backgroundColor,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text("$name($count)"),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPlayListTile extends StatelessWidget {
  final PlaylistDetail data;
  final bool enableBottomRadius;

  const MainPlayListTile({
    Key key,
    @required this.data,
    this.enableBottomRadius = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        borderRadius: enableBottomRadius
            ? const BorderRadius.vertical(bottom: Radius.circular(4))
            : null,
        color: Theme.of(context).backgroundColor,
        child: Container(
          child: PlaylistTile(playlist: data),
        ),
      ),
    );
  }
}

const double _kPlayListHeaderHeight = 48;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  MyPlayListsHeaderDelegate(this.tabController);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _MyPlayListsHeader(controller: tabController);
  }

  @override
  double get maxExtent => _kPlayListHeaderHeight;

  @override
  double get minExtent => _kPlayListHeaderHeight;

  @override
  bool shouldRebuild(covariant MyPlayListsHeaderDelegate oldDelegate) {
    return oldDelegate.tabController != tabController;
  }
}

class _MyPlayListsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController controller;

  const _MyPlayListsHeader({Key key, this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(_kPlayListHeaderHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        labelColor: Theme.of(context).textTheme.bodyText1.color,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(text: context.strings["favorite_article_list"]),
          Tab(text: context.strings["favorite_album_list"]),
          // Tab(text: context.strings["favorite_anthology_list"]),
        ],
      ),
    );
  }
}

class PlayListTypeNotification extends Notification {
  final PlayListType type;

  PlayListTypeNotification({@required this.type});
}

class PlayListSliverKey extends ValueKey {
  final int createdPosition;
  final int favoritePosition;

  const PlayListSliverKey({this.createdPosition, this.favoritePosition})
      : super("_PlayListSliverKey");
}

class UserPlayListSection extends StatefulWidget {
  const UserPlayListSection({
    Key key,
    @required this.userId,
    this.pageController,
  }) : super(key: key);

  final int userId;
  final PageController pageController;

  @override
  _UserPlayListSectionState createState() => _UserPlayListSectionState();
}

class _UserPlayListSectionState extends State<UserPlayListSection> {
  final logger = Logger("_UserPlayListSectionState");

  final _dividerKey = GlobalKey();

  int _dividerIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserPlayListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!UserAccount.of(context).isLogin) {
      return _singleSliver(child: notLogin(context));
    }
    return Loader<List<PlaylistDetail>>(
        initialData: neteaseLocalData.getUserPlaylist(widget.userId),
        loadTask: () {
          return neteaseRepository.userPlaylist(widget.userId);
        },
        loadingBuilder: (context) {
          return _singleSliver(child: Container());
        },
        errorBuilder: (context, result) {
          return _singleSliver(
              child: Loader.buildSimpleFailedWidget(context, result));
        },
        builder: (context, result) {
          final created = result
              .where((p) => p.creator["userId"] == widget.userId)
              .toList();
          final subscribed =
              result.where((p) => p.creator["userId"] != widget.userId);
          _dividerIndex = 2 + created.length;
          return SliverList(
            key: PlayListSliverKey(
                createdPosition: 1, favoritePosition: 3 + created.length),
            delegate: SliverChildListDelegate.fixed([
              Container(
                height: MediaQuery.of(context).size.height - 270,
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: widget.pageController,
                  children: [
                    Loader<Map>(
                        loadTask: () => neteaseRepository.recommendSongs(),
                        builder: (context, result) {
                          List<Music> list = (result["recommend"] as List)
                              .cast<Map>()
                              .map(mapJsonToMusic)
                              .toList();
                          return StatefulBuilder(builder: (context, listState) {
                            return MusicTileConfiguration(
                                token: 'playlist_daily_recommend',
                                musics: list,
                                type: 'my',
                                remove: (Music music) {
                                  list = list.where((Music element) => element.id != music.id).toList();
                                  listState(() {});
                                },
                                trailingBuilder:
                                MusicTileConfiguration.defaultTrailingBuilder,
                                leadingBuilder:
                                MusicTileConfiguration.coverLeadingBuilder,
                                onMusicTap: MusicTileConfiguration.defaultOnTap,
                                child: MusicFavList());
                          });
                        }),
                    Container(
                      color: Colors.white,
                      child: ListView(
                        padding: EdgeInsets.only(top: 20),
                        children: _playlistWidget(subscribed),
                      ),
                    ),
                  ],
                ),
              )
            ], addAutomaticKeepAlives: false),
          );
        });
  }

  Widget notLogin(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(context.strings["playlist_login_description"]),
          TextButton(
            child: Text(context.strings["login_right_now"]),
            onPressed: () {
              Navigator.of(context).pushNamed(pageLogin);
            },
          ),
        ],
      ),
    );
  }

  static Iterable<Widget> _playlistItemWidget() {
    final List<Widget> widgets = <Widget>[];
    return widgets;
  }

  static Iterable<Widget> _playlistWidget(Iterable<PlaylistDetail> details) {
    if (details.isEmpty) {
      return const [];
    }

    final list = details.toList(growable: false);
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      widgets.add(MainPlayListTile(
          data: list[i], enableBottomRadius: i == list.length - 1));
    }
    return widgets;
  }

  static Widget _singleSliver({@required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }

  static Future<PlaylistDetail> playlistDetail(id) async {
    return (await neteaseRepository.playlistDetail(id)).asFuture;
  }
}

class MusicFavList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(16)),
            child: InkWell(
              onTap: () {
                final list =
                MusicTileConfiguration.of(context);
                if (context.player.queue.queueId ==
                    list.token &&
                    context.player.playbackState
                        .isPlaying) {
                  //open playing page
                  Navigator.pushNamed(
                      context, pagePlaying);
                } else {
                  context.player.playWithQueue(
                      PlayQueue(
                          queue: list.queue,
                          queueId: list.token,
                          queueTitle: list.token));
                }
              },
              child: SizedBox.fromSize(
                size: Size.fromHeight(50),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding:
                      EdgeInsets.only(left: 20),
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Theme.of(context)
                          .iconTheme
                          .color,
                    ),
                    Padding(
                        padding:
                        EdgeInsets.only(left: 4)),
                    Text(
                      "播放全部",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2,
                    ),
                    Padding(
                        padding:
                        EdgeInsets.only(left: 2)),
                    Text(
                      "(共${MusicTileConfiguration.of(context).musics.length}首)",
                      style: Theme.of(context)
                          .textTheme
                          .caption,
                    ),
                    Spacer(),
                  ]..removeWhere((v) => v == null),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return MusicTile(MusicTileConfiguration.of(context).musics[index]);
                },
                itemCount: MusicTileConfiguration.of(context).musics.length,
              ))
        ],
      ),
    );
  }
}
