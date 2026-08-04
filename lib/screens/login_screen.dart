import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import 'checklist_screen.dart';
import 'tombador_checklist_screen.dart';
import 'rampa_checklist_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? tipoChecklist;
  const LoginScreen({super.key, this.tipoChecklist});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Usuario? _usuarioSelecionado;
  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  bool _isCarregandoUsuarios = true;
  String? _erroCarregamento;

  final TextEditingController _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _isCarregandoUsuarios = true;
      _erroCarregamento = null;
    });

    try {
      final isConnected = await UsuarioService.testConnection();

      if (!isConnected) {
        setState(() {
          _isCarregandoUsuarios = false;
          _erroCarregamento =
              'Erro de conexão com o servidor. Verifique sua rede.';
        });
        return;
      }

      final usuarios = await UsuarioService.listarUsuarios();
      final usuariosAtivos = usuarios.where((u) => u.ativo).toList();
      usuariosAtivos.sort((a, b) => a.nome.compareTo(b.nome));
      setState(() {
        _usuarios = usuariosAtivos;
        _isCarregandoUsuarios = false;
      });
    } catch (e) {
      setState(() {
        _isCarregandoUsuarios = false;
        _erroCarregamento = e.toString();
      });
    }
  }

  void _selecionarUsuario() {
    if (_usuarios.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecione o Inspetor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha seu nome na lista abaixo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            usuario.nome[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          usuario.nome,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          setState(() {
                            _usuarioSelecionado = usuario;
                            _senhaController.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fazerLogin() async {
    if (_usuarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um inspetor para continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final senha = _senhaController.text.trim();

    if (senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite sua senha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isConnected = await AuthService.testConnection();

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      if (!isConnected) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Erro de conexão com o servidor. Verifique sua rede.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await AuthService.login(_usuarioSelecionado!.ca, senha);

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = false);

      if (result['success']) {
        final usuario = result['usuario'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${usuario.nome}!'),
            backgroundColor: Colors.green,
          ),
        );

        // VERIFICA QUAL TELA DEVE ABRIR
        if (widget.tipoChecklist == 'tombador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TombadorChecklistScreen(usuario: usuario),
            ),
          );
        } else if (widget.tipoChecklist == 'rampa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RampaChecklistScreen(usuario: usuario),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistScreen(usuario: usuario),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.paragliding,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Acesso ao Sistema',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (_isCarregandoUsuarios) ...[
                            const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Carregando lista de inspetores...'),
                                ],
                              ),
                            ),
                          ] else if (_erroCarregamento != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade700, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    _erroCarregamento!,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(color: Colors.red.shade700),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _carregarUsuarios,
                                    child: const Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_usuarios.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.person_off,
                                      color: Colors.orange.shade700, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nenhum usuário ativo encontrado',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.orange.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            InkWell(
                              onTap: _selecionarUsuario,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _usuarioSelecionado != null
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                    width: _usuarioSelecionado != null ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: _usuarioSelecionado != null
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _usuarioSelecionado != null
                                            ? Colors.green.shade100
                                            : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _usuarioSelecionado != null
                                            ? Icons.check_circle
                                            : Icons.person_add,
                                        color: _usuarioSelecionado != null
                                            ? Colors.green
                                            : Colors.blue,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _usuarioSelecionado != null
                                                ? 'Inspetor Selecionado'
                                                : 'Selecione um Inspetor',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (_usuarioSelecionado != null) ...[
                                            Text(
                                              _usuarioSelecionado!.nome,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ] else ...[
                                            const Text(
                                              'Clique para escolher',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_usuarioSelecionado != null) ...[
                              TextField(
                                controller: _senhaController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  hintText: 'Digite sua senha',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_isLoading ||
                                      _isCarregandoUsuarios ||
                                      _usuarioSelecionado == null)
                                  ? null
                                  : _fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '1. Selecione seu nome na lista\n2. Digite sua senha cadastrada',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
