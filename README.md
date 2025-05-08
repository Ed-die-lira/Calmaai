# Calma AI - Aplicativo de Bem-Estar Mental

Calma AI é um aplicativo de bem-estar mental desenvolvido com Flutter (frontend) e Node.js (backend), utilizando apenas ferramentas gratuitas. O aplicativo oferece cinco funcionalidades principais para ajudar os usuários a melhorar sua saúde mental.

## Funcionalidades

1. **Meditações Personalizadas**: Player de áudio com meditações estáticas (calma.mp3, foco.mp3, sono.mp3). Os usuários selecionam seu humor ("Ansioso", "Cansado", "Feliz"), e o backend sugere uma meditação usando a API gratuita da Hugging Face.

2. **Diário Emocional Inteligente**: Campo para registrar texto, com análise de sentimentos (positivo/negativo/neutro) via Hugging Face. Exibe gráfico simples de humor.

3. **Exercícios de Respiração**: Animação circular (expande/retrai em 4s/6s) com narração (MP3 estático: respiracao.mp3).

4. **Lembretes Inteligentes**: Notificações para meditar ou registrar humor em horários fixos, configuráveis pelo usuário.

5. **Comunidade Moderada**: Fórum anônimo para posts, com moderação de conteúdo inadequado via Hugging Face.

## Tecnologias Utilizadas

### Frontend (Flutter)
- Flutter (Dart) para desenvolvimento cross-platform
- Pacotes: audioplayers, fl_chart, http, firebase_auth, onesignal_flutter

### Backend (Node.js)
- Node.js com Express para a API
- MongoDB Atlas para banco de dados
- Hugging Face API para análise de sentimentos, sugestões e moderação

### Autenticação e Notificações
- Firebase Auth para autenticação
- OneSignal para notificações push

## Estrutura do Projeto

```
/calma_ai_flutter
  /lib
    /screens
      home_screen.dart
      meditation_screen.dart
      diary_screen.dart
      breathing_screen.dart
      community_screen.dart
    /widgets
      meditation_card.dart
      audio_player.dart
      mood_button.dart
    /services
      api_service.dart
      auth_service.dart
      notification_service.dart
    /models
      meditation.dart
      diary_entry.dart
      post.dart
    /assets
      background.jpg
    main.dart
  pubspec.yaml
/calma_ai_backend
  /routes
    meditation_routes.js
    diary_routes.js
    community_routes.js
  /models
    user.js
    diary_entry.js
    post.js
  /services
    huggingface_service.js
  /utils
    moderation.js
    auth.js
  server.js
  .env
  package.json
```

## Configuração do Ambiente

### Pré-requisitos
- Flutter SDK (3.0.0 ou superior)
- Node.js (18.x ou superior)
- MongoDB Atlas (conta gratuita)
- Firebase (conta gratuita)
- OneSignal (conta gratuita)
- Hugging Face (conta gratuita)

### Configuração do Backend
1. Navegue até a pasta `calma_ai_backend`
2. Instale as dependências:
   ```
   npm install
   ```
3. Configure o arquivo `.env` com suas credenciais:
   ```
   PORT=3000
   MONGODB_URI=sua_uri_mongodb
   HF_API_KEY=sua_chave_huggingface
   JWT_SECRET=seu_jwt_secret
   FIREBASE_PROJECT_ID=seu_projeto_firebase
   ```
4. Crie uma pasta `static` na raiz do backend e adicione os arquivos de áudio:
   - calma.mp3
   - foco.mp3
   - sono.mp3
   - respiracao.mp3
5. Inicie o servidor:
   ```
   npm run dev
   ```

### Configuração do Frontend
1. Navegue até a pasta `calma_ai_flutter`
2. Instale as dependências:
   ```
   flutter pub get
   ```
3. Configure o Firebase:
   - Crie um projeto no Firebase Console
   - Adicione um aplicativo Android/iOS
   - Siga as instruções para adicionar os arquivos de configuração
4. Configure o OneSignal:
   - Crie um aplicativo no OneSignal
   - Substitua o App ID no arquivo `main.dart`
5. Execute o aplicativo:
   ```
   flutter run
   ```

## Hospedagem

### Backend
O backend pode ser hospedado no Render (free tier):
1. Crie uma conta no Render
2. Crie um novo Web Service
3. Conecte ao repositório Git
4. Configure as variáveis de ambiente
5. Deploy!

### Frontend
O frontend pode ser compilado para Android/iOS:
```
flutter build apk
flutter build ios
```

## Testes

### Backend
Execute os testes com Jest:
```
npm test
```

### Frontend
Execute os testes com Flutter:
```
flutter test
```

## Próximos Passos
- Implementar mais meditações
- Adicionar recursos de gamificação
- Melhorar a interface do usuário
- Adicionar suporte a mais idiomas

## Documentação Adicional
- [Flutter](https://flutter.dev/docs)
- [Node.js](https://nodejs.org/en/docs/)
- [Hugging Face](https://huggingface.co/docs)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [OneSignal](https://documentation.onesignal.com/docs)

## Licença
Este projeto é licenciado sob a licença MIT.
