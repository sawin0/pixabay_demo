part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchImages extends SearchEvent {
  final String query;

  const SearchImages(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreImages extends SearchEvent {
  final String query;

  const LoadMoreImages(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {}
