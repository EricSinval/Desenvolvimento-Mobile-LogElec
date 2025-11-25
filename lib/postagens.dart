import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_create.dart';
import 'dart:io' as io;

class _PostsHeader extends StatefulWidget {
  const _PostsHeader({Key? key}) : super(key: key);

  @override
  State<_PostsHeader> createState() => _PostsHeaderState();
}

class _PostsHeaderState extends State<_PostsHeader> {
  String _companyType = 'descarte';

  @override
  void initState() {
    super.initState();
    _loadType();
  }

  Future<void> _loadType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _companyType = prefs.getString('company_type') ?? 'descarte';
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cadastroLabel = _companyType == 'descarte' ? 'Cadastro de resíduos' : 'Criar post de empresa';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF0E8A6E), const Color(0xFF1EA07F)]),
      ),
      child: Row(
        children: [
          // left: logo
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset('img/LOGO.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.recycling, color: Colors.white, size: 34)),
          ),
          // center: spacer (search removed)
          const Expanded(child: SizedBox()),
          // right: menu (NO LOGIN BUTTON)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.menu, color: Colors.white),
              color: Colors.white,
              onSelected: (v) async {
                // when user selects the cadastro option, open CreatePostScreen
                if (v == 4) {
                  // determine company type from prefs and open create post
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final companyType = prefs.getString('company_type') ?? _companyType;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePostScreen(companyType: companyType)));
                  } catch (e) {
                    // ignore navigation errors
                  }
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 1, child: Text('Empresas de coleta')),
                const PopupMenuItem(value: 2, child: Text('Mensagens')),
                const PopupMenuItem(value: 3, child: Text('Agendamento de coleta')),
                PopupMenuItem(value: 4, child: Text(cadastroLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsFooter extends StatelessWidget {
  const _PostsFooter({Key? key}) : super(key: key);

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
              // Descubra
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
              // contato (campo email)
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
              // idioma + redes
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

class PostsPage extends StatelessWidget {
  // viewing: 'coleta' means show collection companies (for descarte users)
  // viewing: 'descarte' means show posted items (for coleta users)
  final String viewing;
  final String userName;
  const PostsPage({Key? key, required this.viewing, this.userName = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isViewingColeta = viewing == 'coleta';
    // Use the common header/footer and show a welcome strip like the design
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          // top header (same as home but without login button)
          const _PostsHeader(),
          // welcome banner
          Container(
            width: double.infinity,
            color: const Color(0xFFF3EFE7),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Seja bem vindo ${userName.isNotEmpty ? '($userName)' : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          // content (listen to Hive posts box)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder(
                valueListenable: Hive.box('posts').listenable(),
                builder: (context, box, _) {
                  final raw = (Hive.box('posts').values.toList()).cast<Map>().toList();
                  final targetCreator = isViewingColeta ? 'descarte' : 'coleta';
                  final posts = raw.where((p) => (p['creator_type'] ?? '') == targetCreator).toList();
                  if (posts.isEmpty) {
                    // intentionally show no posts on initial entry — empty state
                    return Center(
                      child: Text('Nenhum post por enquanto', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: posts.length,
                    itemBuilder: (ctx, idx) {
                      final p = posts[idx];
                      final title = p['title'] ?? 'Post';
                      final desc = p['description'] ?? '';
                      final imagePath = p['image_path'];
                      final color = Colors.green.shade100;
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: color,
                                child: imagePath != null && imagePath.toString().isNotEmpty
                                    ? Image.file(io.File(imagePath.toString()), fit: BoxFit.cover, errorBuilder: (c, e, s) => Center(child: Icon(Icons.description, size: 48, color: Colors.grey[700])))
                                    : Center(child: Icon(Icons.description, size: 48, color: Colors.grey[700])),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text(desc, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)])),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // footer
          const _PostsFooter(),
        ],
      ),
      
    );
  }
}
