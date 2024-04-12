import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pixel_file_management/dropAreaWidget.dart';
import 'package:pixel_file_management/fichiers/personnelFiless.dart';
import 'package:pixel_file_management/model/fileDataModel.dart';
import 'package:pixel_file_management/personnels/personnels.dart';
import 'package:pixel_file_management/utils/utils.dart';
import 'package:pixel_file_management/viewPdf.dart';
import 'package:pixel_file_management/viewPdfWindows.dart';
import 'package:pixel_file_management/zoomable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:video_player_media_kit/video_player_media_kit.dart';
// import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
// import 'package:media_kit_video/media_kit_video.dart';

// ...
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class FileData {
  String codePers;
  String filePath;
  String fileName;
  int fileSize;

  FileData({
    required this.codePers,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });
}

class _HomePageState extends State<HomePage> {
  var actualFocus = 0;
  var actualSelected = 0;
  File_Data_Model? file;
  final List<XFile> _list = [];
  TextEditingController nameController = TextEditingController();
  var _selectedDate = DateTime.now();
  var _selectedDateRole = DateTime.now();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();
  final TextEditingController _oldRoleController = TextEditingController();
  final TextEditingController _selectedDateController = TextEditingController();
  // var _controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
  // late final videoPlayer = Player();
  // late final videoController = VideoController(videoPlayer);
  // dynamic roles = [];
  dynamic roles = [
    {"role": "Stagière", "actor": "pers-37b5i"},
    {"role": "Responsable Adjointe Marketing", "actor": "pers-s19cm"}
  ];
  // var roles = ['Stagiere', 'Employé'];
  var ancienRole = 'Stagiere';
  var codePers = '';
  bool _dragging = false;
  bool isPlayMusic = false;
  bool isResumeMusic = false;
  final _formKey2 = GlobalKey<FormState>();
  var nameEntreprise = '';

  bool hovering = false;
  List<XFile> droppedFiles = [];
  List droppedFilesPersonnel = [];
  List droppedFilesSelectedPersonnel = [];

  var ext = '';
  // List<XFile> droppedFilesPersonnel = [];
  var selectedCheck = -1;
  var selectedPersonnel = {};
  ScrollController scrollController = ScrollController();
  getExt(file) {
    var filePath = file.paths[0];
    String fileExtension = getFileExtension(filePath);
    print('File extension: $fileExtension');

    return fileExtension;
  }

