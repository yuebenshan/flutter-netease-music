part of '../module.dart';

//basic: 基本：按创建顺序返回20条音频
Handler getAudioListBasic = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=basic&loadNumber=${query['loadNumber']}",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//new: 最新：返回最新20条音频，按日期倒序排列
Handler getAudioListNew = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=new&loadNumber=${query['loadNumber']}",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//wild: 搜索：返回符合搜索条件的20条音频
Handler getAudioListWild = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=wild&wildcard=${query['wildcard']}&loadNumber=${query['loadNumber']}",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//random: 随机：返回随机20条音频
Handler getAudioListRandom = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=random",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//category: 按分类：返回指定分类下的20条音频，按标题升序排列
Handler getAudioListCategory = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=category&category=${query['category']}&loadNumber=${query['loadNumber']}",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

// https://cms2.fsll.tech/audio/getAudioList?type=tag&tag=学习&loadNumber=1
//tag: 按标签：返回指定标签下的20条音频
Handler getAudioListTag = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioList?type=tag&tag=${query['tag']}&loadNumber=${query['loadNumber']}",
      {'limit': query['limit'] ?? 20, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//https://cms2.fsll.tech/audio/getAudioById?audioId=4259
//拿某一条音频
Handler getAudioById = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/audio/getAudioById?audioId=${query['audioId']}",
      {}, cookies: cookie, crypto: Crypto.weapi);
};

// https://cms2.fsll.tech/content/getPinnedCategoryList
//拿种类列表
Handler getPinnedCategoryList = (Map query, List<Cookie> cookie) {
  return request('GET', "https://cms2.fsll.tech/content/getPinnedCategoryList",
      {}, cookies: cookie, crypto: Crypto.weapi);
};

/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////

//歌手专辑
Handler artist_album = (Map query, List<Cookie> cookie) {
  return request('POST', "https://music.163.com/weapi/artist/albums/${query['id']}",
      {'limit': query['limit'] ?? 30, 'offset': query['offset'] ?? 0, 'total': true},
      cookies: cookie, crypto: Crypto.weapi);
};

//歌手介绍
Handler artist_desc = (query, cookie) => request(
    'POST', 'https://music.163.com/weapi/artist/introduction', {'id': query['id']},
    crypto: Crypto.weapi, cookies: cookie);

//歌手分类
/* 
    categoryCode 取值
    入驻歌手 5001
    华语男歌手 1001
    华语女歌手 1002
    华语组合/乐队 1003
    欧美男歌手 2001
    欧美女歌手 2002
    欧美组合/乐队 2003
    日本男歌手 6001
    日本女歌手 6002
    日本组合/乐队 6003
    韩国男歌手 7001
    韩国女歌手 7002
    韩国组合/乐队 7003
    其他男歌手 4001
    其他女歌手 4002
    其他组合/乐队 4003

    initial 取值 a-z/A-Z
*/
Handler artist_list = (Map query, List<Cookie> cookie) {
  return request(
      'POST',
      'https://music.163.com/weapi/artist/list',
      {
        'categoryCode': query['cat'] ?? '1001',
        'initial': (query['initial'] as String)?.toUpperCase()?.codeUnitAt(0) ?? '',
        'offset': query['offset'] ?? 0,
        'limit': query['limit'] ?? 30,
        'total': true
      },
      cookies: cookie,
      crypto: Crypto.weapi);
};

//歌手相关MV
Handler artist_mv = (query, cookie) => request('POST', 'https://music.163.com/weapi/artist/mvs',
    {'artistId': query['id'], 'limit': query['limit'], 'offset': query['offset'], 'total': true},
    crypto: Crypto.weapi, cookies: cookie);

//收藏与取消收藏歌手
Handler artist_sub = (query, cookie) {
  query['t'] = (query['t'] == 1) ? 'sub' : 'unsub';
  return request('POST', 'https://music.163.com/weapi/artist/${query['t']}',
      {'artistId': query['id'], 'artistIds': '[${query['id']}]'},
      crypto: Crypto.weapi, cookies: cookie);
};

//关注歌手列表
Handler artist_sublist = (query, cookie) {
  return request('POST', 'https://music.163.com/weapi/artist/sublist',
      {'limit': query['limit'] ?? 25, 'offset': query['offset'] ?? 0, 'total': true},
      crypto: Crypto.weapi, cookies: cookie);
};

//歌手单曲
Handler artists = (query, cookie) =>
    request('POST', 'https://music.163.com/weapi/v1/artist/${query['id']}', {}, crypto: Crypto.weapi, cookies: cookie);
