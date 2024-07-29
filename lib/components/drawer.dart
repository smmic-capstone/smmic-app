import 'package:flutter/material.dart';
import 'package:smmic/pages/accountinfo.dart';
import 'package:smmic/pages/settings.dart';

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
          const DrawerHeader(
              child: Row(
            children: [
              Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              )),
              Text(
                'Jozua Cyd, Rubio',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          )),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
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
