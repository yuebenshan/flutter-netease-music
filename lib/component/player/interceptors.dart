import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:music_player/music_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/Utils.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/model/model.dart';

import 'player.dart';

class BackgroundInterceptors {
  // 获取播放地址
  static Future<String> playUriInterceptor(String mediaId, String fallbackUri) async {
    /// some devices do not support http request.
    String dirloc;
    if (Platform.isAndroid) {
      dirloc = "/sdcard/download/";
    } else {
      dirloc = (await getApplicationDocumentsDirectory()).path + '/';
    }
    String randid = 'downLoadMusic/_$mediaId';
    String localUrl;
    if (File(dirloc + randid.toString() + ".mp3").existsSync()) {
      localUrl = dirloc + randid.toString() + ".mp3";
      return 'file://$localUrl';
    }

    final result = await neteaseRepository.getPlayUrl(int.parse(mediaId));
    if (result.isError) {
      return fallbackUri;
    }

    return result.asValue.value.replaceFirst("http://", "https://");
  }

  static Future<Uint8List> loadImageInterceptor(MusicMetadata metadata) async {
    final ImageStream stream = CachedImage(metadata.iconUri.toString()).resolve(ImageConfiguration(
      size: const Size(150, 150),
      devicePixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
    ));
    final image = Completer<ImageInfo>();
    stream.addListener(ImageStreamListener((info, a) {
      image.complete(info);
    }, onError: (dynamic exception, StackTrace stackTrace) {
      image.completeError(exception, stackTrace);
    }));
    final result = await image.future
        .then((image) => image.image.toByteData(format: ImageByteFormat.png))
        .then((byte) => byte.buffer.asUint8List())
        .timeout(const Duration(seconds: 10));
    debugPrint("load image for : ${metadata.title} ${result.length}");
    return result;
  }
}

class QuietPlayQueueInterceptor extends PlayQueueInterceptor {
  @override
  Future<List<MusicMetadata>> fetchMoreMusic(BackgroundPlayQueue queue, PlayMode playMode) async {
    if (queue.queueId == FM_PLAY_QUEUE_ID) {
      final musics = await neteaseRepository.getPersonalFmMusics();
      return musics.toMetadataList();
    }
    return super.fetchMoreMusic(queue, playMode);
  }
}
