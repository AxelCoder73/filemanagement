import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// void main() {
//   runApp(ViewPdf());
// }

class ViewPdf extends StatelessWidget {
  var path = '';
  ViewPdf(this.path);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF Viewer'),
        ),
        body: PDFView(
          filePath: path, // Replace with your PDF file path
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
        ),
      ),
    );
  }
}
