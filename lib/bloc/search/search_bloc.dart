import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/pixabay_image.dart';
import '../../services/pixabay_api_service.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchImages>(_onSearchImages);
    on<LoadMoreImages>(_onLoadMoreImages);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchImages(
    SearchImages event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final images = await PixabayApiService.searchImages(event.query, page: 1);
      emit(
        SearchLoaded(
          images: images,
          hasReachedMax: images.length < 20,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(SearchError('Failed to search images: $e'));
    }
  }

  Future<void> _onLoadMoreImages(
    LoadMoreImages event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;
        final newImages = await PixabayApiService.searchImages(
          event.query,
          page: nextPage,
        );

        emit(
          currentState.copyWith(
            images: [...currentState.images, ...newImages],
            hasReachedMax: newImages.length < 20,
            currentPage: nextPage,
          ),
        );
      } catch (e) {
        emit(SearchError('Failed to load more images: $e'));
      }
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
