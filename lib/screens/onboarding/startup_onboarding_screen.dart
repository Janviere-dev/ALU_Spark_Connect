import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/profile/profile_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_chip.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() => _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  // Step 1 — focus areas
  final List<String> _selectedFocusAreas = [];
  final _customFocusCtrl = TextEditingController();

  // Step 2 — mission & team
  final _founderNameCtrl = TextEditingController();
  final _missionCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();
  final _impactCtrl = TextEditingController();
  String? _teamSize;


  @override
  void dispose() {
    _pageController.dispose();
    _customFocusCtrl.dispose();
    _founderNameCtrl.dispose();
    _missionCtrl.dispose();
    _problemCtrl.dispose();
    _impactCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _page--);
    }
  }

  void _addCustomFocusArea() {
    final value = _customFocusCtrl.text.trim();
    if (value.isNotEmpty && !_selectedFocusAreas.contains(value)) {
      setState(() {
        _selectedFocusAreas.add(value);
        _customFocusCtrl.clear();
      });
    }
  }

  Future<void> _finish() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    context.read<ProfileCubit>().load(user);
    await context.read<ProfileCubit>().saveStartupOnboarding(
          founderName: _founderNameCtrl.text.trim(),
          mission: _missionCtrl.text.trim(),
          problemStatement: _problemCtrl.text.trim(),
          impact: _impactCtrl.text.trim(),
          focusAreas: List.from(_selectedFocusAreas),
          teamSize: _teamSize,
        );

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/startup/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_page > 0)
                    GestureDetector(
                      onTap: _back,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_back_ios,
                            size: 18, color: AppColors.primary),
                      ),
                    ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_page + 1) / 3,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Step ${_page + 1} of 3',
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1FocusAreas(
                    selected: _selectedFocusAreas,
                    customCtrl: _customFocusCtrl,
                    onToggle: (area) => setState(() {
                      _selectedFocusAreas.contains(area)
                          ? _selectedFocusAreas.remove(area)
                          : _selectedFocusAreas.add(area);
                    }),
                    onAddCustom: _addCustomFocusArea,
                    onNext: _next,
                  ),
                  _Step2MissionTeam(
                    founderNameCtrl: _founderNameCtrl,
                    missionCtrl: _missionCtrl,
                    problemCtrl: _problemCtrl,
                    impactCtrl: _impactCtrl,
                    teamSize: _teamSize,
                    onTeamSize: (s) => setState(() => _teamSize = s),
                    onNext: _next,
                  ),
                  _Step3Welcome(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Focus Areas ────────────────────────────────────────────────────────

class _Step1FocusAreas extends StatefulWidget {
  final List<String> selected;
  final TextEditingController customCtrl;
  final void Function(String) onToggle;
  final VoidCallback onAddCustom;
  final VoidCallback onNext;

  const _Step1FocusAreas({
    required this.selected,
    required this.customCtrl,
    required this.onToggle,
    required this.onAddCustom,
    required this.onNext,
  });

  @override
  State<_Step1FocusAreas> createState() => _Step1FocusAreasState();
}

class _Step1FocusAreasState extends State<_Step1FocusAreas> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text("What's your startup's focus?", style: AppTextStyles.headlineLg),
          const SizedBox(height: 6),
          Text(
            'Pick the areas that describe your venture best. Add your own if you don\'t see a match.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...AppConstants.focusAreas.map((area) {
                final isSelected = widget.selected.contains(area);
                return SkillChip(
                  label: area,
                  isSelected: isSelected,
                  onTap: () => widget.onToggle(area),
                );
              }),
              // custom chips added by user
              ...widget.selected
                  .where((a) => !AppConstants.focusAreas.contains(a))
                  .map((area) => SkillChip(
                        label: area,
                        isSelected: true,
                        isRemovable: true,
                        onRemove: () => widget.onToggle(area),
                      )),
            ],
          ),
          const SizedBox(height: 20),
          // Custom focus area input
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hint: 'Add your own (e.g. ClimaTech, Web3…)',
                  controller: widget.customCtrl,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onAddCustom,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AppButton(
            label: widget.selected.isEmpty ? 'Skip for now' : 'Continue',
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            onPressed: widget.onNext,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Step 2: Mission & Team ─────────────────────────────────────────────────────

class _Step2MissionTeam extends StatelessWidget {
  final TextEditingController founderNameCtrl;
  final TextEditingController missionCtrl;
  final TextEditingController problemCtrl;
  final TextEditingController impactCtrl;
  final String? teamSize;
  final void Function(String) onTeamSize;
  final VoidCallback onNext;

  const _Step2MissionTeam({
    required this.founderNameCtrl,
    required this.missionCtrl,
    required this.problemCtrl,
    required this.impactCtrl,
    required this.teamSize,
    required this.onTeamSize,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const teamSizes = ['1–5', '6–15', '16–30', '30+'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Tell us about your mission', style: AppTextStyles.headlineLg),
          const SizedBox(height: 6),
          Text(
            'Help students understand what you\'re building and the impact you\'re making at ALU.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _Card(
            icon: Icons.person_outline,
            title: 'Founder Name',
            child: AppTextField(
              hint: 'Full name of the startup founder',
              controller: founderNameCtrl,
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            icon: Icons.flag_outlined,
            title: 'Your Mission',
            child: AppTextField(
              hint: 'We exist to… (what change are you creating?)',
              controller: missionCtrl,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            icon: Icons.lightbulb_outline,
            title: 'Problem You Solve',
            child: AppTextField(
              hint: 'What problem do you solve in the ALU community or beyond?',
              controller: problemCtrl,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            icon: Icons.people_outline,
            title: 'Team Size',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: teamSizes.map((size) {
                final isSelected = teamSize == size;
                return GestureDetector(
                  onTap: () => onTeamSize(size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      size,
                      style: AppTextStyles.labelLg.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            icon: Icons.school_outlined,
            title: 'Impact at ALU',
            child: AppTextField(
              hint: 'How has your startup impacted the ALU community?',
              controller: impactCtrl,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Continue',
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            onPressed: onNext,
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: onNext,
              child: Text(
                'Skip for now',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Step 3: Welcome splash ─────────────────────────────────────────────────────

class _Step3Welcome extends StatelessWidget {
  final Future<void> Function() onFinish;
  const _Step3Welcome({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 72),
              ),
              const SizedBox(height: 40),
              Text(
                'Get talented students\nfor your ALU startup!',
                style: AppTextStyles.headlineLg.copyWith(height: 1.25),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Your startup is now live in the ALU Connect ecosystem. Post roles, discover talent, and build your dream team.',
                style: AppTextStyles.bodyLg
                    .copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              AppButton(
                label: 'Go to Dashboard',
                isLoading: state is ProfileLoading,
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                onPressed: onFinish,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Reusable card
class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Card({required this.icon, required this.title, required this.child});

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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style:
                      AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
