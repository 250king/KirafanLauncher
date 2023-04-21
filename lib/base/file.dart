import 'dart:isolate';
import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';

class FIleHelper {
  static void write(File file, String origin, String replace, int position) {
    try {
      final io = file.openSync(mode: FileMode.append);
      const compare = ListEquality();
      final length = origin.length;
      io.setPositionSync(position);
      final raw = io.readSync(length);
      if (!compare.equals(raw, utf8.encode(replace))) {
        if (compare.equals(raw, utf8.encode(origin))) {
          io.setPositionSync(position);
          io.writeFromSync(utf8.encode(replace));
        }
      }
      io.closeSync();
    }
    // ignore: empty_catches, empty_statements
    catch (e) {}
  }

  static void modify(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (final message in receivePort) {
      final file = message["file"];
      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      while (DateTime.now().millisecondsSinceEpoch / 1000 - time <= 60) {
        write(file, "krr-prd.star-api.com", message["api"], int.parse("4A403", radix: 16));
        write(file, "asset-krr-prd.star-api.com/{0}", message["asset"], int.parse("1D36E", radix: 16));
      }
      Isolate.exit();
    }
  }
}
