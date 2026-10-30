# Smart School • Wali Murid

Implementasi Flutter tujuh layar dari UX-16 sampai UX-22 pengguna:
Beranda, Pusat Notifikasi, Rekap Kehadiran, Jadwal Pelajaran, Nilai Akademik,
Profil, dan Ganti Kata Sandi.

## Menjalankan

Buka folder ini di VS Code atau Android Studio. Gunakan Flutter SDK dengan
Dart yang memenuhi `sdk: ^3.13.3` pada pubspec.yaml asli proyek.
Jalankan dari terminal folder proyek:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Pilih emulator Android atau HP dengan USB debugging aktif.
Untuk APK debug: `flutter build apk --debug`.

## Yang dapat dicoba

- Navigasi lima tab, beranda ke inbox notifikasi, dan tombol kembali.
- Tandai satu/semua notifikasi dibaca. Jumlah belum dibaca ikut berubah.
- Ketuk kehadiran atau notifikasi hadir untuk membuka detail sesi.
- Filter kehadiran hari ini, minggu ini, bulan ini, dan mata pelajaran.
- Ringkasan menghitung catatan sesi yang lolos filter, bukan hari sekolah.
- Pilih Senin–Jumat untuk melihat jadwal yang berbeda.
- Pilih semester genap untuk mencoba keadaan nilai belum tersedia.
- Edit profil dengan validasi nama/email. Simpan sementara dalam memori.
- Validasi konfirmasi kata sandi dan indikator kekuatan, tampil/sembunyikan sandi.
- Keluar menutup tampilan demo, lalu demo dapat dibuka kembali.

## Batas implementasi

Ini prototipe lokal dengan data fiktif. Tidak ada koneksi Firebase, akun login,
FCM, penyimpanan permanen, atau perubahan kata sandi asli. Semua data kembali
ke awal setelah aplikasi dimulai ulang. Tidak ada foto bukti maupun foto profil
asli dalam proyek; avatar memakai inisial. Waktu contoh: 5 Oktober 2026.
Font memakai font sistem Flutter, bukan aset font dari Figma.

Enam mapel ditampilkan lengkap. Rata-rata dihitung dari nilai contoh (87,4),
sehingga berbeda dari angka 87,3 pada gambar. Nilai akhir contoh menggunakan
rata-rata UTS dan UAS dengan bobot sama. Aturan produksi mengikuti sekolah.
Data bulan memuat 44 sesi, 40 hadir, 2 izin, 1 sakit, dan 1 tidak hadir.

## Struktur

- lib/main.dart: entry point.
- lib/features/parent/parent_app.dart: shell dan layar utama.
- lib/features/parent/password_page.dart: form kata sandi.
- lib/features/parent/widgets.dart: komponen bersama dan detail kehadiran.
- lib/features/parent/models.dart: model dan tema.
- lib/features/parent/demo_store.dart: data contoh, filter, state profil/inbox.
- test/widget_test.dart: pengujian data, navigasi, dan inbox.

## Integrasi tim selanjutnya

Ganti ParentDemoStore dengan repository backend terautentikasi. Ambil data
siswa hanya dari relasi wali-siswa yang terverifikasi di server. Notifikasi
harus terkait sessionId + studentId, bukan satu catatan per hari. Gunakan
inbox tersimpan untuk riwayat dan FCM sebagai pemberitahuan. Foto bukti
membutuhkan autentikasi dan pemeriksaan akses server/Storage Rules.
Untuk ganti kata sandi, lakukan autentikasi ulang dan pembaruan akun melalui
Firebase Authentication. Jangan menaruh kredensial service account di aplikasi.
Email profil demo tidak mengubah email autentikasi.

Kode guru/admin tidak ada dalam ZIP sumber yang diterima. Entry point baru
langsung membuka demo wali murid; tim dapat memakai ParentShell pada router
role wali setelah login yang sebenarnya.

## Validasi di lingkungan pengerjaan

Pemeriksaan struktur sumber dan integritas ZIP dilakukan. Flutter/Dart SDK
serta emulator Android tidak tersedia di lingkungan pengerjaan, sehingga
flutter analyze, flutter test, render UI, dan build APK belum dijalankan.
Jalankan perintah di atas pada mesin tim sebelum menggabungkan ke proyek utama.
