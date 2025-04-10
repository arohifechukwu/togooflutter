import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDialogTile extends StatefulWidget {
  final void Function(
      double restaurantRating,
      double driverRating,
      String restaurantComment,
      String driverComment,
      ) onSubmit;

  const RatingDialogTile({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _RatingDialogTileState createState() => _RatingDialogTileState();
}

class _RatingDialogTileState extends State<RatingDialogTile> {
  double restaurantRating = 0.0;
  double driverRating = 0.0;
  final TextEditingController restaurantCommentController = TextEditingController();
  final TextEditingController driverCommentController = TextEditingController();

  @override
  void dispose() {
    restaurantCommentController.dispose();
    driverCommentController.dispose();
    super.dispose();
  }

  Widget _buildRatingSection({
    required String title,
    required double rating,
    required Function(double) onUpdate,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 4),
        RatingBar.builder(
          initialRating: rating,
          minRating: 0,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 32,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onUpdate,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Your feedback helps us improve",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            _buildRatingSection(
              title: "Rate the Restaurant",
              rating: restaurantRating,
              onUpdate: (rating) => setState(() => restaurantRating = rating),
              controller: restaurantCommentController,
              hint: "Leave a comment for the restaurant",
            ),

            _buildRatingSection(
              title: "Rate the Driver",
              rating: driverRating,
              onUpdate: (rating) => setState(() => driverRating = rating),
              controller: driverCommentController,
              hint: "Leave a comment for the driver",
            ),

            ElevatedButton(
              onPressed: () {
                widget.onSubmit(
                  restaurantRating,
                  driverRating,
                  restaurantCommentController.text.trim(),
                  driverCommentController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text("Submit", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
