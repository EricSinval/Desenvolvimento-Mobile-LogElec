import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// image upload removed per request

class CreatePostScreen extends StatefulWidget {
  final String companyType;
  const CreatePostScreen({Key? key, required this.companyType}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _metaCtl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _metaCtl.dispose();
    super.dispose();
  }

  // image picker removed

  Future<void> _savePost() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final box = Hive.box('posts');
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final post = {
      'id': id,
      'creator_type': widget.companyType,
      'title': _titleCtl.text.trim(),
      'description': _descCtl.text.trim(),
      'meta': _metaCtl.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
    };
    await box.put(id, post);
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post salvo')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDescarte = widget.companyType == 'descarte';
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro postagens'),
        backgroundColor: const Color(0xFF0E8A6E),
        elevation: 0,
      ),
      body: Container(
        color: bg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      isDescarte ? 'Cadastro de Descarte' : 'Cadastro de Coleta',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E8A6E)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDescarte ? 'Descreva o material que deseja descartar' : 'Descreva o serviço de coleta oferecido',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // image removed
                    const SizedBox(height: 12),

                    // Form fields
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(_titleCtl, 'Título', Icons.title),
                            const SizedBox(height: 12),
                            _buildTextField(_descCtl, 'Descrição detalhada', Icons.description, maxLines: 3),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _metaCtl,
                              isDescarte ? 'Tipos de resíduos / peso (kg)' : 'Materiais que coleta / capacidade',
                              Icons.category,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    _saving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _savePost,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Enviar Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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