class Review {
  final double rating;
  final String comment;
  final String userId;
  String? userName;

  Review({
    required this.rating,
    required this.comment,
    required this.userId,
    this.userName,
  });
}