import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../playlist_tile.dart';

enum PlayListType { article, album, anthology }

class PlayListsGroupHeader extends StatelessWidget {
  final String name;
  final int count;

  const PlayListsGroupHeader({Key key, @required this.name, this.count}) : super(key: key);

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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: enableBottomRadius ? const BorderRadius.vertical(bottom: Radius.circular(4)) : null,
        color: Theme.of(context).backgroundColor,
        child: Container(
          child: PlaylistTile(playlist: data),
        ),
      ),
    );
  }
}

const double _kPlayListHeaderHeight = 48;

const double _kPlayListDividerHeight = 10;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  MyPlayListsHeaderDelegate(this.tabController);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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

class _MyPlayListsHeader extends StatelessWidget implements PreferredSizeWidget {
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
          Tab(text: context.strings["favorite_anthology_list"]),
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

  const PlayListSliverKey({this.createdPosition, this.favoritePosition}) : super("_PlayListSliverKey");
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
          return _singleSliver(child: Loader.buildSimpleFailedWidget(context, result));
        },
        builder: (context, result) {
          final created = result.where((p) => p.creator["userId"] == widget.userId).toList();
          final subscribed = result.where((p) => p.creator["userId"] != widget.userId);
          _dividerIndex = 2 + created.length;
          return SliverList(
            key: PlayListSliverKey(createdPosition: 1, favoritePosition: 3 + created.length),
            delegate: SliverChildListDelegate.fixed([
              Container(
                height: MediaQuery.of(context).size.height - 270,
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: widget.pageController,
                  children: [
                    ..._playlistWidget(created, item: true),
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        padding: EdgeInsets.only(top: 20),
                        children: _playlistWidget(subscribed),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 16),
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

  static Iterable<Widget> _playlistWidget(Iterable<PlaylistDetail> details, {bool item}) {
    if (details.isEmpty) {
      return const [];
    }
    final list = details.toList(growable: false);
    final List<Widget> widgets = <Widget>[];
    if(item??false) {
      widgets.add(Container(
        color: Colors.white,
        margin: EdgeInsets.only(left: 16, right: 16),
        padding: EdgeInsets.only(top: 10),
        child: FutureBuilder<PlaylistDetail>(
            future: neteaseLocalData.getPlaylistDetail(details.first.id),
            builder: (context, result) {
              return result?.data == null ? Container() : PlaylistBody(result?.data, noHeader: true, count: result?.data?.musicList?.length);
            }),
      ));
    } else {
      for (int i = 0; i < list.length; i++) {
        widgets.add(MainPlayListTile(data: list[i], enableBottomRadius: i == list.length - 1));
      }
    }

    return widgets;
  }

  static Widget _singleSliver({@required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }
}
