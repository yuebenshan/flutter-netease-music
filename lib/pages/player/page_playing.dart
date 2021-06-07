import 'package:music_player/music_player.dart';
import 'package:quiet/material.dart';
import 'package:quiet/material/IconDownLoad.dart';
import 'package:quiet/material/player.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/pages/player/page_playing_landscape.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:dio/dio.dart';
import 'lyric.dart';
import 'player_progress.dart';
import 'package:html2md/html2md.dart' as html2md;

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    if (context.isLandscape) {
      return LandscapePlayingPage();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                PlayingTitle(music: current, light: true),
                _CenterSection(music: current),
                PlayingOperationBar(light: true),
                DurationProgressBar(light: true),
                PlayerControllerBar(light: true),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///player controller
/// pause,play,play next,play previous...
class PlayerControllerBar extends StatelessWidget {
  final bool light;

  const PlayerControllerBar({Key key, this.light}) : super(key: key);

  Widget getPlayModeIcon(BuildContext context, Color color) {
    return Icon(context.playMode.icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    var color = (light
            ? Theme.of(context).iconTheme
            : Theme.of(context).primaryIconTheme)
        .color;

    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            context.transportControls.play();
          }),
      buffering: Container(
        height: 56,
        width: 56,
        child: Center(
          child: Container(
              height: 24, width: 24, child: CircularProgressIndicator()),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: getPlayModeIcon(context, color),
              onPressed: () {
                context.transportControls.setPlayMode(context.playMode.next);
              }),
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToPrevious();
              }),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.menu,
                color: color,
              ),
              onPressed: () {
                PlayingListDialog.show(context);
              }),
        ],
      ),
    );
  }
}

class PlayingOperationBar extends StatelessWidget {
  final bool light;

  const PlayingOperationBar({Key key, this.light = false}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final iconColor = (light
            ? Theme.of(context).iconTheme
            : Theme.of(context).primaryIconTheme)
        .color;

    final music = context.listenPlayerValue.current;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LikeButton.current(context),
        IconDownLoad(music),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(
                  threadId: CommentThreadId(music.id, CommentType.song,
                      payload: CommentThreadPayload.music(music)),
                );
              }));
            }),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: () {
              notImplemented(context);
            }),
      ],
    );
  }
}

class _CenterSection extends StatefulWidget {
  final Music music;

  const _CenterSection({Key key, @required this.music}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(height: 2, fontSize: 16, color: Colors.white);
    return Expanded(child: LayoutBuilder(builder: (context, constraints) {
      //歌词顶部与尾部半透明显示
      return ShaderMask(
        shaderCallback: (rect) {
          return ui.Gradient.linear(Offset(rect.width / 2, 0),
              Offset(rect.width / 2, constraints.maxHeight), [
            const Color(0x00FFFFFF),
            style.color,
            style.color,
            const Color(0x00FFFFFF),
          ], [
            0.0,
            0.05,
            0.9,
            1
          ]);
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Text(html2md.convert(
            '<h1>【专栏】未来学习实验室的教学方法</h1>'
            '<h2>教学内容：真实职场所需要的内容</h2>'
            '<p>'
            '很多学生学习的内容只限于书本，很多培训机构也采用闭门造车的形式教导学生，从而导致学生毕业后发现自己学到的知识和企业要求的存在一定的差异；不仅如此，刚入职场的新人在面对上司、同事，及职场层出不穷的状况也常常措手不及。为了使学生入职后就能把学到的知识用到，并且可以在职场上处理问题游刃有余，我们培训的内容会着重针对职场实用技能：如真正能用得上的学术专业、正确的工作态度、职场人际关系处理方法、真实项目的模拟解决方案等。'
            '</p >'
            '<h2>采用案例式教学</h2>'
            '<p>整个专业课程会以真实案例及项目为主线，贯串学习知识点和技术点。通过老师的带领，使学员可以具有独立开发的能力，学生在结业时将会独立完成企业真实的项目。课程中的项目案例完全采用企业编码规范和设计规范，例如阿里巴巴 规范、合作企业'
            '规范等，提高学员编码规范性，增强程序的可读性和维护性。</p>'
            '<h2>企业大牛指导项目</h2>'
            '<p>为了要学员毕业后快速适应企业环境，我们特地从 IT 名企引入技术总监或项目经理作为学员的直接一对一导师，我们的老师都是职场精英，熟悉职场真实环境，避免老师带领学生闭门造车。由企业大牛来指导和管理学生的专业知识，项目研发过程、要学员'
            '真正体验企业开发过程；初次之外，我们的老师也会着重培养学生正面积极的性格和工作态度，传授给学生真实的职场生存指南，使学生成为职场上的精英人才</p >'
            '<h2>一对一的个性化学习</h2>'
            '<p>'
            '我们的培训内容是根据每个学生不同的教育背景、学习能力、个性和特长以及学习速度量身打造的。我们会在一开始教给学生学学习内容框架、学习方法、学习方向等；接着我们会提供给学生一个自学的时间和环境，在自学后由老师来为学生提供一对一的学习问题解答，并且根据学生情况不断的调整教学内容和教学方式。在这期间，我们会纠正学生错误的学习习惯、学方方式和思维模式等；提升学生的学习能力，使学生即时毕业就业后依然拥有终身学习的能力，可以在职场上不断提升。'
            '</p >'.replaceAll('\n', '<br/><br/>'))),
          ),
        ),
      );
    }));
  }
}

