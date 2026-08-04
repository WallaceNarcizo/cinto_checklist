import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Column(
                children: [
                  Icon(
                    Icons.paragliding,
                    size: 70,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Checklist de Segurança',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Botões
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // BOTÃO 1 - CHECKLIST CINTO
                    _buildMenuButton(
                      context: context,
                      icon: Icons.checklist,
                      title: 'Checklist de Cinto',
                      subtitle: 'Inspeção do cinto paraquedista',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(
                              tipoChecklist: 'cinto',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // BOTÃO 2 - CHECKLIST TOMBADOR
                    _buildMenuButton(
                      context: context,
                      icon: Icons.factory,
                      title: 'Checklist Tombador',
                      subtitle: 'Inspeção NR-12',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(
                              tipoChecklist: 'tombador',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // BOTÃO 3 - CHECKLIST RAMPA ALFA BAG (NOVO)
                    _buildMenuButton(
                      context: context,
                      icon: Icons.ramp_right,
                      title: 'Checklist Rampa Alpha Bag',
                      subtitle: 'Segurança para embarque',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(
                              tipoChecklist: 'rampa',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Versão
              Text(
                'Versão 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
