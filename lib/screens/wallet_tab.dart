import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
      signupVM.fetchCoins();
      signupVM.fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final signupVM = Provider.of<SignUpViewModel>(context);

    final coins = signupVM.coins;
    final balance = signupVM.isCoinsLoading && coins == 0 ? "..." : coins.toString();

    // Coin packages list
    final List<Map<String, String>> coinPackages = [
      {'coins': '1,900', 'price': '₹ 99', 'badge': ''},
      {'coins': '3,800', 'price': '₹ 199', 'badge': ''},
      {'coins': '12,500', 'price': '₹ 499', 'badge': ''},
      {'coins': '25,000', 'price': '₹ 999', 'badge': 'Popular'},
      {'coins': '55,000', 'price': '₹ 1,999', 'badge': ''},
      {'coins': '125,000', 'price': '₹ 4,999', 'badge': ''},
      {'coins': '230,000', 'price': '₹ 9,999', 'badge': 'Best Deal'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Premium Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'My Wallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.accentRose,
                  onRefresh: () async {
                    await signupVM.fetchCoins();
                    await signupVM.fetchOffers();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Wallet Balance overview card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppTheme.glowShadow(AppTheme.accentViolet),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Icon(
                                  Icons.monetization_on_rounded,
                                  size: 130,
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.wallet_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Premium Balance',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  const Text(
                                    'YOUR BALANCE',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    textBaseline: TextBaseline.alphabetic,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    children: [
                                      Text(
                                        balance,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Coins',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // WALLET STORE SECTION
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                            child: Text(
                              "SELECT COIN BUNDLE",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: coinPackages.length,
                          itemBuilder: (context, index) {
                            final pack = coinPackages[index];
                            final hasBadge = pack['badge']!.isNotEmpty;

                            return Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: hasBadge ? AppTheme.accentRose : AppTheme.borderTranslucent,
                                  width: hasBadge ? 1.5 : 1,
                                ),
                                boxShadow: AppTheme.softCardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    if (hasBadge)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: const BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            pack['badge']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.monetization_on_rounded,
                                            color: AppTheme.accentGold,
                                            size: 36,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '${pack['coins']} Coins',
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 38,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _showPurchaseDialog(context, pack, signupVM);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: hasBadge ? AppTheme.accentRose : AppTheme.textPrimary.withOpacity(0.05),
                                                foregroundColor: hasBadge ? Colors.white : AppTheme.textPrimary,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: hasBadge ? Colors.transparent : AppTheme.textPrimary.withOpacity(0.1),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                pack['price']!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                          },
                        ),

                        const SizedBox(height: 32),

                        // Offers
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                            child: Text(
                              "ACTIVE OFFERS",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),

                        if (signupVM.isOffersLoading && signupVM.offers.isEmpty)
                          const Center(
                            child: CircularProgressIndicator(color: AppTheme.accentRose),
                          )
                        else if (signupVM.errorMessage != null && signupVM.offers.isEmpty)
                          Text(
                            'Error loading offers: ${signupVM.errorMessage}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          )
                        else if (signupVM.offers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No active offers available.',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: signupVM.offers.length,
                            itemBuilder: (context, index) {
                              final offer = signupVM.offers[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.borderTranslucent),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.title,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.monetization_on_rounded,
                                                color: AppTheme.accentGold,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${offer.coins} Coins',
                                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showClaimOfferDialog(context, offer, signupVM, coins);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accentRose,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Claim'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, String> pack, SignUpViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderTranslucent),
        ),
        title: Text(
          'Purchase ${pack['coins']} Coins',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Would you like to purchase ${pack['coins']} coins for ${pack['price']}?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _processPurchase(context, pack, viewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(BuildContext context, Map<String, String> pack, SignUpViewModel viewModel) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentRose),
      ),
    );

    final coinsAmount = int.tryParse(pack['coins']!.replaceAll(',', '')) ?? 0;
    final success = await viewModel.addCoins(coinsAmount);

    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading spinner

      if (success) {
        viewModel.fetchTransactions();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully purchased ${pack['coins']} coins!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Purchase failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showClaimOfferDialog(BuildContext context, dynamic offer, SignUpViewModel viewModel, int coins) {
    if (coins < offer.coins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins. Please buy more coins first!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderTranslucent),
        ),
        title: Text(
          'Claim ${offer.title}',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to claim this offer for ${offer.coins} coins?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${offer.title} claimed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              viewModel.deductCoinsForAgentAction(offer.coins as int, 'Claim Offer: ${offer.title}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }
}
