import 'dart:isolate';
import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

class FIleHelper {
  static const timeout = 60;
  
  static const compare = ListEquality();

  static List change(List data, String origin, String replace, int position) {
    print(origin);
    final length = origin.length;
    final raw = data.getRange(position, position + length).toList();
    final result = data;
    if (!compare.equals(raw, utf8.encode(replace)) && compare.equals(raw, utf8.encode(origin))) {
      result.replaceRange(position, position + length, utf8.encode(replace));
    }
    return result;
  }

  static void write(File file, String origin, String replace, int position) {
    try {
      final io = file.openSync(mode: FileMode.append);
      final length = origin.length;
      io.setPositionSync(position);
      final raw = io.readSync(length);
      if (!compare.equals(raw, utf8.encode(replace)) && compare.equals(raw, utf8.encode(origin))) {
        io.setPositionSync(position);
        io.writeFromSync(utf8.encode(replace));
      }
      io.closeSync();
    }
    // ignore: empty_catches, empty_statements
    catch (e) {}
  }

  static void modify(message) {
    final file = message["file"];
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    while (DateTime.now().millisecondsSinceEpoch / 1000 - time <= timeout) {
      write(file, "krr-prd.star-api.com", message["api"], int.parse("4A403", radix: 16));
      write(file, "asset-krr-prd.star-api.com/{0}", message["asset"], int.parse("1D36E", radix: 16));
    }
    Isolate.exit();
  }

  static void modify11(message) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
    final file = message["file"];
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    List data = await file.getContent();
    data = change(data, "krr-prd.star-api.com", message["api"], int.parse("4A403", radix: 16));
    data = change(data, "asset-krr-prd.star-api.com/{0}", message["asset"], int.parse("1D36E", radix: 16));
    while (DateTime.now().millisecondsSinceEpoch / 1000 - time <= timeout) {
      file.writeToFileAsBytes(bytes: data, mode: FileMode.write);
    }
    Isolate.exit();
  }
}
