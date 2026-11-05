
class VideoItem {
  final String id;
  final String title;
  final String videoUrl;

  const VideoItem({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
    );
  }
}
