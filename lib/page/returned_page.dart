import 'package:flutter/material.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/widget/home_appbar.dart';
import 'package:jcbls_app/core/hi_state.dart';

class ReturnedPage extends StatefulWidget {
  const ReturnedPage({Key? key}) : super(key: key);

  @override
  State<ReturnedPage> createState() => _ReturnedPageState();
}

class _ReturnedPageState extends HiState<ReturnedPage>
    with AutomaticKeepAliveClientMixin {
  dynamic listener;

  @override
  void initState() {
    super.initState();
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      print("current: ${current.page}");
      print("pre: ${pre.page}");
      if (widget == current.page || current.page is ReturnedPage) {
        print("打开了Returned: onResume");
      } else if (widget == pre?.page || pre?.page is ReturnedPage) {
        print("Returned: onPause");
      }
    });
  }

  @override
  void dispose() {
    HiNavigator.getInstance().removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar("Returned"),
      body: const Center(
        child: Text('Waiting for development'),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
