import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class LongPressMenu extends StatefulWidget {
  const LongPressMenu({
    super.key,
    required this.position,
    required this.onActionSelected,
    required this.onClose,
  });

  final Offset position;
  final Function(String) onActionSelected;
  final VoidCallback onClose;

  @override
  State<LongPressMenu> createState() => _LongPressMenuState();
}

class _LongPressMenuState extends State<LongPressMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _currentPointerPosition = Offset.zero;
  String _hoveredAction = '';

  @override
  void initState() {
    super.initState();
    _currentPointerPosition = widget.position;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateActiveAction() {
    // Determine which button is being hovered based on distance from current pointer
    final actions = {
      'save': Offset(widget.position.dx - 80, widget.position.dy - 40),
      'send': Offset(widget.position.dx + 80, widget.position.dy - 40),
      'hide': Offset(widget.position.dx, widget.position.dy - 120),
    };

    String active = '';
    double minDistance = 60; // Activation radius

    actions.forEach((key, pos) {
      double dist = (pos - _currentPointerPosition).distance;
      if (dist < minDistance) {
        active = key;
      }
    });

    if (active != _hoveredAction) {
      if (active.isNotEmpty) HapticFeedback.selectionClick();
      setState(() => _hoveredAction = active);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Listener(
        onPointerMove: (event) {
          setState(() => _currentPointerPosition = event.position);
          _updateActiveAction();
        },
        onPointerUp: (event) {
          if (_hoveredAction.isNotEmpty) {
            widget.onActionSelected(_hoveredAction);
          }
          widget.onClose();
        },
        child: Stack(
          children: [
            // Glass Backdrop
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),

            // Central "Feedback" circle (under finger)
            Positioned(
              left: widget.position.dx - 30,
              top: widget.position.dy - 30,
              child: FadeTransition(
                opacity: _controller,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Save Action
            _ActionItem(
              icon: Icons.push_pin_rounded,
              label: 'Save',
              targetPos: Offset(
                widget.position.dx - 80,
                widget.position.dy - 40,
              ),
              isHovered: _hoveredAction == 'save',
              color: const Color(0xFFE60023),
              animation: _controller,
            ),

            // Send Action
            _ActionItem(
              icon: Icons.send_rounded,
              label: 'Send',
              targetPos: Offset(
                widget.position.dx + 80,
                widget.position.dy - 40,
              ),
              isHovered: _hoveredAction == 'send',
              color: Colors.white,
              iconColor: Colors.black,
              animation: _controller,
            ),

            // Hide Action
            _ActionItem(
              icon: Icons.visibility_off_rounded,
              label: 'Hide',
              targetPos: Offset(widget.position.dx, widget.position.dy - 120),
              isHovered: _hoveredAction == 'hide',
              color: Colors.white,
              iconColor: Colors.black,
              animation: _controller,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.targetPos,
    required this.isHovered,
    required this.color,
    this.iconColor = Colors.white,
    required this.animation,
  });

  final IconData icon;
  final String label;
  final Offset targetPos;
  final bool isHovered;
  final Color color;
  final Color iconColor;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      left: targetPos.dx - (isHovered ? 40 : 30),
      top: targetPos.dy - (isHovered ? 40 : 30),
      child: FadeTransition(
        opacity: animation,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isHovered ? 80 : 60,
              height: isHovered ? 80 : 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  if (isHovered)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: isHovered ? 32 : 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
