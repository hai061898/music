import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music/bloc/main_controller.dart';
import 'package:music/data/models/load_enum.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';
import 'package:music/data/services/seach_service.dart';

part 'search_state.dart';

class SearchResultsCubit extends Cubit<SearchResultsState> {
  final repo = SearchService();

  SearchResultsCubit() : super(SearchResultsState.initial());
  void searchSongs(String tag) async {
    if (state.isSong) {
      try {
        emit(state.copyWith(status: LoadPage.loading));
        var songs = await repo.getSongs(tag.toString());
        emit(state.copyWith(
          status: LoadPage.loaded,
          songs: songs,
        ));
      } catch (e) {
        emit(state.copyWith(status: LoadPage.error));
      }
    } else {
      try {
        emit(state.copyWith(status: LoadPage.loading));
        var users = await repo.getUsers(tag.toString());
        emit(state.copyWith(
          status: LoadPage.loaded,
          users: users,
        ));
      } catch (e) {
        emit(state.copyWith(status: LoadPage.error));
      }
    }
  }

  void playSongs(MainController controller, int initial) {
    controller.playSong(controller.convertToAudio(state.songs), initial);
  }

  void isNullToggle() {
    emit(state.copyWith(isNull: !state.isNull));
  }

  void isSongToggle() {
    emit(state.copyWith(isSong: !state.isSong));
  }
}
