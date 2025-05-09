/**
 * Serviço para gerenciar notificações
 * Utiliza OneSignal para notificações push e Flutter Local Notifications para lembretes locais
 */

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // Instância do plugin de notificações locais
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar serviço
  Future<void> init() async {
    // Inicializar timezone
    tz_data.initializeTimeZones();

    // Configurar notificações locais
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Solicitar permissões
    await _requestPermissions();
  }

  // Solicitar permissões para notificações
  Future<void> _requestPermissions() async {
    // Android não precisa de permissão explícita para notificações locais

    // iOS precisa de permissão explícita
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Manipular toque na notificação
  void _onNotificationTap(NotificationResponse response) {
    // Implementar navegação com base no payload
    print('Notificação tocada: ${response.payload}');
  }

  // Agendar lembrete
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> days, // 0-6 (domingo-sábado)
    String? payload,
  }) async {
    // Configurar detalhes da notificação
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminders_channel',
      'Lembretes',
      channelDescription: 'Canal para lembretes do Calma AI',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF64B5F6),
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Agendar para cada dia da semana selecionado
    for (final int day in days) {
      // Calcular próxima data para este dia da semana
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      // Calcular dias até o próximo dia da semana desejado
      int daysUntil = day - now.weekday;
      if (daysUntil < 0)
        daysUntil += 7; // Se for no passado, agendar para próxima semana

      // Criar data e hora para o lembrete
      final DateTime reminderDate = today.add(Duration(days: daysUntil));
      final DateTime scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        time.hour,
        time.minute,
      );

      // Converter para timezone
      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      // Agendar notificação
      await _localNotifications.zonedSchedule(
        id + day, // ID único para cada dia
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  // Cancelar lembrete
  Future<void> cancelReminder(int id) async {
    // Cancelar para todos os dias da semana
    for (int i = 0; i < 7; i++) {
      await _localNotifications.cancel(id + i);
    }
  }

  // Cancelar todos os lembretes
  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }

  // Enviar notificação OneSignal para um usuário específico
  Future<void> initOneSignal() async {
    try {
      // Substitua com sua App ID do OneSignal
      const String oneSignalAppId = 'd11775db-2106-443e-868b-145760ea1579';

      // Inicializar OneSignal com a nova API
      OneSignal.initialize(oneSignalAppId);

      // Solicitar permissão para notificações com a nova API
      await OneSignal.Notifications.requestPermission(true);

      // Configurar manipulador de notificações recebidas
      // Nota: Verificar a documentação mais recente para o método correto
      // Comentando esta parte para evitar erros
      /*
      OneSignal.Notifications.willShowInForegroundHandler((notification) {
        print('Notificação recebida: ${notification.body}');
        return true;
      });
      */

      print('OneSignal inicializado com sucesso');
    } catch (e) {
      print('Erro ao inicializar OneSignal: $e');
    }
  }

  // Enviar notificação OneSignal para um usuário específico ou agendar
  Future<void> sendOneSignalNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    DateTime? scheduledTime, // Para lembretes inteligentes
  }) async {
    try {
      // Na versão 5.3.0, não podemos enviar notificações diretamente do cliente
      // É necessário usar um backend para enviar notificações

      // Adicionar identificação do usuário
      await OneSignal.login(userId);

      // Adicionar dados do usuário como tags
      await OneSignal.User.addTags({
        "userId": userId,
        "lastNotification": DateTime.now().toIso8601String(),
      });

      print('Usuário identificado no OneSignal: $userId');
      print(
          'Para enviar notificações, use o dashboard do OneSignal ou a API REST via backend');

      // Nota: Para enviar notificações, você precisa usar o dashboard do OneSignal
      // ou implementar uma chamada à API REST do OneSignal no seu backend
    } catch (e) {
      print('Erro ao configurar usuário no OneSignal: $e');
      rethrow;
    }
  }
}
