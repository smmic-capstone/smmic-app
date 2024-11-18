import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_dialog.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';

class SinkNodeCard extends StatefulWidget {
  const SinkNodeCard({super.key, required this.deviceInfo});

  final SinkNode deviceInfo;

  @override
  State<SinkNodeCard> createState() => _SinkNodeCardState();
}

class _SinkNodeCardState extends State<SinkNodeCard> {

  @override
  Widget build(BuildContext context) {
    return _cardBackground();
  }

  Widget _cardBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(
                Radius.circular(25)
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(25)
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
