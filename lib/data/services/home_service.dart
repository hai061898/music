import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';
import 'package:music/data/services/url_api.dart';

import 'get_response.dart';

class HomeService {
  Future<List<User>> getUsers() async {
    final query = {
      "page": (Random().nextInt(8)).toString(),
      "limit": 26.toString()
    };
    Response res =
        await getResponse(Uri.https(baseUrl, basePath + '/users', query));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final users = (body['results'] as List)
          .map<User>((user) => User.fromJson(user))
          .toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<SongModel>> getSongs() async {
    final query = {"limit": 30.toString()};
    final value = await getResponse(Uri.https(
      baseUrl,
      basePath + '/songs/random/all',
      query,
    ));
    if (value.statusCode == 200) {
      final body = jsonDecode(value.body);

      final songs = (body['results'] as List)
          .map((user) => SongModel.fromJson(user))
          .toList();

      return songs;
    } else {
      throw Exception('Failed to load users');
    }
  }
}
