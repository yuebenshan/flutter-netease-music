import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:quiet/part/part.dart';

import '_playlists.dart';
import '_preset_grid.dart';
import '_profile.dart';

///the first page display in page_main
class MainPageMy extends StatefulWidget {
  @override
  createState() => _MainPageMyState();
}

class _MainPageMyState extends State<MainPageMy> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final Logger logger = Logger("_MainPlaylistState");

  ScrollController _scrollController = ScrollController();

  TabController _tabController;
  PageController _pageController;

  bool _scrollerAnimating = false;
  bool _tabAnimating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: PlayListType.values.length, vsync: this);
    _pageController = PageController(initialPage: 0);
    _tabController.addListener(_onUserSelectedTab);
  }

  // 三个菜单切换
  void _onUserSelectedTab() {
    logger.info("_onUserSelectedTab : ${_tabController.index} ${_tabController.indexIsChanging}");
    _pageController.animateToPage(_tabController.index, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    if (_scrollerAnimating || _tabAnimating) {
      return;
    }
    // _scrollToPlayList(PlayListType.values[_tabController.index]);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = UserAccount.of(context).userId;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              UserProfileSection(),
              // PresetGridSection(),
              SizedBox(height: 8),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: MyPlayListsHeaderDelegate(_tabController),
        ),
        NotificationListener<PlayListTypeNotification>(
          onNotification: (notification) {
            _updateCurrentTabSelection(notification.type);
            return true;
          },
          child: UserPlayListSection(
            userId: userId,
            pageController: _pageController,
          ),
        ),
      ],
    );
  }

  void _computeScroller(void callback(PlayListSliverKey sliverKey, List<Element> children, int start, int end)) {
    SliverMultiBoxAdaptorElement playListSliver;
    void playListSliverFinder(Element element) {
      if (element.widget.key is PlayListSliverKey) {
        playListSliver = element;
      } else if (playListSliver == null) {
        element.visitChildElements(playListSliverFinder);
      }
    }

    // to find PlayListSliver.
    context.visitChildElements(playListSliverFinder);

    final PlayListSliverKey sliverKey = playListSliver.widget.key as PlayListSliverKey;
    assert(playListSliver != null, "can not find sliver");
    assert(sliverKey != null, "can not find sliver");

    logger.info("sliverKey : created position: ${sliverKey.createdPosition} ${sliverKey.favoritePosition}");

    final List<Element> children = [];
    playListSliver.visitChildElements((element) {
      children.add(element);
    });
    if (children.isEmpty) {
      return;
    }
    final start = _index(children.first);
    final end = _index(children.last);
    if (end <= start) {
      return;
    }
    logger.info("position start - end -> $start - $end");
    callback(sliverKey, children, start, end);
  }


  static int _index(Element element) {
    int index;
    void _findIndex(Element e) {
      if (e.widget is IndexedSemantics) {
        index = (e.widget as IndexedSemantics).index;
      } else {
        e.visitChildElements(_findIndex);
      }
    }

    element.visitChildElements(_findIndex);
    assert(index != null, "can not get index for element $element");
    return index;
  }

  @override
  bool get wantKeepAlive => true;

  void _updateCurrentTabSelection(PlayListType type) async {
    if (_tabController.index == type.index) {
      return;
    }
    if (_tabController.indexIsChanging || _scrollerAnimating || _tabAnimating) {
      return;
    }
    _tabAnimating = true;
    _tabController.animateTo(type.index, duration: kTabScrollDuration);
    Future.delayed(kTabScrollDuration + Duration(milliseconds: 100)).whenComplete(() {
      _tabAnimating = false;
    });
  }
}
