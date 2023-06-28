import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inbound_dao.dart';
import 'package:jcbls_app/model/inbound_batch.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class InboundMountListPage extends StatefulWidget {
  const InboundMountListPage({Key? key}) : super(key: key);

  @override
  State<InboundMountListPage> createState() => _InboundMountListPageState();
}

class _InboundMountListPageState extends HiState<InboundMountListPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<InboundBatch> inboundBatches = [];
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
      if (widget == current.page || current.page is InboundMountListPage) {
        // print("打开了待处理列表: onResume");
        textEditingController.clear(); // 清除搜索栏
        loadData(); // 重新加载数据
        resumeFlag = true;
      } else if (widget == pre?.page || pre?.page is InboundMountListPage) {
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
        appBar: appBar("Mount List", "", () {}),
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
      "Sku Code",
      "Scan Sku Code",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        loadData(skuCode: num);
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
      children: _batchTable(),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    ));
    return widgets;
  }

  List<TableRow> _batchTable() {
    List<TableRow> tableList = [
      TableRow(decoration: const BoxDecoration(color: Colors.grey), children: [
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "BatchNum",
              textAlign: TextAlign.center,
            )),
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "SkuCode",
              textAlign: TextAlign.center,
            )),
        Container(
            padding: const EdgeInsets.all(12),
            child: const Text(
              "QTY",
              textAlign: TextAlign.center,
            )),
        Container(padding: const EdgeInsets.all(12), child: const Text(""))
      ])
    ];
    for (var ele in inboundBatches) {
      tableList.add(TableRow(
        decoration: const BoxDecoration(color: Colors.white10),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              "${ele.batchNum}",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                "${ele.baseSku!['sku_code']}",
                textAlign: TextAlign.center,
              )),
          Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                "${ele.quantity}",
                textAlign: TextAlign.center,
              )),
          Container(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(
                      RouteStatus.inboundMountPage,
                      args: {"batch": ele});
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

  void loadData({skuCode = ""}) async {
    try {
      var result;
      if (skuCode != "") {
        result = await InboundDao.waitToMount(skuCode: skuCode);
      } else {
        result = await InboundDao.waitToMount();
      }
      if (result['code'] == 0) {
        setState(() {
          inboundBatches.clear();
          for (var item in result['data']['rec_infos']) {
            inboundBatches.add(InboundBatch.fromJson(item));
          }
          if (inboundBatches.length == 1 && skuCode != "") {
            HiNavigator.getInstance().onJumpTo(RouteStatus.inboundMountPage,
                args: {"batch": inboundBatches[0]});
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
          inboundBatches.clear();
        });
      }
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        num = "";
        inboundBatches.clear();
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
