import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../providers/progress_provider.dart';

class RewardScreen extends ConsumerWidget {
  const RewardScreen({Key? key}) : super(key: key);

  static const List<Reward> _rewards = [
    Reward(
      id: 'reward_001',
      name: 'First Star 🌟',
      description: 'Kiếm được sao đầu tiên',
      requiredStars: 1,
      icon: '🌟',
      rarity: 'common',
    ),
    Reward(
      id: 'reward_002',
      name: 'Star Collector ⭐⭐⭐',
      description: 'Kiếm được 5 sao',
      requiredStars: 5,
      icon: '⭐⭐⭐',
      rarity: 'common',
    ),
    Reward(
      id: 'reward_003',
      name: 'Gold Star Master 🏆',
      description: 'Kiếm được 10 sao',
      requiredStars: 10,
      icon: '🏆',
      rarity: 'rare',
    ),
    Reward(
      id: 'reward_004',
      name: 'Super Learner 🚀',
      description: 'Kiếm được 20 sao',
      requiredStars: 20,
      icon: '🚀',
      rarity: 'rare',
    ),
    Reward(
      id: 'reward_005',
      name: 'Ultimate Champion 👑',
      description: 'Kiếm được 50 sao',
      requiredStars: 50,
      icon: '👑',
      rarity: 'legendary',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Phần Thưởng'),
        backgroundColor: AppColors.accentColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.accentColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Thành Tích Của Bạn',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bạn đã kiếm được ${userProgress.totalStars} ⭐',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _rewards.length,
                itemBuilder: (context, index) {
                  final reward = _rewards[index];
                  final isUnlocked =
                      userProgress.totalStars >= reward.requiredStars;
                  return _buildRewardCard(
                    reward,
                    isUnlocked,
                    userProgress.totalStars,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(
    Reward reward,
    bool isUnlocked,
    int totalStars,
  ) {
    final bgColor =
        isUnlocked ? _getRarityColor(reward.rarity) : Colors.grey[300];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: _getRarityColor(reward.rarity).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                const BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                reward.icon,
                style: TextStyle(
                  fontSize: 48,
                  // ✅ CORRECT
                  color: Color.fromARGB(
                    (isUnlocked ? 255 : 76).toInt(), // alpha:  0-255
                    255, // R
                    255, // G
                    255, // B
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  reward.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3.copyWith(
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${reward.requiredStars} ⭐',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isUnlocked ? Colors.white70 : Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (!isUnlocked)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(6),
                child: Text(
                  '${reward.requiredStars - totalStars}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFF95E1D3);
      case 'rare':
        return const Color(0xFF4D96FF);
      case 'legendary':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }
}
