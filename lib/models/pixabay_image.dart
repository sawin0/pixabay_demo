class PixabayImage {
  final int id;
  final String webformatURL;
  final String tags;
  final int imageSize;
  final int views;
  final int downloads;
  final String user;

  PixabayImage({
    required this.id,
    required this.webformatURL,
    required this.tags,
    required this.imageSize,
    required this.views,
    required this.downloads,
    required this.user,
  });

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'],
      webformatURL: json['webformatURL'],
      tags: json['tags'],
      imageSize: json['imageSize'],
      views: json['views'],
      downloads: json['downloads'],
      user: json['user'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webformatURL': webformatURL,
      'tags': tags,
      'imageSize': imageSize,
      'views': views,
      'downloads': downloads,
      'user': user,
    };
  }

  String getFormattedSize() {
    if (imageSize < 1024) {
      return imageSize.toString();
    } else if (imageSize < 1024 * 1024) {
      return '${(imageSize / 1024).toStringAsFixed(1)}K';
    } else if (imageSize < 1024 * 1024 * 1024) {
      return '${(imageSize / (1024 * 1024)).toStringAsFixed(1)}M';
    } else {
      return '${(imageSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  String getFormattedViewsOrDownloads() {
    if (views < 1000) {
      return views.toString();
    } else if (views < 1000000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    }
  }
}
