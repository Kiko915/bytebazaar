import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'dart:ui';
import 'dart:async';

/// Enum for feedback type
enum BFeedbackType { success, error, info, warning }

/// Brand-aligned feedback snackbar
class _ModernFeedbackContent extends StatefulWidget {
  // ... (fields as before)

  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final String? title;
  final String message;
  final Duration duration;
  final VoidCallback onClose;

  const _ModernFeedbackContent({
    Key? key,
    required this.icon,
    required this.textColor,
    required this.bgColor,
    required this.title,
    required this.message,
    required this.duration,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_ModernFeedbackContent> createState() => _ModernFeedbackContentState();
}

class _ModernFeedbackContentState extends State<_ModernFeedbackContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 350),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeInBack,
    ));
    // Listen for animation end (auto-close)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onClose();
      }
    });
    // Ensure autoclose for overlay (top)
    _autoCloseTimer = Timer(widget.duration, () async {
      if (mounted && (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward)) {
        await _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (_controller.status == AnimationStatus.forward || _controller.status == AnimationStatus.completed) {
      await _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Prevent border clipping
                child: CustomPaint(
                  painter: _BorderProgressPainter(
                    progress: 1.0 - Curves.easeInOut.transform(_controller.value),
                    color: widget.textColor,
                    borderRadius: 16,
                    borderWidth: 4,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.bgColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.bgColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.textColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null)
                              Text(
                                widget.title!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: widget.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                              ),
                            Text(
                              widget.message,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: widget.textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _handleClose,
                        child: Icon(Icons.close, color: widget.textColor.withOpacity(0.7), size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class _BorderProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderRadius;
  final double borderWidth;

  _BorderProgressPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paintBg = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final paintFg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    // Draw background border
    canvas.drawRRect(rrect, paintBg);
    // Draw progress border (ensure progress is at least a small value to see the start)
    if (progress > 0.01) {
      final path = Path()..addRRect(rrect);
      final metrics = path.computeMetrics().first;
      final len = metrics.length * progress.clamp(0.01, 1.0);
      final extract = metrics.extractPath(0, len);
      canvas.drawPath(extract, paintFg);
    }

  }

  @override
  bool shouldRepaint(_BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

enum BFeedbackPosition { top, bottom }

class BFeedback {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    BFeedbackType type = BFeedbackType.info,
    Duration duration = const Duration(seconds: 3),
    BFeedbackPosition position = BFeedbackPosition.bottom,
  }) {
    final Color bgColor;
    final Color textColor = BColors.white;
    final IconData icon;
    switch (type) {
      case BFeedbackType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case BFeedbackType.error:
        bgColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case BFeedbackType.warning:
        bgColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case BFeedbackType.info:
        bgColor = BColors.primary;
        icon = Icons.info_outline;
        break;
    }

    if (position == BFeedbackPosition.top) {
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (ctx) => SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
              child: _ModernFeedbackContent(
                icon: icon,
                textColor: textColor,
                bgColor: bgColor,
                title: title,
                message: message,
                duration: duration,
                onClose: () {
                  entry.remove();
                },
              ),
            ),
          ),
        ),
      );
      overlay.insert(entry);
      return;
    }
    // Default: bottom (SnackBar)
    final EdgeInsets margin = position == BFeedbackPosition.top
        ? const EdgeInsets.fromLTRB(16, 32, 16, 0)
        : const EdgeInsets.fromLTRB(16, 0, 16, 16);
    final snackBarBehavior = SnackBarBehavior.floating;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: snackBarBehavior,
        margin: margin,
        padding: EdgeInsets.zero,
        content: _ModernFeedbackContent(
          icon: icon,
          textColor: textColor,
          bgColor: bgColor,
          title: title,
          message: message,
          duration: duration,
          onClose: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
