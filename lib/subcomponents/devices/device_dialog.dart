import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/devices_services.dart';
import '../../models/device_data_models.dart';
import '../../utils/global_navigator.dart';

// TODO: add longitude and latitude

class DeviceDialog{
  DeviceDialog ({required this.context,required this.deviceID,required this.latitude,required this.longitude});

  final String deviceID;
  final String? latitude;
  final String? longitude;
  final BuildContext context;
  final DevicesServices _devicesServices = DevicesServices();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();
  final TextEditingController sinkNameController = TextEditingController();
  final TextEditingController sensorNameController = TextEditingController();

  void renameDialog(){
     showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Rename Sink Node"),
            content: TextField(
              decoration: const InputDecoration(hintText: "Enter new name"),
              controller: sinkNameController,
            ),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("Cancel")
              ),
              TextButton(onPressed: () async {
                UserAccess? _userAccess = context.read<AuthProvider>().accessData;
                List <SinkNode>? _sinkNodeList = context.read<DevicesProvider>().sinkNodeList;
                if(_userAccess == null) {
                  context.read<AuthProvider>().accessStatus == TokenStatus.forceLogin;
                  _globalNavigator.forceLoginDialog();
                }else{
                  if(_sinkNodeList == null) {
                    //TODO: implement a proper null handle in case _sinkNode == null
                    print('sink node list is null: $_sinkNodeList');
                    return;
                  }else{
                    Map<String,dynamic> skDataProvider = {
                      'deviceID' : deviceID,
                      'deviceName' : sinkNameController.text,
                      'latitude' : latitude,
                      'longitude' : longitude,
                      "registeredSensorNodes" : context.read<DevicesProvider>().sinkNodeList.where((sink) => sink.deviceID == deviceID).first.registeredSensorNodes
                    };

                    Map<String,dynamic> skData = {
                      'SKID' : deviceID,
                      'SK_Name' : sinkNameController.text,
                      'latitude' : latitude,
                      'longitude' : longitude
                    };
                    await _devicesServices.updateSKDeviceName(token: _userAccess.token, deviceID: deviceID, sinkName: skData);

                    if(context.mounted){
                      context.read<DevicesProvider>().sinkNameChange(skDataProvider);
                    }


                  }

                }

              }, child: const Text("Save"))
            ],

          );
        }
     );
  }
  void renameSNDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Rename Node"),
            // TODO: limit to 12 characters ang name
            content: TextField(
              decoration: const InputDecoration(hintText: "Enter New Name"),
              controller: sensorNameController,
            ),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: const Text("Cancel")),
              TextButton(onPressed: () async {
                UserAccess? userAccess = context.read<AuthProvider>().accessData;
                List<SensorNode>? sensorNodeList = context.read<DevicesProvider>().sensorNodeList;

                if(userAccess == null){
                  context.read<AuthProvider>().accessStatus == TokenStatus.forceLogin;
                  _globalNavigator.forceLoginDialog();
                }else{
                  if(sensorNodeList == null){
                    print("sensor node device dialog null : $sensorNodeList");
                  }else{
                    String registerSinkNodeID = context.read<DevicesProvider>().sensorNodeList.where((sensor) => sensor.deviceID == deviceID).first.registeredSinkNode;
                    Map<String,dynamic> snDataProvider = {
                      'deviceID' : deviceID,
                      'deviceName' : sensorNameController.text,
                      'latitude' : latitude,
                      'longitude' : longitude,
                      'sinkNodeID' : registerSinkNodeID
                    };
                    print("device Dialog $snDataProvider");
                    Map<String,dynamic> snUpdatedData = {
                      'SNID' : deviceID,
                      'SensorNode_Name' : sensorNameController.text,
                      'latitude' : latitude,
                      'longitude' : longitude
                    };
                    print("object");
                    await _devicesServices.updateSNDeviceName(token: userAccess.token, deviceID: deviceID, sensorName: snUpdatedData, sinkNodeID: registerSinkNodeID);

                    if(context.mounted){
                      context.read<DevicesProvider>().sensorNameChange(snDataProvider);
                    }
                  }
                }

              }, child: const Text("Save"))
            ],
          );
        });
  }
}



