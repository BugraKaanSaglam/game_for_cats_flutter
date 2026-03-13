import 'package:share_plus/share_plus.dart';

class AppShareService {
  AppShareService._();

  static final AppShareService instance = AppShareService._();

  Future<void> shareText({
    required String subject,
    required String text,
  }) async {
    await SharePlus.instance.share(ShareParams(subject: subject, text: text));
  }
}
