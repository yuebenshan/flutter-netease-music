part of "page_main.dart";

class _LandscapeMainPage extends StatefulWidget {
  @override
  _LandscapeMainPageState createState() => _LandscapeMainPageState();
}

const _navigationSearch = pageSearch;

const _navigationMyPlaylist = "playlist";

const _navigationCloud = "cloud";

const _navigationFmPlayer = "fm";

const _navigationSettings = "settings";

const List<String> _navigations = [_navigationSearch, _navigationMyPlaylist, _navigationCloud, _navigationFmPlayer];

class _LandscapeMainPageState extends State<_LandscapeMainPage> with NavigatorObserver {
  static const double DRAWER_WIDTH = 120.0;

  final GlobalKey<NavigatorState> _landscapeNavigatorKey = GlobalKey(debugLabel: "landscape_main_navigator");

  final GlobalKey<NavigatorState> _landscapeSecondaryNavigatorKey = GlobalKey(
    debugLabel: "landscape_secondary_navigator",
  );

  String _currentSubRouteName;

  @override
  void didPush(Route route, Route previousRoute) {
    _onPageSelected(route);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    _onPageSelected(previousRoute);
  }

  void _onPageSelected(Route route) {
    final name = route.settings.name;
    debugPrint("on landscape show : $name");
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      setState(() {
        _currentSubRouteName = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: DisableBottomController(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints.tightFor(width: DRAWER_WIDTH),
                    decoration: BoxDecoration(
                        border: BorderDirectional(end: BorderSide(color: Theme.of(context).dividerColor))),
                    child: _LandscapeDrawer(selectedRouteName: _currentSubRouteName),
                  ),
                  Expanded(
                    child: OverlapNavigator(
                      child: ScreenSplitWidget(
                        start: MainPlaylistPage(),
                        end: _SecondaryPlaceholder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomPlayerBar(
            paddingPageBottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }
}

class ScreenSplitWidget extends StatelessWidget {
  final Widget start;
  final Widget end;

  const ScreenSplitWidget({Key key, @required this.start, @required this.end})
      : assert(start != null),
        assert(end != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: start),
        Flexible(child: end),
      ],
    );
  }
}

class _LandscapeDrawer extends StatelessWidget {
  // Current selected page name in Main Drawer.
  final String selectedRouteName;

  const _LandscapeDrawer({Key key, @required this.selectedRouteName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DrawerTile(
                selected: _navigationSearch == selectedRouteName,
                icon: Icon(Icons.search),
                title: Text("搜索"),
                onTap: () {
                  context.primaryNavigator.pushNamed(_navigationSearch);
                }),
            _DrawerTile(
                selected: _navigationMyPlaylist == selectedRouteName,
                icon: Icon(Icons.music_note),
                title: Text("我的音乐"),
                onTap: () {
                  context.primaryNavigator.pushNamed(_navigationMyPlaylist);
                }),
            _DrawerTile(
                selected: _navigationCloud == selectedRouteName,
                icon: Icon(Icons.cloud),
                title: Text("发现音乐"),
                onTap: () {
                  context.primaryNavigator.pushNamed(_navigationCloud);
                }),
            _DrawerTile(
                selected: _navigationFmPlayer == selectedRouteName,
                icon: Icon(Icons.radio),
                title: Text("私人FM"),
                onTap: () {
                  context.primaryNavigator.pushNamed(_navigationFmPlayer);
                }),
            Spacer(),
            _DrawerTile(
              icon: Icon(Icons.settings),
              title: Container(),
              onTap: () {
                context.primaryNavigator.pushNamed(_navigationSettings);
              },
            ),
            _DrawerTile(
                icon: Icon(Icons.account_circle),
                title: Text("我的"),
                onTap: () {
                  if (!UserAccount.of(context).isLogin) {
                    context.rootNavigator.pushNamed(pageLogin);
                    return;
                  }
                  context.primaryNavigator.push(
                    MaterialPageRoute(builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId)),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// Default page for secondary navigator
class _SecondaryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("仿网易云音乐"),
            InkWell(
              child: Text("https://github.com/boyan01/flutter-netease-music",
                  style: TextStyle(color: Theme.of(context).accentColor)),
              onTap: () {
                launch("https://github.com/boyan01/flutter-netease-music");
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom player bar for landscape
class _BottomPlayerBar extends StatelessWidget {
  final double paddingPageBottom;

  const _BottomPlayerBar({Key key, this.paddingPageBottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      return SizedBox(height: paddingPageBottom);
    }
    return BottomControllerBar(
      bottomPadding: paddingPageBottom,
    );
  }
}
