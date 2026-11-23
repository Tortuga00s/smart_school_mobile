# Audit empat lampiran

| Lampiran | Temuan | Tindakan |
|---|---|---|
| PRD Smart School | DOCX dengan kebutuhan Windows admin, Android guru/wali, sesi per mapel, Firebase/Cloud Run, consent, notifikasi per sesi | Disalin utuh ke PRD.docx; teks tabel dan paragraf diekstrak ke PRD.txt; tahap 1 dipetakan pada status fitur |
| Flutter Mobile Smart School | Android runner dan scaffold lain tersedia; lib berisi **role wali saja**, masuk langsung ke ParentShell; statistik dan data demo independen; belum ada role guru | Melanjutkan source dan layout wali, menambah gateway role, layar guru dan adapter data bersama |
| Flutter Admin Windows Prototype | 10 area admin, CRUD demo dan validasi konflik, tetapi belum ada folder windows/runner dan data hanya di memori | Melanjutkan UI/store asli; memindahkan domain data ke shared package; menambah koneksi API dan runner Windows dari scaffold Flutter yang sudah ada di source mobile |
| pemmob | 23 PNG frame desain: login, dashboard guru, laporan berhalangan, konfirmasi, scan/verifikasi, kehadiran, jadwal, nilai, profil, dashboard wali dan notifikasi | Semua 23 frame diperiksa dalam contact sheet dan disertakan utuh di docs/design; tidak dipakai sebagai foto bukti siswa |

PRD menuliskan rekomendasi tiga klien terpisah. Instruksi pengguna yang terbaru memilih **dua aplikasi**: Windows Admin dan Android Mobile dengan role guru/wali, sehingga struktur akhir mengikuti dua aplikasi tersebut.

## Keberlanjutan source mobile

| Source asli | Lokasi akhir | Penanganan |
|---|---|---|
| `lib/main.dart` | `apps/mobile/lib/main.dart` | Dipertahankan dan diadaptasi |
| `lib/features/parent/parent_app.dart` | `apps/mobile/lib/features/parent/parent_app.dart` | Dipertahankan dan diadaptasi |
| `lib/features/parent/password_page.dart` | `apps/mobile/lib/features/parent/password_page.dart` | Dipertahankan dan diadaptasi |
| `lib/features/parent/widgets.dart` | `apps/mobile/lib/features/parent/widgets.dart` | Dipertahankan dan diadaptasi |
| `lib/features/parent/demo_store.dart` | `apps/mobile/lib/features/parent/demo_store.dart` | Dipertahankan dan diadaptasi |
| `lib/features/parent/models.dart` | `apps/mobile/lib/features/parent/models.dart` | Dipertahankan dan diadaptasi |

Source admin `main.dart`, `admin_app.dart`, `screens.dart`, dan `ui.dart` dilanjutkan. `app_state.dart` menjadi re-export shared DTO/repository untuk menjaga kompatibilitas import. Model dan metode admin asli menjadi dasar `packages/school_data/lib/src/models.dart` dan `demo_repository.dart`; tidak dibuat dashboard admin pengganti.

Perubahan visual yang diperlukan terbatas pada pemilih role, pemilih anak, banner backend demo/kegagalan koneksi, dan pengisian konten dashboard dari repository. Guru memakai kartu putih, gradien biru, jarak, ikon dan navigasi sesuai pola frame. Frame scan wajah tidak diklaim fungsional; jalur manual diterapkan terlebih dahulu sebagaimana strategi PRD.

Form admin/guru diperbaiki agar controller tidak dibuang sebelum dialog selesai ditutup. Angka/statistik wali yang semula statis diganti hasil data bersama. Seed admin lama tetap tersedia sebagai data fiktif; bukan rekonstruksi data sekolah nyata.

Checksum keempat file asli ada di INPUT_MANIFEST.json. Output tidak memuat .dart_tool/build cache atau konfigurasi perangkat lokal. Tidak ada service-account/key cloud yang ditambahkan.
