import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smmic/pages/accountinfo.dart';

class ComponentDrawer extends StatefulWidget {
  const ComponentDrawer({super.key});

  @override
  State<ComponentDrawer> createState() => ComponentDrawerState();
}

class ComponentDrawerState extends State<ComponentDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Center(child: Text('SIMMIC'))),
          GestureDetector(
            onTap: () {},
            child: const ListTile(
                leading: Icon(Icons.settings_sharp), title: Text('Settings')),
          ),
          GestureDetector(
            onTap: () {},
            child: ListTile(
                leading: const Icon(Icons.person), title: Text('Manage Account'),
            onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageAccount()
                  ));
              },
            ),
          )
        ],
      ),
    );
  }
}
