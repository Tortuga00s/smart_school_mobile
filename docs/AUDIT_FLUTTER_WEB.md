# Audit dan refactor Flutter Web

Source utama: `SMART_SCHOOL(1).zip` terbaru, Library ID `libfile_feb58539de14819197702a854553757f`. SHA-256 sama dengan paket tahap 1 sebelumnya. Source terbaru diekstrak tersendiri sebelum diedit.

| Lokasi awal | Penggunaan | Perubahan |
|---|---|---|
| `packages/school_data/lib/src/demo_repository.dart` | `dart:io`, `HttpClient`, set Content-Length dan header native | `JsonHttpTransport` berbasis `package:http`; GET/PUT dan header role tetap sama; injection client untuk test |
| `packages/school_data/lib/live_api.dart` | `dart:io`, `HttpClient`, `HttpHeaders`, `HttpException` | Transport HTTP bersama; Bearer token, HTTPS wajib, POST assignment dan timeout dipertahankan |
| `packages/school_data/lib/demo_connection.dart` | `dart:io`, `Platform.isAndroid` | `demoApiUrl()` memakai `kIsWeb` dahulu, lalu `defaultTargetPlatform` |
| `packages/school_data/test/api_integration_test.dart` | Process, Directory, ServerSocket, HttpOverrides, Platform Windows untuk menyalakan Python | Tetap pengujian VM; diberi `@TestOn('vm')`; tidak diimpor aplikasi |
| `packages/school_data/test/seed_test.dart` | File untuk ekspor seed opsional | Tetap pengujian VM; diberi `@TestOn('vm')` |
| `packages/school_data/test/load_fonts.dart` | File untuk memuat font golden test | Helper khusus VM; screenshot test mobile diberi `@TestOn('vm')`; tidak diimpor aplikasi |
| `apps/mobile/test/live_flow_vm_test.dart` | HttpOverrides untuk client native asli pada uji UI HTTP | Test khusus VM dengan flag RUN_LIVE_FLOW; suite browser memakai client browser asli |
| `apps/mobile/lib/**` | Tidak memiliki import `dart:io` langsung sebelum refactor; ketergantungan berasal dari shared package | Tidak mengubah source UI. Semua dependency runtime yang menghalangi Web telah dihapus |

Audit sesudah refactor: **tidak ada import `dart:io`, HttpClient, HttpHeaders atau Platform.isAndroid pada `apps/mobile/lib` dan `packages/school_data/lib`.** Import `package:http` memilih implementasi browser/native sesuai target. Test-only `dart:io` tetap sah pada VM dan dipisahkan dari suite browser.

Transport tidak menetapkan `Origin`, `Host`, atau `Content-Length` secara manual; browser mengelolanya. JSON menggunakan UTF-8, timeout mencakup pengiriman dan pembacaan response, dan status error tetap tersedia untuk UI/rollback revisi yang sudah ada. Tidak memakai stub Web dengan data lain atau server kedua.

`services/demo_api/server.py` menerima preflight tanpa identitas tetapi tetap memeriksa role saat operasi data sebenarnya. POST dan PUT memakai fungsi simpan yang sama, dengan revisi optimistis, filter role dan audit yang sama. Header CORS diberikan juga pada error untuk origin lokal yang valid. Origin luar ditolak sebelum mutasi.

Seluruh byte source `apps/mobile/lib` dipertahankan. Folder Android dipertahankan dengan satu perbaikan versi yang diperlukan: AGP 9.1.0 → 9.1.1 pada settings.gradle.kts agar memenuhi minimum Flutter 3.50. Manifest, source Kotlin, UI dan endpoint emulator tidak berubah. Perubahan lain hanya shared networking, metadata Web, server CORS, tes dan dokumentasi. Struktur tetap satu monorepo, dua project Flutter.

Referensi resmi:

- https://pub.dev/packages/http
- https://pub.dev/documentation/http/latest/browser_client/BrowserClient-class.html
- https://docs.flutter.dev/platform-integration/web/building
- https://docs.flutter.dev/platform-integration/web/initialization
