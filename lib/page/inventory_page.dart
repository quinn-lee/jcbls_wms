import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/widget/home_appbar.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends HiState<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar("Inventory"),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Transfer Unmount"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.transferUnmountScanSpacePage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Transfer Mount"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.transferMountScanSpacePage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Check"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.inventoryCheckTasksPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Blue Thermal Print TEST"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.blueThermalPrintPage);
            },
          ),
        ],
      ),
    );
  }
}
