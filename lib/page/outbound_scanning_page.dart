import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/outbound_dao.dart';
import 'package:jcbls_app/util/string_util.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class OutboundScanningPage extends StatefulWidget {
  const OutboundScanningPage({Key? key}) : super(key: key);

  @override
  State<OutboundScanningPage> createState() => _OutboundScanningPageState();
}

class _OutboundScanningPageState extends HiState<OutboundScanningPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Outbound Scanning", "", () {}),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: Container(
            child: ListView(children: _buildWidget()),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [
      ScanInput(
        "Shipment Num",
        "",
        focusNode,
        textEditingController,
        onChanged: (text) {
          num = text;
        },
        onSubmitted: (text) {
          if (isNotEmpty(num)) {
            _submit(num!);
          } else {
            showWarnToast("Please Scan Shipment Num");
          }
        },
      )
    ];
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
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

  void _submit(String unum) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String newShipmentNum = matchShipmentNum(unum);
      var result = await OutboundDao.scanning(newShipmentNum);
      if (result['code'] == 0) {
        if (result['data']['scan_log']['level'] != 'error') {
          showToast("Outbound Scanning Successful");
          var now = DateTime.now();
          setState(() {
            _isLoading = false;
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second} - $newShipmentNum,${result['data']['scan_log']['remark']}"
            });
          });
          player.play('sounds/success01.mp3');
        } else {
          showWarnToast(result['data']['scan_log']['remark']);
          setState(() {
            _isLoading = false;
            resultShow.add({
              "status": false,
              "show": result['data']['scan_log']['remark']
            });
          });
          player.play('sounds/alert.mp3');
        }
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
      num = null;
    });
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
