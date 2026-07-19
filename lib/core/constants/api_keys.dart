/// Third-party API credentials.
///
/// ⚠️ IMPORTANT: This file intentionally contains NO real API keys so the
/// project is safe to push to a public GitHub repo. Fill these in locally
/// (or better, pass them at build time with `--dart-define`) and never
/// commit real secrets.
///
/// Example:
///   flutter run \
///     --dart-define=EMAILJS_SERVICE_ID=xxx \
///     --dart-define=EMAILJS_PUBLIC_KEY=xxx \
///     --dart-define=EMAILJS_TEMPLATE_ID=xxx \
///     --dart-define=EMAILJS_PASSWORD_TEMPLATE_ID=xxx \
///     --dart-define=AI_SUMMARY_API_KEY=xxx
class ApiKeys {
  ApiKeys._();

  // EmailJS (https://www.emailjs.com/) — used for booking / status / password
  // recovery emails. Leave blank to disable email sending.
  static const String emailJsServiceId =
      String.fromEnvironment('EMAILJS_SERVICE_ID', defaultValue: '');
  static const String emailJsPublicKey =
      String.fromEnvironment('EMAILJS_PUBLIC_KEY', defaultValue: '');
  static const String emailJsTemplateId =
      String.fromEnvironment('EMAILJS_TEMPLATE_ID', defaultValue: '');
  static const String emailJsPasswordTemplateId = String.fromEnvironment(
      'EMAILJS_PASSWORD_TEMPLATE_ID',
      defaultValue: '');

  // AI feedback summarizer (Google Gemini by default — see
  // repositories/summary_repository.dart). Leave blank to disable
  // AI-generated summaries.
  static const String aiSummaryApiKey =
      String.fromEnvironment('AI_SUMMARY_API_KEY', defaultValue: '');
}
