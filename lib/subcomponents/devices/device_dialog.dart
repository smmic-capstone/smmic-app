import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/devices_services.dart';
import '../../models/device_data_models.dart';
import '../../utils/global_navigator.dart';

class SKDeviceDialog{
  SKDeviceDialog ({required this.context,required this.deviceID});

  final String deviceID;
  final BuildContext context;
  final DevicesServices _devicesServices = DevicesServices();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();
  final TextEditingController sinkNameController = TextEditingController();

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
                    print(_sinkNodeList);
                    return;
                  }else{
                    Map<String,dynamic> skDataProvider = {
                      'deviceID' : deviceID,
                      'deviceName' : sinkNameController.text,
                      'longitude' : "",
                      'latitude' : "",
                      "registeredSensorNodes" : context.read<DevicesProvider>().sinkNodeList.where((sink) => sink.deviceID == deviceID).first.registeredSensorNodes
                    };

                    Map<String,dynamic> skData = {
                      'SKID' : deviceID,
                      'SK_Name' : sinkNameController.text
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
}

