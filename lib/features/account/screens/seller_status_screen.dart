import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/features/account/screens/seller_dashboard_screen.dart';

class SellerStatusScreen extends StatefulWidget {
  final String status; // initial status: 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final VoidCallback? onReapply;
  final VoidCallback? onGoToDashboard;

  const SellerStatusScreen({
    Key? key,
    required this.status,
    this.rejectionReason,
    this.onReapply,
    this.onGoToDashboard,
  }) : super(key: key);

  @override
  State<SellerStatusScreen> createState() => _SellerStatusScreenState();
}

class _SellerStatusScreenState extends State<SellerStatusScreen> {
  late String _status;
  String? _rejectionReason;
  bool _loading = true;
  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _rejectionReason = widget.rejectionReason;
    _listenToStatus();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _listenToStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    _statusSubscription = FirebaseFirestore.instance
        .collection('seller_applications')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || doc.data() == null) {
        setState(() {
          _loading = false;
          _status = 'pending';
        });
        return;
      }
      final data = doc.data()!;
      setState(() {
        _status = data['status'] ?? 'pending';
        _rejectionReason = data['rejectionReason'];
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Seller Application Status'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    String lottieAsset;
    Widget content;
    switch (_status) {
      case 'pending':
        lottieAsset = 'assets/lottie/sa-pending.json';
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(lottieAsset, height: 180),
            SizedBox(height: 24),
            Text(
              'Your application is pending',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'We are reviewing your seller application. You will be notified once a decision has been made.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: Text('Back to Home'),
            ),
          ],
        );
        break;
      case 'rejected':
        lottieAsset = 'assets/lottie/sa-rejected.json';
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(lottieAsset, height: 180),
            SizedBox(height: 24),
            Text(
              'Application Rejected',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              _rejectionReason?.isNotEmpty == true
                  ? _rejectionReason!
                  : 'Your application was not approved. Please review the reason and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onReapply != null) widget.onReapply!();
              },
              child: Text('Re-apply as Seller'),
            ),
          ],
        );
        break;
      case 'approved':
        lottieAsset = 'assets/lottie/sa-approved.json';
        // Start confetti when approved
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confettiController.play(); // Safe to call repeatedly; play() will restart if already running
        });
        content = Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(lottieAsset, height: 180),
                SizedBox(height: 24),
                Text(
                  'Congratulations!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green),
                ),
                SizedBox(height: 12),
                Text(
                  'Your seller application has been approved!',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 34),
                // Add more approved content here if you want
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.dashboard, color: Colors.white),
                    label: Text('Go to Seller Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
                      );
                      if (widget.onGoToDashboard != null) widget.onGoToDashboard!();
                    },
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    numberOfParticles: 30,
                    maxBlastForce: 20,
                    minBlastForce: 5,
                    emissionFrequency: 0.05,
                    gravity: 0.2,
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      default:
        lottieAsset = '';
        content = Center(child: Text('Unknown status.'));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Application Status'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: content,
        ),
      ),
    );
  }
}
