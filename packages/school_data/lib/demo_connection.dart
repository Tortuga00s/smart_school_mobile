import 'demo_endpoint.dart';

// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'school_data.dart';

/// Deliberately demo-only. A live adapter must use real ID tokens and HTTPS.
class DemoConnection extends StatefulWidget {
  const DemoConnection({super.key, required this.store, required this.child});
  final SchoolStore store;
  final Widget child;
  @override
  State<DemoConnection> createState() => _DemoConnectionState();
}

class _DemoConnectionState extends State<DemoConnection> {
  late final address = TextEditingController(text: demoApiUrl());
  @override
  void initState() {
    super.initState();
    widget.store.connect(address.text);
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final s = widget.store;
      if (!s.loaded)
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school, size: 56, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Hubungkan Backend Demo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Jalankan server demo bersama. Seluruh data fiktif; login dan Firebase belum online.',
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: address,
                      decoration: const InputDecoration(
                        labelText: 'Alamat API demo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (s.connectionError != null)
                      Text(
                        s.connectionError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    FilledButton(
                      onPressed: () => s.connect(address.text.trim()),
                      child: const Text('Hubungkan / Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      return Column(
        children: [
          Material(
            color: s.connectionError == null
                ? const Color(0xFFFFF3D5)
                : const Color(0xFFFFDFDF),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.connectionError ??
                            (s.saving
                                ? 'Menyimpan ke demo API…'
                                : 'DEMO LOKAL • Firebase / FCM belum online'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    if (s.connectionError != null)
                      TextButton(
                        onPressed: () => s.refresh(),
                        child: const Text('Muat ulang'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AbsorbPointer(
              absorbing: s.saving || s.connectionError != null,
              child: widget.child,
            ),
          ),
        ],
      );
    },
  );
}
