import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/component.dart';
import 'package:quiet/pages/comments/comments.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/repository.dart';
import 'package:scoped_model/scoped_model.dart';

import 'music_video_detail.dart';
import 'video_player_model.dart';

class MusicVideoPageScope extends StatelessWidget {
  final int mvId;

  final Widget child;

  const MusicVideoPageScope({Key key, this.mvId, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loader(
        loadTask: () => neteaseRepository.mvDetail(mvId),
        builder: (context, result) {
          final MusicVideoDetail detail = MusicVideoDetail.fromJsonMap(result['data']);
          final bool subscribed = result['subed'];
          return MusicVideoContainer(musicVideoDetail: detail, subscribed: subscribed, child: child);
        });
  }
}

class MusicVideoContainer extends StatefulWidget {
  final MusicVideoDetail musicVideoDetail;
  final bool subscribed;
  final Widget child;

  const MusicVideoContainer({Key key, this.musicVideoDetail, this.subscribed, this.child}) : super(key: key);

  @override
  _MusicVideoContainerState createState() => _MusicVideoContainerState();
}

class _MusicVideoContainerState extends State<MusicVideoContainer> {
  VideoPlayerModel _model;
  bool _pausedPlayingMusic = false;

  @override
  void initState() {
    super.initState();
    _model = VideoPlayerModel(widget.musicVideoDetail, subscribed: widget.subscribed);
    _model.videoPlayerController.play();
    //TODO audio focus
    if (context.player.playbackState.isPlaying) {
      context.transportControls.pause();
      _pausedPlayingMusic = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _model.videoPlayerController.dispose();
    //try to resume paused music
    if (_pausedPlayingMusic) {
      context.transportControls.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentId = CommentThreadId(_model.data.id, CommentType.mv);
    return ScopedModel<VideoPlayerModel>(
      model: _model,
      child: ScopedModel<CommentList>(
        model: CommentList(commentId),
        child: widget.child,
      ),
    );
  }
}