  getWidget(ext, url) {
    if (ext == 'png' || ext == 'jpg') {
      return Row(
        children: [
          Icon(Icons.remove_red_eye),
          SizedBox(
            width: 5,
          ),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ZoomableImageDialog(
                      imageUrl: File(
                          url.files[0].path), // Replace with your image URL
                    );
                  });
            },
            child: Text(
              'Agrandir b',
              // style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    } else if (ext == 'mp3') {
      return Row(
        children: [
          Icon(Icons.music_note),
          SizedBox(
            width: 5,
          ),
          isPlayMusic
              ? Row(
                  children: [
                    Text('Lecture en cours ...'),
                    TextButton(
                      onPressed: () {
                        pausedMp3(url);
                      },
                      child: Text(
                        'Arrêter',
                        style: TextStyle(color: Colors.red),
                      ),
                      // style: TextStyle(color: Colors.black),
                    ),
                  ],
                )
              : TextButton(
                  onPressed: () {
                    playMp3(url);
                  },
                  child: Text('Jouer'),
                  // style: TextStyle(color: Colors.black),
                )
        ],
      );
    } else if (ext == 'mp4') {
      return Row(
        children: [
          Icon(Icons.video_camera_back),
          SizedBox(
            width: 5,
          ),
          TextButton(
              onPressed: () {
                viewVideo(url);
              },
              child: Text(
                'Regarder',
                // style: TextStyle(color: Colors.black),
              )),
        ],
      );
    } else if (ext == 'pdf') {
      return Row(
        children: [
          Icon(Icons.remove_red_eye),
          SizedBox(
            width: 5,
          ),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ViewPdfWindows(url.files[0].path);
                  });
            },
            child: Text(
              'Voir le pdf',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.remove_red_eye),
          SizedBox(
            width: 5,
          ),
          Text(
            'Agrandir b',
            style: TextStyle(color: Colors.black),
          ),
        ],
      );
    }
  }

  final player = AudioPlayer();
  // final videoPlayer = ();
  playMp3(url) async {
    // print(url.files[0].path);
    // print("url::11");
    setState(() {
      isPlayMusic = true;
      isResumeMusic = false;
    });
    await player.play(DeviceFileSource(url.files[0].path),
        mode: PlayerMode.mediaPlayer);
    await player.play(UrlSource(url.files[0].path));
  }

  viewVideo(url) async {
    // print(url.files[0].path);
    // print("url::11");
    setState(() {
      // videoPlayer.open(Media(url.files[0].path));
      // isPlayMusic = true;
    });
    // await player.play(DeviceFileSource(url.files[0].path),
    //     mode: PlayerMode.mediaPlayer);
    // await player.play(UrlSource(url.files[0].path));
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      // videoPlayer.stop();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
            content: Center(
              child: SizedBox(
                // width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                // Use [Video] widget to display video output.
                // child: Video(controller: videoController),
              ),
            ),
          );
        });
  }

  pausedMp3(url) async {
    // print(url);
    print("ispaused::");

    // final player = AudioPlayer();
    player.pause();
    // print(dur);
    // print("dur:::");
    // await player.pause();
    setState(() {
      isPlayMusic = false;
      isResumeMusic = false;
    });
  }

  resumedMp3(url) async {
    // print(url);
    print("ispaused::");

    // final player = AudioPlayer();
    player.resume();
    // print(dur);
    // print("dur:::");
    // await player.pause();
    setState(() {
      isResumeMusic = true;
      isPlayMusic = true;
    });
  }

  getImportSize() {
    var code = selectedPersonnel['codePers'];
    print(code);
    print("code");
    var tab = [];
    setState(() {
      droppedFilesSelectedPersonnel.clear();
    });
    for (var i = 0; i < droppedFilesPersonnel.length; i++) {
      print(droppedFilesPersonnel);
      print("droppedFilesPersonnel");
      if (droppedFilesPersonnel[i]['codePers'] == code) {
        tab.add(droppedFilesPersonnel[i]);
        setState(() {
          droppedFilesSelectedPersonnel.add(droppedFilesPersonnel[i]);
        });
      }
    }
    print(tab.length);
    print("tab.length");
    return tab.length;
  }

  getPersImportSize() {
    var code = selectedPersonnel['codePers'];
    print(code);
    print("code");
    var tab = [];
    setState(() {
      droppedFilesSelectedPersonnel.clear();
    });
    for (var i = 0; i < droppedFilesPersonnel.length; i++) {
      if (droppedFilesPersonnel[i]['codePers'] == code) {
        tab.add(droppedFilesPersonnel[i]);
        setState(() {
          droppedFilesSelectedPersonnel.add(droppedFilesPersonnel[i]);
        });
      }
    }
    print(tab.length);
    print("tab.length");
    return tab.length;
  }

  dynamic personnels = [
    {
      'index': '1',
      'nom': 'Sibiri',
      'prenom': 'Anatol',
      'age': '18',
      'fonction': 'DG'
    }
  ];
  String selectedActor = '';

  getItems(codePers) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    var items = [];
    print(roles);
    print("roles");
    for (var role in roles) {
      if (role['codePers'] == codePers) {
        print(role);
        print("role");
        var datePriseFonction = dateFormat.format(role['datePriseFonction']);

        items.add(role['role'] +
            ' (' +
            dateFormat.format(role['datePriseFonction']) +
            ')');
      }
    }
    return items.map<DropdownMenuItem<String>>((dynamic value) {
      print(value);
      print("value");
      return new DropdownMenuItem<String>(
        value: value.toString(),
        child: new Text(value.toString()),
      );
    }).toList();
  }

  getRolesForActor(String actor) {
    // Filter roles based on the selected actor
    return roles
        .where((role) => role['codePers'] == actor)
        .map((role) => role['role'])
        .toList();
  }

  Future _pickImage() async {
    setState(() {
      actualSelected = 0;
    });
    print('here::');
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        droppedFiles.add(pickedFile);
      });
      // Faites quelque chose avec l'image sélectionnée ici
      print('Chemin de l\'image : ${pickedFile.path}');
    }
  }

  Future _pickImagePersonnel() async {
    // print(selectedPersonnel);
    // print("selectedPersonnel");
    setState(() {
      actualSelected = 2;
    });
    print('here::');
    // final pickedFile =
    //     await ImagePicker().pickImage(source: ImageSource.gallery);
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'pdf',
        'doc',
        'ai',
        'psd',
        'png',
        'jpeg',
        'doc',
        'xls',
        'xlsx',
        'docx',
        'mp3',
        'mp4'
      ],
    );

    // print(pickedFile);
    // print("pickedFile:::");
    if (pickedFile != null) {
      setState(() {
        droppedFilesPersonnel.add(
            {'codePers': selectedPersonnel['codePers'], 'file': pickedFile});
        // droppedFilesPersonnel.add(pickedFile);
      });
      getImportSize();
      // Faites quelque chose avec l'image sélectionnée ici
      print('Chemin de l\'image : ${pickedFile.paths}');
    }
  }

  editScreen(data, index) {
    showDialog(
        context: context,
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;
          return AlertDialog(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width / 2,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey2,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            initialValue: codePers,
                            enabled: false,
                            // controller: _nameController,
                            decoration:
                                InputDecoration(labelText: 'Code personnel'),
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Nom'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer le nom';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(labelText: 'Prénom'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer le prénom';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(labelText: 'Âge'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer l\'âge';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Container(
                                width: width / 5,
                                child: TextFormField(
                                  enabled: false,
                                  controller: _roleController,
                                  decoration: InputDecoration(
                                      labelText: 'Fonction actuelle'),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: width / 5,
                                child: TextFormField(
                                  enabled: false,
                                  controller: _selectedDateController,
                                  decoration: InputDecoration(
                                      labelText: 'Date de prise de fonction'),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            // width: 300,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width / 5,
                                      child: TextFormField(
                                        onChanged: (value) {},
                                        controller: _newRoleController,
                                        decoration: InputDecoration(
                                            labelText: 'Nouvelle fonction'),
                                        // validator: (value) {
                                        //   if (value!.isEmpty) {
                                        //     return 'veuillez entrer le rôle';
                                        //   }
                                        //   return null;
                                        // },
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _selectedDateRole == null
                                              ? 'Modifier la date de prise de fonction'
                                              // : 'Date de prise de fonction: ${_selectedDate.toString()}',
                                              : 'Date de prise de fonction: ${dateFormat.format(_selectedDateRole)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              // locale: const Locale('fr', 'FR'),
                                              initialDate: _selectedDateRole,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2101),
                                            );
                                            if (picked != null &&
                                                picked != _selectedDateRole) {
                                              setState(() {
                                                _selectedDateRole = picked;
                                                Navigator.pop(context);
                                                editScreen(data, index);
                                              });
                                            }
                                          },
                                          child: Text(
                                              'Modifier la date de prise de fonction'),
                                        )
                                      ],
                                    ),

                                    //   ],
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                child: DropdownButton<String>(
                                  hint: Text('Ancienne(s) fonction(s)'),
                                  // value: selectedActor,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedActor = newValue!;
                                    });
                                  },
                                  // items:,
                                  items: getItems(codePers),
                                ),
                              ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                final box = await Hive.openBox('pixelFiles');

                                if (_formKey2.currentState!.validate()) {
                                  // _savePersonnel();
                                  var newData = {};
                                  if (_newRoleController.text.isNotEmpty) {
                                    newData = {
                                      'nom': _nameController.text,
                                      'prenom': _surnameController.text,
                                      'age': _ageController.text,
                                      'oldRole': _roleController.text,
                                      'fonction': _newRoleController.text,
                                      'datePriseFonction': _selectedDateRole,
                                      'codePers': codePers,
                                    };
                                    final box =
                                        await Hive.openBox('pixelFiles');
                                    var personnelData =
                                        await box.get('personnelData');

// Create a new list to store modified personnel data
                                    List<dynamic> updatedPersonnelData = [];

                                    for (var i = 0;
                                        i < personnelData.length;
                                        i++) {
                                      if (i == index) {
                                        updatedPersonnelData.add(newData);
                                      } else {
                                        updatedPersonnelData
                                            .add(personnelData[i]);
                                      }
                                    }
                                    await box.put(
                                        'personnelData', updatedPersonnelData);
                                  } else {}

                                  if (!roles
                                          .contains(_oldRoleController.text) &&
                                      _oldRoleController.text !=
                                          _newRoleController.text &&
                                      _newRoleController.text.isNotEmpty) {
                                    // Add a new role if it doesn't already exist
                                    setState(() {
                                      roles.add({
                                        'dateChange': getTodayDate(),
                                        'heureChange': getTodayHeure(),
                                        'role': _oldRoleController.text,
                                        'codePers': codePers,
                                        'datePriseFonction': _selectedDate,
                                      });
                                    });
                                  }

                                  var personnelsFonctions =
                                      box.get('personnelFonctions');
                                  if (personnelsFonctions == null) {
                                    await box.put('personnelFonctions', roles);
                                  } else {
                                    // Merge existing roles with new roles
                                    for (var pf in personnelsFonctions) {
                                      if (!roles.contains(pf)) {
                                        roles.add(pf);
                                      }
                                    }
                                    await box.put('personnelFonctions', roles);
                                  }

                                  // final box = await Hive.openBox('pixelFiles');
                                  // var personnelData =
                                  //     await box.get('personnelData');
                                  // for (var i = 0;
                                  //     i < personnelData.length;
                                  //     i++) {
                                  //   if (i == index) {
                                  //     personnelData[i] = newData;
                                  //   }
                                  // }
                                  // if (!roles
                                  //         .contains(_oldRoleController.text) &&
                                  //     _oldRoleController.text !=
                                  //         _roleController.text) {
                                  //   setState(() {
                                  //     roles.add({
                                  //       'dateChange': getTodayDate(),
                                  //       'heureChange': getTodayHeure(),
                                  //       'role': _oldRoleController.text,
                                  //       'codePers': codePers
                                  //     });
                                  //   });
                                  // } else {}
                                  // await box.put('personnelData', personnelData);
                                  // var personnelsFonctions =
                                  //     box.get('personnelFonctions');
                                  // if (personnelsFonctions == null) {
                                  //   await box.put('personnelFonctions', roles);
                                  // } else {
                                  //   for (var pf in personnelsFonctions) {
                                  //     roles.add(pf);
                                  //   }
                                  //   await box.put('personnelFonctions', roles);
                                  // }
                                  setState(() {
                                    getPersonnelsData();
                                  });
                                  Navigator.pop(context);
                                  msgAwait(context, 'Modifer avec succès');
                                }
                              },
                              child: Text('Enregistrer les modifications'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  registerData(data) async {
    Navigator.pop(context);
    final box = await Hive.openBox('pixelFiles');
    await box.put('nomEntreprise', data);
    msgAwait(context, "Le nom de l'entreprise à été enregistrée");
    var nomEntreprise = await box.get('nomEntreprise');
    print(nomEntreprise);
    print("nomEntreprise");
    if (nomEntreprise != null) {
      setState(() {
        nameEntreprise = nomEntreprise['nomEntreprise'];
      });
    }
  }

  getEnterpriseName() async {
    final box = await Hive.openBox('pixelFiles');
    var nomEntreprise = await box.get('nomEntreprise');
    // await box.delete('nomEntreprise');
    print(nomEntreprise);
    print("nomEntreprise");
    if (nomEntreprise != null) {
      setState(() {
        nameEntreprise = nomEntreprise['nomEntreprise'];
      });
    }

    nomEntreprise != null
        ? null
        // ignore: use_build_context_synchronously
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Container(
                height: 300,
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Entrez le nom de votre entreprise',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrez le nom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  var data = {
                                    "nomEntreprise": nameController.text,
                                    "dateCreation": getTodayDate(),
                                  };
                                  await registerData(data);
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     content: Text('Company name submitted'),
                                  //   ),
                                  // );
                                  // Here you can handle the submission logic
                                }
                              },
                              child: Text('Valider'),
                            ),
                          ),
                        ],
                      ),
                    )),
              ));
            });
  }

  getPersonnelsData() async {
    final box = await Hive.openBox('pixelFiles');
    var personnelData = await box.get('personnelData');
    var pf = await box.get('personnelFonctions');
    setState(() {
      if (pf == null) {
        roles = [];
      } else {
        roles = pf;
      }
    });
    // box.delete('personnelData');
    print(roles);
    print("roles");

    if (personnelData == null) {
      setState(() {
        personnels = [];
      });
    } else {
      setState(() {
        personnels = personnelData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Durations.short1).then((value) {
      getEnterpriseName();
      getPersonnelsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Row(
        children: [
          Card(
            // color: Color.fromARGB(255, 198, 197, 197),
            elevation: 10,
            child: Container(
              width: width / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Align(
                      child: Text(
                        '${nameEntreprise}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        actualFocus = 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        color: actualFocus == 0 ? Colors.blue : Colors.white,
                      ),
                      width: 150,
                      padding: EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          Text(
                            'Personnels',
                            style: TextStyle(
                                fontSize: 17,
                                color: actualFocus == 0
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        actualFocus = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        color: actualFocus == 1 ? Colors.blue : Colors.white,
                      ),
                      width: 150,
                      child: Row(
                        children: [
                          Icon(Icons.file_copy),
                          Text(
                            'Fichiers',
                            style: TextStyle(
                                fontSize: 17,
                                color: actualFocus == 1
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actualFocus == 0 ? Personnels(width) : Fichiers(heigth, width),
        ],
      ),
    );
  }

  Column Fichiers(double heigth, double width) {
    return Column(
      children: [
        Card(
            // elevation: 10,
            child: Container(
          height: heigth / 11,
          width: width - width / 5,
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      actualSelected = 0;
                    });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        // color: Colors.white,
                        color:
                            actualSelected == 0 ? Colors.orange : Colors.black,
                      ),
                      padding: EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Icon(Icons.import_export, color: Colors.white),
                          Text(
                            'Importer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ))),
              SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      actualSelected = 2;
                    });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        // color: Colors.white,
                        color:
                            actualSelected == 2 ? Colors.orange : Colors.grey,
                      ),
                      padding: EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Icon(Icons.people_alt, color: Colors.white),
                          Text(
                            'Collaborateurs',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ))),
              SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      actualSelected = 1;
                    });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        // color: Colors.white,
                        color:
                            actualSelected == 1 ? Colors.orange : Colors.grey,
                      ),
                      padding: EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.white),
                          Text(
                            'Voir mes fichiers importés',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ))),
            ],
          ),
        )),
        actualSelected == 2
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width - width / 5,
                      height: 150,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width / 1.3,
                            child: MasonryGridView.count(
                              itemCount: personnels.length,
                              // crossAxisCount: crossAxisCount,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 130,
                                  // color: Colors.green,
                                  child: Card(
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Nom: ${personnels[index]['nom']}'),
                                            Text(
                                                'Prénom: ${personnels[index]['prenom']}'),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                  'Fonction: ${personnels[index]['fonction']}'),
                                            ),
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.blue[200])),
                                                onPressed: () async {
                                                  // await Hive.deleteBoxFromDisk(
                                                  //     'files');
                                                  // var files =
                                                  //     await Hive.openBox(
                                                  //         'files');
                                                  // // files.clear();
                                                  // var codePers =
                                                  //     selectedPersonnel[
                                                  //         'codePers'];
                                                  // List adressedFiles =
                                                  //     await files.get(
                                                  //             'code-$codePers') ??
                                                  //         [];
                                                  // print(adressedFiles);
                                                  // print("adressedFiles::");
                                                  // if (adressedFiles == null) {
                                                  //   adressedFiles = [];
                                                  // } else {}
                                                  // // ignore: use_build_context_synchronously
                                                  // showDialog(
                                                  //     context: context,
                                                  //     builder: (context) {
                                                  //       return AlertDialog(
                                                  //         actions: [
                                                  //           TextButton(
                                                  //               onPressed: () {
                                                  //                 Navigator.pop(
                                                  //                     context);
                                                  //               },
                                                  //               child: Text(
                                                  //                 'Fermer',
                                                  //                 style: TextStyle(
                                                  //                     color: Colors
                                                  //                         .red),
                                                  //               ))
                                                  //         ],
                                                  //         content: Container(
                                                  //           // width: width - 200,
                                                  //           height:
                                                  //               heigth - 200,
                                                  //           child: Column(
                                                  //             children: [
                                                  //               SizedBox(
                                                  //                   width:
                                                  //                       width /
                                                  //                           1.3,
                                                  //                   height:
                                                  //                       heigth -
                                                  //                           200,
                                                  //                   child: MasonryGridView
                                                  //                       .count(
                                                  //                     itemCount:
                                                  //                         adressedFiles
                                                  //                             .length,
                                                  //                     // crossAxisCount: crossAxisCount,
                                                  //                     itemBuilder:
                                                  //                         (context,
                                                  //                             index) {
                                                  //                       // ignore: avoid_unnecessary_containers
                                                  //                       return Container(
                                                  //                           // color: Colors
                                                  //                           //     .red,
                                                  //                           height:
                                                  //                               200,
                                                  //                           width:
                                                  //                               120,
                                                  //                           child:
                                                  //                               Column(
                                                  //                             mainAxisAlignment: MainAxisAlignment.start,
                                                  //                             crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                             children: [
                                                  //                               Row(
                                                  //                                 mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                 children: [
                                                  //                                   Container(child: Image.file(width: 100, height: 100, File(adressedFiles[index]['filePath']))),
                                                  //                                   // Container(child: Image.file(width: 100, height: 100, File(adressedFiles[index]['file'].path))),
                                                  //                                   Container(
                                                  //                                     child: Column(
                                                  //                                       mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                       children: [
                                                  //                                         // IconButton(
                                                  //                                         //     onPressed: () {},
                                                  //                                         //     icon: Icon(
                                                  //                                         //       Icons.share,
                                                  //                                         //       color: Colors.blue,
                                                  //                                         //     )),
                                                  //                                         // IconButton(
                                                  //                                         //     onPressed: () {},
                                                  //                                         //     icon: Icon(
                                                  //                                         //       Icons.delete,
                                                  //                                         //       color: Colors.red,
                                                  //                                         //     )),
                                                  //                                         IconButton(
                                                  //                                             onPressed: () {},
                                                  //                                             icon: Icon(
                                                  //                                               Icons.remove_red_eye,
                                                  //                                               color: Colors.grey,
                                                  //                                             ))
                                                  //                                       ],
                                                  //                                     ),
                                                  //                                   )
                                                  //                                 ],
                                                  //                               ),
                                                  //                               Text('${adressedFiles[index]['fileName']}')
                                                  //                             ],
                                                  //                           ));
                                                  //                     },
                                                  //                     crossAxisCount:
                                                  //                         5,
                                                  //                   ))
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       );
                                                  //     });

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PersonnelFiles(
                                                                selectedPersonnel)),
                                                  );
                                                },
                                                child: Text(
                                                  'Voir Fichiers',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ))
                                          ],
                                        ),
                                        Checkbox(
                                          value: selectedCheck == index
                                              ? true
                                              : false,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCheck = index;
                                              selectedPersonnel =
                                                  personnels[index];
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              crossAxisCount: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    selectedCheck == -1
                        ? Text('')
                        : Container(
                            color: Colors.grey[300],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: width / 4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informations détaillés',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Nom: ${selectedPersonnel['nom']}',
                                          // style: TextStyle(
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 20),
                                        ),
                                        Text(
                                          'Prénom: ${selectedPersonnel['prenom']}',
                                          // style: TextStyle(
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 20)
                                        ),
                                        Text(
                                          'Fonction: ${selectedPersonnel['fonction']}',
                                          // style: TextStyle(
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 20)
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  // width: width / 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            height: heigth / 1.5,
                                            width: width / 4,
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: DropAreaWidget(
                                                texte:
                                                    'Déposer ici les fichiers de ce personnel',
                                                pickImage: _pickImagePersonnel,
                                                onFiles: (files) {
                                                  for (var file in files) {
                                                    if (!droppedFilesPersonnel
                                                        .any((element) =>
                                                            element['file']
                                                                .path ==
                                                            file.path)) {
                                                      print("file:::");
                                                      print(file);
                                                      droppedFilesPersonnel
                                                          .add({
                                                        'codePers':
                                                            selectedPersonnel[
                                                                'codePers'],
                                                        'file': file
                                                      });
                                                    }
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Container(
                                            // height: heigth / 2,
                                            // color: Colors.yellow,
                                            width: width / 4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Fichiers importés n(${getImportSize()})',
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      if (droppedFilesPersonnel
                                                          .isNotEmpty)
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  droppedFilesPersonnel
                                                                      .clear();
                                                                  droppedFilesSelectedPersonnel
                                                                      .clear();
                                                                });
                                                              },
                                                              child: const Text(
                                                                'Tout supprimer',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                List
                                                                    // List<FileData>
                                                                    listeData =
                                                                    [];
                                                                print(
                                                                    droppedFilesSelectedPersonnel);
                                                                print(
                                                                    "droppedFilesSelectedPersonnel");

                                                                for (var fileData
                                                                    in droppedFilesSelectedPersonnel) {
                                                                  listeData
                                                                      .add({
                                                                    'codePers':
                                                                        fileData[
                                                                            'codePers'],
                                                                    'filePath': fileData[
                                                                            'file']
                                                                        .files[
                                                                            0]
                                                                        .path,
                                                                    'fileName': fileData[
                                                                            'file']
                                                                        .files[
                                                                            0]
                                                                        .name,
                                                                    'fileSize': fileData[
                                                                            'file']
                                                                        .files[
                                                                            0]
                                                                        .size,
                                                                  });
                                                                }
                                                                var files =
                                                                    await Hive
                                                                        .openBox(
                                                                            'files');
                                                                var codePers =
                                                                    selectedPersonnel[
                                                                        'codePers'];
                                                                await files.put(
                                                                    'code-$codePers',
                                                                    listeData);
                                                                // droppedFilesSelectedPersonnel);
                                                                setState(() {
                                                                  // droppedFilesPersonnel
                                                                  //     .clear();
                                                                  // droppedFilesSelectedPersonnel
                                                                  //     .clear();
                                                                });
                                                                msgAwait(
                                                                    context,
                                                                    'Fichiers enregistrés');
                                                                // setState(() {});
                                                              },
                                                              child: const Text(
                                                                'Tout enregistrer',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  // width: 200,
                                                  // color: Colors.red,
                                                  height: heigth / 2,
                                                  child: Scrollbar(
                                                    thumbVisibility: true,
                                                    trackVisibility: true,
                                                    controller:
                                                        scrollController,
                                                    child: ListView.separated(
                                                      controller:
                                                          scrollController,
                                                      itemCount:
                                                          getPersImportSize(),
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                                  height: 4),
                                                      itemBuilder:
                                                          (context, index) =>
                                                              Container(
                                                        width: 200,
                                                        color: Colors.blue[50],
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ext == 'image'
                                                                  ? Container(
                                                                      child: Image.file(
                                                                          width:
                                                                              200,
                                                                          File(droppedFilesSelectedPersonnel[index]['file']
                                                                              .paths[0])),
                                                                    )
                                                                  : getExt(droppedFilesSelectedPersonnel[index]
                                                                              [
                                                                              'file']) ==
                                                                          'pdf'
                                                                      ? Container(
                                                                          child: Image.asset(
                                                                              width:
                                                                                  100,
                                                                              height:
                                                                                  100,
                                                                              'images/pdf.png'))
                                                                      : getExt(droppedFilesSelectedPersonnel[index]['file']) ==
                                                                              'docx'
                                                                          ? Container(
                                                                              child: Image.asset(width: 100, height: 100, 'images/word.png'))
                                                                          : getExt(droppedFilesSelectedPersonnel[index]['file']) == 'xlsx'
                                                                              ? Container(child: Image.asset(width: 100, height: 100, 'images/excel.png'))
                                                                              : getExt(droppedFilesSelectedPersonnel[index]['file']) == 'ai'
                                                                                  ? Container(child: Image.asset(width: 100, height: 100, 'images/ai.png'))
                                                                                  : getExt(droppedFilesSelectedPersonnel[index]['file']) == 'mp3'
                                                                                      ? Container(child: Image.asset(width: 100, height: 100, 'images/mp3.png'))
                                                                                      : getExt(droppedFilesSelectedPersonnel[index]['file']) == 'mp4'
                                                                                          ? Container(
                                                                                              child: Image.asset(width: 100, height: 100, 'images/mp4.png'),
                                                                                            )
                                                                                          : Container(
                                                                                              child: Image.file(width: 100, height: 100, File(droppedFilesSelectedPersonnel[index]['file'].paths[0])),
                                                                                            ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    color: Colors
                                                                        .white,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child: Text(
                                                                      droppedFilesSelectedPersonnel[index]
                                                                              [
                                                                              'file']
                                                                          .names[0],
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Colors.red),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            print(droppedFilesSelectedPersonnel);
                                                                            print("droppedFilesSelectedPersonnel");
                                                                            print(droppedFilesSelectedPersonnel[index]);
                                                                            print("droppedFilesSelectedPersonnel[index]");
                                                                            var actualImage =
                                                                                droppedFilesSelectedPersonnel[index]['file'].files[0].path;
                                                                            setState(() {
                                                                              // droppedFilesSelectedPersonnel.remove(droppedFilesSelectedPersonnel[index]);

                                                                              droppedFilesPersonnel.removeWhere((element) => element['file'].files[0].path == actualImage);
                                                                              droppedFilesSelectedPersonnel.removeWhere((element) => element['file'].files[0].path == actualImage);
                                                                            });
                                                                            print(droppedFilesSelectedPersonnel);
                                                                            print("droppedFilesSelectedPersonnel after:::");
                                                                          },
                                                                          child: Text(
                                                                              'Enlever m',
                                                                              style: TextStyle(color: Colors.black))),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      // Text(
                                                                      // onPressed:
                                                                      //     () {
                                                                      // getExt(droppedFilesSelectedPersonnel[index]['file']) == 'pdf'
                                                                      //     ? showDialog(
                                                                      //         context: context,
                                                                      //         builder: (context) {
                                                                      //           return ViewPdfWindows(droppedFilesSelectedPersonnel[index]['file'].paths[0]);
                                                                      //         })
                                                                      //     : getExt(droppedFilesSelectedPersonnel[index]['file']) == 'mp3'
                                                                      //         ? playMp3()
                                                                      //         : showDialog(
                                                                      //             context: context,
                                                                      //             builder: (context) {
                                                                      //               return ZoomableImageDialog(
                                                                      //                 imageUrl: File(droppedFilesSelectedPersonnel[index]['file'].paths[0]), // Replace with your image URL
                                                                      //               );
                                                                      //             });
                                                                      // },
                                                                      // child:
                                                                      getWidget(
                                                                          getExt(droppedFilesSelectedPersonnel[index]
                                                                              [
                                                                              'file']),
                                                                          droppedFilesSelectedPersonnel[index]
                                                                              [
                                                                              'file'])
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                  ],
                ),
              )
            : actualSelected == 1
                ? Container(
                    width: width - width / 5,
                    // color: Colors.yellow,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width - width / 4.5,
                              height: heigth - 100,
                              child: Scrollbar(
                                thumbVisibility: true,
                                trackVisibility: true,
                                controller: scrollController,
                                child: MasonryGridView.count(
                                  controller: scrollController,
                                  mainAxisSpacing:
                                      8.0, // Espacement vertical entre les éléments
                                  crossAxisSpacing: 8.0,
                                  crossAxisCount:
                                      5, // Nombre de colonnes dans la grille
                                  itemCount: droppedFiles.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: EdgeInsets.all(8.0),
                                      child: Card(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 70,
                                              child: Image.file(
                                                File(droppedFiles[index].path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Container(
                                              width: 150,
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                '${droppedFiles[index].name}',
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },

                                  // Espacement horizontal entre les éléments
                                ),
                              ),
                            ),

                            // for (var i = 0; i < droppedFiles.length; i++) ...{
                            //   Container(
                            //       // color: Colors.red,
                            //       width: 100,
                            //       height: 150,
                            //       child: Card(
                            //         child: Column(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             Container(
                            //               width: 150,
                            //               height: 70,
                            //               child: Image.file(
                            //                   width: 100,
                            //                   File(droppedFiles[i].path)),
                            //             ),
                            //             Container(
                            //               width: width,
                            //               // color: Colors.amber,
                            //               child: Align(
                            //                 child: Text(
                            //                   '${droppedFiles[i].name}',
                            //                   style: TextStyle(fontSize: 10),
                            //                 ),
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       ))
                            // }
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        // color: Colors.green,
                        width: width - width / 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Drop your images',
                              //   style: Theme.of(context)
                              //       .textTheme
                              //       .displaySmall
                              //       ?.copyWith(color: Colors.white),
                              // ),
                              // Text(
                              //   'JPG, PNG, GIF files are allowed',
                              //   style: Theme.of(context).textTheme.titleLarge,
                              // ),
                              // const SizedBox(height: 16),
                              Container(
                                // color: Colors.red,
                                // width: width / 2,
                                height: heigth - 115,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width / 3,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: DropAreaWidget(
                                          texte:
                                              'Déposer ici les fichiers à importer',
                                          pickImage: _pickImage,
                                          onFiles: (files) {
                                            for (var file in files) {
                                              if (!droppedFiles.any((element) =>
                                                  element.path == file.path)) {
                                                print("file:::");
                                                print(file);
                                                droppedFiles.add(file);
                                              }
                                            }

                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      // height: heigth / 2,
                                      // color: Colors.red,
                                      width: width / 2.7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'Fichiers importés m(${droppedFiles.length})',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              if (droppedFiles.isNotEmpty)
                                                TextButton(
                                                  onPressed: () {
                                                    // droppedFiles.clear();
                                                    setState(() {
                                                      droppedFilesPersonnel
                                                          .clear();
                                                      droppedFilesSelectedPersonnel
                                                          .clear();
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Tout supprimer',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                )
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            // width: 200,
                                            // color: Colors.red,
                                            height: heigth / 1.4,
                                            child: Scrollbar(
                                              thumbVisibility: true,
                                              trackVisibility: true,
                                              controller: scrollController,
                                              child: ListView.separated(
                                                controller: scrollController,
                                                itemCount: droppedFiles.length,
                                                separatorBuilder: (context,
                                                        index) =>
                                                    const SizedBox(height: 4),
                                                itemBuilder: (context, index) =>
                                                    Container(
                                                  color: Colors.blue[50],
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        child: Image.file(
                                                            width: 300,
                                                            File(droppedFiles[
                                                                    index]
                                                                .path)),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            color: Colors.white,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Text(
                                                              droppedFiles[
                                                                      index]
                                                                  .name,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.delete,
                                                                  color: Colors
                                                                      .red),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    var actualImage =
                                                                        droppedFiles[index]
                                                                            .path;
                                                                    setState(
                                                                        () {
                                                                      droppedFiles.removeWhere((element) =>
                                                                          element
                                                                              .path ==
                                                                          actualImage);
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                      'Enlever',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black))),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(Icons
                                                                  .remove_red_eye),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return ZoomableImageDialog(
                                                                            imageUrl:
                                                                                File(droppedFiles[index].path), // Replace with your image URL
                                                                          );
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                    'Agrandir',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // )

                      // Container(
                      //   height: 300,
                      //   child: DropZoneWidget(
                      //     onDroppedFile: (file) =>
                      //         setState(() => this.file = file),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // DroppedFileWidget(file: file),
                      // Container(
                      //   // color: Colors.red,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(width: 1),
                      //   ),
                      //   height: heigth / 2,
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.import_export,
                      //         size: 45,
                      //       ),
                      //       Container(
                      //         width: width - width / 5,
                      //         child: Align(
                      //             child: Text(
                      //                 'Déposer ici les fichiers à importer ')),
                      //       )
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
      ],
    );
  }

  Column Personnels(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Card(
              // elevation: 10,
              child: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddPersonnelForm();
                      });
                },
                child: Container(
                  width: 150,
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    // color: Colors.white,
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_box,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    getPersonnelsData();
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    Text('Actualiser'),
                  ],
                ))
          ],
        ),
        Card(
          // color: Colors.orange[50],
          elevation: 10,
          child: Container(
            // color: Colors.red,
            width: width - (width / 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Align(
                    child: Text(
                      'Personnels',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  width: width / 1.5,
                  // height: 200,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DataTable(
                              // border: TableBorder.all(width: 1.0),
                              // showBottomBorder: true,
                              headingRowColor:
                                  MaterialStatePropertyAll(Colors.white),
                              columns: [
                                DataColumn(label: Text('N')),
                                DataColumn(label: Text('Nom')),
                                // DataColumn(label: Text('Prénom client')),
                                DataColumn(label: Text('Prénom')),
                                DataColumn(label: Text('Âge')),
                                DataColumn(label: Text('Fonction')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: [
                                for (var i = 0; i < personnels.length; i++) ...{
                                  DataRow(cells: [
                                    DataCell(Text((i + 1).toString())),
                                    DataCell(Text(personnels[i]['nom'])),
                                    // DataCell(Text(personnel.clientName +
                                    //     ' ' +
                                    //     personnel.clientSurname)),
                                    DataCell(Text(personnels[i]['prenom'])),
                                    DataCell(
                                        Text(personnels[i]['age'].toString())),
                                    // DataCell(Text(personnel.name)),
                                    DataCell(Text(personnels[i]['fonction'])),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            print(personnels);
                                            print("personnels");
                                            setState(() {
                                              _nameController.text =
                                                  personnels[i]['nom'];
                                              _surnameController.text =
                                                  personnels[i]['prenom'];
                                              _ageController.text =
                                                  personnels[i]['age']
                                                      .toString();
                                              _roleController.text =
                                                  personnels[i]['fonction'];
                                              _oldRoleController.text =
                                                  personnels[i]['fonction'];
                                              codePers =
                                                  personnels[i]['codePers'];
                                              // var date = DateTime.parse(
                                              //     personnels[i]
                                              //         ['datePriseFonction']);
                                              _selectedDate = personnels[i]
                                                  ['datePriseFonction'];
                                              _selectedDateController.text =
                                                  dateFormat.format(personnels[
                                                      i]['datePriseFonction']);
                                              print(_selectedDate);
                                              print("_selectedDate::op");

                                              //  dateFormat
                                              //     .format(date)
                                            });
                                            editScreen(personnels[i], i);
                                            // editpersonnel(
                                            //     personnel,
                                            //     personnels.indexWhere(
                                            //         (element) =>
                                            //             element == personnel));
                                            // Action pour modifier le produit
                                            // Vous pouvez ajouter votre logique ici
                                            // print('Modifier ${personnel.name}');
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.import_export),
                                          onPressed: () {
                                            // Action pour supprimer le produit
                                            // Vous pouvez ajouter votre logique ici
                                            // print(
                                            //     'Supprimer ${personnel.name}');
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.remove_red_eye),
                                          onPressed: () {
                                            // Navigation vers la page du produit
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         personnelPage(personnel: personnel),
                                            //   ),
                                            // );
                                          },
                                        ),
                                      ],
                                    )),
                                  ]),
                                }
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
