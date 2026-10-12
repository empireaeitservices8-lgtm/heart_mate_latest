import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';
import 'package:dating_app/screens/call/view_model/call_viewmodel.dart';
import 'package:dating_app/models/call.dart';
import 'package:dating_app/models/user_listing.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  int _selectedSegment = 0; // 0: Wallet, 1: Call History
  String _activeFilter = 'All'; // All, Incoming, Outgoing, Missed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
      final callVM = Provider.of<CallViewModel>(context, listen: false);
      signupVM.fetchCoins();
      signupVM.fetchOffers();
      callVM.fetchServerCallHistory();
    });
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$min $period';

    if (diff.inDays == 0 && now.day == dt.day) {
      return 'Today, $timeStr';
    } else if (diff.inDays <= 1 && now.subtract(const Duration(days: 1)).day == dt.day) {
      return 'Yesterday, $timeStr';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $timeStr';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Missed';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s mins';
  }

  void _confirmClearLogs(BuildContext context, CallViewModel callVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to delete all call logs?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRose,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              callVM.clearCallLogs();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleCallback(BuildContext context, CallLog log, CallViewModel callVM, SignUpViewModel signupVM) async {
    final rate = callVM.getCoinsRate(log.type);
    final minCoins = rate * 15;

    if (signupVM.coins < minCoins) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.monetization_on_rounded, color: AppTheme.accentGold, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Insufficient Coins',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You need at least $minCoins coins (15 secs call) to dial ${log.contactName}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.borderTranslucent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedSegment = 0; // Switch to Wallet tab
                          });
                        },
                        child: const Text('Add Coins', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      return;
    }

    final user = UserListing(
      id: log.contactId,
      name: log.contactName,
      status: 'online',
      isVerified: true,
    );

    // Navigate directly to the outgoing ringing screen without an intermediate loader dialog
    Navigator.pushNamed(context, '/outgoing-call');

    final dialing = await callVM.startCall(user, log.type, signupVM);
    if (!dialing && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect call. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List<CallLog> _getFilteredLogs(List<CallLog> allLogs) {
    if (_activeFilter == 'All') return allLogs;
    if (_activeFilter == 'Incoming') {
      return allLogs.where((log) => log.isIncoming).toList();
    }
    if (_activeFilter == 'Outgoing') {
      return allLogs.where((log) => !log.isIncoming).toList();
    }
    if (_activeFilter == 'Missed') {
      return allLogs.where((log) => !log.wasConnected && log.isIncoming).toList();
    }
    return allLogs;
  }

  @override
  Widget build(BuildContext context) {
    final signupVM = Provider.of<SignUpViewModel>(context);
    final callVM = Provider.of<CallViewModel>(context);

    final coins = signupVM.coins;
    final balance = signupVM.isCoinsLoading && coins == 0 ? "..." : coins.toString();

    // Determine logs list based on fallback state
    final List<CallLog> rawLogs;
    final bool showingLocalFallback;

    if (callVM.historyError != null) {
      rawLogs = callVM.callLogs;
      showingLocalFallback = true;
    } else {
      rawLogs = callVM.isHistoryLoading ? [] : callVM.serverCallLogs;
      showingLocalFallback = false;
    }

    final filteredLogs = _getFilteredLogs(rawLogs);

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
                      child: Text(
                        _selectedSegment == 0 ? 'My Wallet' : 'Call History',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_selectedSegment == 1)
                      IconButton(
                        icon: Icon(
                          Icons.delete_sweep_rounded, 
                          color: rawLogs.isEmpty ? Colors.white24 : AppTheme.accentRose, 
                          size: 24,
                        ),
                        onPressed: rawLogs.isEmpty ? null : () => _confirmClearLogs(context, callVM),
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
                    await callVM.fetchServerCallHistory();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Wallet Balance overview card (always visible at top of Wallet & History tab)
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
                        const SizedBox(height: 24),

                        // Sliding Tab Selector between Wallet and Call History
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.borderTranslucent),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSegment = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: _selectedSegment == 0
                                          ? AppTheme.primaryGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      "Wallet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedSegment == 0
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSegment = 1;
                                    });
                                    callVM.fetchServerCallHistory();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: _selectedSegment == 1
                                          ? AppTheme.primaryGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      "Call History",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedSegment == 1
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Render Wallet Packages or Call History based on active segment
                        if (_selectedSegment == 0) ...[
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
                        ] else ...[
                          // CALL HISTORY SECTION
                          if (showingLocalFallback)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRose.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.accentRose.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_off_rounded, color: AppTheme.accentRose, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Server sync failed. Displaying local logs.',
                                      style: TextStyle(
                                        color: AppTheme.accentRose.withOpacity(0.9),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Filter chips
                          _buildFilterChips(),
                          const SizedBox(height: 16),

                          // Call Logs list
                          if (callVM.isHistoryLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: CircularProgressIndicator(color: AppTheme.accentRose),
                              ),
                            )
                          else if (filteredLogs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                              child: Center(
                                child: Text(
                                  'No call logs found for this category.',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredLogs.length,
                              itemBuilder: (context, index) {
                                final log = filteredLogs[index];
                                final isIncoming = log.isIncoming;
                                final isMissed = !log.wasConnected && isIncoming;
                                
                                IconData callTypeIcon = log.type == CallType.video 
                                    ? Icons.videocam_rounded 
                                    : Icons.phone_rounded;

                                IconData statusIcon = isMissed
                                    ? Icons.phone_missed_rounded
                                    : (isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded);

                                Color statusColor = isMissed
                                    ? AppTheme.accentRose
                                    : (isIncoming ? AppTheme.callGreen : AppTheme.callIndigo);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceCard,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.borderTranslucent),
                                    boxShadow: AppTheme.softCardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar image
                                      Container(
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppTheme.primaryGradient,
                                        ),
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundImage: AssetImage(log.contactAvatar),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Middle description details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log.contactName,
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(statusIcon, color: statusColor, size: 14),
                                                const SizedBox(width: 6),
                                                Text(
                                                  isMissed ? 'Missed call' : (isIncoming ? 'Incoming' : 'Outgoing'),
                                                  style: TextStyle(
                                                    color: statusColor.withOpacity(0.85),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•  ${_formatDuration(log.durationSeconds)}',
                                                  style: const TextStyle(
                                                    color: AppTheme.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _formatDateTime(log.timestamp),
                                              style: TextStyle(
                                                color: AppTheme.textSecondary.withOpacity(0.7),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Right action & Billing
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (log.coinsSpent > 0)
                                            Row(
                                              children: [
                                                const Icon(Icons.monetization_on_rounded, color: AppTheme.accentGold, size: 12),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '-${log.coinsSpent}',
                                                  style: const TextStyle(
                                                    color: AppTheme.accentRose,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Text(
                                              isMissed ? '0 Coins' : 'Free',
                                              style: TextStyle(
                                                color: isMissed ? Colors.white30 : AppTheme.callGreen,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const SizedBox(height: 12),

                                          // Callback triggers callViewModel dialing
                                          GestureDetector(
                                            onTap: () => _handleCallback(context, log, callVM, signupVM),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.08),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: statusColor.withOpacity(0.15)),
                                              ),
                                              child: Icon(
                                                callTypeIcon,
                                                color: statusColor,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Incoming', 'Outgoing', 'Missed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _activeFilter = filter;
                  });
                }
              },
              selectedColor: AppTheme.accentRose,
              backgroundColor: AppTheme.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppTheme.borderTranslucent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
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
        // Log transaction locally
        final transaction = {
          'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Coin Purchase',
          'subtitle': 'Credit Bundle',
          'amount': '+$coinsAmount Coins',
          'type': 'purchase',
          'date': 'Today',
          'status': 'success',
          'timestamp': DateTime.now().toIso8601String(),
        };
        // Add credit entry
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
              // Deduct coins locally
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
