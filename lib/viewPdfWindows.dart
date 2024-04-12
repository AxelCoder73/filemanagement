import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class ViewPdfWindows extends StatefulWidget {
  var path = '';
  ViewPdfWindows(this.path);

  @override
  State<ViewPdfWindows> createState() => _ViewPdfWindowsState();
}

class _ViewPdfWindowsState extends State<ViewPdfWindows> {
  static const int _initialPage = 1;
  bool _isSampleDoc = true;
  bool isLoading = false;
  late PdfController _pdfController =
      PdfController(document: PdfDocument.openFile(widget.path));
  Uint8List? myUint8List = null;

  load() async {
    // ignore: prefer_const_declarations

    // var file = await LoadFile(url);
    // // print('await ::file');
    // print("file.runtimeType");
    // print(file.runtimeType);
    // setState(() {
    //   _pdfController = PdfController(
    //     document: PdfDocument.openData(file),
    //     initialPage: _initialPage,
    //   );
    //   isLoading = false;
    // });
    var file = widget.path;
    print(file);
    print("file");
    return file;
  }

  @override
  void initState() {
    super.initState();
    _load() async {
      print('in:::');
      _pdfController = PdfController(
        // document: PdfDocument.openFile(
        // 'C:/Users/axeln/AppData/Documents/Burkina-2014-SVT-serie-D-1er-Tour-Sujet-2-Remp.pdf'),
        document: PdfDocument.openAsset(load()),
        // document: PdfDocument.openAsset(await load()),
        initialPage: _initialPage,
      );
    }

    _load();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.grey,
            appBar: AppBar(
              title: const Text('Pdfx example'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.navigate_before),
                  onPressed: () {
                    _pdfController.previousPage(
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 100),
                    );
                  },
                ),
                PdfPageNumber(
                  controller: _pdfController,
                  builder: (_, loadingState, page, pagesCount) => Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$page/${pagesCount ?? 0}',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: () {
                    _pdfController.nextPage(
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 100),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (_isSampleDoc) {
                      _pdfController.loadDocument(
                          PdfDocument.openAsset('assets/flutter_tutorial.pdf'));
                    } else {
                      _pdfController.loadDocument(
                          PdfDocument.openAsset('assets/hello.pdf'));
                    }
                    _isSampleDoc = !_isSampleDoc;
                  },
                ),
              ],
            ),
            body: PdfView(
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageBuilder: _pageBuilder,
              ),
              controller: _pdfController,
            ),
          );
  }

  PhotoViewGalleryPageOptions _pageBuilder(
    BuildContext context,
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) {
    return PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 2,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
    );
  }
}
