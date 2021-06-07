import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiet/Utils.dart';
import 'package:quiet/model/music.dart';

class IconDownLoad extends StatefulWidget {
  final Music music;

  const IconDownLoad(
    this.music, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IconDownLoadState();
  }
}

class _IconDownLoadState extends State<IconDownLoad> {
  bool downloading = false;

  double progress = 0;

  String path;
  String dirloc = "";
  String randid = '';

  Random random = new Random();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPath();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () async {
        print('下载');
        bool exists = await checkDownload();
        if (!exists) {
          downloadFile();
        }
      },
      child: progress > 0
          ? Container(
              child: Text('${(progress * 100).toStringAsFixed(2)}%'),
            )
          : Padding(
              padding: EdgeInsets.only(right: 20),
              child: FutureBuilder<bool>(
                future: checkDownload(),
                builder: (context, sData) {
                  return (sData?.data ?? false)
                      ? Icon(
                          Icons.file_download_done,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        )
                      : Icon(Icons.file_download, size: 30,);
                },
              ),
            ),
    );
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    bool storage = await Permission.storage.request().isGranted;
    if (storage) {
      try {
        //2、创建文件
        FileUtils.mkdir([dirloc]);

        //3、使用 dio 下载文件
        await dio
            .download(widget.music.url, dirloc + randid.toString() + ".mp3",
                onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            downloading = true;
            // 4、连接资源成功开始下载后更新状态
            progress = (receivedBytes / totalBytes);
          });
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        downloading = false;
        progress = 0;
        path = dirloc + randid.toString() + ".mp3";
      });
    } else {
      setState(() {
        progress = 0;
        downloadFile();
      });
    }
  }

  Future<bool> checkDownload() {
    if (dirloc != "" && randid != "") {
      return File(dirloc + randid.toString() + ".mp3").exists();
    } else {
      return Future.value(false);
    }
  }

  void initPath() async {
    randid = 'downLoadMusic/_${widget.music.id}';
    if (Platform.isAndroid) {
      dirloc = "/sdcard/download/";
    } else {
      dirloc = (await getApplicationDocumentsDirectory()).path + '/';
    }
    if(!Directory(dirloc + 'downLoadMusic/').existsSync()) {
      Directory(dirloc + 'downLoadMusic/').createSync();
    }
    setState(() {
    });
  }
}
