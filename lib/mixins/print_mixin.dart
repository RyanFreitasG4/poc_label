import 'dart:io';

import 'package:barcode/barcode.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart' hide Barcode;
import 'package:image/image.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' hide Barcode;

mixin PrintReceipt {
  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    printer.text('------------------------------',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    final Uint8List imgBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // printer.text('------------------------------',
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4, 2, 3];
    // final List<dynamic> barData128 = "{ABC-abc-1234".split("");
    // printer.barcode(Barcode.upcA(barData));
    // printer.barcode(Barcode.code128(barData128));

    final Image image = Image(200, 100);
    fill(image, getColor(255, 255, 255));
    drawBarcode(image, Barcode.code128(), 'ABC-abc-1234', font: arial_24);

    printer.image(image);

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
