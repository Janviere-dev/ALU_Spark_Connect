import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/admin/admin_cubit.dart';
import '../../blocs/admin/admin_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    context.read<AdminCubit>().loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final repo = context.read<AuthRepository>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out', style: AppTextStyles.headlineSm),
        content: Text(
          'Are you sure you want to sign out of the admin panel?',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await repo.signOut();
      navigator.pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Text('Admin Panel', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => context.read<AdminCubit>().loadAll(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelStyle: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.labelMd,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.statusShortlisted,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminLoaded) {
            return Column(
              children: [
                _StatsRow(
                  pending: state.pending.length,
                  approved: state.approved.length,
                  rejected: state.rejected.length,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _StartupList(
                        startups: state.pending,
                        emptyMessage: 'No pending submissions',
                        emptyIcon: Icons.inbox_outlined,
                      ),
                      _StartupList(
                        startups: state.approved,
                        emptyMessage: 'No approved startups yet',
                        emptyIcon: Icons.check_circle_outline,
                      ),
                      _StartupList(
                        startups: state.rejected,
                        emptyMessage: 'No rejected submissions',
                        emptyIcon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Pull to refresh'));
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int pending;
  final int approved;
  final int rejected;

  const _StatsRow({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _Stat(count: pending, label: 'Pending', color: AppColors.statusUnderReview),
          const SizedBox(width: 12),
          _Stat(count: approved, label: 'Approved', color: AppColors.statusShortlisted),
          const SizedBox(width: 12),
          _Stat(count: rejected, label: 'Rejected', color: AppColors.error),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _Stat({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTextStyles.headlineMd.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupList extends StatelessWidget {
  final List<UserModel> startups;
  final String emptyMessage;
  final IconData emptyIcon;

  const _StartupList({
    required this.startups,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (startups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: startups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _StartupCard(startup: startups[i]),
    );
  }
}

class _StartupCard extends StatelessWidget {
  final UserModel startup;

  const _StartupCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context, startup),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            _Avatar(name: startup.ventureName ?? startup.fullName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.ventureName ?? 'Unnamed Startup',
                    style: AppTextStyles.labelLg,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${startup.fullName} · ${startup.location ?? 'No location'}',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    startup.email,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.outline),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: startup.status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case 'approved':
        color = AppColors.statusShortlisted;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = AppColors.statusUnderReview;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
            color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

Future<void> _sendApprovalEmail(UserModel startup) async {
  const appUrl = 'https://alu-spark-connect.web.app';
  final name = startup.fullName;
  final venture = startup.ventureName ?? 'your startup';
  final subject = Uri.encodeComponent('Your ALU Startup Profile is Approved! 🎉');
  final body = Uri.encodeComponent(
      'Hi $name,\n\n'
      'Great news! ALU Career Development has reviewed your details and verified '
      '$venture as an eligible venture for ALU student talent.\n\n'
      'Your account is now fully active. Click the link below to sign in and set up your workspace:\n\n'
      '$appUrl\n\n'
      'If you have any questions, simply reply to this email.\n\n'
      'Best regards,\n'
      'ALU Career Development Team');
  final uri = Uri.parse('mailto:${startup.email}?subject=$subject&body=$body');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

Future<void> _sendRejectionEmail(UserModel startup, String reason) async {
  final name = startup.fullName;
  final venture = startup.ventureName ?? 'your startup';
  final rejectionReason = reason.trim().isEmpty
      ? 'The uploaded documentation was missing, unclear, or did not match our records.'
      : reason.trim();
  final subject = Uri.encodeComponent(
      'Update regarding your startup verification on ALU Connect');
  final body = Uri.encodeComponent(
      'Hi $name,\n\n'
      'Thank you for submitting $venture to the ALU Connect talent platform.\n\n'
      'Our team reviewed your submission, but unfortunately we were unable to verify your venture\'s status within the ALU ecosystem at this time.\n\n'
      'Reason: $rejectionReason\n\n'
      'Don\'t worry — if this was a mistake, simply reply directly to this email with a screenshot of your eLab acceptance or current ALU enrollment details and we will happily re-review your account.\n\n'
      'Best regards,\n'
      'ALU Career Development Team');
  final uri = Uri.parse('mailto:${startup.email}?subject=$subject&body=$body');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

void _showDetail(BuildContext context, UserModel startup) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<AdminCubit>(),
      child: _DetailSheet(startup: startup),
    ),
  );
}

class _DetailSheet extends StatefulWidget {
  final UserModel startup;
  const _DetailSheet({required this.startup});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  final _reasonCtrl = TextEditingController();
  bool _showRejectInput = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.startup;
    final isPending = s.status == 'pending' || s.status == null;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  _Avatar(name: s.ventureName ?? s.fullName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.ventureName ?? 'Unnamed Startup',
                            style: AppTextStyles.headlineSm),
                        Text(
                          'Submitted by ${s.fullName}',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: s.status),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  if (s.ventureName != null)
                    _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Startup Name',
                        value: s.ventureName!),
                  _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Founder Name',
                      value: s.fullName),
                  _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: s.email),
                  if (s.location != null)
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: s.location!),
                  _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Submitted',
                      value: _formatDate(s.createdAt)),
                  if (s.docsLink != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.tryParse(s.docsLink!);
                        if (uri != null) await launchUrl(uri);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_open_outlined,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Open Verification Documents',
                                style: AppTextStyles.labelLg
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded,
                                color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'eLab certificate · RDB registration · Pitch deck',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_showRejectInput) ...[
                    const SizedBox(height: 20),
                    Text('Reason for rejection',
                        style: AppTextStyles.labelLg),
                    const SizedBox(height: 6),
                    Text(
                      'This will be shown to the founder in their notification.',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _reasonCtrl,
                      maxLines: 4,
                      style: AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. The documents provided did not match our eLab records. Please reply with your acceptance letter.',
                        hintStyle: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.outline),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Actions — only for pending startups
            if (isPending)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: _showRejectInput
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                context
                                    .read<AdminCubit>()
                                    .reject(s, _reasonCtrl.text);
                                Navigator.pop(context);
                                await _sendRejectionEmail(s, _reasonCtrl.text);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: Text('Send Rejection',
                                  style: AppTextStyles.labelLg
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                setState(() => _showRejectInput = false),
                            child: Text('Cancel',
                                style: AppTextStyles.labelLg
                                    .copyWith(color: AppColors.onSurfaceVariant)),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Reject'),
                              onPressed: () =>
                                  setState(() => _showRejectInput = true),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18),
                              label: Text('Approve',
                                  style: AppTextStyles.labelLg
                                      .copyWith(color: Colors.white)),
                              onPressed: () async {
                                context.read<AdminCubit>().approve(s);
                                Navigator.pop(context);
                                await _sendApprovalEmail(s);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusShortlisted,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.outline)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
