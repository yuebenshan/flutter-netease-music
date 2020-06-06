part of 'page_music_video_player.dart';

class _PageMusicVideoLandScape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: CloseButton(),
          title: Text(context.obtainVideoPlayer.data.name),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(flex: 3, child: _VideoPlayerLayout()),
              Flexible(flex: 2, child: _CommentLayout()),
            ],
          ),
        )
      ],
    );
  }
}

class _VideoPlayerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SimpleMusicVideo(),
        _InformationSection(),
        _ActionsSection(),
        _ArtistSection(hasBottomDivider: false),
      ],
    );
  }
}

class _CommentLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CommentList commentList = ScopedModel.of<CommentList>(context, rebuildOnChange: true);
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        commentList.loadMore(notification: notification);
        return false;
      },
      child: ListView.builder(
        itemCount: commentList.items.length,
        itemBuilder: commentList.obtainBuilder(),
      ),
    );
  }
}
