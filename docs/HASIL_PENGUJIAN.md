> Arsip pengujian tahap 1. Untuk perubahan Flutter Web dan hasil build terbaru, baca [HASIL_PENGUJIAN_WEB.md](HASIL_PENGUJIAN_WEB.md).

# Hasil pengujian tahap 1

Tanggal: **16 November 2026**. Lingkungan: Linux, Flutter **3.50.0 stable**, Dart **3.14.0**, Python **3.12**. Tidak tersedia host Windows, Android SDK/emulator, perangkat Android atau project Firebase yang sudah dikonfigurasi.

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Flutter analyze shared package | Lulus, no issues | `test-logs/school_data-analyze.txt` |
| Flutter analyze Admin | Lulus, no issues | `test-logs/admin_windows-analyze.txt` |
| Flutter analyze Mobile | Lulus, no issues | `test-logs/mobile-analyze.txt` |
| Test shared domain + API client integration | **7 lulus** | `test-logs/school_data-tests.txt` |
| Test store + widget Admin | **6 lulus** | `test-logs/admin_windows-tests.txt` |
| Test adapter/navigasi/widget Mobile | **5 lulus** | `test-logs/mobile-tests.txt` |
| Test backend demo HTTP | **9 lulus** | `test-logs/demo-api-tests.txt` |
| Python syntax Cloud Run/demo backend | Lulus `py_compile` | Pemeriksaan sintaks, bukan uji Firebase live |
| Build debug APK | **Terhenti: No Android SDK found** | `test-logs/android-build-attempt.txt` |
| Build/run Windows EXE | Belum dijalankan; membutuhkan Windows + Visual Studio C++ | Jalankan panduan root pada PC Windows |
| Firebase/Auth/Firestore/Storage/FCM live | Belum diuji, belum online | Tidak ada kredensial atau deployment yang dibuat |

**Total 27 test lulus.** Ini bukan klaim bahwa seluruh acceptance criteria produksi PRD telah dipenuhi.

## Skenario yang benar-benar diuji

- Penugasan satu guru ke lebih dari satu kelas; konflik jadwal kelas/guru/ruang dan batas jam bersisian.
- Sesi hanya dapat dibuka oleh guru yang ditugaskan, open idempotent dan status kehadiran terpisah antarmapel.
- Manual attendance membutuhkan alasan; retry status sama tidak menggandakan event; koreksi menambahkan riwayat.
- Penutupan sesi ditolak sebelum semua siswa ditinjau; guru tidak dapat menulis kembali sesi tertutup.
- Input nilai dibatasi penugasan dan rentang 0–100.
- **Integrasi sungguhan**: test menyalakan proses server demo Python pada port lokal sementara, menghubungkan tiga instance repository Flutter (admin/guru/wali), mengubah nama siswa dari admin, membaca perubahan pada guru/wali, mencatat absensi guru, lalu memeriksa inbox wali dan monitoring admin. Ini HTTP nyata dengan berkas sementara, bukan hanya mock UI.
- Server menolak identitas demo tak sesuai, penulisan master oleh guru, penulisan absensi oleh wali, sesi milik guru lain dan pengubahan tautan anak oleh wali.
- Snapshot lama mendapat 409; snapshot baru disimpan ke berkas. Pengulangan status yang sama tidak menghasilkan event baru.
- Navigasi admin seluruh 10 area, form tambah guru, navigasi mobile guru/wali dan gateway yang tidak menyediakan admin.
- Statistik wali berasal dari data bersama, tanda dibaca bekerja lokal, dan nilai diperbarui dari repository.
- Render widget pada **1440×900** untuk admin dan **390×844** untuk mobile; interaksi konfirmasi sesi dan pencatatan manual diuji tanpa overflow yang terdeteksi pada skenario tersebut.

## Render yang diperiksa

- `screenshots/admin-dashboard.png`
- `screenshots/teacher-dashboard.png`
- `screenshots/teacher-attendance.png`
- `screenshots/parent-dashboard.png`

Render dibuat oleh Flutter widget tests dengan data fiktif dan font uji yang dibundel beserta lisensinya. Ini bukan screenshot Windows/Android terpasang. Header/bagian dinamis memakai tanggal perangkat saat pengujian. Untuk meregenerasi render dari folder masing-masing aplikasi:

```powershell
flutter test --dart-define=CAPTURE_VISUALS=true --update-goldens
```

`flutter test` biasa tetap menguji interaksi dan overflow tetapi tidak membandingkan gambar bertanggal dengan baseline lama. Font DejaVu hanya untuk test; tema runtime asli tetap dipertahankan.

## Perbaikan yang ditemukan melalui pengujian

1. Controller form dibuang sebelum animasi dialog selesai; kini dialog menunggu unmount sebelum controller dibuang.
2. Klien Flutter mengirim body chunked, sedangkan demo server membaca Content-Length; klien kini menetapkan panjang body UTF-8 sebelum pengiriman. Uji HTTP tiga repository membuktikan alur sesudah perbaikan.
3. Badge `TIDAK_HADIR` pada prototype semula dapat ikut kondisi hijau karena mengandung kata `HADIR`; kondisi status diperbaiki.
4. Statistik, konten kehadiran terakhir dan nilai wali yang semula statis diganti data dari repository bersama.

Flutter awalnya terblokir karena deteksi lingkungan mencoba endpoint metadata. Source tool diverifikasi dan pengujian dijalankan dengan `CI=true` agar deteksi metadata tidak dijalankan. Tidak ada langkah pengujian tersisa yang membutuhkan akses endpoint metadata.

## Pengujian yang masih wajib di perangkat target

Build dan jalankan Windows serta Android, uji keyboard/mouse, ukuran jendela 1280×720, Android 360dp/tablet, teks besar, keyboard dialog, Wi-Fi terputus, dua perangkat bersamaan, restart laptop/server, pemulihan konflik saat dialog terbuka, login Firebase, otorisasi emulator, notification permissions, FCM, foto privat dan installer. Lihat backlog untuk rincian fitur produksi yang belum tersedia.
