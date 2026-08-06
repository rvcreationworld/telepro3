import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogService {
  Future<bool> ensurePermission() async {
    final status = await Permission.phone.status;
    if (status.isGranted) return true;
    return (await Permission.phone.request()).isGranted;
  }

  Future<List<CallLogEntry>> fetch({DateTime? after}) async {
    final entries = await CallLog.query(
      dateFrom: after?.millisecondsSinceEpoch,
    );
    return entries.toList(growable: false);
  }
}
