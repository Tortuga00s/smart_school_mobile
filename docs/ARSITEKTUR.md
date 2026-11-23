# Arsitektur dan batas integrasi

## Pembaruan Flutter Web

Mobile sekarang mendukung Android dan Web. Semua networking runtime memakai `package:http`; deteksi platform menggunakan `kIsWeb` lalu `defaultTargetPlatform`. CORS lokal ada di demo API; desain UI tidak berubah. Lihat `AUDIT_FLUTTER_WEB.md`, `PANDUAN_FLUTTER_WEB.md` dan `HASIL_PENGUJIAN_WEB.md`.

## Fondasi tahap 1 yang dipertahankan

Kedua aplikasi menggunakan DTO dan `SchoolStore` dari `packages/school_data`. Implementasi demo secara fisik terpisah dalam `lib/src/demo_repository.dart`, bukan terselip sebagai data produksi. Widget wali yang sudah ada memakai adapter `ParentDemoStore` ke repository bersama.

`services/demo_api/server.py` adalah sumber kebenaran demo. Klien mengambil snapshot tersaring per role, menyimpan dengan revisi optimistis dan menerima kembali snapshot canonical. Revisi lama mendapat HTTP 409 dan klien memuat ulang; pengguna mengulang perubahan setelah meninjau pesan. Tidak ada penggabungan konflik diam-diam. Penyimpanan atomik memakai temporary file lalu replace, dengan mutex dalam satu proses server. Server ini tidak untuk multi-instance Cloud Run.

- Admin: master data, penugasan, jadwal, persetujuan contoh, koreksi, pengaturan.
- Guru: jadwal yang ditugaskan / pengganti, sesi, absensi manual, laporan berhalangan, nilai dalam penugasan.
- Wali: siswa yang tertaut G01, riwayat/inbox/nilai/jadwal, profil. Mobile tidak memiliki navigasi admin.
- Pemeriksaan role demo memakai `X-Demo-Role` + `X-Demo-Uid`. **Ini identitas simulasi, bukan autentikasi aman.** Nama guru dan master non-sensitif fiktif masih dibagikan untuk merender relasi. Filter data anak ada di server, tetapi demo bukan bukti kesiapan keamanan produksi.
- Event inbox diturunkan server dari perubahan status absensi. Retry status sama tidak membuat event tambahan; perubahan status menghasilkan revisi baru. Delivery selalu `DEMO_INBOX_ONLY`. Tanda dibaca masih lokal pada sesi UI wali.
- Seed masih berisi catatan ilustrasi lama dari prototype. Metode `WAJAH` pada seed adalah label data fiktif warisan; tidak memiliki foto dan bukan hasil scan nyata. Absensi baru hanya `MANUAL`.

## Jalur produksi yang disiapkan

Admin Windows dan Mobile → HTTPS Cloud Run API → Firebase Admin SDK → satu Firestore sekolah. Android memperoleh Firebase ID token lewat Firebase Auth; desktop memerlukan alur identitas yang tervalidasi, misalnya OIDC browser dengan PKCE lalu pertukaran token yang sesuai. Tidak menaruh service-account JSON di Flutter.

`IdTokenProvider` adalah batas penyedia token; `LiveSchoolApi` menyertakan Bearer token dan menolak HTTP. UI demo belum menginstansiasikan adapter live. Mengubah URL demo ke alamat Cloud Run tidak otomatis membuat integrasi produksi berfungsi karena kontrak demo dan live sengaja berbeda.

`services/cloud_run_api/main.py` menyediakan fondasi nyata:

| Endpoint | Implementasi |
|---|---|
| GET `/health` | Status service foundation |
| GET `/v1/me` | Verifikasi ID token + user aktif + schoolId dari server |
| GET `/v1/assignments` | Filter sekolah; guru hanya assignment miliknya; maksimum 200 |
| POST `/v1/assignments` | Admin saja; validasi referensi lintas sekolah; transaksi create idempotent melalui ID deterministik + audit |
| POST `/v1/sessions`, `/v1/attendance`, `/v1/proof-access` | HTTP 501 eksplisit; belum selesai |

Cloud Run memakai Application Default Credentials dari service identity. Firebase rules menolak seluruh baca/tulis klien langsung pada tahap fondasi. Admin SDK melewati rules, sehingga kontrol role/schoolId wajib di setiap endpoint server. Ini lebih ketat dari rancangan akses langsung SDK di PRD; akses langsung Android dapat dibuka nanti setelah rules dan uji emulator otorisasi tersedia.

Menyiapkan lokal untuk pengembangan API live (bukan untuk demo UI):

```powershell
cd services/cloud_run_api
py -3 -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
# Konfigurasikan project Firebase/ADC secara terpisah; jangan commit key.
uvicorn main:app --host 127.0.0.1 --port 8081
```

Belum dilakukan deploy, konfigurasi IAM, pembuatan akun Firebase, pemasangan token provider, atau pengujian Firestore live. Endpoint health tidak mengakses Firebase; endpoint lain memerlukan konfigurasi sah. Status produksi tetap **belum online**.

## Lanjutan sesuai PRD

Firestore production harus memakai koleksi `users`, `students`, `guardians`, `student_guardians`, `classes`, `subjects`, `academic_years`, `teaching_assignments`, `schedules`, `sessions`, `attendance`, `consents`, `face_enrollments`, `notifications`, `user_devices`, `attendance_audits`, `calendar_exceptions`.

Demo masih menyimpan satu `guardianId` per siswa; relasi banyak wali per siswa harus dimigrasi ke `student_guardians` sebelum produksi. ID absensi deterministik per sessionId/studentId; penulisan server memakai transaksi, waktu server, revision dan request idempotency. Notifikasi produksi memakai recipientUid/sessionId/eventType/revision. Sesi belum dimulai tidak menghasilkan tidak hadir massal. Scheduler memeriksa deadline hanya pada sesi terbuka, setelah kalender/izin/pengganti diperiksa. Status peringatan berbeda dari tidak hadir final.

Bukti foto disimpan privat di Storage, tanpa URL publik atau foto dalam FCM. Endpoint bukti wajib memverifikasi schoolId, consent, guru penugasan atau wali tertaut; signed access berumur pendek jika dipakai, dengan audit dan retensi. Kamera/ML Kit hanya deteksi; pengenalan identitas dan liveness memerlukan implementasi/pengujian tersendiri.

## Referensi resmi yang diperiksa

- https://firebase.google.com/docs/admin/setup
- https://firebase.google.com/docs/auth/admin/verify-id-tokens
- https://docs.cloud.google.com/run/docs/authenticating/end-users
- https://docs.flutter.dev/platform-integration/windows/setup
- https://docs.flutter.dev/platform-integration/windows/building

Rujukan ini mendasari kontrak integrasi, bukan bukti fitur cloud sudah beroperasi.
