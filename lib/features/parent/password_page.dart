import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});
  @override
  State<PasswordPage> createState() => _PasswordPageState();
}
class _PasswordPageState extends State<PasswordPage> {
  final form = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final hidden = [true, true, true];
  @override
  void dispose() { oldPassword.dispose(); newPassword.dispose(); confirmPassword.dispose(); super.dispose(); }
  int get strength => [newPassword.text.length >= 8, RegExp('[a-z]').hasMatch(newPassword.text) && RegExp('[A-Z]').hasMatch(newPassword.text), RegExp('[0-9]').hasMatch(newPassword.text), RegExp(r'[^a-zA-Z0-9]').hasMatch(newPassword.text)].where((v) => v).length;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Ganti Kata Sandi')), body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Keamanan akun Wali Murid', style: TextStyle(color: schoolMuted)), const SizedBox(height: 18),
    const GradientPanel(child: Row(children: [Icon(Icons.lock_outline, size: 38, color: Colors.white), SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Perbarui kata sandi Anda', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)), SizedBox(height: 6), Text('Gunakan kata sandi yang kuat dan tidak mudah ditebak.', style: TextStyle(fontSize: 12, color: Colors.white70))]))])), const SizedBox(height: 16),
    SchoolCard(child: Column(children: [_field(0, 'Kata sandi lama', oldPassword), const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider()), _field(1, 'Kata sandi baru', newPassword), const SizedBox(height: 18), _field(2, 'Konfirmasi kata sandi baru', confirmPassword)])),
    const SizedBox(height: 8), Row(children: [const Expanded(child: Text('Kekuatan kata sandi baru', style: TextStyle(color: schoolMuted, fontSize: 12))), Text(['Belum diisi', 'Lemah', 'Cukup', 'Baik', 'Kuat'][strength], style: TextStyle(color: strength >= 3 ? schoolGreen : schoolOrange, fontWeight: FontWeight.w700, fontSize: 12))]), const SizedBox(height: 8),
    Row(children: [for (var i = 0; i < 4; i++) Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: i < strength ? (strength >= 3 ? schoolGreen : schoolOrange) : schoolBorder)))]), const SizedBox(height: 20),
    _rule('Minimal 8 karakter', newPassword.text.length >= 8), _rule('Gunakan variasi huruf, angka, atau simbol', strength >= 3), _rule('Konfirmasi kata sandi sudah cocok', newPassword.text.isNotEmpty && newPassword.text == confirmPassword.text),
    const SizedBox(height: 18), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF2E2), borderRadius: BorderRadius.circular(16)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: Color(0xFFAA6419)), SizedBox(width: 12), Expanded(child: Text('Mode demo: perubahan kata sandi belum terhubung Firebase. Tombol di bawah hanya memeriksa isian.', style: TextStyle(color: Color(0xFFAA6419), height: 1.5)))])), const SizedBox(height: 18),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (form.currentState!.validate()) { FocusScope.of(context).unfocus(); oldPassword.clear(); newPassword.clear(); confirmPassword.clear(); setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isian valid. Kata sandi belum diubah karena Firebase belum terhubung.'))); } }, icon: const Icon(Icons.check), label: const Text('Simpan Kata Sandi'))), const SizedBox(height: 8), Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal'))),
  ])))));
  Widget _rule(String label, bool valid) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Icon(valid ? Icons.check_circle : Icons.radio_button_unchecked, color: valid ? schoolGreen : schoolMuted, size: 20), const SizedBox(width: 10), Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: schoolMuted)))]));
  Widget _field(int index, String label, TextEditingController controller) => TextFormField(controller: controller, obscureText: hidden[index], autocorrect: false, enableSuggestions: false, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(tooltip: hidden[index] ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi', onPressed: () => setState(() => hidden[index] = !hidden[index]), icon: Icon(hidden[index] ? Icons.visibility_off_outlined : Icons.visibility_outlined))), validator: (value) {
    if (value == null || value.isEmpty) { return 'Wajib diisi'; }
    if (index == 1 && value.length < 8) { return 'Minimal 8 karakter'; }
    if (index == 1 && value == oldPassword.text) { return 'Harus berbeda dari kata sandi lama'; }
    if (index == 2 && value != newPassword.text) { return 'Konfirmasi belum cocok'; }
    return null;
  });
}
