import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/application_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/status_badge.dart';

class ApplicantsScreen extends StatefulWidget {
  final String? opportunityId;
  const ApplicantsScreen({super.key, this.opportunityId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (widget.opportunityId != null) {
        context.read<ApplicationCubit>().loadForOpportunity(widget.opportunityId!);
      } else {
        context.read<ApplicationCubit>().loadForStartup(authState.user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: true,
        userInitials: user?.initials ?? 'S',
        onNotification: () =>
            Navigator.pushNamed(context, '/startup/notifications'),
        onSettings: () => Navigator.pushNamed(context, '/startup/settings'),
      ),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return const _EmptyApplicants();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Applicants', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 4),
                  Text(
                    '${state.applications.length} application${state.applications.length == 1 ? '' : 's'} received',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: state.applications.length.toString(),
                        gradient: AppColors.primaryGradient,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Shortlisted',
                        value: state.applications
                            .where((a) =>
                                a.status == ApplicationStatus.shortlisted)
                            .length
                            .toString(),
                        gradient: AppColors.pinkGradient,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Interviews',
                        value: state.applications
                            .where((a) =>
                                a.status ==
                                ApplicationStatus.interviewScheduled)
                            .length
                            .toString(),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary.withValues(alpha: 0.7)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...state.applications.map(
                    (app) => _ApplicantCard(
                      application: app,
                      onTap: () => _openDetail(context, app),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const _EmptyApplicants();
        },
      ),
    );
  }

  void _openDetail(BuildContext context, ApplicationModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ApplicationCubit>(),
        child: _ApplicationDetailSheet(application: app),
      ),
    );
  }
}

//  Application detail bottom sheet 

class _ApplicationDetailSheet extends StatelessWidget {
  final ApplicationModel application;
  const _ApplicationDetailSheet({required this.application});

  Future<void> _openCv(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = application;
    final canDecide = app.status == ApplicationStatus.submitted ||
        app.status == ApplicationStatus.underReview;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            app.studentName.isNotEmpty
                                ? app.studentName[0].toUpperCase()
                                : 'S',
                            style: AppTextStyles.headlineSm
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.studentName,
                                style: AppTextStyles.headlineSm),
                            Text(
                              app.roleTitle,
                              style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: app.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.appliedTimeAgo,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  // Applicant info
                  _InfoCard(
                    icon: Icons.person_outline,
                    title: 'Applicant Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(Icons.email_outlined, app.studentEmail),
                        if (app.studentUniversity != null) ...[
                          const SizedBox(height: 6),
                          _DetailRow(Icons.school_outlined, app.studentUniversity!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Duration
                  if (app.duration != null) ...[
                    _InfoCard(
                      icon: Icons.timer_outlined,
                      title: 'Commitment Duration',
                      child: Text(app.duration!, style: AppTextStyles.bodyMd),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Pitch
                  if (app.pitch.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.format_quote_outlined,
                      title: 'Cover Message',
                      child: Text(
                        '"${app.pitch}"',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Skills
                  if (app.studentSkills.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.bolt_outlined,
                      title: 'Skills',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: app.studentSkills
                            .map((s) => SkillChip(label: s))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // CV: tappable link
                  if (app.cvUrl != null) ...[
                    _InfoCard(
                      icon: Icons.attach_file,
                      title: 'CV / Resume',
                      child: GestureDetector(
                        onTap: () => _openCv(app.cvUrl!),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_outlined,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'View CV',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new,
                                color: AppColors.primary, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Decision buttons
                  if (canDecide) ...[
                    const SizedBox(height: 8),
                    Text('Make a Decision', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 12),
                    _DecisionButton(
                      label: 'Accept',
                      icon: Icons.check_circle_outline,
                      color: AppColors.statusAccepted,
                      onTap: () => _showNoteDialog(
                        context,
                        app,
                        ApplicationStatus.accepted,
                        'Accept Candidate',
                        'Congratulations! Share the next steps with them.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DecisionButton(
                      label: 'Shortlist',
                      icon: Icons.star_outline,
                      color: AppColors.statusShortlisted,
                      onTap: () => _showNoteDialog(
                        context,
                        app,
                        ApplicationStatus.shortlisted,
                        'Shortlist Candidate',
                        'Great fit! Let them know you\'re interested.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DecisionButton(
                      label: 'Schedule Interview',
                      icon: Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      onTap: () => _showNoteDialog(
                        context,
                        app,
                        ApplicationStatus.interviewScheduled,
                        'Schedule Interview',
                        'Include interview details, date, time, and any link (e.g. meet.google.com/...).',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DecisionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      color: AppColors.error,
                      onTap: () => _showNoteDialog(
                        context,
                        app,
                        ApplicationStatus.rejected,
                        'Reject Application',
                        'Share brief, constructive feedback.',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    ApplicationModel app,
    ApplicationStatus status,
    String title,
    String hint,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a message to ${app.studentName}:',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              final note = ctrl.text.trim();
              if (note.isEmpty) return;
              context.read<ApplicationCubit>().updateStatusWithNote(
                    applicationId: app.id,
                    status: status,
                    studentId: app.studentId,
                    note: note,
                    roleTitle: app.roleTitle,
                  );
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close sheet
            },
            child: Text('Send & Decide',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DecisionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: AppTextStyles.labelLg.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface)),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;

  const _ApplicantCard({required this.application, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = application;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      app.studentName.isNotEmpty
                          ? app.studentName[0].toUpperCase()
                          : 'S',
                      style: AppTextStyles.headlineSm
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName,
                          style: AppTextStyles.headlineSm),
                      Text(
                        app.roleTitle,
                        style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: app.status),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: AppColors.outline, size: 18),
              ],
            ),
            if (app.pitch.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"${app.pitch}"',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  app.appliedTimeAgo,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                if (app.cvUrl != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file,
                            color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text('CV',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Tap to review',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  const _StatCard(
      {required this.label, required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineMd
                    .copyWith(color: Colors.white)),
            Text(label,
                style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  const _EmptyApplicants();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No applicants yet', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here once students apply to your opportunities.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
