import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixabay_app/models/pixabay_image.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.image, this.isFavorite = false});

  final PixabayImage image;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: image.webformatURL,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  ),
                ),
              ),
              if (isFavorite)
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      'V',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.grey.shade900,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner: ${image.user}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Size: ${image.getFormattedSize()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
