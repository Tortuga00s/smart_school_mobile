# SMART_SCHOOL — Admin Windows + Mobile Android/Web

Satu monorepo, **dua project Flutter terpisah**, satu sumber data backend per lingkungan:

| Folder | Isi |
|---|---|
| `apps/admin_windows` | Melanjutkan prototype Flutter Admin, termasuk runner Windows yang sebelumnya belum ada |
| `apps/mobile` | Source mobile asli dipertahankan; role Guru dan Orang Tua dalam satu aplikasi Android/Web |
| `packages/school_data` | DTO bersama, repository demo terpisah, koneksi demo, kontrak token + adapter HTTPS produksi awal |
| `services/demo_api` | Backend bersama yang berjalan lokal; satu seed dan satu berkas penyimpanan data |
| `services/cloud_run_api` | Fondasi backend produksi Firebase Admin SDK + Cloud Run; **belum dideploy** |
| `firebase` | Rules deny-by-default dan indeks awal |
| `docs` | PRD asli, 23 frame desain, panduan, laporan uji, backlog, provenance, screenshot render widget |
| `scripts` | Peluncur Windows dan pemeriksaan project |

Tidak ada dua repositori terpisah dan tidak ada Firebase/service account secret di aplikasi.
Cloud Run API adalah calon pengganti demo API pada lingkungan produksi, bukan database kedua yang aktif bersamaan.

## Jalankan Mobile di Chrome (baru)

Panduan lengkap: [PANDUAN_FLUTTER_WEB.md](docs/PANDUAN_FLUTTER_WEB.md). Audit: [AUDIT_FLUTTER_WEB.md](docs/AUDIT_FLUTTER_WEB.md). Hasil terbaru: [HASIL_PENGUJIAN_WEB.md](docs/HASIL_PENGUJIAN_WEB.md).

Terminal pertama dari root:

```powershell
py -3 services/demo_api/server.py
```

Terminal kedua:

```powershell
cd apps/mobile
flutter pub get
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --dart-define=DEMO_API_URL=http://127.0.0.1:8080
```

Default Chrome/Web adalah `http://127.0.0.1:8080`; default native Android Emulator tetap `http://10.0.2.2:8080`. UI dan role tetap sama. `package:http` digunakan di kedua target, dan backend lokal mendukung CORS untuk origin loopback Flutter. Tidak perlu mematikan keamanan browser.

## Mulai cepat di Windows

1. Pasang Flutter stable (versi pengujian: **3.50.0 / Dart 3.14.0**), Git, Python 3.12+, Android Studio/SDK untuk Android.
2. Untuk Admin Windows pasang **Visual Studio** dengan workload **Desktop development with C++** dan Windows SDK. VS Code saja tidak mencukupi.
3. Ekstrak seluruh ZIP ke folder, misalnya `D:\SMART_SCHOOL`. Jangan hanya menyalin satu folder aplikasi: dependency lokal ada di `packages`.
4. Buka terminal pada root `SMART_SCHOOL`, jalankan:

```powershell
py -3 services/demo_api/server.py
```

Biarkan terminal ini terbuka. Data contoh awal berasal dari `seed.json`; perubahan disimpan ke `services/demo_api/demo-state.json`. Hanya satu proses server pada satu port. Untuk reset, hentikan server lalu hapus `demo-state.json`.

5. Pada terminal kedua:

```powershell
cd apps/admin_windows
flutter doctor -v
flutter pub get
flutter run -d windows --dart-define=DEMO_API_URL=http://127.0.0.1:8080
```

Tekan **Buka Pratinjau Dashboard**. Ini pratinjau admin demo, bukan autentikasi akun asli.
Alternatif: jalankan `scripts\run_demo_api.bat`, lalu `scripts\run_admin.bat`.

## Mobile pada emulator Android

Buka emulator dari Android Studio. Pada terminal lain:

```powershell
cd apps/mobile
flutter pub get
flutter devices
flutter run -d <ID_EMULATOR> --dart-define=DEMO_API_URL=http://10.0.2.2:8080
```

