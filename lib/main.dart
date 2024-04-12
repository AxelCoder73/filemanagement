import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:pixel_file_management/home.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

class XFileTypeAdapter extends TypeAdapter<XFile> {
  @override
  final typeId = 100; // Un identifiant unique pour XFile

  @override
  XFile read(BinaryReader reader) {
    // Décoder la chaîne en XFile
    final path = reader.read();
    return XFile(path);
  }

  @override
  void write(BinaryWriter writer, XFile obj) {
    // Encoder XFile en une chaîne (par exemple, le chemin du fichier)
    writer.write(obj.path);
  }
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

class FileDataAdapter extends TypeAdapter<FileData> {
  @override
  final int typeId = 0; // Unique identifier for this adapter

  @override
  FileData read(BinaryReader reader) {
    return FileData(
      codePers: reader.readString(),
      filePath: reader.readString(),
      fileName: reader.readString(),
      fileSize: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FileData obj) {
    writer.writeString(obj.codePers);
    writer.writeString(obj.filePath);
    writer.writeString(obj.fileName);
    writer.writeInt(obj.fileSize);
  }
}

class FilePickerResultAdapter extends TypeAdapter<FilePickerResult> {
  @override
  final typeId = 33; // Unique identifier for this type
  @override
  FilePickerResult read(BinaryReader reader) {
    final pathsLength = reader.readByte();
    final paths =
        List<String>.generate(pathsLength, (_) => reader.readString());
    final namesLength = reader.readByte();
    final names =
        List<String>.generate(namesLength, (_) => reader.readString());
    final bytesLength = reader.readByte();
    final bytes = List<Uint8List>.generate(bytesLength, (_) {
      final byteListLength = reader.readByte();
      final byteList =
          List<int>.generate(byteListLength, (_) => reader.readInt());
      return Uint8List.fromList(byteList);
    });
    final sizesLength = reader.readByte();
    final sizes = List<int>.generate(sizesLength, (_) => reader.readInt());
    // Construct and return FilePickerResult
    return FilePickerResult(
      List<PlatformFile>.generate(pathsLength, (index) {
        return PlatformFile(
          name: names[index],
          path: paths[index],
          bytes: bytes[index],
          size: sizes[index],
        );
      }),
    );
  }

  @override
  void write(BinaryWriter writer, FilePickerResult obj) {
    // Implement serialization logic here
    // Example: writer.writeString(obj.someProperty);
    throw HiveError('Writing to Hive is not implemented for FilePickerResult.');
  }
}

// Define a TypeAdapter for FilePickerResult

// Example usage in your model class
// @HiveType(typeId: 0)
// class Place extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String name;

//   @HiveField(2)
//   final String imagePath; // Store the file path as a String

//   @HiveField(3)
//   final Location? location;

//   Place(this.id, this.name, this.imagePath, this.location);
// }

// Enregistrez l'adaptateur personnalisé pour XFile
void registerXFileAdapter() {}

void main() async {
  await Hive.initFlutter();
  // await Hive.ignoreTypeId(33);
  // MediaKit.ensureInitialized();
  // Hive.resetAdapters();
  // <FilePickerResultAdapter>();
  // Hive.registerAdapter(FilePickerResultAdapter());
  Hive.registerAdapter(FileDataAdapter());
  Hive.registerAdapter(XFileTypeAdapter());
  initializeDateFormatting('fr_Fr').then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
