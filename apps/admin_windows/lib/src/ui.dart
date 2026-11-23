import 'package:school_data/dialogs.dart';
// Keep original Material UI imports compatible with the uploaded project.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class C {
  static const navy = Color(0xFF10305A);
  static const blue = Color(0xFF1976D2);
  static const bright = Color(0xFF2186E8);
  static const pale = Color(0xFFEAF4FF);
  static const light = Color(0xFFF5F8FD);
  static const line = Color(0xFFE5ECF5);
  static const dark = Color(0xFF182C48);
  static const muted = Color(0xFF7B8BA1);
  static const green = Color(0xFF158D61);
  static const orange = Color(0xFFDA8A21);
  static const red = Color(0xFFD85263);
}

ThemeData smartTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.blue),
  );
  return base.copyWith(
    scaffoldBackgroundColor: C.light,
    textTheme: base.textTheme.apply(
      fontFamily: 'Segoe UI',
      bodyColor: C.dark,
      displayColor: C.dark,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.blue, width: 1.6),
      ),
      labelStyle: const TextStyle(color: C.muted, fontSize: 13),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.blue,
        side: const BorderSide(color: C.line),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.width,
  });
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: C.line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x060C315F),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: -.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: const TextStyle(color: C.muted, fontSize: 13),
            ),
          ],
        ),
        if (action != null) action!,
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class AppBadge extends StatelessWidget {
  const AppBadge(this.text, {super.key, this.color, this.background});
  final String text;
  final Color? color, background;
  @override
  Widget build(BuildContext context) {
    final b = background ?? _badgeBg(text);
    final f = color ?? _badgeFg(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: b,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.replaceAll('_', ' '),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: f),
      ),
    );
  }

  Color _badgeBg(String s) {
    if (s.contains('HADIR') && !s.contains('BELUM') && !s.contains('TIDAK') ||
        s == 'ACTIVE' ||
        s == 'AKTIF' ||
        s == 'DISETUJUI') {
      return const Color(0xFFE3F8ED);
    }
    if (s.contains('BELUM') || s == 'PENDING' || s == 'TERLAMBAT') {
      return const Color(0xFFFFF2DA);
    }
    if (s.contains('TIDAK') ||
        s == 'CANCELLED' ||
        s == 'DICABUT' ||
        s == 'DITOLAK') {
      return const Color(0xFFFFE8EB);
    }
    return C.pale;
  }

  Color _badgeFg(String s) {
    if (s.contains('HADIR') && !s.contains('BELUM') && !s.contains('TIDAK') ||
        s == 'ACTIVE' ||
        s == 'AKTIF' ||
        s == 'DISETUJUI') {
      return C.green;
    }
    if (s.contains('BELUM') || s == 'PENDING' || s == 'TERLAMBAT') {
      return C.orange;
    }
    if (s.contains('TIDAK') ||
        s == 'CANCELLED' ||
        s == 'DICABUT' ||
        s == 'DITOLAK') {
      return C.red;
    }
    return C.blue;
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
    required this.tint,
  });
  final IconData icon;
  final String title, value, note;
  final Color tint;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint, size: 23),
            ),
            const Icon(Icons.more_horiz, size: 20, color: C.muted),
          ],
        ),
        const SizedBox(height: 19),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 7),
        Text(note, style: const TextStyle(color: C.muted, fontSize: 11)),
      ],
    ),
  );
}

class SmartTable extends StatelessWidget {
  const SmartTable({super.key, required this.columns, required this.rows});
  final List<String> columns;
  final List<List<Widget>> rows;
  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(35),
        child: Center(
          child: Text(
            'Tidak ada data yang cocok.',
            style: TextStyle(color: C.muted),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFE)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: C.muted,
        ),
        dataTextStyle: const TextStyle(fontSize: 13, color: C.dark),
        horizontalMargin: 18,
        columnSpacing: 32,
        dataRowMinHeight: 62,
        dataRowMaxHeight: 70,
        dividerThickness: .5,
        columns: [for (final c in columns) DataColumn(label: Text(c))],
        rows: [
          for (final cells in rows)
            DataRow(cells: [for (final w in cells) DataCell(w)]),
        ],
      ),
    );
  }
}

Widget cell(String s, {bool strong = false, Color? color}) => Text(
  s,
  style: TextStyle(
    color: color ?? (strong ? C.dark : C.muted),
    fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
    fontSize: 12,
  ),
);

Widget primaryButton(
  String label,
  VoidCallback onPressed, {
  IconData icon = Icons.add_rounded,
}) => ElevatedButton.icon(
  onPressed: onPressed,
  icon: Icon(icon, size: 17),
  label: Text(label),
);

Widget ghostButton(
  String label,
  VoidCallback onPressed, {
  IconData icon = Icons.edit_outlined,
}) => TextButton.icon(
  onPressed: onPressed,
  icon: Icon(icon, size: 17),
  label: Text(label),
);

Widget field(
  TextEditingController ctl,
  String label, {
  String? hint,
  int lines = 1,
}) => TextField(
  controller: ctl,
  maxLines: lines,
  decoration: InputDecoration(labelText: label, hintText: hint),
);

Widget dropdown(
  String label,
  String selected,
  List<DropdownMenuItem<String>> items,
  ValueChanged<String?> onChange,
) => DropdownButtonFormField<String>(
  initialValue: selected,
  decoration: InputDecoration(labelText: label),
  items: items,
  onChanged: onChange,
  isExpanded: true,
);

List<DropdownMenuItem<String>> options(Iterable<(String, String)> pairs) => [
  for (final p in pairs)
    DropdownMenuItem(
      value: p.$1,
      child: Text(p.$2, overflow: TextOverflow.ellipsis),
    ),
];

void inform(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? C.red : C.navy,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String message, {
  String yes = 'Konfirmasi',
}) async =>
    await settledDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(yes),
          ),
        ],
      ),
    ) ??
    false;

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5E7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: Color(0xFFBD7920)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'MODE DEMO: data fiktif tersimpan di backend lokal bersama. Login asli, Firebase, foto wajah, dan push FCM belum aktif.',
            style: TextStyle(fontSize: 12, color: Color(0xFF87571B)),
          ),
        ),
      ],
    ),
  );
}
