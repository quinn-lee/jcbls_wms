import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inventory_dao.dart';
import 'package:jcbls_app/util/string_util.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/login_button.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class InventoryCheckOperatePage extends StatefulWidget {
  final Map checkTask;
  const InventoryCheckOperatePage(this.checkTask, {Key? key}) : super(key: key);

  @override
  State<InventoryCheckOperatePage> createState() =>
      _InventoryCheckOperatePageState();
}

class _InventoryCheckOperatePageState
    extends HiState<InventoryCheckOperatePage> {
  String? num;
  int countingQuantity = 0;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  bool submitEnable = false;
  List<Map> resultShow = [];
  List? skus;
  AudioCache player = AudioCache();
  bool _isLoading = false;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      skus = widget.checkTask['infos'];
      setDataRow(skus!);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    focusNode1.dispose();
    textEditingController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sku Scan(${widget.checkTask['space_num']})'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: ListView(
            children: _buildWidget(),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Sku",
      "Scan Sku Number",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
      },
      onSubmitted: (text) {
        checkInput();
      },
    ));
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));
    widgets.add(ScanInput(
      "Counting Quantity",
      "Counting Quantity",
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        try {
          if (isNotEmpty(text) && text != "") {
            countingQuantity = int.parse(text);
          } else {
            countingQuantity = 0;
          }
        } catch (e) {
          countingQuantity = 0;
        }

        checkInput();
      },
    ));

    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Submit',
        1,
        enable: submitEnable,
        onPressed: operate,
      ),
    ));

    for (var element in resultShow.reversed) {
      widgets.add(ListTile(
        title: Text(
          element['show'],
          style: const TextStyle(color: Colors.white),
        ),
        tileColor: element['status']
            ? const Color(0xFF4e72b8)
            : const Color(0xFFf15b6c),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    widgets.add(DataTable(columns: const [
      DataColumn(label: Text('Sku Code')),
      // DataColumn(
      //   label: Text('Name'),
      // ),
      DataColumn(
        label: Text('Total Quantity'),
      ),
    ], rows: dataRows));
    return widgets;
  }

  // 构建表格数据
  void setDataRow(List<dynamic> data) {
    dataRows.clear();
    for (int i = 0; i < data.length; i++) {
      dataRows.add(DataRow(
        cells: [
          DataCell(SelectableText('${data[i]['sku_code']}')),
          // DataCell(Text('${data[i]['name_en']}')),
          DataCell(Text('${data[i]['after_quantity']}')),
        ],
      ));
    }
  }

  // 验证输入是否可以提交
  void checkInput() {
    bool enable;
    if (isNotEmpty(num) && countingQuantity > 0) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      submitEnable = enable;
    });
  }

  // 提交
  void operate() async {
    dynamic result;
    setState(() {
      submitEnable = false; // 防止重复提交
      _isLoading = true;
    });
    try {
      if (num != null && num != "" && countingQuantity > 0) {
        var result = await InventoryDao.checkOperate(
            widget.checkTask['id'], num!, countingQuantity);

        if (result['code'] == 0) {
          setState(() {
            _isLoading = false;
            skus = result['data']['check_task']['infos'];
            setDataRow(skus!);
            resultShow.add({
              "status": true,
              "show":
                  "Submit Success ! Sku Num : ${num ?? ''} , quantity : $countingQuantity"
            });
          });
          player.play('sounds/success01.mp3');
        } else {
          // print(result['reason']);
          showWarnToast(result['message'].join(","));
          setState(() {
            _isLoading = false;
            resultShow
                .add({"status": false, "show": result['message'].join(",")});
          });
          player.play('sounds/alert.mp3');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
    }
    if (mounted) {
      textEditingController.clear();
      textEditingController1.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
    setState(() {
      countingQuantity = 0;
      num = "";
    });
  }
}