// 这是歌词
class PlayingLyricView extends StatelessWidget {
  final VoidCallback onTap;

  final Music music;

  const PlayingLyricView({Key key, this.onTap, @required this.music})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressTrackingContainer(
        builder: _buildLyric, player: context.player);
  }

  Widget _buildLyric(BuildContext context) {
    TextStyle style = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(height: 2, fontSize: 16, color: Colors.white);
    final playingLyric = PlayingLyric.of(context);

    if (playingLyric.hasLyric) {
      return LayoutBuilder(builder: (context, constraints) {
        final normalStyle = style.copyWith(color: style.color.withOpacity(0.7));
        //歌词顶部与尾部半透明显示
        return ShaderMask(
          shaderCallback: (rect) {
            return ui.Gradient.linear(Offset(rect.width / 2, 0),
                Offset(rect.width / 2, constraints.maxHeight), [
              const Color(0x00FFFFFF),
              style.color,
              style.color,
              const Color(0x00FFFFFF),
            ], [
              0.0,
              0.15,
              0.85,
              1
            ]);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Lyric(
              lyric: playingLyric.lyric,
              lyricLineStyle: normalStyle,
              highlight: style.color,
              position: context.playbackState.computedPosition,
              onTap: onTap,
              size: Size(
                  constraints.maxWidth,
                  constraints.maxHeight == double.infinity
                      ? 0
                      : constraints.maxHeight),
              playing: context.playbackState.isPlaying,
            ),
          ),
        );
      });
    } else {
      return Container(
        child: Center(
          child: Text(playingLyric.message, style: style),
        ),
      );
    }
  }
}

class PlayingTitle extends StatelessWidget {
  final Music music;
  final bool light;

  const PlayingTitle({Key key, @required this.music, this.light = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: AppBar(
        elevation: 0,
        primary: false,
        iconTheme: light
            ? Theme.of(context).iconTheme
            : Theme.of(context).primaryIconTheme,
        actionsIconTheme: light
            ? Theme.of(context).iconTheme
            : Theme.of(context).primaryIconTheme,
        textTheme: light
            ? Theme.of(context).textTheme
            : Theme.of(context).primaryTextTheme,
        leading: LandscapeWidgetSwitcher(
          portrait: (context) {
            return IconButton(
                tooltip: '返回上一层',
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).appBarTheme.color,
                ),
                onPressed: () => Navigator.pop(context));
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              music.title,
              style: TextStyle(fontSize: 17),
            ),
            InkWell(
              onTap: () {
                launchArtistDetailPage(context, music.artist);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: Text(
                      music.artistString,
                      style: (light
                              ? Theme.of(context).textTheme
                              : Theme.of(context).primaryTextTheme)
                          .bodyText2
                          .copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 17),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("下载"),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert,
            ),
          ),
          LandscapeWidgetSwitcher(landscape: (context) {
            return CloseButton(onPressed: () {
              context.rootNavigator.maybePop();
            });
          })
        ],
      ),
    );
  }
}
