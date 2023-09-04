import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inventory_dao.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';

class InventoryCheckTasksPage extends StatefulWidget {
  const InventoryCheckTasksPage({Key? key}) : super(key: key);

  @override
  State<InventoryCheckTasksPage> createState() =>
      _InventoryCheckTasksPageState();
}

class _InventoryCheckTasksPageState extends HiState<InventoryCheckTasksPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List checkTasks = [];
  bool _isLoading = true;
  AudioCache player = AudioCache();
  var listener;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Check Tasks", "", () {}),
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
              "Task Num",
              textAlign: TextAlign.center,
            )),
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Space",
              textAlign: TextAlign.center,
            )),
        Container(padding: const EdgeInsets.all(12), child: const Text(""))
      ])
    ];
    for (var ele in checkTasks) {
      tableList.add(TableRow(
        decoration: const BoxDecoration(color: Colors.white10),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              "${ele['task_num']}",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                "${ele['space_num']}",
                textAlign: TextAlign.center,
              )),
          Container(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(
                      RouteStatus.inboundUploadPhotosPage,
                      args: {"check_task": ele});
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

  void loadData() async {
    try {
      var result;
      result = await InventoryDao.checkTasks();
      if (result['code'] == 0) {
        setState(() {
          checkTasks.clear();
          checkTasks = result['data']['check_tasks'];

          _isLoading = false;
        });
        if (result['data'].length == 0) {
          showWarnToast("No Check Tasks Need To Be Processed");
        }
      } else {
        // print(result['reason']);
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          checkTasks.clear();
        });
      }
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        checkTasks.clear();
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
