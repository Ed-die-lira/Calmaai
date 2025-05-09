/**
 * Tela inicial do aplicativo
 * Exibe um carrossel de meditações, botões para as funcionalidades principais
 * e formulário para configurar lembretes
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importar serviços
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

// Importar modelos
import '../models/meditation.dart';

// Importar widgets
import '../widgets/meditation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de meditações
  List<Meditation> _meditations = [];

  // Estado de carregamento
  bool _isLoading = true;

  // Serviço de notificações
  final NotificationService _notificationService = NotificationService();

  // Controladores para o formulário de lembretes
  final TextEditingController _reminderTitleController =
      TextEditingController();
  TimeOfDay _reminderTime = TimeOfDay.now();
  final List<bool> _reminderDays = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();

    // Inicializar notificações
    _notificationService.init();

    // Carregar meditações após o widget ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeditations();
    });
  }

  @override
  void dispose() {
    // Liberar recursos
    _reminderTitleController.dispose();
    super.dispose();
  }

  // Carregar meditações do backend
  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obter token de autenticação
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      // Criar instância do serviço de API
      final apiService = ApiService(token: token);

      // Obter meditações
      final meditations = await apiService.getMeditations();

      if (mounted) {
        setState(() {
          _meditations = meditations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar meditações: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar meditações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Selecionar horário para lembrete
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  // Agendar lembrete
  Future<void> _scheduleReminder() async {
    // Validar formulário
    if (_reminderTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um título para o lembrete'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar se pelo menos um dia foi selecionado
    if (!_reminderDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um dia da semana'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Obter dias selecionados
      final List<int> selectedDays = [];
      for (int i = 0; i < _reminderDays.length; i++) {
        if (_reminderDays[i]) {
          selectedDays.add(i);
        }
      }

      // Agendar lembrete
      await _notificationService.scheduleReminder(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: _reminderTitleController.text,
        body: 'Hora de cuidar da sua saúde mental!',
        time: _reminderTime,
        days: selectedDays,
      );

      // Limpar formulário
      _reminderTitleController.clear();
      setState(() {
        for (int i = 0; i < _reminderDays.length; i++) {
          _reminderDays[i] = false;
        }
      });

      // Mostrar confirmação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lembrete agendado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erro ao agendar lembrete: $e');

      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar lembrete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obter estado de autenticação
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calma AI'),
        actions: [
          // Botão de logout
          if (authService.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authService.logout(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção de meditações
                  const Text(
                    'Meditações',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Carrossel de meditações
                  SizedBox(
                    height: 180,
                    child: _meditations.isEmpty
                        ? const Center(
                            child: Text('Nenhuma meditação disponível'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _meditations.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                child: MeditationCard(
                                  meditation: _meditations[index],
                                  onTap: () {
                                    // Navegar para a tela de meditação
                                    Navigator.pushNamed(
                                      context,
                                      '/meditation',
                                      arguments: _meditations[index],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Seção de funcionalidades
                  const Text(
                    'Funcionalidades',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grade de funcionalidades
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      // Diário Emocional
                      _buildFeatureCard(
                        icon: Icons.book,
                        title: 'Diário Emocional',
                        onTap: () => Navigator.pushNamed(context, '/diary'),
                      ),

                      // Exercícios de Respiração
                      _buildFeatureCard(
                        icon: Icons.air,
                        title: 'Respiração',
                        onTap: () => Navigator.pushNamed(context, '/breathing'),
                      ),

                      // Comunidade
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Comunidade',
                        onTap: () => Navigator.pushNamed(context, '/community'),
                      ),

                      // Meditações
                      _buildFeatureCard(
                        icon: Icons.spa,
                        title: 'Meditações',
                        onTap: () =>
                            Navigator.pushNamed(context, '/meditation'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Seção de lembretes
                  const Text(
                    'Lembretes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formulário de lembretes
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de título
                          TextField(
                            controller: _reminderTitleController,
                            decoration: const InputDecoration(
                              labelText: 'Título do lembrete',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Seletor de horário
                          Row(
                            children: [
                              const Text('Horário:'),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: _selectTime,
                                child: Text(
                                  '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Seletor de dias da semana
                          const Text('Dias da semana:'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildDayChip(0, 'D'),
                              _buildDayChip(1, 'S'),
                              _buildDayChip(2, 'T'),
                              _buildDayChip(3, 'Q'),
                              _buildDayChip(4, 'Q'),
                              _buildDayChip(5, 'S'),
                              _buildDayChip(6, 'S'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Botão de agendar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _scheduleReminder,
                              child: const Text('Agendar Lembrete'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Construir card de funcionalidade
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: const Color(0xFF64B5F6),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir chip de dia da semana
  Widget _buildDayChip(int day, String label) {
    return FilterChip(
      label: Text(label),
      selected: _reminderDays[day],
      onSelected: (selected) {
        setState(() {
          _reminderDays[day] = selected;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF64B5F6),
      labelStyle: TextStyle(
        color: _reminderDays[day] ? Colors.white : Colors.black,
      ),
    );
  }
}
