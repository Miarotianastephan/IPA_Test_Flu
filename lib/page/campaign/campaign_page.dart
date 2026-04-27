import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/campaign.dart';
import 'package:live_app/models/user_progress.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/campaign_provider.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key});

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
  }

  Future<void> _loadData() async {
    try {
      final campaignState = ref.read(campaignProvider);
      if (campaignState.campaign == null) {
        await ref.read(campaignProvider.notifier).loadCampaign();
      }

      final updatedCampaignState = ref.read(campaignProvider);
      if (updatedCampaignState.campaign != null) {
        await ref
            .read(userProgressProvider.notifier)
            .loadUserProgress(campaignId: updatedCampaignState.campaign!.id);
      }
      _progressController.forward();
    } catch (e) {
      debugPrint('Error loading campaign data: $e');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignState = ref.watch(campaignProvider);
    final userProgressState = ref.watch(userProgressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: campaignState.isLoading || userProgressState.isLoading
              ? _buildGameLoadingScreen()
              : campaignState.error != null || userProgressState.error != null
              ? _buildGameErrorScreen(
                  campaignState.error ??
                      userProgressState.error ??
                      'Unknown error',
                )
              : campaignState.campaign != null
              ? _buildGameCampaignScreen(campaignState.campaign!)
              : _buildNoCampaignScreen(),
        ),
      ),
    );
  }

  Widget _buildGameLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    Text(
                      'INITIALIZING MISSION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: Color(0xFF00D4FF), blurRadius: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Preparing your campaign data...',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameErrorScreen(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MISSION FAILED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [Shadow(color: Colors.red, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                color: Colors.red[200],
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGameActionButton(
              text: 'RETRY MISSION',
              icon: Icons.refresh_rounded,
              onPressed: () async {
                await _loadData();
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCampaignScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.2),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO ACTIVE MISSIONS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new campaigns',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCampaignScreen(Campaign campaign) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCampaignHeader(campaign),
            const SizedBox(height: 24),
            _buildMissionStatsAndProgress(campaign),
            const SizedBox(height: 24),
            _buildRewardsPreview(campaign),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionStatsAndProgress(Campaign campaign) {
    if (campaign.campaignTier.isEmpty) {
      return _buildStatsDashboard(campaign);
    }

    final userProgressState = ref.watch(userProgressProvider);
    final userProgress = userProgressState.userProgress;
    final userProgressAmount = userProgress != null
        ? double.tryParse(userProgress.progressAmount) ?? 0.0
        : 0.0;

    final sortedTiers = List<CampaignTier>.from(campaign.campaignTier)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    CampaignTier? currentTier;
    for (final tier in sortedTiers) {
      final threshold = double.tryParse(tier.thresholdAmount) ?? 0.0;
      if (userProgressAmount >= threshold) {
        currentTier = tier;
      } else {
        break;
      }
    }

    final currentThreshold = currentTier != null
        ? (double.tryParse(currentTier.thresholdAmount) ?? 0.0)
        : 0.0;
    final currentTierLabel = currentTier != null
        ? '${currentTier.tierCode.toUpperCase()} - \$${currentThreshold.toStringAsFixed(0)}'
        : 'NONE - \$0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.25),
            const Color(0xFF5B21B6).withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MISSION',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'CURRENT PROGRESS',
                  '\$${userProgress?.progressAmount ?? '0'}',
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  'CURRENT TIER',
                  _getCurrentTier(campaign),
                  Icons.emoji_events_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'NEXT TIER',
                  '\$${_getNextTierRequirement(campaign)}',
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  'REMAINING',
                  '\$${_getRemainingAmount(campaign, userProgress)}',
                  Icons.hourglass_top_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 90,
                      child: CustomPaint(
                        painter: TierProgressPainter(
                          tiers: sortedTiers,
                          userProgress: userProgressAmount,
                          animation: _progressAnimation.value,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHeader(Campaign campaign) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor(campaign.status).withOpacity(0.8),
                _getStatusColor(campaign.status).withOpacity(0.4),
                _getStatusColor(campaign.status).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(campaign.status).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 5),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            campaign.campaignCode,
                            style: const TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(campaign.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTimeInfo(
                    icon: Icons.play_arrow_rounded,
                    label: 'START',
                    time: _formatDateTime(campaign.startTime),
                  ),
                  const SizedBox(width: 16),
                  _buildTimeInfo(
                    icon: Icons.flag_rounded,
                    label: 'END',
                    time: _formatDateTime(campaign.endTime),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF00D4FF), size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildStatsDashboard(Campaign campaign) {
    final userProgressState = ref.watch(userProgressProvider);
    final userProgress = userProgressState.userProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.3),
            const Color(0xFF312E81).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MISSION STATS',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'CURRENT PROGRESS',
                  '\$${userProgress?.progressAmount ?? '0'}',
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  'CURRENT TIER',
                  _getCurrentTier(campaign),
                  Icons.emoji_events_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'NEXT TIER',
                  '\$${_getNextTierRequirement(campaign)}',
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildStatCard(
                  'REMAINING',
                  '\$${_getRemainingAmount(campaign, userProgress)}',
                  Icons.hourglass_top_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00D4FF), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFF00D4FF), blurRadius: 4)],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsPreview(Campaign campaign) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFDC2626).withOpacity(0.3),
            const Color(0xFFEA580C).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCD34D).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFCD34D).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REWARDS',
            style: TextStyle(
              color: Color(0xFFFCD34D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRewardItem(
                  'EXCLUSIVE',
                  'Badges',
                  Icons.military_tech_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRewardItem(
                  'SPECIAL',
                  'Offers',
                  Icons.card_giftcard_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRewardItem('BONUS', 'Points', Icons.stars_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String type, String reward, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFCD34D), size: 24),
          const SizedBox(height: 8),
          Text(
            type,
            style: const TextStyle(
              color: Color(0xFFFCD34D),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reward,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentTier(Campaign campaign) {
    final userProgressState = ref.watch(userProgressProvider);
    final userProgress = userProgressState.userProgress;

    if (userProgress == null || campaign.campaignTier.isEmpty) return 'None';

    final userAmount = double.tryParse(userProgress.progressAmount) ?? 0.0;
    final sortedTiers = List<CampaignTier>.from(campaign.campaignTier)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    String currentTier = 'None';
    for (final tier in sortedTiers) {
      final threshold = double.tryParse(tier.thresholdAmount) ?? 0.0;
      if (userAmount >= threshold) {
        currentTier = tier.tierCode;
      } else {
        break;
      }
    }

    return currentTier;
  }

  String _getNextTierRequirement(Campaign campaign) {
    final userProgressState = ref.watch(userProgressProvider);
    final userProgress = userProgressState.userProgress;

    if (userProgress == null || campaign.campaignTier.isEmpty) return '0';

    final userAmount = double.tryParse(userProgress.progressAmount) ?? 0.0;
    final sortedTiers = List<CampaignTier>.from(campaign.campaignTier)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final tier in sortedTiers) {
      final threshold = double.tryParse(tier.thresholdAmount) ?? 0.0;
      if (userAmount < threshold) {
        return threshold.toStringAsFixed(0);
      }
    }

    return 'MAX';
  }

  String _getRemainingAmount(Campaign campaign, UserProgress? userProgress) {
    if (userProgress == null || campaign.campaignTier.isEmpty) return '0';

    final userAmount = double.tryParse(userProgress.progressAmount) ?? 0.0;
    final sortedTiers = List<CampaignTier>.from(campaign.campaignTier)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final tier in sortedTiers) {
      final threshold = double.tryParse(tier.thresholdAmount) ?? 0.0;
      if (userAmount < threshold) {
        return (threshold - userAmount).toStringAsFixed(0);
      }
    }

    return '0';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'inactive':
        return const Color(0xFF6B7280);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'expired':
        return const Color(0xFFEF4444);
      case 'draft':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}

class TierProgressPainter extends CustomPainter {
  final List<CampaignTier> tiers;
  final double userProgress;
  final double animation;

  TierProgressPainter({
    required this.tiers,
    required this.userProgress,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tiers.isEmpty) return;

    final sortedTiers = List<CampaignTier>.from(tiers)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final thresholds = sortedTiers
        .map((tier) => double.tryParse(tier.thresholdAmount) ?? 0.0)
        .toList();
    final maxThreshold = thresholds.isEmpty
        ? 1.0
        : thresholds.reduce((a, b) => a > b ? a : b);

    final lineStart = Offset(size.width * 0.08, size.height * 0.35);
    final lineEnd = Offset(size.width * 0.92, size.height * 0.35);

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(lineStart, lineEnd, bgPaint);

    final progressRatio = (userProgress / maxThreshold).clamp(0.0, 1.0);
    final progressEnd = Offset(
      lineStart.dx + (lineEnd.dx - lineStart.dx) * progressRatio * animation,
      lineStart.dy,
    );

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
      ).createShader(Rect.fromPoints(lineStart, progressEnd))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(lineStart, progressEnd, progressPaint);

    for (int i = 0; i < thresholds.length; i++) {
      final threshold = thresholds[i];
      final ratio = (threshold / maxThreshold).clamp(0.0, 1.0);
      final x = lineStart.dx + (lineEnd.dx - lineStart.dx) * ratio;
      final isCompleted = userProgress >= threshold;

      final tierPaint = Paint()
        ..color = isCompleted ? Colors.green : Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, lineStart.dy), 12, tierPaint);

      final borderPaint = Paint()
        ..color = isCompleted ? Colors.green : const Color(0xFF00D4FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(Offset(x, lineStart.dy), 12, borderPaint);

      final tierCode = sortedTiers[i].tierCode;
      final textPainter = TextPainter(
        text: TextSpan(
          text: tierCode,
          style: TextStyle(
            color: isCompleted ? Colors.green : const Color(0xFF00D4FF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, lineStart.dy - 26),
      );

      final amountPainter = TextPainter(
        text: TextSpan(
          text: '\$${threshold.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      amountPainter.layout();
      amountPainter.paint(
        canvas,
        Offset(x - amountPainter.width / 2, lineStart.dy + 17),
      );
    }

    if (userProgress > 0) {
      final userRatio = (userProgress / maxThreshold).clamp(0.0, 1.0);
      final userX = lineStart.dx + (lineEnd.dx - lineStart.dx) * userRatio;

      final glowPaint = Paint()
        ..color = const Color(0xFFFFA500).withOpacity(0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(userX, lineStart.dy), 12, glowPaint);

      final userPaint = Paint()
        ..color = const Color(0xFFFFA500)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(userX, lineStart.dy), 8, userPaint);

      final userTextPainter = TextPainter(
        text: const TextSpan(
          text: 'YOU',
          style: TextStyle(
            color: Color(0xFFFFA500),
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      userTextPainter.layout();
      userTextPainter.paint(
        canvas,
        Offset(userX - userTextPainter.width / 2, lineStart.dy - 42),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
