import '../models/application_model.dart';
import '../models/notification_model.dart';
import '../models/opportunity_model.dart';
import '../models/user_model.dart';

class MockDB {
  static final MockDB _instance = MockDB._internal();
  factory MockDB() => _instance;
  MockDB._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  void setCurrentUser(UserModel? user) => _currentUser = user;

  final List<UserModel> _users = [
    UserModel(
      id: 'student_001',
      fullName: 'Janviere Munezero',
      email: 'amina.okoro@alustudent.com',
      role: UserRole.student,
      education: 'Global Challenges & Entrepreneurship',
      shortPitch:
          'Aspiring fintech entrepreneur passionate about creating accessible payment systems for rural trade in East Africa.',
      skills: ['Product Strategy', 'UI/UX Design', 'Python', 'Market Research'],
      focusAreas: ['Fintech', 'AI & ML', 'SaaS'],
      availability: '15-20 hrs/week',
      startDate: 'Immediately',
      portfolioUrl: 'https://Janviere.dev',
      linkedinUrl: 'linkedin.com/in/janvieremunezero',
      isOpenToOpportunities: true,
      onboardingComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 'student_002',
      fullName: 'Kwame Asante',
      email: 'kwame.asante@alustudent.com',
      role: UserRole.student,
      education: 'Computer Science & Engineering',
      shortPitch: 'Full-stack developer with a passion for scalable systems and open-source projects.',
      skills: ['Flutter', 'Dart', 'Firebase', 'React', 'Python'],
      focusAreas: ['Engineering', 'SaaS', 'AI & ML'],
      availability: '20-30 hrs/week',
      startDate: 'Within 2 weeks',
      linkedinUrl: 'linkedin.com/in/kwameasante',
      githubUrl: 'github.com/kwameasante',
      isOpenToOpportunities: true,
      onboardingComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserModel(
      id: 'startup_001',
      fullName: 'John Doe',
      email: 'john.doe@alueducation.com',
      role: UserRole.startup,
      ventureName: 'Nexus AI Solutions',
      shortPitch: 'Building AI-powered tools for African SMEs.',
      skills: [],
      focusAreas: ['AI & ML', 'SaaS', 'Fintech'],
      isOpenToOpportunities: false,
      onboardingComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserModel(
      id: 'startup_002',
      fullName: 'Sarah Chen',
      email: 'sarah.chen@alueducation.com',
      role: UserRole.startup,
      ventureName: 'Learnify Education',
      shortPitch: 'Next-gen learning platform connecting students with quality education.',
      skills: [],
      focusAreas: ['EdTech', 'SaaS'],
      isOpenToOpportunities: false,
      onboardingComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserModel(
      id: 'startup_003',
      fullName: 'Aisha Ndiaye',
      email: 'aisha.ndiaye@alustudent.com',
      role: UserRole.startup,
      ventureName: 'GreenPlanet Agri',
      shortPitch: 'Sustainable agri-tech solutions for smallholder farmers across West Africa.',
      skills: [],
      focusAreas: ['AgriTech', 'Sustainability'],
      isOpenToOpportunities: false,
      onboardingComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  final List<OpportunityModel> _opportunities = [
    OpportunityModel(
      id: 'opp_001',
      startupId: 'startup_002',
      startupName: 'Learnify Education',
      roleTitle: 'Flutter Developer',
      category: 'Engineering',
      description:
          'Help us build the mobile app for our next-gen learning platform. You\'ll work directly with our engineering team on real features, UI/UX implementation, and backend integration. This is a high-impact role for a student looking to gain professional product experience.',
      whyJoinUs:
          'Early-stage startup equity potential\nDirect mentorship from senior engineers',
      skills: ['Flutter', 'Dart', 'Problem Solving', 'UI Implementation'],
      commitment: 'Part-time (8-10 hrs/week)',
      location: 'On-campus',
      duration: '3 Months',
      isRemoteFriendly: false,
      equityOffered: true,
      applicantCount: 24,
      viewCount: 340,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    OpportunityModel(
      id: 'opp_002',
      startupId: 'startup_001',
      startupName: 'Nexus AI Solutions',
      roleTitle: 'Product Design Lead',
      category: 'Design',
      description:
          'Lead the product design for our AI-powered SME tools. You\'ll define user journeys, create high-fidelity prototypes, and collaborate with engineers to bring world-class experiences to African entrepreneurs.',
      whyJoinUs: 'Work on cutting-edge AI products\nEquity participation\nMentorship from industry leaders',
      skills: ['Figma', 'UX Strategy', 'Prototyping', 'User Research'],
      commitment: 'Part-time (15-20 hrs/week)',
      location: 'Remote',
      duration: '6 Months',
      isRemoteFriendly: true,
      equityOffered: true,
      compensation: '\$2,500/mo + Equity',
      applicantCount: 42,
      viewCount: 1200,
      status: OpportunityStatus.active,
      isFeatured: true,
      postedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    OpportunityModel(
      id: 'opp_003',
      startupId: 'startup_003',
      startupName: 'GreenPlanet Agri',
      roleTitle: 'Operations Intern',
      category: 'Operations',
      description:
          'Support day-to-day operations including farmer outreach, logistics coordination, and data collection. You\'ll gain hands-on experience in agri-tech operations across West Africa.',
      skills: ['Project Management', 'Excel', 'Community Building', 'Data Analytics'],
      commitment: 'Part-time (15-20 hrs/week)',
      location: 'Kigali, Rwanda',
      duration: '3 Months',
      isRemoteFriendly: false,
      equityOffered: false,
      applicantCount: 18,
      viewCount: 210,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    OpportunityModel(
      id: 'opp_004',
      startupId: 'startup_001',
      startupName: 'Nexus AI Solutions',
      roleTitle: 'Junior UX Strategist',
      category: 'Design',
      description:
          'Shape the user experience for our B2B AI platform. Define research frameworks, test prototypes with real SME users, and influence product direction at a fast-growing startup.',
      skills: ['Figma', 'User Research', 'Systems Thinking', 'Illustrator'],
      commitment: 'Part-time (15-20 hrs/week)',
      location: 'Remote',
      duration: '4 Months',
      isRemoteFriendly: true,
      equityOffered: false,
      applicantCount: 31,
      viewCount: 480,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OpportunityModel(
      id: 'opp_005',
      startupId: 'startup_002',
      startupName: 'Learnify Education',
      roleTitle: 'Growth Marketing Intern',
      category: 'Marketing',
      description:
          'Drive student acquisition and engagement for our platform. You\'ll own campaigns across social media, email, and partnerships, with full ownership of creative and strategy.',
      skills: ['Social Media', 'Content Writing', 'SEO', 'Data Analytics'],
      commitment: 'Part-time (10-15 hrs/week)',
      location: 'Remote',
      duration: '3 Months',
      isRemoteFriendly: true,
      equityOffered: false,
      applicantCount: 12,
      viewCount: 270,
      status: OpportunityStatus.paused,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    OpportunityModel(
      id: 'opp_006',
      startupId: 'startup_003',
      startupName: 'GreenPlanet Agri',
      roleTitle: 'Data Analyst',
      category: 'Data & Analytics',
      description:
          'Analyze farmer data to uncover insights that improve crop yield recommendations. Build dashboards and reports for our field teams and investors.',
      skills: ['Python', 'SQL', 'Data Analytics', 'Excel'],
      commitment: 'Part-time (10-15 hrs/week)',
      location: 'Remote',
      duration: '4 Months',
      isRemoteFriendly: true,
      equityOffered: false,
      applicantCount: 9,
      viewCount: 190,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OpportunityModel(
      id: 'opp_007',
      startupId: 'startup_002',
      startupName: 'Learnify Education',
      roleTitle: 'Social Media Assistant',
      category: 'Content Creation',
      description:
          'Create engaging content for our social channels, manage community interactions, and grow our student audience across Instagram, Twitter/X, and LinkedIn.',
      skills: ['Social Media', 'Content Writing', 'Graphic Design', 'Community Building'],
      commitment: 'Part-time (4-6 hrs/week)',
      location: 'Kigali',
      duration: '3 Months',
      isRemoteFriendly: false,
      equityOffered: false,
      applicantCount: 7,
      viewCount: 145,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    OpportunityModel(
      id: 'opp_008',
      startupId: 'startup_001',
      startupName: 'Nexus AI Solutions',
      roleTitle: 'Software Engineering Intern',
      category: 'Engineering',
      description:
          'Build and maintain backend services for our AI inference pipeline. You\'ll work with Python, Firebase, and cloud infrastructure.',
      skills: ['Python', 'Firebase', 'Node.js', 'SQL'],
      commitment: 'Part-time (20-30 hrs/week)',
      location: 'On-campus',
      duration: '6 Months',
      isRemoteFriendly: false,
      equityOffered: true,
      applicantCount: 86,
      viewCount: 1200,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    OpportunityModel(
      id: 'opp_009',
      startupId: 'startup_001',
      startupName: 'Nexus AI Solutions',
      roleTitle: 'UI/UX Design Associate',
      category: 'Design',
      description:
          'Create stunning interfaces for our enterprise dashboard. You\'ll own the design system and work alongside the engineering team to ship features weekly.',
      skills: ['Figma', 'UI/UX Design', 'Illustrator', 'Prototyping'],
      commitment: 'Part-time (15-20 hrs/week)',
      location: 'On-campus',
      duration: '4 Months',
      isRemoteFriendly: false,
      equityOffered: false,
      applicantCount: 42,
      viewCount: 480,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<ApplicationModel> _applications = [
    ApplicationModel(
      id: 'app_001',
      studentId: 'student_001',
      studentName: 'Amina Okoro',
      studentEmail: 'amina.okoro@alustudent.com',
      studentUniversity: 'ALU Rwanda',
      opportunityId: 'opp_002',
      roleTitle: 'Product Desi...',
      startupName: 'Stark Industries...',
      pitch: 'I am deeply passionate about designing products that solve real problems for African entrepreneurs. My experience in both UX design and market research makes me an ideal fit for this role.',
      status: ApplicationStatus.interviewScheduled,
      matchScore: 92,
      studentSkills: ['Figma', 'UX Strategy', 'Market Research'],
      appliedAt: DateTime.now().subtract(const Duration(days: 7)),
      interviewDate: DateTime.now().add(const Duration(days: 3)),
    ),
    ApplicationModel(
      id: 'app_002',
      studentId: 'student_001',
      studentName: 'Amina Okoro',
      studentEmail: 'amina.okoro@alustudent.com',
      studentUniversity: 'ALU Rwanda',
      opportunityId: 'opp_004',
      roleTitle: 'Frontend Developer',
      startupName: 'Innovate X',
      pitch: 'My background in product strategy and UI/UX design positions me well to contribute to frontend development with a user-centered mindset.',
      status: ApplicationStatus.underReview,
      matchScore: 78,
      studentSkills: ['UI/UX Design', 'Product Strategy'],
      appliedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    ApplicationModel(
      id: 'app_003',
      studentId: 'student_001',
      studentName: 'Amina Okoro',
      studentEmail: 'amina.okoro@alustudent.com',
      studentUniversity: 'ALU Rwanda',
      opportunityId: 'opp_005',
      roleTitle: 'Marketing Fellow',
      startupName: 'Global Ventures',
      pitch: 'My experience with market research and community management gives me the tools to drive impactful marketing campaigns that resonate with African audiences.',
      status: ApplicationStatus.accepted,
      matchScore: 88,
      studentSkills: ['Market Research', 'Community Building', 'Content Writing'],
      appliedAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    ApplicationModel(
      id: 'app_004',
      studentId: 'student_002',
      studentName: 'Kwame Asante',
      studentEmail: 'kwame.asante@alustudent.com',
      studentUniversity: 'ALU Mauritius',
      opportunityId: 'opp_001',
      roleTitle: 'Flutter Developer',
      startupName: 'Learnify Education',
      pitch: 'Flutter is my primary stack and I have shipped two production apps. I would love to bring that experience to help build Learnify\'s mobile experience.',
      status: ApplicationStatus.shortlisted,
      matchScore: 98,
      studentSkills: ['Flutter', 'Dart', 'Firebase'],
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ApplicationModel(
      id: 'app_005',
      studentId: 'student_002',
      studentName: 'Kwame Asante',
      studentEmail: 'kwame.asante@alustudent.com',
      studentUniversity: 'ALU Mauritius',
      opportunityId: 'opp_002',
      roleTitle: 'Product Design Lead',
      startupName: 'Nexus AI Solutions',
      pitch: 'My systems thinking approach and design experience would help lead product direction at Nexus.',
      status: ApplicationStatus.underReview,
      matchScore: 85,
      studentSkills: ['Figma', 'User Research', 'Systems Thinking'],
      appliedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'notif_001',
      userId: 'student_001',
      type: NotificationType.interviewInvitation,
      title: 'Interview Invitation',
      body:
          "You've been shortlisted for the Product Design role at GreenTech Solutions. Schedule your slot now.",
      isRead: false,
      isPriority: true,
      actionId: 'app_001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif_002',
      userId: 'student_001',
      type: NotificationType.applicationStatusChange,
      title: 'Application status changed',
      body: "Your application for **Startup X** has moved to 'Review' stage.",
      isRead: false,
      isPriority: false,
      actionId: 'app_002',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'notif_003',
      userId: 'student_001',
      type: NotificationType.newMessage,
      title: 'New message from Startup X',
      body: '"Hello! We loved your portfolio and would like...',
      isRead: false,
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'notif_004',
      userId: 'student_001',
      type: NotificationType.deadlineApproaching,
      title: 'Deadline Approaching',
      body: 'ALU Incubation Lab applications close in 24 hours.',
      isRead: false,
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'notif_005',
      userId: 'student_001',
      type: NotificationType.profileAchievement,
      title: 'Profile Achievement',
      body: "You've reached 'Expert' level in Project Management. Badge added!",
      isRead: true,
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 'notif_006',
      userId: 'student_001',
      type: NotificationType.systemUpdate,
      title: 'System Maintenance',
      body: 'Scheduled portal update completed successfully.',
      isRead: true,
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  List<UserModel> get users => List.unmodifiable(_users);
  List<OpportunityModel> get opportunities => List.unmodifiable(_opportunities);
  List<ApplicationModel> get applications => List.unmodifiable(_applications);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  UserModel? findUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  void addUser(UserModel user) => _users.add(user);

  void updateUser(UserModel updated) {
    final idx = _users.indexWhere((u) => u.id == updated.id);
    if (idx != -1) _users[idx] = updated;
    if (_currentUser?.id == updated.id) _currentUser = updated;
  }

  void addOpportunity(OpportunityModel opp) => _opportunities.add(opp);

  void updateOpportunity(OpportunityModel updated) {
    final idx = _opportunities.indexWhere((o) => o.id == updated.id);
    if (idx != -1) _opportunities[idx] = updated;
  }

  void addApplication(ApplicationModel app) {
    _applications.add(app);
    final oppIdx = _opportunities.indexWhere((o) => o.id == app.opportunityId);
    if (oppIdx != -1) {
      _opportunities[oppIdx] = _opportunities[oppIdx].copyWith(
        applicantCount: _opportunities[oppIdx].applicantCount + 1,
      );
    }
  }

  void updateApplication(ApplicationModel updated) {
    final idx = _applications.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _applications[idx] = updated;
  }

  void markAllNotificationsRead(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  List<OpportunityModel> getOpportunitiesForStartup(String startupId) =>
      _opportunities.where((o) => o.startupId == startupId).toList();

  List<ApplicationModel> getApplicationsForStudent(String studentId) =>
      _applications.where((a) => a.studentId == studentId).toList();

  List<ApplicationModel> getApplicationsForOpportunity(String opportunityId) =>
      _applications.where((a) => a.opportunityId == opportunityId).toList();

  List<NotificationModel> getNotificationsForUser(String userId) =>
      _notifications.where((n) => n.userId == userId).toList();

  List<UserModel> getOpenStudents() =>
      _users.where((u) => u.role == UserRole.student && u.isOpenToOpportunities).toList();
}
