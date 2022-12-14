import 'package:flutter/services.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
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
  late bool isPrinting;

  @override
  void initState() {
    super.initState();
    loadConfigPrinter();
    isPrinting = false;
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
    await loadConfigPrinter();
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res =
        await printer.connect(ipPrinter, port: int.parse(portPrinter));

    if (res == PosPrintResult.success) {
      await printDemoReceipt(printer);
      printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impressão efetuada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    printer.text(
      'G4 Tech. Its Works !!',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy HH:mm:ss');
    final String timestamp = formatter.format(now);
    printer.text(
      timestamp,
      styles: PosStyles(align: PosAlign.center),
      linesAfter: 2,
    );
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
