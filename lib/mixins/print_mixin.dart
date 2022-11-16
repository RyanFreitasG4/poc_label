import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:image/image.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

mixin PrintReceipt {
  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    printer.text('------------------------------',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    final ByteData data = await rootBundle.load('assets/image.png');
    final Uint8List imgBytes = data.buffer.asUint8List();
    final Image image = decodeImage(imgBytes)!;
    printer.image(image);

    printer.text('------------------------------',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    printer.barcode(Barcode.upcA(barData));

    printer.text('------------------------------',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);
    printer.text('=== G4TECH ===', styles: PosStyles(align: PosAlign.center));
    printer.text('ENDEREÇO::', styles: PosStyles(align: PosAlign.center));
    printer.text('Rua dos Andradas, 220',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Centro, Cornélio Procópio - PR',
        styles: PosStyles(align: PosAlign.center));
    printer.text('ENTRE EM CONTATO:',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Tel: (43) 99956-2946',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Email: contato@g4tech.com.br',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Web: https://www.g4tech.com.br/',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);
    printer.text('--------------------------------',
        styles: PosStyles(align: PosAlign.center));

    printer.feed(2);
    printer.cut();
  }
}