import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:pixel_file_management/simpleFadeWidget.dart';
import 'package:pixel_file_management/utils/utils.dart';

class DropAreaWidget extends StatefulWidget {
  final void Function(List<XFile> files) onFiles;
  final void Function() pickImage;
  final texte;
  const DropAreaWidget(
      {Key? key,
      required this.onFiles,
      required this.texte,
      required this.pickImage})
      : super(key: key);

  @override
  State<DropAreaWidget> createState() => _DropAreaWidgetState();
}

class _DropAreaWidgetState extends State<DropAreaWidget> {
  //
  bool dragging = false;
  Offset localPosition = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      // color: Colors.green,
      child: Stack(
        children: [
          Positioned.fill(
            child: DropTarget(
              onDragEntered: (details) {
                // print(details);
                // print("details");
                dragging = true;
                localPosition = details.localPosition;
                setState(() {});
              },
              onDragUpdated: (details) {
                localPosition = details.localPosition;
                setState(() {});
              },
              onDragExited: (details) {
                dragging = false;
                localPosition = details.localPosition;
                setState(() {});
              },
              onDragDone: (details) {
                final files = details.files.where(
                  (element) =>
                      ImageUtils.checkMimeType(element.path) !=
                      ImageMimeType.other,
                );
                // print(files);
                // print("details.files");
                // print(details.files);
                // print("file:::1");
                widget.onFiles(files.toList());
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: dragging ? Colors.white24 : Colors.white12,
                  border: Border.all(
                    color: Colors.white54,
                    width: dragging ? 4 : 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          print('there');
                          widget.pickImage();
                        },
                        child: const Icon(Icons.cloud_download, size: 96)),
                    const SizedBox(height: 8),
                    Text(widget.texte,
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
          ),
          Container(
            // color: Colors.red,
            // width: 200,
            // height: 200,
            child: Positioned(
              // left: localPosition.dx - 28,
              // top: localPosition.dy - 28,
              child: SizedBox(
                width: 156,
                height: 56,
                child: IgnorePointer(
                  ignoring: true,
                  child: SimpleFadeWidget(
                    reverse: dragging,
                    child: Image.asset('images/image.png'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
