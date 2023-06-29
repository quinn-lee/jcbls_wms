import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inbound_dao.dart';
import 'package:jcbls_app/model/inbound_task.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class InboundTasksPage extends StatefulWidget {
  const InboundTasksPage({Key? key}) : super(key: key);

  @override
  State<InboundTasksPage> createState() => _InboundTasksPageState();
}

class _InboundTasksPageState extends HiState<InboundTasksPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<InboundTask> inboundTasks = [];
  String? num;
  bool _isLoading = true;
  AudioCache player = AudioCache();
  var listener;

  @override
  void initState() {
    bool resumeFlag = false;
    super.initState();
    textEditingController.addListener(() {
      // print("controller: ${textEditingController.text}");
    });
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      // print("current: ${current.page}");
      // print("pre: ${pre.page}");
      if (widget == current.page || current.page is InboundTasksPage) {
        // print("打开了待处理列表: onResume");
        textEditingController.clear(); // 清除搜索栏
        loadData(); // 重新加载数据
        resumeFlag = true;
      } else if (widget == pre?.page || pre?.page is InboundTasksPage) {
        // print("待处理列表: onPause");
      }
    });
    if (!resumeFlag) {
      loadData();
    }
  }

  @override
  void dispose() {
    HiNavigator.getInstance().removeListener(listener!);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Inbound Tasks", "", () {}),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: Container(
            child: ListView(
              children: _buildWidget(),
            ),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Inbound Num",
      "Scan Inbound Num",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        loadData(taskNum: num);
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    widgets.add(Table(
      children: _taskTable(),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    ));
    return widgets;
  }

  List<TableRow> _taskTable() {
    List<TableRow> tableList = [
      TableRow(decoration: const BoxDecoration(color: Colors.grey), children: [
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Inbound Num",
              textAlign: TextAlign.center,
            )),
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Customer",
              textAlign: TextAlign.center,
            )),
        Container(padding: const EdgeInsets.all(12), child: const Text(""))
      ])
    ];
    for (var ele in inboundTasks) {
      tableList.add(TableRow(
        decoration: const BoxDecoration(color: Colors.white10),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              "${ele.taskNum}",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                "${ele.org!['abbr_code']}",
                textAlign: TextAlign.center,
              )),
          Container(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(
                      RouteStatus.inboundUploadPhotosPage,
                      args: {"task": ele});
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.blueAccent,
                ),
              )),
        ],
      ));
    }
    return tableList;
  }

  void loadData({taskNum = ""}) async {
    try {
      var result;
      if (taskNum != "") {
        result = await InboundDao.tasks(taskNum: taskNum);
      } else {
        result = await InboundDao.tasks();
      }
      if (result['code'] == 0) {
        setState(() {
          inboundTasks.clear();
          for (var item in result['data']['inbound_tasks']) {
            inboundTasks.add(InboundTask.fromJson(item));
          }
          if (inboundTasks.length == 1 && taskNum != "") {
            HiNavigator.getInstance().onJumpTo(
                RouteStatus.inboundUploadPhotosPage,
                args: {"task": inboundTasks[0]});
          }
          num = "";
          _isLoading = false;
        });
        if (result['data'].length == 0) {
          showWarnToast("No Inbound Batch Need To Be Processed");
        }
      } else {
        // print(result['reason']);
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          num = "";
          inboundTasks.clear();
        });
      }
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        num = "";
        inboundTasks.clear();
      });
    }
    if (mounted) {
      textEditingController.clear(); // 清除搜索栏
      FocusScope.of(context).requestFocus(focusNode); //聚焦
    }
  }

  @override
  bool get wantKeepAlive => true;
}
