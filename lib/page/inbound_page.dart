import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/widget/home_appbar.dart';

class InboundPage extends StatefulWidget {
  const InboundPage({Key? key}) : super(key: key);

  @override
  State<InboundPage> createState() => _InboundPageState();
}

class _InboundPageState extends HiState<InboundPage> {
  dynamic listener;

  @override
  void initState() {
    super.initState();
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      print("current: ${current.page}");
      print("pre: ${pre.page}");
      if (widget == current.page || current.page is InboundPage) {
        print("打开了Inbound: onResume");
      } else if (widget == pre?.page || pre?.page is InboundPage) {
        print("Inbound: onPause");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar("Inbound"),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Inbound Mount"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.inboundMountListPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Inbound Scanning"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.inboundScanningPage);
            },
          ),
        ],
      ),
    );
  }
}
