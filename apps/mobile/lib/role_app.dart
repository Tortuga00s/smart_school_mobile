
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:school_data/school_data.dart';
import 'package:school_data/demo_connection.dart';

import 'features/parent/parent_app.dart';
import 'features/teacher/teacher_shell.dart';
import 'services/auth_service.dart';

class RoleGateway extends StatefulWidget {
  const RoleGateway({super.key});

  @override
  State<RoleGateway> createState() => _RoleGatewayState();
}

class _RoleGatewayState extends State<RoleGateway> {
  final AuthService _auth = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  SchoolStore? data;

  String role = 'teacher';
  String teacher = 'T01';

  bool _loading = false;
  bool _firebaseAuthenticated = false;

  String? _error;

  Future<void> _login() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final accountRole =
          (profile['role'] ?? '').toString().toLowerCase();

      final teacherId =
          (profile['teacherId'] ?? '').toString();

      final parentId =
          (profile['parentId'] ?? '').toString();

      if (accountRole == 'teacher' && teacherId.isEmpty) {
        throw Exception(
          'ID Guru belum terdaftar di profil Firestore.',
        );
      }

      if (accountRole == 'parent' && parentId.isEmpty) {
        throw Exception(
          'ID Orang Tua belum terdaftar di profil Firestore.',
        );
      }

      final newStore = SchoolStore()
        ..demoRole = accountRole
        ..demoUid = accountRole == 'teacher'
            ? teacherId
            : parentId;

      if (!mounted) {
        newStore.dispose();
        return;
      }

      setState(() {
        role = accountRole;

        if (accountRole == 'teacher') {
          teacher = teacherId;
        }

        data = newStore;
        _firebaseAuthenticated = true;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _enterDemo() {
    setState(() {
      data = SchoolStore()
        ..demoRole = role
        ..demoUid = role == 'teacher' ? teacher : 'G01';

      _firebaseAuthenticated = false;
    });
  }

  void exit() {
    final old = data;
    final wasAuthenticated = _firebaseAuthenticated;

    setState(() {
      data = null;
      _firebaseAuthenticated = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      old?.dispose();
    });

    if (wasAuthenticated) {
      _auth.signOut().catchError((_) {});
    }
  }

  @override
  void dispose() {
    data?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return DemoConnection(
        store: data!,
        child: role == 'teacher'
            ? TeacherShell(
                data: data!,
                uid: teacher,
                onExit: exit,
              )
            : ParentShell(
                data: data!,
                onExit: exit,
              ),
      );
    }

    // Browser tetap menggunakan prototype demo.
    if (kIsWeb) {
      return _buildDemoGateway();
    }

    // Android menggunakan Firebase Authentication.
    return _buildFirebaseLogin();
  }

  Widget _buildFirebaseLogin() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 76,
                    color: Color(0xFF1765C5),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Smart School',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Masuk menggunakan akun resmi '
                    'yang telah didaftarkan oleh Admin sekolah.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onSubmitted: (_) {
                      if (!_loading) _login();
                    },
                  ),

                  const SizedBox(height: 20),

                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Masuk'),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Smart School • Secure Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoGateway() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 68,
                    color: Color(0xFF1765C5),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Smart School',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih peran untuk menjelajahi alur demo sekolah.',
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'teacher',
                        label: Text('Guru'),
                        icon: Icon(Icons.co_present),
                      ),
                      ButtonSegment(
                        value: 'parent',
                        label: Text('Orang Tua'),
                        icon: Icon(Icons.family_restroom),
                      ),
                    ],
                    selected: {role},
                    onSelectionChanged: (v) {
                      setState(() => role = v.first);
                    },
                  ),
                  const SizedBox(height: 22),
                  if (role == 'teacher')
                    DropdownButtonFormField<String>(
                      initialValue: teacher,
                      items: const [
                        DropdownMenuItem(
                          value: 'T01',
                          child: Text('Ahmad — Matematika'),
                        ),
                        DropdownMenuItem(
                          value: 'T02',
                          child: Text('Siti — IPA'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => teacher = v);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Identitas demo guru',
                      ),
                    ),
                  if (role == 'parent')
                    const Text(
                      'Wali demo: Rina Andini • Ahmad Rizki (8A)',
                    ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _enterDemo,
                    child: const Text('Buka Demo'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DEMO • Bukan login akun asli. '
                    'Firebase login digunakan pada Android.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
