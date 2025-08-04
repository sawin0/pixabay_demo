part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final PixabayImage image;

  const AddToFavorites(this.image);

  @override
  List<Object> get props => [image];
}

class RemoveFromFavorites extends FavoritesEvent {
  final PixabayImage image;

  const RemoveFromFavorites(this.image);

  @override
  List<Object> get props => [image];
}
