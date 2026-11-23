# Smart School Mobile — Android dan Flutter Web

Lanjutan source mobile yang diunggah: layar wali dipertahankan, role guru dan satu backend data bersama. Android dan Google Chrome memakai source UI yang sama; `package:http` memilih implementasi native/browser.

- Chrome: default API `http://127.0.0.1:8080`.
- Android Emulator: default API `http://10.0.2.2:8080`.
- Override: `--dart-define=DEMO_API_URL=...`.

Jalankan backend dari root sebelum membuka demo. Panduan: [Flutter Web](../../docs/PANDUAN_FLUTTER_WEB.md), [README root](../../README.md), [hasil uji terbaru](../../docs/HASIL_PENGUJIAN_WEB.md).

Aplikasi Admin Windows tetap project terpisah dalam monorepo ini. Scaffold platform lain dari source lama dipertahankan; dukungan yang dikerjakan di sini adalah Android/Web untuk mobile.
