import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/audio_service.dart';

class SoundToggleButton extends StatefulWidget {
  final double size;
  final EdgeInsets? padding;

  const SoundToggleButton({
    super.key,
    this.size = 32.0,
    this.padding,
  });

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(milliseconds: 100))
          .map((_) => AudioService.instance.isSoundEnabled),
      builder: (context, snapshot) {
        final isSoundEnabled = snapshot.data ?? AudioService.instance.isSoundEnabled;
        return GestureDetector(
          onTap: _toggleSound,
          child: Container(
            width: widget.size,
            height: widget.size,
            padding: widget.padding ?? const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.neutralDark,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Icon(
              isSoundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: Colors.white,
              size: widget.size * 0.6,
            ),
          ),
        );
      },
    );
  }

  void _toggleSound() async {
    await AudioService.instance.toggleSound();
    // Trigger rebuild to update the icon
    setState(() {});
  }
}
