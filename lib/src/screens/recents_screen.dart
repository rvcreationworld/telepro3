import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/call_log_service.dart';
import '../services/call_log_sync_service.dart';
import '../theme/app_theme.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen>
    with WidgetsBindingObserver {
  final _logs = CallLogService();
  final _sync = CallLogSyncService();
  List<CallLogEntry> _entries = const [];
  bool _loading = true;
  bool _permissionDenied = false;
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() => _loading = true);
    }
    final allowed = await _logs.ensurePermission();
    if (!allowed) {
      if (mounted) {
        setState(() {
          _loading = false;
          _permissionDenied = true;
        });
      }
      return;
    }
    try {
      final entries = await _logs.fetch();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
        _permissionDenied = false;
      });
      final outcome = await _sync.sync(entries);
      if (!mounted) return;
      setState(
        () => _syncMessage = switch (outcome) {
          SyncOutcome.disabled => 'Dashboard sync is not configured',
          SyncOutcome.nothingToSync => 'Dashboard is up to date',
          SyncOutcome.uploaded => 'New calls synced to dashboard',
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _syncMessage = 'Sync will retry later';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('Recent calls'),
            actions: [
              IconButton(
                onPressed: _refresh,
                tooltip: 'Refresh and sync',
                icon: const Icon(Icons.sync_rounded),
              ),
            ],
          ),
          if (_syncMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_done_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _syncMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_permissionDenied)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _MessageState(
                icon: Icons.shield_outlined,
                title: 'Call-log access is needed',
                message:
                    'TelePro uses it to show recent calls and send authorized records to your dashboard.',
                action: FilledButton(
                  onPressed: openAppSettings,
                  child: Text('Open settings'),
                ),
              ),
            )
          else if (_entries.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _MessageState(
                icon: Icons.history_toggle_off_rounded,
                title: 'No calls yet',
                message: 'Your recent cellular calls will appear here.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
              sliver: SliverList.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) => RepaintBoundary(
                  child: _CallTile(
                    entry: _entries[index],
                    onCall: () => _dial(_entries[index].number),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _dial(String? number) async {
    if (number == null || number.isEmpty) return;
    await launchUrl(
      Uri(scheme: 'tel', path: number),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _CallTile extends StatelessWidget {
  const _CallTile({required this.entry, required this.onCall});
  final CallLogEntry entry;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final missed = entry.callType == CallType.missed;
    final outgoing = entry.callType == CallType.outgoing;
    final date = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
    final title = (entry.name?.trim().isNotEmpty ?? false)
        ? entry.name!
        : (entry.number ?? 'Unknown');
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: (missed ? AppColors.missed : AppColors.primary)
              .withValues(alpha: .12),
          child: Icon(
            outgoing ? Icons.call_made_rounded : Icons.call_received_rounded,
            color: missed ? AppColors.missed : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: missed ? AppColors.missed : AppColors.ink,
          ),
        ),
        subtitle: Text(
          '${entry.number ?? ''}  •  ${_formatDate(date)}\n${_formatDuration(entry.duration ?? 0)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onCall,
          tooltip: 'Call',
          icon: const Icon(Icons.phone_rounded, color: AppColors.success),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final now = DateTime.now();
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    if (now.year == value.year &&
        now.month == value.month &&
        now.day == value.day) {
      return 'Today, $time';
    }
    return '${value.day}/${value.month}/${value.year}, $time';
  }

  String _formatDuration(int seconds) =>
      seconds < 60 ? '${seconds}s' : '${seconds ~/ 60}m ${seconds % 60}s';
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 58, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      );
}