Ganti `<ID_EMULATOR>` dengan ID dari `flutter devices`, tanpa tanda `< >`. `10.0.2.2` adalah alamat host Windows dari Android Emulator. Jangan memakai `localhost` emulator untuk server di laptop.

Pilih Guru (Ahmad/T01 atau Siti/T02) atau Orang Tua (Rina/G01). Mobile tidak menyediakan role atau layar admin. Alamat server juga bisa diubah di layar koneksi jika backend belum terjangkau.

## Mobile pada HP Android fisik

Pilihan paling mudah melalui USB, setelah USB debugging aktif:

```powershell
adb reverse tcp:8080 tcp:8080
cd apps/mobile
flutter run -d <ID_HP> --dart-define=DEMO_API_URL=http://127.0.0.1:8080
```

Atau gunakan Wi-Fi lokal yang sama, jalankan server dengan `--host 0.0.0.0`, lalu isi `http://IP_LAPTOP:8080` di aplikasi. Izinkan port 8080 hanya pada jaringan privat. Demo memakai identitas header yang bisa dipalsukan; gunakan data fiktif dan jangan publikasikan server ini ke internet.

HTTP cleartext hanya diizinkan pada manifest **debug Android**, untuk demo lokal. Build release membutuhkan HTTPS dan alur login produksi yang belum selesai. Tidak ada klaim APK rilis siap digunakan sekolah.

## Coba satu alur bersama

1. Admin: buat/ubah data guru/siswa, penugasan atau jadwal. Perubahan baru tersimpan ketika proses simpan selesai tanpa banner error.
2. Guru Ahmad: lihat jadwal Matematika 8A/8B; mulai sesi tanggal hari ini melalui dialog konfirmasi. Jadwal demo adalah jadwal mingguan; batas hari/jam sekolah belum ditegakkan.
3. Catat Hadir/Terlambat/Izin/Sakit/Tidak Hadir dengan alasan. Seluruh pencatatan tahap ini manual, tanpa kamera atau foto palsu.
4. Wali Rina: buka kembali role Orang Tua pada HP yang sama atau jalankan aplikasi di perangkat lain; inbox dan riwayat memperlihatkan hasil sesi. Pemilihan Ahmad Rizki atau Putra Wijaya tersedia di atas dashboard.
5. Admin: buka Monitoring Absensi untuk memeriksa perubahan. Polling demo setiap sekitar 2 detik.
6. Guru: tinjau status semua siswa sebelum menutup sesi. Sesi tertutup tidak dapat diubah guru pada demo; koreksi admin tetap tersedia.
7. Guru Siti: mulai sesi IPA. Kehadiran Ahmad pada Matematika tidak otomatis hadir pada IPA. Event inbox terpisah per sesi.

Satu laptop + emulator/HP semuanya harus mengarah ke proses demo API yang sama. Tidak ada sinkronisasi Firebase online.

## Build dan pemeriksaan

```powershell
# Jalankan dari root repo:
powershell -ExecutionPolicy Bypass -File scripts/check.ps1

# Build Admin pada Windows:
cd apps/admin_windows
flutter build windows --release

# Build debug Android untuk demo lokal:
cd ../mobile
flutter build apk --debug --dart-define=DEMO_API_URL=http://10.0.2.2:8080
```

Distribusi Windows membutuhkan seluruh folder `build\windows\x64\runner\Release`, bukan hanya EXE. Build Windows harus dilakukan pada Windows. Status build dan pengujian terbaru ada pada `docs/HASIL_PENGUJIAN_WEB.md`. Build tidak menggantikan uji instalasi pada perangkat target. `docs/HASIL_PENGUJIAN.md` adalah arsip tahap 1.

Lihat `docs/ARSITEKTUR.md`, `docs/BELUM_SELESAI.md`, `docs/AUDIT_SUMBER.md`, dan `docs/HASIL_PENGUJIAN.md` untuk batas implementasi dan tahap berikutnya.
