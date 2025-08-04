import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/pixabay_image.dart';
import '../../services/favorites_service.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await FavoritesService.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await FavoritesService.addToFavorites(event.image);
      final favorites = await FavoritesService.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError('Failed to add to favorites: $e'));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await FavoritesService.removeFromFavorites(event.image);
      final favorites = await FavoritesService.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError('Failed to remove from favorites: $e'));
    }
  }

  bool isFavorite(PixabayImage image) {
    if (state is FavoritesLoaded) {
      final favorites = (state as FavoritesLoaded).favorites;
      return favorites.any((fav) => fav.id == image.id);
    }
    return false;
  }
}
