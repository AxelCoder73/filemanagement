import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pixel_file_management/utils/utils.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      theme: ThemeData(
        primaryColor: Colors.blue,
        // accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: AddPersonnelForm(),
      ),
    );
  }
}

class AddPersonnelForm extends StatefulWidget {
  @override
  _AddPersonnelFormState createState() => _AddPersonnelFormState();
}

class _AddPersonnelFormState extends State<AddPersonnelForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  var codePers = '';

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // locale: const Locale("fr", "FR"),
      // locale: Locale('fr', 'FR'),
      // locale: Locale('fr', 'FR'),
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController.text = generateEmployeeCode();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de Personnel'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width / 3,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      enabled: false,
                      // initialValue: codePers,
                      controller: _codeController,
                      decoration: InputDecoration(labelText: 'Code personnel'),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Veuillez entrer le nom';
                      //   }
                      //   return null;
                      // },
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
                    TextFormField(
                      controller: _roleController,
                      decoration: InputDecoration(labelText: 'Rôle'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'veuillez entrer le rôle';
                        }
                        return null;
                      },
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _selectedDate == null
                              ? 'Modifier la date de prise de fonction'
                              : 'Date de prise de fonction: ${dateFormat.format(_selectedDate)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              // locale: const Locale('fr', 'FR'),
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Text('Modifier la date de prise de fonction'),
                        )
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _savePersonnel();
                          }
                        },
                        child: Text('Enregistrer'),
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
  }

  void _savePersonnel() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final role = _roleController.text.trim();
    final box = await Hive.openBox('pixelFiles');
    final personnelBox = [];
    var personnelData = await box.get('personnelData');
    if (personnelData == null) {
      personnelBox.add({
        'nom': name,
        'prenom': surname,
        'age': age,
        'fonction': role,
        'datePriseFonction': _selectedDate,
        'codePers': _codeController.text
      });
      await box.put('personnelData', personnelBox);
    } else {
      personnelBox.add({
        'nom': name,
        'prenom': surname,
        'age': age,
        'datePriseFonction': _selectedDate,
        'fonction': role,
        'codePers': _codeController.text
      });
      for (var personnel in personnelData) {
        personnelBox.add(personnel);
      }
      await box.put('personnelData', personnelBox);
    }

    _nameController.clear();
    _surnameController.clear();
    _ageController.clear();
    _roleController.clear();
    setState(() {
      _codeController.text = generateEmployeeCode();
    });
  }
}
