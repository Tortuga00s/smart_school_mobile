# Menjalankan Smart School Mobile di Google Chrome

Mobile kini memiliki dua target: **Android dan Web**, dengan satu UI dan satu pilihan role Guru/Orang Tua. Aplikasi Admin Windows tetap berada di project terpisah dalam monorepo yang sama.

## Jalankan backend

Pada terminal di root `SMART_SCHOOL`:

```powershell
py -3 services/demo_api/server.py
```

Pada Linux/macOS gunakan `python3` sebagai pengganti `py -3`. Biarkan terminal tetap terbuka. Backend mendengarkan `http://127.0.0.1:8080` dan menyimpan data fiktif pada `services/demo_api/demo-state.json`. Hentikan server sebelum menghapus berkas ini untuk mereset demo.

## Jalankan Flutter Web

Syarat: Flutter stable (diuji 3.50.0 / Dart 3.14.0), Google Chrome, Python 3. Untuk build Android, gunakan Android SDK dan JDK lengkap yang menyediakan javac, bukan hanya JRE. Jalankan terminal lain:

```powershell
cd apps/mobile
flutter pub get
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --dart-define=DEMO_API_URL=http://127.0.0.1:8080
```

Alternatif Windows: jalankan `scripts\run_demo_api.bat` dan `scripts\run_web.bat` dari hasil ekstrak. Buka aplikasi di `http://127.0.0.1:7357`. Tidak perlu ekstensi browser atau mematikan keamanan CORS Chrome.

Argumen `DEMO_API_URL` boleh dihilangkan: default Web tetap `http://127.0.0.1:8080`, termasuk ketika browser melaporkan platform Android.

## Build dan sajikan hasil release

```powershell
cd apps/mobile
flutter build web --release --no-web-resources-cdn --dart-define=DEMO_API_URL=http://127.0.0.1:8080
py -3 -m http.server 7357 --bind 127.0.0.1 --directory build/web
```

Buka `http://127.0.0.1:7357`. Sajikan melalui HTTP server; jangan membuka `index.html` lewat `file://`. Opsi `--no-web-resources-cdn` menyertakan resource renderer lokal; ini tidak menambahkan fitur offline untuk data sekolah.

## Pilihan role dan alur utama

1. Guru → pilih Ahmad/Siti → Buka Demo. Jadwal tetap terbatas pada penugasannya.
2. Guru → Mulai Mengajar → Konfirmasi → catat absensi manual beralasan → tinjau seluruh siswa → Selesaikan Absensi.
3. Guru → Nilai → pilih siswa → isi UTS/UAS 0–100 → Simpan Nilai.
4. Guru → Profil → Keluar / Ganti Peran → pilih Orang Tua → Buka Demo.
5. Wali → riwayat kehadiran, jadwal, akademik, profil dan inbox. Pilih Ahmad Rizki/Putra Wijaya pada dropdown anak.
6. Backend tetap satu. Data yang ditulis dari Chrome dapat dibaca Android dan Admin yang menunjuk server yang sama.

Scan wajah, bukti foto, Firebase Auth dan push FCM belum online. Mengganti target ke Web tidak mengaktifkan fitur tersebut.

## Android tetap tersedia

Manifest izin, source Kotlin dan UI Android dipertahankan. AGP pada settings.gradle.kts diperbarui 9.1.0 → 9.1.1 agar memenuhi minimum Flutter 3.50; validasi build tidak dinonaktifkan. Untuk Android Emulator:

```powershell
cd apps/mobile
flutter run -d <ID_EMULATOR> --dart-define=DEMO_API_URL=http://10.0.2.2:8080
```

Tanpa override, default native Android tetap `http://10.0.2.2:8080`. Untuk HP USB gunakan `adb reverse tcp:8080 tcp:8080` dan override `http://127.0.0.1:8080`. HTTP cleartext pada Android tetap hanya untuk build debug sesuai konfigurasi sebelumnya.

## CORS dan troubleshooting

Backend menerima origin `http(s)://localhost:<port>`, `http(s)://127.0.0.1:<port>`, atau loopback IPv6. Port pengembangan/test boleh berbeda. Tidak ada wildcard origin, cookie credential, atau bypass role. Origin domain luar dan `null`/`file://` ditolak.

- GET `/health`, GET `/snapshot`: pemeriksaan service dan baca data.
- PUT `/snapshot`: simpan snapshot dengan pemeriksaan revisi dan role.
- POST `/snapshot`: alias operasi simpan yang sama; bukan bypass validasi.
- OPTIONS: preflight 204 untuk GET/POST/PUT/OPTIONS dan header JSON/identitas demo yang diizinkan.
- Respons 400/403/404/409 bagi origin lokal tetap menyertakan CORS, sehingga aplikasi dapat membaca error sebenarnya.

Jika koneksi gagal, pastikan backend menyala, alamat laptop memakai `127.0.0.1` dan port 8080, dan Web disajikan dari origin lokal di atas. Jangan memakai alamat emulator `10.0.2.2` pada Chrome laptop. Jika muncul 409, muat ulang data dan ulangi perubahan setelah meninjaunya. Jangan publikasikan demo API ini ke internet; identitas header-nya masih simulasi.

## Uji ulang

Dari setiap folder `packages/school_data`, `apps/admin_windows`, dan `apps/mobile`:

```powershell
flutter pub get
flutter analyze
flutter test
```

Uji CORS backend dari root:

```powershell
py -3 -m unittest discover -s services/demo_api -v
```

Untuk uji Chrome otomatis, jalankan backend dengan **berkas state uji terpisah dan baru** (jangan menunjuk data demo yang ingin disimpan):

```powershell
py -3 services/demo_api/server.py --port 8181 --state web-smoke-state.json
```

Lalu dari `apps/mobile`:

```powershell
flutter test --platform chrome test/browser/web_smoke_test.dart --dart-define=DEMO_API_URL=http://127.0.0.1:8181 --dart-define=BROWSER_DEMO_API_URL=http://127.0.0.1:8181 --reporter expanded
```

Hentikan server dan hapus `web-smoke-state.json` sebelum mengulangi suite tersebut. Uji Chrome menulis sesi absensi dan nilai fiktif. Uji VM biasa melewati suite browser; suite browser secara khusus tidak mengimpor helper `dart:io` untuk font atau proses Python.

Uji alur UI dengan HTTP native (tambahan, bukan pengganti browser), dengan backend uji yang sama:

```powershell
flutter test test/live_flow_vm_test.dart --dart-define=RUN_LIVE_FLOW=true --dart-define=DEMO_API_URL=http://127.0.0.1:8181 --dart-define=BROWSER_DEMO_API_URL=http://127.0.0.1:8181 --reporter expanded
```

Gunakan state uji baru sebelum setiap suite. Alur UI yang sama dibagikan antara entrypoint browser dan native; factory client native hanya berada di test, bukan runtime aplikasi.

Pemeriksaan Web dapat dijalankan dari root dengan `powershell -File scripts/check_web.ps1`. Tambahkan `-RunChrome` setelah menyalakan backend uji baru pada port 8181 untuk menjalankan suite Chrome juga.
