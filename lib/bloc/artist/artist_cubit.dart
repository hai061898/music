import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music/bloc/main_controller.dart';
import 'package:music/data/models/load_enum.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';
import 'package:music/data/services/artists_service.dart';

part 'artist_state.dart';

class ArtistProfileCubit extends Cubit<ArtistProfileState> {
  final repo = GetArtistsData();
  ArtistProfileCubit() : super(ArtistProfileState.initial());
  void getUser(String id) async {
    try {
      emit(state.copyWith(status: LoadPage.loading));
      emit(
        state.copyWith(
          songs: await repo.getSongs(id),
          user: await repo.getUserData(id),
          status: LoadPage.loaded,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoadPage.error));
    }
  }

  void playSongs(MainController controller, int initial) {
    controller.playSong(controller.convertToAudio(state.songs), initial);
  }
}