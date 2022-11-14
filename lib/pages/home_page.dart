import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:poc_label/components/custom_dialog_mixin.dart';
import 'package:poc_label/components/menu_widget.dart';
import 'package:poc_label/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with CustomDialogMixin {
  late TextEditingController _docController;
  late String ipPrinter;
  late String portPrinter;

  @override
  void initState() {
    super.initState();
    loadConfigPrinter();
    _docController = TextEditingController(text: '');
  }

  Future<void> loadConfigPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    ipPrinter = prefs.getString('ip') ?? '';
    portPrinter = prefs.getString('port') ?? '';

    if (ipPrinter.isEmpty || portPrinter.isEmpty) {
      showCustomDialog(
        context: context,
        title: 'Atenção!',
        content: 'Impressora não está configurada!',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                )
                .then((value) => Navigator.of(context).pop()),
            child: const Text('Ir para configurações'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: Theme.of(context)
                  .textTheme
                  .button
                  ?.copyWith(color: Colors.red),
            ),
          ),
        ],
      );
    }
  }

  Future<void> openBarcodeScanCamera() async {
    String barcodeScanData;

    try {
      barcodeScanData = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.DEFAULT,
      );
    } on PlatformException {
      barcodeScanData = '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Falha na leitura.'),
          duration: Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }

    if (!mounted) return;

    if (barcodeScanData.isNotEmpty) {
      _docController.text = barcodeScanData;
      FocusScope.of(context).unfocus();
      connectPrinter();
    }
  }

  void connectPrinter() async {
    loadConfigPrinter();
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res =
        await printer.connect(ipPrinter, port: int.parse(portPrinter));

    if (res == PosPrintResult.success) {
      // showCustomDialog(
      //   context: context,
      //   title: 'Sucesso!!',
      //   content: 'Conexão com a impressora efetuada com sucesso!',
      //   actions: [
      //     TextButton(
      //       onPressed: () => () => Navigator.of(context).pop(),
      //       child: const Text('Fechar'),
      //     )
      //   ],
      // );
      printDemoReceipt(printer);
      printer.disconnect();
    }
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    // Print image
    final ByteData data = await rootBundle.load('assets/logo.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image? image = decodeImage(bytes);
    printer.image(image!);

    printer.text('GROCERYLY',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text('889  Watson Lane', styles: PosStyles(align: PosAlign.center));
    printer.text('New Braunfels, TX',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Tel: 830-221-1234',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Web: www.example.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    printer.hr();
    printer.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    printer.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'ONION RINGS', width: 7),
      PosColumn(
          text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    printer.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'PIZZA', width: 7),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    printer.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'SPRING ROLLS', width: 7),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    printer.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'CRUNCHY STICKS', width: 7),
      PosColumn(
          text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    printer.hr();

    printer.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    printer.hr(ch: '=', linesAfter: 1);

    printer.row([
      PosColumn(
          text: 'Cash',
          width: 8,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$15.00',
          width: 4,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    printer.row([
      PosColumn(
          text: 'Change',
          width: 8,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 4,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    printer.feed(2);
    printer.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    printer.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    printer.feed(1);
    printer.cut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: const [MenuWidget()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _docController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                label: const Text('Nº Documento:'),
                suffixIcon: IconButton(
                  onPressed: () => openBarcodeScanCamera(),
                  icon: const Icon(Icons.camera_alt),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Imprimir teste'),
                onPressed: () => connectPrinter(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
