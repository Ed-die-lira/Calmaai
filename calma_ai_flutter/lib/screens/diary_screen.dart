/**
 * Tela de diário emocional
 * Permite ao usuário registrar seu estado emocional
 * e visualizar o histórico com análise de sentimentos
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Importar serviços
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Importar modelos
import '../models/diary_entry.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  // Controlador para o campo de texto
  final TextEditingController _textController = TextEditingController();
  
  // Estado de carregamento
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Histórico de entradas
  List<DiaryEntry> _entries = [];
  
  // Estatísticas
  Map<String, dynamic> _stats = {};
  
  // Controlador de abas
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador de abas
    _tabController = TabController(length: 2, vsync: this);
    
    // Carregar histórico
    _loadHistory();
  }
  
  @override
  void dispose() {
    // Liberar recursos
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Carregar histórico do diário
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Obter token e ID do usuário
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      final userId = authService.user?.uid;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Criar instância do serviço de API
      final apiService = ApiService(token: token);
      
      // Obter histórico
      final entries = await apiService.getDiaryHistory(userId);
      
      // Obter estatísticas
      final stats = await apiService.getDiaryStats(userId);
      
      setState(() {
        _entries = entries;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar histórico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Salvar entrada no diário
  Future<void> _saveEntry() async {
    // Validar texto
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escreva algo no diário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Obter token e ID do usuário
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      final userId = authService.user?.uid;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Criar instância do serviço de API
      final apiService = ApiService(token: token);
      
      // Salvar entrada
      final entry = await apiService.saveDiaryEntry(userId, text);
      
      // Limpar campo
      _textController.clear();
      
      // Atualizar histórico
      await _loadHistory();
      
      setState(() {
        _isSaving = false;
      });
      
      // Mostrar confirmação com o sentimento detectado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Entrada salva! Sentimento detectado: ${entry.sentimentEmoji} ${_getSentimentName(entry.sentiment)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Mudar para a aba de histórico
      _tabController.animateTo(1);
    } catch (e) {
      print('Erro ao salvar entrada: $e');
      setState(() {
        _isSaving = false;
      });
      
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar entrada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Obter nome do sentimento em português
  String _getSentimentName(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return 'Positivo';
      case 'negative':
        return 'Negativo';
      case 'neutral':
        return 'Neutro';
      default:
        return sentiment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Emocional'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nova Entrada'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de nova entrada
          _buildNewEntryTab(),
          
          // Aba de histórico
          _buildHistoryTab(),
        ],
      ),
    );
  }
  
  // Construir aba de nova entrada
  Widget _buildNewEntryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Como você está se sentindo hoje?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de texto
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Escreva sobre seus sentimentos, pensamentos ou experiências...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          
          // Botão de salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Salvando...'),
                      ],
                    )
                  : const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
  
  // Construir aba de histórico
  Widget _buildHistoryTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gráfico de humor
                if (_stats.isNotEmpty) ...[
                  const Text(
                    'Seu Humor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gráfico de pizza
                  SizedBox(
                    height: 200,
                    child: _buildMoodChart(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Histórico de entradas
                const Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Lista de entradas
                _entries.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma entrada no diário ainda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Data e sentimento
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.formattedDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(entry.sentimentColor),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(entry.sentimentEmoji),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getSentimentName(entry.sentiment),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Texto da entrada
                                  Text(entry.text),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
  }
  
  // Construir gráfico de humor
  Widget _buildMoodChart() {
    // Verificar se há estatísticas
    if (_stats.isEmpty || _stats['sentiments'] == null) {
      return const Center(
        child: Text('Sem dados suficientes para o gráfico'),
      );
    }
    
    // Obter dados de sentimentos
    final sentiments = _stats['sentiments'] as Map<String, dynamic>;
    final positive = sentiments['positive'] as int;
    final negative = sentiments['negative'] as int;
    final neutral = sentiments['neutral'] as int;
    
    // Verificar se há entradas
    final total = positive + negative + neutral;
    if (total == 0) {
      return const Center(
        child: Text('Sem dados suficientes para o gráfico'),
      );
    }
    
    // Criar seções do gráfico
    final sections = <PieChartSectionData>[];
    
    if (positive > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF81C784), // Verde
          value: positive.toDouble(),
          title: '${(positive / total * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    if (negative > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFE57373), // Vermelho
          value: negative.toDouble(),
          title: '${(negative / total * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    if (neutral > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF90CAF9), // Azul
          value: neutral.toDouble(),
          title: '${(neutral / total * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return Row(
      children: [
        // Gráfico
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        
        // Legenda
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Positivo', const Color(0xFF81C784), positive),
              const SizedBox(height: 8),
              _buildLegendItem('Negativo', const Color(0xFFE57373), negative),
              const SizedBox(height: 8),
              _buildLegendItem('Neutro', const Color(0xFF90CAF9), neutral),
            ],
          ),
        ),
      ],
    );
  }
  
  // Construir item da legenda
  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
