import 'package:flutter/material.dart';

class ZoomableImageDialog extends StatelessWidget {
  final dynamic imageUrl;

  ZoomableImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Fermer'))
      ],
      content: InteractiveViewer(
        maxScale: 5.0, // Maximum zoom level
        minScale: 0.5, // Minimum zoom level
        child: Image.file(imageUrl),
      ),
    );
  }
}

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Zoomable Image Example'),
//         ),
//         body: Center(
//           child: ZoomableImageDialog(
//             imageUrl: 'https://example.com/your_image_url.jpg', // Replace with your image URL
//           ),
//         ),
//       ),
//     );
//   }
// }
