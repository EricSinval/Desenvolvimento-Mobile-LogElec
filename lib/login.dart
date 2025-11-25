import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/local_auth_service.dart';
import 'postagens.dart';
import 'cadastroEmpresa.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    final api = ApiService();
    final success = await api.login(_emailCtl.text.trim(), _passCtl.text.trim());
    setState(() => _loading = false);
    if (success) {
      // try to determine company type from prefs
      final prefs = await SharedPreferences.getInstance();
      final companyType = prefs.getString('company_type') ?? 'descarte';
      final name = prefs.getString('user_name') ?? '';
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login bem-sucedido')));
      // Pass the actual company type to PostsPage so it can show posts from the opposite type
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PostsPage(viewing: companyType, userName: name)));
    } else {
      // fallback to local auth
      final local = await LocalAuthService.login(_emailCtl.text.trim(), _passCtl.text.trim());
      if (local != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login local bem-sucedido')));
        final companyType = (local['company_type'] ?? 'descarte').toString();
        final name = (local['name'] ?? '');
        // persist name and companyType to prefs for future backend logins
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('company_type', companyType);
        await prefs.setString('user_name', name);
        // pass the actual company type
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PostsPage(viewing: companyType, userName: name)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha no login — verifique credenciais e endpoints')));
      }
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // use same background color as home page for a consistent look
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: bg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Faça login com sua conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 8),
                    TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
                    const SizedBox(height: 14),
                    _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _doLogin, child: const SizedBox(width: double.infinity, child: Center(child: Text('Entrar')))),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
                    }, child: const Text('Criar conta'))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
