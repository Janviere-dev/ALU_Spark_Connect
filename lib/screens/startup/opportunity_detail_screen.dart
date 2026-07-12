import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_chip.dart';

class StartupOpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;
  const StartupOpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<StartupOpportunityDetailScreen> createState() =>
      _StartupOpportunityDetailScreenState();
}

class _StartupOpportunityDetailScreenState
    extends State<StartupOpportunityDetailScreen> {
  OpportunityModel? _opp;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  // Edit controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _compCtrl = TextEditingController();
  String? _editCategory;
  String _editCommitment = 'Part-time';
  String _editLocation = 'Remote';
  List<String> _editSkills = [];
  List<String> _editCustomSkills = [];
  DateTime? _editDeadline;

  final List<String> _commitmentOptions = ['Part-time', 'Full-time', 'Project-based'];
  final List<String> _locationOptions = ['Remote', 'On-site', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _compCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final opp = await context
        .read<OpportunityRepository>()
        .getById(widget.opportunityId);
    if (mounted) setState(() { _opp = opp; _loading = false; });
  }

  void _startEditing() {
    final o = _opp!;
    _titleCtrl.text = o.roleTitle;
    _descCtrl.text = o.description;
    _compCtrl.text = o.compensation ?? '';
    _editCategory = o.category;
    _editCommitment = o.commitment;
    _editLocation = o.location;
    _editSkills = List.from(o.skills);
    _editCustomSkills = o.skills
        .where((s) => !AppConstants.skillsList.contains(s))
        .toList();
    _editDeadline = o.deadline;
    setState(() => _editing = true);
  }

  void _discardEdits() => setState(() => _editing = false);

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    if (_editCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = _opp!.copyWith(
        roleTitle: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _editCategory,
        commitment: _editCommitment,
        location: _editLocation,
        isRemoteFriendly:
            _editLocation == 'Remote' || _editLocation == 'Hybrid',
        compensation: _compCtrl.text.trim().isNotEmpty
            ? _compCtrl.text.trim()
            : null,
        skills: _editSkills,
        deadline: _editDeadline,
      );
      await context.read<OpportunityRepository>().update(updated);
      if (mounted) setState(() { _opp = updated; _editing = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _closePosting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Close Posting?', style: AppTextStyles.headlineSm),
        content: Text(
          'This will mark the role as closed and students will no longer see it.',
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
            child: Text('Close It',
                style:
                    AppTextStyles.labelLg.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context
        .read<OpportunityRepository>()
        .updateStatus(_opp!.id, OpportunityStatus.closed);
    if (mounted) {
      setState(() =>
          _opp = _opp!.copyWith(status: OpportunityStatus.closed));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posting closed')),
      );
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _editDeadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _editDeadline = picked);
  }

  void _addCustomSkill() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Custom Skill', style: AppTextStyles.headlineSm),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Solidity, Blender, Swahili...',
            hintStyle:
                AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
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
              final skill = ctrl.text.trim();
              if (skill.isNotEmpty && !_editSkills.contains(skill)) {
                setState(() {
                  _editCustomSkills.add(skill);
                  _editSkills.add(skill);
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('Add',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is AuthAuthenticated &&
        _opp?.startupId == authState.user.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ALU Connect',
            style:
                AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        actions: [
          if (!_loading && _opp != null && isOwner)
            if (_editing) ...[
              TextButton(
                onPressed: _discardEdits,
                child: Text('Discard',
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ),
              TextButton(
                onPressed: _saving ? null : _save,
                child: Text('Save',
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.primary)),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
                onPressed: _startEditing,
              ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary))
          : _opp == null
              ? Center(
                  child: Text('Opportunity not found',
                      style: AppTextStyles.bodyLg))
              : _editing
                  ? _EditView(
                      opp: _opp!,
                      titleCtrl: _titleCtrl,
                      descCtrl: _descCtrl,
                      compCtrl: _compCtrl,
                      editCategory: _editCategory,
                      editCommitment: _editCommitment,
                      editLocation: _editLocation,
                      editSkills: _editSkills,
                      editCustomSkills: _editCustomSkills,
                      editDeadline: _editDeadline,
                      commitmentOptions: _commitmentOptions,
                      locationOptions: _locationOptions,
                      onCategorySelect: (c) =>
                          setState(() => _editCategory = c),
                      onCommitmentSelect: (c) =>
                          setState(() => _editCommitment = c),
                      onLocationSelect: (l) =>
                          setState(() => _editLocation = l),
                      onSkillToggle: (s) {
                        setState(() {
                          if (_editSkills.contains(s)) {
                            _editSkills.remove(s);
                          } else {
                            _editSkills.add(s);
                          }
                        });
                      },
                      onCustomSkillRemove: (s) {
                        setState(() {
                          _editCustomSkills.remove(s);
                          _editSkills.remove(s);
                        });
                      },
                      onPickDeadline: _pickDeadline,
                      onClearDeadline: () =>
                          setState(() => _editDeadline = null),
                      onAddCustomSkill: _addCustomSkill,
                      saving: _saving,
                      onSave: _save,
                    )
                  : _DetailView(
                      opp: _opp!,
                      isOwner: isOwner,
                      onEdit: _startEditing,
                      onClose: _closePosting,
                      onViewApplicants: () => Navigator.pushNamed(
                        context,
                        '/startup/applicants',
                        arguments: _opp!.id,
                      ),
                    ),
    );
  }
}

// ── Detail view ─────────────────────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  final OpportunityModel opp;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onViewApplicants;

  const _DetailView({
    required this.opp,
    required this.isOwner,
    required this.onEdit,
    required this.onClose,
    required this.onViewApplicants,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed =
        opp.status == OpportunityStatus.closed || opp.isExpired;
    final deadlineColor = opp.deadline != null &&
            opp.deadline!.difference(DateTime.now()).inDays < 3
        ? AppColors.error
        : AppColors.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(opp.roleTitle, style: AppTextStyles.headlineLg),
              ),
              if (isClosed)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Closed',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.error),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusAcceptedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.statusAccepted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${opp.startupName} • ${opp.category}',
            style: AppTextStyles.bodyLg
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatBadge(
                icon: Icons.people_outline,
                label: '${opp.applicantCount} applicant${opp.applicantCount == 1 ? "" : "s"}',
              ),
              const SizedBox(width: 10),
              _StatBadge(
                icon: Icons.schedule_outlined,
                label: opp.deadlineLabel,
                color: isClosed ? AppColors.error : deadlineColor,
              ),
              const SizedBox(width: 10),
              _StatBadge(
                icon: Icons.location_on_outlined,
                label: opp.location,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Description',
            child: Text(opp.description, style: AppTextStyles.bodyMd),
          ),
          if (opp.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Required Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    opp.skills.map((s) => SkillChip(label: s)).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Section(
            title: 'Logistics',
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.timer_outlined, label: opp.commitment),
                if (opp.compensation != null && opp.compensation!.isNotEmpty)
                  _DetailRow(
                      icon: Icons.attach_money_outlined,
                      label: opp.compensation!),
                if (opp.equityOffered)
                  _DetailRow(
                      icon: Icons.pie_chart_outline,
                      label: 'Equity offered'),
                if (opp.isRemoteFriendly)
                  _DetailRow(
                      icon: Icons.wifi_outlined,
                      label: 'Remote friendly'),
              ],
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 28),
            AppButton(
              label: 'View Applicants (${opp.applicantCount})',
              onPressed: onViewApplicants,
              icon: const Icon(Icons.people_outline,
                  color: Colors.white, size: 18),
            ),
            if (!isClosed) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Close Posting',
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _StatBadge({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurfaceVariant;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.labelSm.copyWith(color: c),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: AppTextStyles.headlineSm),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Edit view ────────────────────────────────────────────────────────────────

class _EditView extends StatelessWidget {
  final OpportunityModel opp;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController compCtrl;
  final String? editCategory;
  final String editCommitment;
  final String editLocation;
  final List<String> editSkills;
  final List<String> editCustomSkills;
  final DateTime? editDeadline;
  final List<String> commitmentOptions;
  final List<String> locationOptions;
  final void Function(String) onCategorySelect;
  final void Function(String) onCommitmentSelect;
  final void Function(String) onLocationSelect;
  final void Function(String) onSkillToggle;
  final void Function(String) onCustomSkillRemove;
  final VoidCallback onPickDeadline;
  final VoidCallback onClearDeadline;
  final VoidCallback onAddCustomSkill;
  final bool saving;
  final VoidCallback onSave;

  const _EditView({
    required this.opp,
    required this.titleCtrl,
    required this.descCtrl,
    required this.compCtrl,
    required this.editCategory,
    required this.editCommitment,
    required this.editLocation,
    required this.editSkills,
    required this.editCustomSkills,
    required this.editDeadline,
    required this.commitmentOptions,
    required this.locationOptions,
    required this.onCategorySelect,
    required this.onCommitmentSelect,
    required this.onLocationSelect,
    required this.onSkillToggle,
    required this.onCustomSkillRemove,
    required this.onPickDeadline,
    required this.onClearDeadline,
    required this.onAddCustomSkill,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Edit Opportunity', style: AppTextStyles.headlineLg),
          const SizedBox(height: 4),
          Text('Changes are saved to Firebase immediately.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          _FormCard(
            icon: Icons.work_outline,
            title: 'Role Details',
            child: Column(
              children: [
                AppTextField(
                  label: 'Role Title',
                  hint: 'e.g. Product Design Intern',
                  controller: titleCtrl,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  hint: 'Describe the role...',
                  controller: descCtrl,
                  maxLines: 5,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Compensation (optional)',
                  hint: 'e.g. \$1,000/mo or Equity only',
                  controller: compCtrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            icon: Icons.category_outlined,
            title: 'Category',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.opportunityCategories.map((cat) {
                final isSelected = editCategory == cat;
                return GestureDetector(
                  onTap: () => onCategorySelect(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected ? AppColors.primaryGradient : null,
                      color: isSelected
                          ? null
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            icon: Icons.tune_outlined,
            title: 'Logistics',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commitment', style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: commitmentOptions.map((opt) {
                    final isSelected = editCommitment == opt;
                    return GestureDetector(
                      onTap: () => onCommitmentSelect(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradient
                              : null,
                          color: isSelected
                              ? null
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: AppTextStyles.labelMd.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text('Location', style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: locationOptions.map((opt) {
                    final isSelected = editLocation == opt;
                    return GestureDetector(
                      onTap: () => onLocationSelect(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradient
                              : null,
                          color: isSelected
                              ? null
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: AppTextStyles.labelMd.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Application Deadline (optional)',
                    style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onPickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: editDeadline != null
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: editDeadline != null
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: editDeadline != null
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            editDeadline != null
                                ? 'Closes ${editDeadline!.day}/${editDeadline!.month}/${editDeadline!.year}'
                                : 'No deadline — stays open until closed manually',
                            style: AppTextStyles.labelMd.copyWith(
                              color: editDeadline != null
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (editDeadline != null)
                          GestureDetector(
                            onTap: onClearDeadline,
                            child: const Icon(Icons.close,
                                color: AppColors.onSurfaceVariant,
                                size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            icon: Icons.bolt_outlined,
            title: 'Required Skills',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (editCustomSkills.isNotEmpty) ...[
                  Text('Added by you',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: editCustomSkills
                        .map((s) => SkillChip(
                              label: s,
                              isSelected: true,
                              isRemovable: true,
                              onRemove: () => onCustomSkillRemove(s),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...AppConstants.skillsList.map((skill) {
                      final isSelected = editSkills.contains(skill);
                      return SkillChip(
                        label: skill,
                        isSelected: isSelected,
                        onTap: () => onSkillToggle(skill),
                      );
                    }),
                    GestureDetector(
                      onTap: onAddCustomSkill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('Add custom',
                                style: AppTextStyles.labelMd
                                    .copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Save Changes',
            isLoading: saving,
            icon: const Icon(Icons.check_outlined,
                color: Colors.white, size: 18),
            onPressed: onSave,
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _FormCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: AppColors.onSurface, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headlineSm),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
