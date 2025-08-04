part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<PixabayImage> images;
  final bool hasReachedMax;
  final int currentPage;

  const SearchLoaded({
    required this.images,
    required this.hasReachedMax,
    required this.currentPage,
  });

  SearchLoaded copyWith({
    List<PixabayImage>? images,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return SearchLoaded(
      images: images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [images, hasReachedMax, currentPage];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
