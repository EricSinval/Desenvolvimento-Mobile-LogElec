import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// image upload removed per request
import 'services/api_service.dart';
import 'services/local_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _cnpjCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  String? _companyType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyType();
  }

  Future<void> _loadCompanyType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyType = prefs.getString('company_type') ?? 'descarte';
    });
  }

  // image picker removed

  @override
  Widget build(BuildContext context) {
    // use same background color as home page
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // Title
                      const Text(
                        'Crie uma conta',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0E8A6E)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Company type label
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8AC3B6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tipo: ${_companyType == 'descarte' ? 'Empresa de Descarte' : 'Empresa de Coleta'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF153B33)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // image removed (disabled)
                      const SizedBox(height: 12),

                      // Form fields card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(_nameCtl, 'Nome/Razão Social', Icons.business),
                              const SizedBox(height: 12),
                              _buildTextField(_cnpjCtl, 'CNPJ', Icons.numbers),
                              const SizedBox(height: 12),
                              _buildTextField(_addressCtl, 'Endereço', Icons.location_on),
                              const SizedBox(height: 12),
                              _buildTextField(_emailCtl, 'Email', Icons.email),
                              const SizedBox(height: 12),
                              _buildTextField(_passCtl, 'Senha', Icons.lock, obscure: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      _saving
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? true) {
                                  setState(() => _saving = true);
                                  final payload = {
                                    'name': _nameCtl.text.trim(),
                                    'cnpj': _cnpjCtl.text.trim(),
                                    'address': _addressCtl.text.trim(),
                                    'email': _emailCtl.text.trim(),
                                    'password': _passCtl.text,
                                    'company_type': _companyType,
                                  };
                                  final api = ApiService();
                                  final success = await api.signup(payload);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada no backend')));
                                    Navigator.of(context).pop();
                                    return;
                                  }
                                  final ok = await LocalAuthService.register(payload);
                                  setState(() => _saving = false);
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada localmente')));
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao criar conta')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Enviar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0E8A6E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0E8A6E), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
    );
  }
}
