import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/transfer_dao.dart';
import 'package:jcbls_app/util/string_util.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/login_button.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class TransferMountPage extends StatefulWidget {
  final String spaceNum;
  const TransferMountPage(this.spaceNum, {Key? key}) : super(key: key);

  @override
  State<TransferMountPage> createState() => _TransferMountPageState();
}

class _TransferMountPageState extends HiState<TransferMountPage> {
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  final TextEditingController textEditingController2 = TextEditingController();
  FocusNode focusNode2 = FocusNode();
  String? skuNum;
  int? maxQty;
  int? quantity;
  bool canSubmit = false;
  bool _isLoading = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Transfer(${widget.spaceNum})", "", () {}),
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
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        skuNum = text;
        // print("num: $num");
        checkInput();
      },
      onSubmitted: (text) {
        if (isNotEmpty(skuNum)) {
          _getMaxQty(skuNum!);
        } else {
          showWarnToast("Please Scan Sku Code");
        }
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    if (maxQty != null) {
      widgets.add(ListTile(
        title: const Text("Max Quantity: "),
        subtitle: Text("$maxQty"),
      ));
    }
    widgets.add(ScanInput(
      "Mount Quantity",
      "Mount Quantity",
      focusNode2,
      textEditingController2,
      onChanged: (text) {
        if (isNotEmpty(text) && text != "") {
          quantity = int.parse(text);
        } else {
          quantity = 0;
        }
        checkInput();
      },
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Mount',
        1,
        enable: canSubmit,
        onPressed: _mount,
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
    return widgets;
  }

  void _getMaxQty(String skuNum) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var result;
      result = await TransferDao.getMaxMountQty(skuNum);
      if (result['code'] == 0) {
        setState(() {
          _isLoading = false;
          maxQty = 0;
          for (Map ele in result['data']) {
            maxQty = (maxQty! + ele['max_mount_quantity']) as int?;
          }
          quantity = maxQty;
          textEditingController2.text = quantity.toString();
        });
        if (mounted) {
          FocusScope.of(context).requestFocus(focusNode2);
        }
        checkInput();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mount() async {
    setState(() {
      _isLoading = true;
      canSubmit = false;
    });
    try {
      var result;
      result = await TransferDao.mount(skuNum!, widget.spaceNum, quantity!);
      if (result['code'] == 0) {
        showToast("Transfer Mount Successful");
        var now = DateTime.now();
        setState(() {
          _isLoading = false;
          resultShow.add({
            "status": true,
            "show":
                "${now.hour}:${now.minute}:${now.second} - Succeeded! $skuNum"
          });
        });
        player.play('sounds/success01.mp3');
      } else {
        showWarnToast(result['message'].join(","));
        setState(() {
          _isLoading = false;
          resultShow
              .add({"status": false, "show": result['message'].join(",")});
        });
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    setState(() {
      skuNum = null;
      _isLoading = false;
      maxQty = null;
      quantity = null;
    });
    if (mounted) {
      textEditingController1.clear();
      textEditingController2.clear();
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  checkInput() {
    if (isNotEmpty(skuNum) && quantity != null && quantity! > 0) {
      setState(() {
        canSubmit = true;
      });
    } else {
      setState(() {
        canSubmit = false;
      });
    }
  }
}
