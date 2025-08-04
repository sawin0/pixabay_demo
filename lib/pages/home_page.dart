import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixabay_app/widgets/image_widget.dart';

import '../bloc/favorites/favorites_bloc.dart';
import '../models/pixabay_image.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load favorites when the page initializes
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  Future<void> _showRemoveDialog(PixabayImage image) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Favorites'),
          content: const Text(
            'Do you want to remove this image from your favorites?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('YES'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      context.read<FavoritesBloc>().add(RemoveFromFavorites(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorite Images'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
              if (context.mounted) {
                context.read<FavoritesBloc>().add(LoadFavorites());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(LoadFavorites());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(
                child: Text(
                  'Your favorite list is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final image = state.favorites[index];
                return GestureDetector(
                  onTap: () => _showRemoveDialog(image),
                  child: ImageWidget(image: image),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
