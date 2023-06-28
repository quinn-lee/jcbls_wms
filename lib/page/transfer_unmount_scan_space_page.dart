import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/string_util.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class TransferUnmountScanSpacePage extends StatefulWidget {
  const TransferUnmountScanSpacePage({Key? key}) : super(key: key);

  @override
  State<TransferUnmountScanSpacePage> createState() =>
      _TransferUnmountScanSpacePageState();
}

class _TransferUnmountScanSpacePageState
    extends HiState<TransferUnmountScanSpacePage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Transfer Unmount", "", () {}),
        body: LoadingContainer(
          cover: true,
          isLoading: false,
          child: Container(
            child: ListView(
              children: [
                ScanInput(
                  "Shelf Num",
                  "Scan Shelf Num",
                  focusNode,
                  textEditingController,
                  onChanged: (text) {
                    num = text;
                    // print("num: $num");
                  },
                  onSubmitted: (text) {
                    if (isNotEmpty(num)) {
                      HiNavigator.getInstance().onJumpTo(
                          RouteStatus.transferUnmountPage,
                          args: {"space_num": num});
                    } else {
                      showWarnToast("Please Scan Shelf Num");
                    }
                  },
                )
              ],
            ),
          ),
        ));
  }
}
