# Status fitur dan pekerjaan lanjutan

Pembaruan Web: runtime `dart:io` sudah diganti `package:http`, Chrome didukung dan CORS lokal tersedia. Status build/pengujian terbaru berada di `HASIL_PENGUJIAN_WEB.md`; rincian di bawah mempertahankan backlog produksi tahap 1.

## Sudah diimplementasikan pada tahap 1

| Area | Cakupan nyata |
|---|---|
| Struktur | Dua aplikasi Flutter dalam satu root, DTO dan repository bersama |
| Admin | Dashboard, navigasi 10 area, cari/ubah/tambah guru-siswa-wali, aktif/nonaktif, kelas-mapel, penugasan, cek bentrok, jadwal, monitoring/koreksi beralasan, izin/pengganti, consent simulasi, pengaturan dan audit demo |
| Mobile role | Pemilihan guru/wali demo, ganti role/logout; admin tidak ada di mobile |
| Guru | Dashboard dan jadwal milik guru, konfirmasi sesi, absensi manual 5 status, alasan wajib, penutupan setelah semua siswa ditinjau, laporan berhalangan, nilai UTS/UAS tervalidasi, profil baca |
| Wali | Layar asli dipertahankan, pilih anak tertaut, riwayat/filter sesi, inbox dan detail tanpa foto palsu, tandai dibaca lokal, nilai dari input guru, jadwal dari admin, edit profil demo, validasi form sandi dengan keterangan belum mengubah akun |
| Data bersama | Satu demo API lokal, polling, snapshot tersaring data anak, persistensi berkas, revisi optimistis, rollback/muat ulang saat gagal, banner koneksi/penyimpanan |
| Integrasi | Token-provider contract, adapter HTTPS, fondasi Cloud Run dengan verifikasi Firebase ID token/role/schoolId, assignment transaction + audit, rules deny-by-default |

## Belum selesai — tidak boleh diklaim aktif/online

1. Firebase project, Firebase Auth Android, autentikasi desktop OIDC/PKCE yang tervalidasi, reset sandi, session/token lifecycle dan pemasangan adapter live ke UI.
2. CRUD produksi lengkap di API. Fondasi live baru `/me` dan assignment; endpoint sesi/absensi/bukti mengembalikan 501. Pagination/cursor produksi dan konsistensi schema lengkap masih perlu dikembangkan.
3. Attendance server transactions, waktu server, request idempotency, substitusi **per tanggal sesi**, kalender sekolah dan penegakan jam sebenarnya. Demo dapat membuka jadwal mingguan pada tanggal hari ini untuk uji alur. Pengganti pada demo melekat ke jadwal sampai diubah lagi.
4. Kamera, izin kamera, deteksi wajah, enrollment, consent sah, recognition, liveness, pengujian bias/akurasi. Tidak ada skor akurasi atau foto hasil scan yang dikarang.
5. Storage privat, upload foto, akses bukti terotorisasi, audit akses foto, pencabutan/penghapusan biometrik, retensi otomatis.
6. Cloud Functions/Scheduler, pemeriksaan deadline, warning belum tercatat, kalender/izin yang disetujui, outbox persisten, retry dan pengiriman FCM. Demo hanya inbox lokal bersama; tidak pernah mengklaim push diterima HP.
7. Relasi banyak wali per siswa (`student_guardians`), verifikasi relasi, undangan akun dan penggantian role berdasarkan akun sekolah. Demo memiliki satu guardianId per siswa dan dua identitas guru yang diizinkan di server.
8. Inbox guru lengkap sesuai desain, integrasi laporan berhalangan ke pembaruan jadwal/notifikasi wali, edit profil guru dan manajemen akun. Wali dapat melihat perubahan jadwal, tetapi event pembatalan/pengganti otomatis belum dibuat.
9. Read receipt/inbox dibaca lintas perangkat, rekap timezone sekolah, ekspor CSV/PDF, impor CSV dengan pratinjau, pagination tabel, pelaporan nilai dengan bobot resmi, semester/tahun ajaran dinamis penuh. Tanda dibaca masih lokal pada sesi UI.
10. Antrean offline, rekonsiliasi, retry bisnis otomatis, loading/empty/error/perizinan untuk seluruh alur lanjutan. Demo menolak menulis saat koneksi bermasalah, tidak menjanjikan sinkronisasi offline.
11. App Check, pengujian rules emulator, rate limiting, IAM least privilege, audit immutable produksi dan hardening API. Header identitas demo sengaja mudah dipalsukan; jangan dipakai untuk data sekolah nyata.
12. Uji instalasi emulator/perangkat nyata, build native Windows, installer Windows dengan DLL/runtime, signing, CI target platform, update aplikasi dan pilot sekolah. Status build APK pada pembaruan Web dicatat terpisah di HASIL_PENGUJIAN_WEB.md. Screenshot dalam folder ini adalah render widget test, bukan screenshot EXE/APK yang sudah diinstal.

## Urutan tahap berikutnya

Mulai dari Firebase Auth + API master data dan sesi/absensi manual dalam transaksi; migrasi repository UI dari demo ke live. Setelah otorisasi dan notifikasi per sesi teruji, tambahkan bukti privat, persetujuan sah dan kamera. Pengenalan wajah/liveness dikerjakan setelah alur non-biometrik dapat dipakai dengan benar.


## Verifikasi yang masih terbuka pada pembaruan Web

Pengujian langsung di Chrome belum terverifikasi karena pembatasan peluncuran browser/socket lingkungan, meski build Web dan CORS backend lulus. Suite browser ada di `apps/mobile/test/browser/web_smoke_test.dart`; jalankan dengan backend/state uji baru di laptop. Instalasi APK pada emulator/HP tetap perlu dilakukan terpisah.
