import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _ipController = TextEditingController(text: '');
    _portController = TextEditingController(text: '');
    configPreferences();
  }

  Future<void> configPreferences() async {
    prefs = await SharedPreferences.getInstance();

    _ipController.text = prefs.getString('ip') ?? '';
    _portController.text = prefs.getString('port') ?? '';
  }

  Future<void> saveConfigs() async {
    if (_formKey.currentState!.validate()) {
      prefs.setString('ip', _ipController.text);
      prefs.setString('port', _portController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.horizontal,
          backgroundColor: Colors.green,
          content: Text("Configurações salvas com sucesso"),
          duration: Duration(seconds: 3),
        ),
      );
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Configurações da impressora:",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            controller: _ipController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              label: Text("IP:"),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Preencha este campo';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            label: Text("Porta:"),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha este campo';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => saveConfigs(),
                icon: const Icon(Icons.save),
                label: const Text("Salvar"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
