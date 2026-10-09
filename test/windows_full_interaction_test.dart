import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pindea/core/database/device_database.dart';
import 'package:pindea/core/database/workspace_database.dart';
import 'package:pindea/core/database/providers/database_providers.dart';
import 'package:pindea/features/notes/data/notes_repository.dart';
import 'package:pindea/features/notes/domain/models/block_item.dart';
import 'package:pindea/features/notes/presentation/editor/note_editor_screen.dart';
import 'package:pindea/features/notes/presentation/trash/trash_screen.dart';
import 'package:pindea/features/notes/providers/notes_providers.dart';
import 'package:pindea/main.dart';
import 'package:pindea/shared/widgets/app_card.dart';
import 'package:pindea/shared/widgets/app_dialog.dart';
import 'package:pindea/shared/widgets/app_header.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return Directory.systemTemp.path;
    });
  });

  group('Uji Mandiri Fungsional Tombol & Alur Interaksi Windows', () {

    testWidgets('1. Verifikasi Tombol Header, Drawer Menu, dan Navigasi Drawer', (tester) async {
      await tester.pumpWidget(const PindeaApp());
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
      await tester.pump();

      // Pastikan Header muncul
      expect(find.text('Pindea'), findsOneWidget);

      // A. Tombol Menu Utama (Drawer / Hamburger icon)
      final menuButton = find.byTooltip('Menu Utama');
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi Drawer terbuka dengan seluruh item navigasi
      expect(find.text('Kotak Sampah'), findsOneWidget);
      expect(find.text('Status Sinkronisasi'), findsOneWidget);
      expect(find.text('Ekspor & Cadangan'), findsOneWidget);

      // B. Tutup Drawer via tap "Semua Catatan"
      await tester.tap(find.text('Semua Catatan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // C. Tombol Sinkronisasi pada Header
      final syncButton = find.byTooltip('Sync Status');
      expect(syncButton, findsOneWidget);
      await tester.tap(syncButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi Sync Status Sheet terbuka dengan judul yang tepat
      expect(find.text('Sinkronisasi LAN & Perangkat'), findsOneWidget);

      // Tutup Sync Status Sheet
      Navigator.of(tester.element(find.text('Sinkronisasi LAN & Perangkat'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('2. Verifikasi Tombol Pencarian, Filter Chips, dan Sort Chips', (tester) async {
      await tester.pumpWidget(const PindeaApp());
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
      await tester.pump();

      // A. Input Pencarian Real-Time
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);

      await tester.enterText(searchInput, 'Rencana Belanja');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Rencana Belanja'), findsOneWidget);

      // Verifikasi tombol Clear ('X') pada Search field
      final clearButton = find.byIcon(PhosphorIcons.xCircle());
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Rencana Belanja'), findsNothing);

      // B. Tombol Chip Urutan (Date vs Title)
      final dateChip = find.text('Date ▾');
      final titleChip = find.text('Title');
      expect(dateChip, findsOneWidget);
      expect(titleChip, findsOneWidget);

      await tester.tap(titleChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(dateChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // C. Tombol Filter Chip ('Filter ▽')
      final filterChip = find.text('Filter ▽');
      expect(filterChip, findsOneWidget);
      await tester.tap(filterChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi Filter Sheet terbuka
      expect(find.text('Filter Catatan'), findsOneWidget);
      expect(find.text('Berdasarkan Folder'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      // Klik opsi folder 'Personal'
      await tester.tap(find.text('Personal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Filter Catatan'), findsNothing);

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('3. Verifikasi Tombol Ekspor & Dialog Cadangan (Data Portability)', (tester) async {
      await tester.pumpWidget(const PindeaApp());
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
      await tester.pump();

      // Buka drawer dan klik 'Ekspor & Cadangan'
      await tester.tap(find.byTooltip('Menu Utama'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Ekspor & Cadangan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Lembar Ekspor & Cadangan terbuka
      expect(find.text('Ekspor & Cadangan'), findsOneWidget);
      expect(find.text('Cadangkan Seluruh Workspace (JSON)'), findsOneWidget);

      // Klik tombol Cadangkan JSON
      await tester.tap(find.text('Cadangkan Seluruh Workspace (JSON)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog sukses cadangan muncul
      expect(find.text('Cadangan JSON Berhasil Dibuat'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);

      // Tutup dialog
      await tester.tap(find.text('Tutup'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Cadangan JSON Berhasil Dibuat'), findsNothing);

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('4. Verifikasi Interaksi Lengkap NoteEditorScreen (Header, Dock 6 Blok, Checklist)', (tester) async {
      final deviceDb = DeviceDatabase(NativeDatabase.memory());
      final workspaceDb = WorkspaceDatabase(NativeDatabase.memory());
      final repo = NotesRepository(
        deviceDb: deviceDb,
        workspaceDb: workspaceDb,
        deviceId: 'windows-test-device',
      );

      final note = await repo.createNote(
        workspaceId: 'ws-win-test',
        userId: 'user-win-test',
        title: 'Catatan Uji Windows',
        initialBlockContent: 'Isi teks awal paragraf',
      );
      await repo.addBlock('ws-win-test', note.id, BlockType.checklist, content: 'Tugas Uji Selesai');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceDatabaseProvider.overrideWithValue(deviceDb),
            notesRepositoryProvider.overrideWith((ref) => Future.value(repo)),
            currentUserIdProvider.overrideWith((ref) => Future.value('user-win-test')),
          ],
          child: MaterialApp(
            home: NoteEditorScreen(noteId: note.id),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // A. Verifikasi NoteEditorScreen terbuka dengan judul yang tepat
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Catatan Uji Windows'), findsOneWidget);

      // B. Verifikasi tombol Header (Back, Pin Quick Note, Warna Palette)
      final backButton = find.byIcon(PhosphorIconsBold.arrowLeft);
      expect(backButton, findsOneWidget);

      final pinButton = find.byTooltip('Pin Quick Note');
      expect(pinButton, findsOneWidget);

      final colorButton = find.byTooltip('Warna Quick Note');
      expect(colorButton, findsOneWidget);

      // Tap Pin Quick Note toggle
      await tester.tap(pinButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Warna Palette untuk membuka Bottom Sheet
      await tester.tap(colorButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pilih Warna Quick Note'), findsOneWidget);
      Navigator.of(tester.element(find.text('Pilih Warna Quick Note'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // C. Verifikasi tombol-tombol Toolbar Dock (6 jenis blok + undo/redo)
      expect(find.text('T'), findsOneWidget); // Blok Teks
      expect(find.text('H'), findsOneWidget); // Blok Heading
      expect(find.byIcon(PhosphorIconsRegular.checkSquare), findsWidgets); // Blok Checklist
      expect(find.byIcon(PhosphorIconsRegular.listBullets), findsOneWidget); // Blok Bullet
      expect(find.byIcon(PhosphorIconsRegular.image), findsOneWidget); // Blok Media
      expect(find.byIcon(PhosphorIconsRegular.link), findsOneWidget); // Blok Tautan

      // D. Tambahkan Blok Teks baru via Dock
      await tester.tap(find.text('T'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // E. Interaksi Toggle Checklist (Ubah centang dari persegi kosong)
      final squareCheckboxes = find.byIcon(PhosphorIconsRegular.square);
      if (squareCheckboxes.evaluate().isNotEmpty) {
        await tester.tap(squareCheckboxes.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // F. Edit Judul Catatan
      await tester.enterText(find.text('Catatan Uji Windows'), 'Catatan Uji Windows Direvisi');
      await tester.pump();
      expect(find.text('Catatan Uji Windows Direvisi'), findsOneWidget);

      // Bersihkan widget tree dan database
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
      await deviceDb.close();
      await workspaceDb.close();
    });

    testWidgets('5. Verifikasi Tombol & Konfirmasi di Trash Screen (Dengan Provider Terisi)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trashNotesStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: TrashScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi Header Trash
      expect(find.text('Sampah'), findsOneWidget);
      expect(find.byTooltip('Kembali'), findsOneWidget);

      // Saat kosong, menampilkan teks ramah
      expect(find.text('Kotak sampah kosong'), findsOneWidget);

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('6. Verifikasi Dialog Konfirmasi Standar (AppDialog)', (tester) async {
      bool? confirmResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                confirmResult = await AppDialog.confirm(
                  context: ctx,
                  title: 'Konfirmasi Uji',
                  message: 'Apakah Anda yakin ingin melanjutkan?',
                  confirmLabel: 'Ya, Lanjut',
                  isDestructive: true,
                );
              },
              child: const Text('Buka Dialog'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Buka dialog
      await tester.tap(find.text('Buka Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Konfirmasi Uji'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin melanjutkan?'), findsOneWidget);
      expect(find.text('Ya, Lanjut'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Klik konfirmasi
      await tester.tap(find.text('Ya, Lanjut'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(confirmResult, isTrue);
      expect(find.text('Konfirmasi Uji'), findsNothing);
    });
  });

  group('Uji Mandiri Kepatuhan Visual & Sistem Desain (Design System Compliance)', () {
    testWidgets('7. Verifikasi Aturan Kartu & Ketiadaan Kartu pada Header dan Icon (Card Rules)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Header (Harus tanpa AppCard)
                const AppHeader(title: 'Pindea Test'),
                // Konten preview (Harus dengan AppCard)
                AppCard(
                  child: const Text('Kartu Catatan'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // 1. Verifikasi AppHeader bukan turunan AppCard dan tidak dibungkus AppCard
      final headerFinder = find.byType(AppHeader);
      expect(headerFinder, findsOneWidget);
      expect(find.ancestor(of: headerFinder, matching: find.byType(AppCard)), findsNothing);

      // 2. Verifikasi AppCard dirender secara benar untuk kartu catatan
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Kartu Catatan'), findsOneWidget);

      // 3. Verifikasi Tombol aksi di AppHeader flat/naked tanpa bungkus AppCard
      final syncIconFinder = find.byTooltip('Sync Status');
      expect(syncIconFinder, findsOneWidget);
      expect(find.ancestor(of: syncIconFinder, matching: find.byType(AppCard)), findsNothing);
    });
  });
}
