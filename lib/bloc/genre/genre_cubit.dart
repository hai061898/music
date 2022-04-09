import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music/bloc/main_controller.dart';
import 'package:music/data/models/load_enum.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';
import 'package:music/data/services/genre_service.dart';

part 'genre_state.dart';

class GenreCubit extends Cubit<GenreState> {
  final repo = GenreService();

  GenreCubit() : super(GenreState.initial());
  void init(String tag) async {
    try {
      emit(state.copyWith(status: LoadPage.loading));
      var users = await repo.getUsers(tag);
      var songs = await repo.getSongs(tag);
      emit(state.copyWith(
        status: LoadPage.loaded,
        users: users,
        songs: songs,
      ));
    } catch (e) {
      emit(state.copyWith(status: LoadPage.error));
    }
  }

  void playSongs(MainController controller, int initial) {
    controller.playSong(controller.convertToAudio(state.songs), initial);
  }
}