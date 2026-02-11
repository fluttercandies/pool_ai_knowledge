class ChatReference {
  final String postId;
  final String title;

  const ChatReference({required this.postId, required this.title});

  factory ChatReference.fromJson(Map<String, dynamic> json) => ChatReference(
        postId: json['post_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );
}
