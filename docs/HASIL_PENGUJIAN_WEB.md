# Hasil pengujian pembaruan Flutter Web

Tanggal: 16 November 2026. Source utama: SMART_SCHOOL(1).zip terbaru. Lingkungan pengujian: Linux, Flutter 3.50.0 / Dart 3.14.0, Python 3.12. Google Chrome resmi 157.0.8103.78 tersedia untuk percobaan headless.

| Pemeriksaan | Hasil nyata | Bukti |
|---|---|---|
| `flutter analyze` — shared data, mobile, admin | **Lulus: no issues** | `web-test-logs/*-analyze.txt` |
| `flutter test` — shared package | **17 lulus** | `web-test-logs/school_data-test.txt` |
| `flutter test` — admin Windows | **6 lulus** | `web-test-logs/admin_windows-test.txt` |
| `flutter test` — mobile | **5 lulus**; uji HTTP live tambahan dilewati pada perintah biasa | `web-test-logs/mobile-test.txt` |
| Python demo API + CORS | **16 lulus** | `web-test-logs/demo-api-cors-tests.txt` |
| Alur UI dengan backend nyata melalui HTTP native | **2 lulus** | `web-test-logs/native-live-flow.txt`, `live-flow-api.txt` |
| `flutter build web --release --no-web-resources-cdn` | **Lulus**, `build/web` dihasilkan; Wasm dry-run juga sukses | `web-test-logs/build-web.txt`, `build-web-artifacts.json` |
| Google Chrome headless test suite | **Terhalang lingkungan**, belum lulus/terverifikasi | `web-test-logs/chrome-tests.txt` |
| Koneksi Flutter Web → demo API dalam Chrome | **Belum dapat diverifikasi langsung**, karena browser gagal diluncurkan | Penjelasan batas browser di bawah |
| Build debug APK | **Lulus**, APK debug terbentuk; belum diinstal pada perangkat | `web-test-logs/android-build.txt` |
| Instalasi/jalankan pada HP/emulator Android | Belum dilakukan, tidak ada perangkat uji | Tidak diklaim telah diuji pada perangkat |

**Total 46 test lulus** pada VM/HTTP/backend. Angka ini **tidak mencakup kelulusan Chrome**. Laporan tahap 1 disimpan sebagai arsip di HASIL_PENGUJIAN.md.

## Yang dibuktikan pengujian

- Web menggunakan default localhost `127.0.0.1:8080`, termasuk ketika TargetPlatform Android; Android native tetap `10.0.2.2:8080`. Override alamat tetap bekerja.
- Transport `package:http` mengirim GET, POST, PUT dan OPTIONS, body JSON UTF-8, header identitas dan Bearer token live; timeout dan status error tetap tersedia.
- Preflight GET/POST/PUT/OPTIONS mendapat 204; respons menyertakan origin yang tepat, daftar header dan metode. Error 403/404/409 untuk origin lokal tetap memiliki CORS. Origin luar, metode tak didukung dan header tak diizinkan ditolak.
- POST/PUT menggunakan otorisasi dan revisi yang sama. Guru tidak dapat menulis master data, wali tidak dapat menulis absensi, dan revisi lama mendapat 409.
- Uji live menyalakan server dengan state sementara, kemudian menulis/membaca data melalui HTTP nyata. Pada alur UI guru membuka sesi, mencatat absensi manual, menyimpan nilai 88/94, keluar dan masuk sebagai wali. Wali membaca hasil absensi/nilai, membuka semua tab, inbox, menandai dibaca, memilih Putra Wijaya dan kembali ke pemilih role.
- Tidak ada import `dart:io` pada runtime `apps/mobile/lib` atau `packages/school_data/lib`. Penggunaan `dart:io` tersisa khusus test VM dengan platform annotation. Kompilasi Web berhasil.
- Semua source Dart dalam `apps/mobile/lib` identik secara byte dengan source terbaru sebelum refactor: tidak ada perubahan desain UI. Bukti hash ada di `web-test-logs/ui-preservation.json`.

## Batas pengujian Chrome — jangan dianggap lulus

Perintah yang dicoba:

```text
flutter test --platform chrome test/browser/web_smoke_test.dart --reporter expanded
```

Google Chrome resmi dipanggil melalui CHROME_EXECUTABLE untuk lingkungan headless. Peluncuran gagal sebelum aplikasi dimuat dengan pesan:

```text
FATAL:chrome/browser/process_singleton_posix.cc
socket() failed: Operation not permitted (1)
Chrome process exited with code -6 before DevTools listening.
```

Ini pembatasan socket lingkungan uji, bukan hasil pengamatan error CORS aplikasi. Tidak ada `--disable-web-security` atau bypass CORS. Alternatif koneksi browser ekstensi juga tidak tersedia, dan browser terpisah tidak dapat menjangkau localhost proses backend (`ERR_CONNECTION_REFUSED`). Karena itu **tidak ada klaim bahwa koneksi, pergantian role atau fitur utama sudah berhasil diuji langsung di Chrome**.

Suite Chrome sudah disediakan dan berbagi langkah UI dengan suite native yang lulus. Jalankan suite Chrome pada laptop melalui panduan PANDUAN_FLUTTER_WEB.md dengan backend uji/state baru. Uji CORS server lulus, tetapi konfirmasi CORS di browser tetap perlu dilakukan di lingkungan yang dapat meluncurkan Chrome.

## Android

Source Android dipertahankan. Satu perbaikan versi diperlukan pada `android/settings.gradle.kts`: AGP 9.1.0 → 9.1.1 untuk memenuhi minimum Flutter 3.50. Tidak memakai `--android-skip-build-dependency-validation`. Manifest, source Kotlin, UI dan alamat emulator tidak berubah.

Percobaan awal menemukan keterbatasan lingkungan JRE tanpa javac, lalu dependency download melalui proxy memerlukan trust store JDK yang sesuai dengan host. Pengaturan SDK/JDK/proxy tersebut hanya dipakai pada lingkungan test dan tidak dimasukkan ke source/ZIP. Hasil akhir: **build debug APK lulus** setelah perbaikan AGP dan penyiapan JDK/SDK test. Hash dan ukuran APK ada pada `web-test-logs/android-build-artifact.json`; binary build tidak dibundel ke ZIP source. Gradle/Kotlin masih memberikan peringatan upgrade mendatang yang tidak menghentikan build. Tidak ada credential, certificate override atau local.properties yang dibundel.

## Reproduksi dan batas produk

Lihat PANDUAN_FLUTTER_WEB.md dan `scripts/check_web.ps1`. Test browser dan live UI menulis data fiktif; gunakan backend dengan state sementara yang baru.

Login asli, Firebase/Cloud Run live, pengenalan wajah, foto bukti, FCM dan kemampuan offline tetap belum online. Penambahan Web tidak mengubah status fitur-fitur tersebut.
