import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music/data/models/load_enum.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/data/models/user_model.dart';
import 'package:music/data/services/home_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final repo = HomeService();
  HomeCubit() : super(HomeState.initial());

  void getUsers() async {
    try {
      emit(state.copyWith(status: LoadPage.loading));

      emit(state.copyWith(
        users: await repo.getUsers(),
        songs: await repo.getSongs(),
        status: LoadPage.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(status: LoadPage.error));
    }
  }
}