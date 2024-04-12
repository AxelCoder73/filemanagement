import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

class ShopDesign {
  static const color = Colors.lightBlue;
}

String employeeCode = '';

generateEmployeeCode() {
  // Generate a code in the format "pers-xxxxx" with a mix of letters and numbers
  employeeCode = 'pers-${generateRandomCharacters(5)}';

  return employeeCode;
}

String generateRandomCharacters(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  String result = '';
  for (int i = 0; i < length; i++) {
    result += characters[random.nextInt(characters.length)];
  }
  return result;
}

getTodayHeure() {
  DateTime now = DateTime.now();
  int hour = now.hour;
  int minute = now.minute;
  int second = now.second;
  return '$hour:$minute:$second';
}

getTodayHeure2() {
  DateTime now = DateTime.now();
  int hour = now.hour;
  int minute = now.minute;
  int second = now.second;
  return '$hour:$minute';
}

formattedAmount(amount) {
  if (amount == null) {
    return amount.toString();
  } else {
    List<int> montants = [amount];

    List<String> montantsFormates = montants.map((montant) {
      if (montant >= 1000) {
        String montantChaine = montant.toString();
        return montantChaine.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match.group(1)}.');
      } else {
        return montant.toString();
      }
    }).toList();

    // print(montantsFormates);
    return montantsFormates[0];
  }
}

getFileExtension(String filePath) {
  List<String> parts = filePath.split('.');
  return parts.last;
}

msgAwait(context, text) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(text),
        );
      });
}

formattedDate(date) {
  return jsonEncode(DateFormat('dd/MM/yyyy').format(date));
}

getTodayYear() {
  return 2023;
  // return DateTime.now().year;
}

getTodayDate() {
  return formattedDate(DateTime.now());
}

enum ImageMimeType { jpg, png, gif, other }

class ImageUtils {
  //
  static ImageMimeType checkMimeType(String path) {
    final mime = lookupMimeType(path)!;

    if (mime == 'image/gif') {
      return ImageMimeType.gif;
    }
    if (mime == 'image/png') {
      return ImageMimeType.png;
    }
    if (mime == 'image/jpeg') {
      return ImageMimeType.jpg;
    }
    return ImageMimeType.other;
  }

  static String imgeByMimeType(String path) {
    final mimeType = checkMimeType(path);
    if (mimeType == ImageMimeType.gif) {
      return 'images/gif.png';
    }
    if (mimeType == ImageMimeType.png) {
      return 'images/png.png';
    }

    return 'images/jpg.png';
  }
}
