import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/outbound_dao.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';

class OutboundWaveSinglePage extends StatefulWidget {
  const OutboundWaveSinglePage({Key? key}) : super(key: key);

  @override
  State<OutboundWaveSinglePage> createState() => _OutboundWaveSinglePageState();
}

class _OutboundWaveSinglePageState extends HiState<OutboundWaveSinglePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List waves = [];
  bool _isLoading = true;
  AudioCache player = AudioCache();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Outbound Waves", "", () {}),
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
    // widgets.add(ScanInput(
    //   "Inbound Num",
    //   "Scan Inbound Num",
    //   focusNode,
    //   textEditingController,
    //   onChanged: (text) {
    //     num = text;
    //     // print("num: $num");
    //   },
    //   onSubmitted: (text) {
    //     loadData(taskNum: num);
    //   },
    //   // focusChanged: (bool hasFocus) {
    //   //   if (!hasFocus) {}
    //   // },
    // ));
    // widgets.add(const Divider(
    //   height: 1,
    //   color: Colors.white,
    // ));
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
              "Wave Num",
              textAlign: TextAlign.center,
            )),
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Date",
              textAlign: TextAlign.center,
            )),
        Container(padding: const EdgeInsets.all(12), child: const Text(""))
      ])
    ];
    for (var ele in waves) {
      tableList.add(TableRow(
        decoration: const BoxDecoration(color: Colors.white10),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              "${ele['wave_num']}",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                "${ele['created_at'].substring(5, 10)}",
                textAlign: TextAlign.center,
              )),
          Container(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(
                      RouteStatus.outboundWaveDetailPage,
                      args: {"wave": ele});
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
      result = await OutboundDao.waitToPick();
      if (result['code'] == 0) {
        setState(() {
          waves.clear();
          waves = result['data']['outbound_waves'];
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
          waves.clear();
        });
      }
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        waves.clear();
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
