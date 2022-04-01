import 'dart:convert';

import 'package:http/http.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';

import 'get_response.dart';
import 'url_api.dart';

class GenreService {
  Future<List<User>> getUsers(String tag) async {
    final query = {
      "page": 0.toString(),
      "limit": 50.toString(),
    };

    Response res = await getResponse(
        Uri.https(baseUrl, basePath + '/tags/artists/' + tag, query));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return (body['results'] as List).map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("failed fetch users ");
    }
  }

  Future<List<SongModel>> getSongs(String tag) async {
    final query = {
      "page": 0.toString(),
      "limit": 50.toString(),
    };

    Response res =
        await getResponse(Uri.https(baseUrl, basePath + '/tags/' + tag, query));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);

      return (body['results'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList();
    } else {
      throw Exception("failed fetch users ");
    }
  }
}
