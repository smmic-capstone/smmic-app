// import 'package:flutter/material.dart';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:smmic/models/sink_node_data_model.dart';
// import 'package:smmic/subcomponents/devices/battery_level.dart';
// import 'package:smmic/subcomponents/devices/device_name.dart';
// import 'package:smmic/subcomponents/devices/digital_display.dart';
// import 'package:smmic/subcomponents/devices/gauge.dart';
//
// class SinkNodeCard extends StatefulWidget {
//   const SinkNodeCard({super.key, required this.deviceData});
//
//   final SinkNodeData deviceData;
//
//   @override
//   State<SinkNodeCard> createState() => _SinkNodeCardState();
// }
//
// class _SinkNodeCardState extends State<SinkNodeCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//             margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
//             padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.all(Radius.circular(15)),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       spreadRadius: 0,
//                       blurRadius: 4,
//                       offset: const Offset(0, 4)
//                   )
//                 ]
//             ),
//             height: 160,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     children: [
//                       Expanded(
//                           flex: 3,
//                           child: DeviceName(deviceName: data['deviceName'])
//                       ),
//                       Expanded(
//                           flex: 1,
//                           child: BatteryLevel(batteryLevel: data['batteryLevel'])
//                       )
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Container(),
//                 ),
//               ],
//             )
//         ),
//         Container(
//           padding: const EdgeInsets.only(right: 37, top: 12),
//           alignment: Alignment.topRight,
//           child: RotatedBox(
//             quarterTurns: 2,
//             child: Icon(
//               CupertinoIcons.arrow_down_left_circle,
//               size: 20,
//               color: Colors.black.withOpacity(0.25),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }