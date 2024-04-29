import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({super.key});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  @override
  void initState() {
    super.initState();
    // Check availability
    NfcManager.instance.isAvailable().then((isAvailable) {
      if (!isAvailable) {
        return;
      }
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          launchUrl(Uri.parse('https://ys.mihoyo.com/cloud/'), mode: LaunchMode.externalApplication);
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.isAvailable().then((isAvailable) {
      if (!isAvailable) {
        return;
      }
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('原神启动'),
      ),
      body: const Center(
        child:  Text('等待校园卡'),
      ),
    );
  }
}
