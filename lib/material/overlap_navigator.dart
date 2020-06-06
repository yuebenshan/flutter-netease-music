import 'package:flutter/material.dart';

const double _kMinFlingVelocity = 365.0;
const Duration _kAnimationDuration = Duration(milliseconds: 300);

class OverlapNavigator extends StatefulWidget {
  final Widget child;

  const OverlapNavigator({Key key, this.child})
      : assert(child != null),
        super(key: key);

  @override
  _OverlapNavigatorState createState() => _OverlapNavigatorState();

  static OverlapNavigatorHandle of(BuildContext context, {bool root = false}) {
    _OverlapNavigatorState state;
    if (root) {
      state = context.findRootAncestorStateOfType<_OverlapNavigatorState>();
    } else {
      state = context.findAncestorStateOfType<_OverlapNavigatorState>();
    }
    assert(() {
      if (state == null) {
        throw FlutterError("state is null!");
      }
      return true;
    }());
    return _OverlapNavigatorController(state, context);
  }
}

extension OverlapNavigatorContextExt on BuildContext {
  OverlapNavigatorHandle get overlapNavigator => OverlapNavigator.of(this);

  OverlapNavigatorHandle get rootOverlapNavigator => OverlapNavigator.of(this, root: true);
}

abstract class OverlapNavigatorHandle {
  void push(WidgetBuilder builder);

  Future<bool> pop();
}

class _OverlapNavigatorController implements OverlapNavigatorHandle {
  final _OverlapNavigatorState _state;

  final BuildContext context;

  final int index;

  _OverlapNavigatorController(this._state, this.context) : index = _index(context);

  @override
  Future<bool> pop() async {
    if (index == null || index >= _state._routes.length - 1) {
      return _state.pop();
    } else {
      final int count = _state._routes.length - index + 1;
      int counter = count;
      while (counter > 0 && await _state.pop()) {
        counter--;
      }
      return counter != count;
    }
  }

  @override
  void push(WidgetBuilder builder) {
    if (index == null || index >= _state._routes.length - 1) {
      _state.push(builder);
    } else {
      _state.replace(index + 1, builder);
    }
  }

  static int _index(BuildContext context) {
    _PageIndex index = context.findAncestorWidgetOfExactType<_PageIndex>();
    return index?.index;
  }
}

class _OverlapNavigatorState extends State<OverlapNavigator> with TickerProviderStateMixin {
  List<WidgetBuilder> _routes = [];

  double get _translation => _pageSlideAnimation.value;

  AnimationController _animationController;

  Animation _pageSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: 0,
      vsync: this,
      duration: _kAnimationDuration,
      debugLabel: "breadcrumb navigator translation animation",
    );
    _pageSlideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _animationController
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void push(WidgetBuilder builder) {
    _routes.add(builder);
    _animationController.value = 1;
    _animationController.reverse();
  }

  void replace(int index, WidgetBuilder builder) {
    setState(() {
      _routes[index] = builder;
    });
  }

  Future<bool> pop() async {
    if (_routes.isEmpty) {
      return false;
    }
    await _animationController.forward().whenComplete(() {
      _routes.removeLast();
      _animationController.value = 0;
    });
    return true;
  }

  List<Widget> _buildPages(BoxConstraints pageConstraints) {
    if (_routes.isEmpty) return const [];
    List<Widget> list = [];

    // build offstage items
    for (int i = _routes.length - 3; i >= 0; i--) {
      bool offstage = true;
      if (i == _routes.length - 3 && _translation != 0) {
        offstage = false;
      }
      list.add(_buildPage(i, pageConstraints, isStart: true, offstage: offstage));
    }
    if (_routes.length - 2 >= 0) {
      Widget widget = _buildPage(
        _routes.length - 2,
        pageConstraints,
        isStart: true,
        offstage: false,
        translation: _translation,
      );
      list.add(widget);
    }
    list.add(_buildPage(
      _routes.length - 1,
      pageConstraints,
      isStart: false,
      offstage: false,
      translation: _translation,
    ));
    return list;
  }

  Widget _buildPage(
    int index,
    BoxConstraints pageConstraints, {
    @required bool isStart,
    @required bool offstage,
    double translation = 0.0,
  }) {
    assert(_routes.isNotEmpty);
    assert(index >= 0 && index < _routes.length);
    final Widget widget = Container(
      constraints: pageConstraints,
      child: _PageIndex(index: index, child: Builder(builder: _routes[index])),
    );
    return Offstage(
      offstage: offstage,
      child: Align(
        alignment: isStart ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
        child: Transform.translate(
          offset: Offset(translation * pageConstraints.maxWidth, 0),
          child: widget,
        ),
      ),
    );
  }

  Widget _gestureHandler({Widget child, double pageWidth}) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onHorizontalDragUpdate: (detail) {
        _animationController.value += (detail.delta.dx / pageWidth);
      },
      onHorizontalDragEnd: (detail) {
        if (detail.velocity.pixelsPerSecond.dx.abs() > _kMinFlingVelocity) {
          final double visualVelocity = detail.velocity.pixelsPerSecond.dx / pageWidth;
          _animationController.fling(velocity: visualVelocity).whenComplete(() {
            if (visualVelocity > 0) {
              _routes.removeLast();
              _animationController.value = 0;
            }
          });
        } else if (_animationController.value < 0.5) {
          _animationController.reverse();
        } else {
          pop();
        }
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await pop();
      },
      child: LayoutBuilder(
        builder: (context, constraint) {
          assert(constraint.hasBoundedWidth, "can not use BreadcrumbNavigator in unboundedWith Layout");
          final pageWidth = constraint.maxWidth / 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              _PageIndex(child: widget.child, index: -1),
              _gestureHandler(
                pageWidth: pageWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: _buildPages(
                    constraint.copyWith(
                      maxWidth: pageWidth,
                      minWidth: pageWidth,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _PageIndex extends StatelessWidget {
  /// The index in [_OverlapNavigatorState].
  /// -1 represent the initial page
  final int index;
  final Widget child;

  const _PageIndex({Key key, @required this.index, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
