import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pixel_file_management/utils/utils.dart';

class PersonnelFiles extends StatefulWidget {
  var selectedPersonnel;
  PersonnelFiles(this.selectedPersonnel);

  @override
  State<PersonnelFiles> createState() => _PersonnelFilesState();
}

class _PersonnelFilesState extends State<PersonnelFiles> {
  List adressedFiles = [];
  getFiles() async {
    var files = await Hive.openBox('files');
    // files.clear();
    var codePers = widget.selectedPersonnel['codePers'];
    setState(() {
      adressedFiles = files.get('code-$codePers') ?? [];
    });
    print(adressedFiles);
    print("adressedFiles::");
    if (adressedFiles == null) {
      adressedFiles = [];
    } else {}
  }

  var openDocName = '';

  getContentByExt(extTab) async {
    var files = await Hive.openBox('files');
    var codePers = widget.selectedPersonnel['codePers'];
    adressedFiles = files.get('code-$codePers') ?? [];
    // var images
    print(adressedFiles);
    print("adressedFiles");
    var filterData = [];
    for (var file in adressedFiles) {
      var fileExt = getFileExtension(file['filePath']);
      print(fileExt);
      print("fileExt");
      for (var ext in extTab) {
        if (fileExt == ext) {
          filterData.add(file);
        }
      }
    }

    setState(() {
      adressedFiles = filterData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    var heigth = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width - 100,
            height: heigth - 100,
            // color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.yellow,
                  // width: width / 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  openDocName = 'Music';
                                });
                                getContentByExt(['mp3']);
                              },
                              child: modelFolder('Music', openDocName)),
                          InkWell(
                              onTap: () {
                                getContentByExt(['mp4']);
                                setState(() {
                                  openDocName = 'Vidéos';
                                });
                              },
                              child: modelFolder('Vidéos', openDocName)),
                          InkWell(
                              onTap: () {
                                getContentByExt(['docx', 'xlsx', 'pdf']);
                                setState(() {
                                  openDocName = 'Documents';
                                });
                              },
                              child: modelFolder('Documents', openDocName)),
                          InkWell(
                              onTap: () {
                                getContentByExt(['png', 'jpg', 'jpeg']);
                                setState(() {
                                  openDocName = 'Images';
                                });
                              },
                              child: modelFolder('Images', openDocName)),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: width,
                    height: 580,
                    // color: Colors.green,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width / 6,
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            color: Colors.blue[200],
                            child: Text('$openDocName'),
                          ),
                          SizedBox(
                              width: width / 1.3,
                              height: heigth - 200,
                              child: MasonryGridView.count(
                                itemCount: adressedFiles.length,
                                // crossAxisCount: crossAxisCount,
                                itemBuilder: (context, index) {
                                  // ignore: avoid_unnecessary_containers
                                  return Container(
                                      // color: Colors
                                      //     .red,
                                      height: 200,
                                      width: 120,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  child: Image.file(
                                                      width: 100,
                                                      height: 100,
                                                      File(adressedFiles[index]
                                                          ['filePath']))),
                                              // Container(child: Image.file(width: 100, height: 100, File(adressedFiles[index]['file'].path))),
                                              Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // IconButton(
                                                    //     onPressed: () {},
                                                    //     icon: Icon(
                                                    //       Icons.share,
                                                    //       color: Colors.blue,
                                                    //     )),
                                                    // IconButton(
                                                    //     onPressed: () {},
                                                    //     icon: Icon(
                                                    //       Icons.delete,
                                                    //       color: Colors.red,
                                                    //     )),
                                                    IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                          Icons.remove_red_eye,
                                                          color: Colors.grey,
                                                        ))
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Text(
                                              '${adressedFiles[index]['fileName']}')
                                        ],
                                      ));
                                },
                                crossAxisCount: 5,
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container modelFolder(dossierNom, openDocName) {
    return Container(
      child: openDocName == dossierNom
          ? Column(
              children: [
                Container(
                  // color: Colors.teal,
                  child:
                      Image.asset(width: 70, height: 70, 'images/folder.png'),
                ),
                Container(
                    // color: Colors.teal,
                    child: Text('$dossierNom'))
              ],
            )
          : Column(
              children: [
                Container(
                  // color: Colors.teal,
                  child: Image.asset(
                      width: 70, height: 70, 'images/closeFolder.png'),
                ),
                Container(
                    // color: Colors.teal,
                    child: Text('$dossierNom'))
              ],
            ),
    );
  }
}
