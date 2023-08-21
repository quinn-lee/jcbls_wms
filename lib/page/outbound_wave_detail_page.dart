import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class OutboundWaveDetailPage extends StatefulWidget {
  final Map wave;
  const OutboundWaveDetailPage(this.wave, {Key? key}) : super(key: key);

  @override
  State<OutboundWaveDetailPage> createState() => _OutboundWaveDetailPageState();
}

class _OutboundWaveDetailPageState extends HiState<OutboundWaveDetailPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List _pickInfos = [];
  String? _num;
  bool _isLoading = true;
  AudioCache player = AudioCache();
  int? _sortColumn;
  bool _sortAscending = true;
  Function(int, bool)? _sortCallback;
  var listener;

  @override
  void initState() {
    super.initState();
    setState(() {
      _pickInfos = widget.wave['pick_infos'];
      _isLoading = false;
      _sortCallback = (int column, bool isAscending) {
        setState(() {
          _sortColumn = column;
          _sortAscending = isAscending;
        });
      };
    });
  }

  @override
  void dispose() {
    // HiNavigator.getInstance().removeListener(listener!);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("${widget.wave['wave_num']}", "", () {}),
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
      "ShpmtNum/Sku",
      "Scan ShpmtNum Or SkuNum",
      focusNode,
      textEditingController,
      onChanged: (text) {
        _num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        loadData(_num);
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    widgets.add(_createDataTable());
    return widgets;
  }

  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(),
      horizontalMargin: 10.0,
      showBottomBorder: true,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumn,
      columnSpacing: 10,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(label: const Text('SpaceNum'), onSort: _sortCallback),
      DataColumn(label: const Text('SkuNum'), onSort: _sortCallback),
      DataColumn(label: const Text('ShpmtNum'), onSort: _sortCallback)
    ];
  }

  List<DataRow> _createRows() {
    _pickInfos.sort((d1, d2) {
      bool isAscending = _sortAscending;
      var result = 0;
      if (_sortColumn == 0) {
        result = d1['space_num'].compareTo(d2['space_num']);
      }
      if (_sortColumn == 1) {
        result = d1['sku_code'].compareTo(d2['sku_code']);
      }
      if (_sortColumn == 2) {
        result = d1['shpmt_num'].compareTo(d2['shpmt_num']);
      }

      if (isAscending) {
        return result;
      }

      return -result;
    });
    return _pickInfos
        .map((pick) => DataRow(cells: [
              DataCell(Text(pick['space_num'].toString())),
              DataCell(Text(pick['sku_code'])),
              DataCell(Text(pick['shpmt_num']))
            ]))
        .toList();
  }

  void loadData(String? num) async {
    try {
      List newPickInfos = [];
      if (num == "" || num == null) {
        newPickInfos = widget.wave['pick_infos'];
      } else {
        if (num.length == 28 && num.substring(0, 1) == '%') {
          for (var pick in widget.wave['pick_infos']) {
            if (pick['shpmt_num'] == num.substring(8, 22)) {
              newPickInfos.add(pick);
            }
          }
        } else if (num.startsWith("0145") ||
            num.startsWith("0998") ||
            num.startsWith("0147") ||
            num.startsWith("0150") ||
            num.startsWith("0159") ||
            num.startsWith("053") ||
            num.startsWith("094")) {
          for (var pick in widget.wave['pick_infos']) {
            if (pick['shpmt_num'] == num) {
              newPickInfos.add(pick);
            }
          }
        } else {
          for (var pick in widget.wave['pick_infos']) {
            if (pick['sku_code'] == num) {
              newPickInfos.add(pick);
            }
          }
        }
      }
      setState(() {
        _pickInfos = newPickInfos;
      });
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
    }
    setState(() {
      _num = "";
    });
    if (mounted) {
      textEditingController.clear(); // 清除搜索栏
      FocusScope.of(context).requestFocus(focusNode); //聚焦
    }
  }

  @override
  bool get wantKeepAlive => true;
}
