import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/call.dart';
import '../../../../models/user_listing.dart';
import '../../signup/view_model/signup_viewmodel.dart';
import '../view_model/call_viewmodel.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CallViewModel>(context, listen: false).fetchServerCallHistory();
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
        title: const Text('Clear History', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete all call logs?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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
                          Navigator.pushNamed(context, '/coin');
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

  @override
  Widget build(BuildContext context) {
    final callVM = Provider.of<CallViewModel>(context);
    final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
    
    // Choose logs to display based on status (server logs or local logs fallback)
    final List<CallLog> logs;
    final bool showingLocalFallback;

    if (callVM.historyError != null) {
      logs = callVM.callLogs;
      showingLocalFallback = true;
    } else {
      logs = callVM.isHistoryLoading ? [] : callVM.serverCallLogs;
      showingLocalFallback = false;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Call History',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_rounded, 
                        color: logs.isEmpty ? Colors.white24 : AppTheme.accentRose, 
                        size: 24,
                      ),
                      onPressed: logs.isEmpty ? null : () => _confirmClearLogs(context, callVM),
                    ),
                  ],
                ),
              ),

              // Server Offline Fallback Banner
              if (showingLocalFallback)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.accentRose.withOpacity(0.15),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off_rounded, color: AppTheme.accentRose, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server sync failed. Displaying local logs.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // logs lists, loading, or empty states
              Expanded(
                child: callVM.isHistoryLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentRose),
                      )
                    : (logs.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
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
                                ),
                                child: Row(
                                  children: [
                                    // Left Avatar
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

                                    // Center details (Name, duration type, datetime)
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

                                    // Right Coin Billing & Call back action
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Coin billing
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

                                        // Callback button
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
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Visual Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderTranslucent),
            ),
            child: const Icon(
              Icons.phone_disabled_rounded,
              color: AppTheme.textSecondary,
              size: 64,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Call Logs',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Calls you make and receive will be listed here. Add some coins and connect with matches!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.glowShadow(AppTheme.accentRose),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
