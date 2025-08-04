import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixabay_app/widgets/image_widget.dart';

import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/search/search_bloc.dart';
import '../models/pixabay_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final searchBloc = context.read<SearchBloc>();
      if (searchBloc.state is SearchLoaded) {
        final state = searchBloc.state as SearchLoaded;
        if (!state.hasReachedMax) {
          searchBloc.add(LoadMoreImages(_searchController.text.trim()));
        }
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _searchImages() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchBloc>().add(SearchImages(query));
    }
  }

  void _toggleFavorite(PixabayImage image) {
    final favoritesBloc = context.read<FavoritesBloc>();
    if (favoritesBloc.isFavorite(image)) {
      favoritesBloc.add(RemoveFromFavorites(image));
    } else {
      favoritesBloc.add(AddToFavorites(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new images'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for images...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchImages(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchImages,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, searchState) {
                if (searchState is SearchInitial) {
                  return const Center(
                    child: Text(
                      'Search for images to add to your favorites',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else if (searchState is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (searchState is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${searchState.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _searchImages,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (searchState is SearchLoaded) {
                  if (searchState.images.isEmpty) {
                    return const Center(
                      child: Text(
                        'No images found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favoritesState) {
                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: searchState.hasReachedMax
                            ? searchState.images.length
                            : searchState.images.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= searchState.images.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final image = searchState.images[index];
                          final isFavorite = context
                              .read<FavoritesBloc>()
                              .isFavorite(image);

                          return GestureDetector(
                            onTap: () => _toggleFavorite(image),
                            child: ImageWidget(
                              image: image,
                              isFavorite: isFavorite,
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
