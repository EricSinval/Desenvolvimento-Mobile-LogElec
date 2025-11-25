import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/api_service.dart';
import 'services/local_auth_service.dart';
import 'login.dart';
import 'cadastroEmpresa.dart';
import 'postagens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('posts');
  runApp(const LogElecApp());
}

class LogElecApp extends StatelessWidget {
  const LogElecApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0E8A6E);
    final teal = const Color(0xFF2CA68A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LogElec Mobile',
      theme: ThemeData(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF3EFE7),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(fontSize: 15.0),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: const [
                        SizedBox(height: 18),
                        _HeroSection(),
                        SizedBox(height: 18),
                        _ChoicePanel(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF0E8A6E), const Color(0xFF1EA07F)]),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset('img/LOGO.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.recycling, color: Colors.white, size: 34)),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0E8A6E), Color(0xFF1EA07F)]),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Descubra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Descarte', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text('Coleta', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text('Cadastro de itens', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Entre em contato conosco!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Seu email aqui!',
                          suffixIcon: TextButton(onPressed: () {}, child: const Text('Enviar')),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Idioma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        value: 'Português',
                        items: const [
                          DropdownMenuItem(value: 'Português', child: Text('Português')),
                          DropdownMenuItem(value: 'English', child: Text('English')),
                        ],
                        onChanged: (_) {},
                        decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.facebook, color: Colors.white), SizedBox(width: 12), Icon(Icons.camera_alt, color: Colors.white), SizedBox(width: 12), Icon(Icons.work, color: Colors.white)]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;
      final padding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
      return Container(
        padding: padding,
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _HeroText()),
                  const SizedBox(width: 24),
                  SizedBox(width: 320, height: 180, child: _HeroImage()),
                ],
              )
            : Column(
                children: const [
                  _HeroText(),
                  SizedBox(height: 12),
                  SizedBox(height: 180, child: _HeroImage()),
                ],
              ),
      );
    });
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Tecnologia sustentável',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: const Color(0xFF173A2F))),
        const SizedBox(height: 12),
        const Text(
          'A LogElec surgiu com foco em ajudar a sociedade no descarte de resíduos eletrônicos. Buscamos uma solução simples e eficiente para facilitar o descarte e a coleta desses materiais.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        color: Colors.white,
        child: Image.asset(
          'img/LOGO.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade200, Colors.green.shade400]),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.recycling, size: 56, color: Colors.white70),
                    SizedBox(height: 8),
                    Text('LogElec', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFF8AC3B6), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 4))]),
          child: Column(
            children: [
              const Text('Qual empresa você se enquadra?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF153B33))),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        children: const [
                          Expanded(child: _ChoiceCard(title: 'Empresas que precisam descartar resíduos sólidos eletrônicos', buttonText: 'Realizo descarte!')),
                          SizedBox(width: 12),
                          Expanded(child: _ChoiceCard(title: 'Empresas que realizam coleta de resíduos eletrônicos para fins recicláveis', buttonText: 'Realizo coleta!')),
                        ],
                      )
                    : Column(
                        children: const [
                          _ChoiceCard(title: 'Empresas que precisam descartar resíduos sólidos eletrônicos', buttonText: 'Realizo descarte!'),
                          SizedBox(height: 12),
                          _ChoiceCard(title: 'Empresas que realizam coleta de resíduos eletrônicos para fins recicláveis', buttonText: 'Realizo coleta!'),
                        ],
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String buttonText;
  const _ChoiceCard({Key? key, required this.title, required this.buttonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF234B42))),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final key = buttonText.toLowerCase().contains('descarte') ? 'descarte' : 'coleta';
                await prefs.setString('company_type', key);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
              },
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

