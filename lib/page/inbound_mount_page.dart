import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inbound_dao.dart';
import 'package:jcbls_app/model/inbound_batch.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'package:jcbls_app/widget/appbar.dart';
import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/login_button.dart';
import 'package:jcbls_app/widget/scan_input.dart';

class InboundMountPage extends StatefulWidget {
  final InboundBatch inboundBatch;
  const InboundMountPage(this.inboundBatch, {Key? key}) : super(key: key);

  @override
  State<InboundMountPage> createState() => _InboundMountPageState();
}

class _InboundMountPageState extends HiState<InboundMountPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? spaceNum;
  bool canSubmit = true;
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      // print("controller: ${textEditingController.text}");
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Inbound Mount", "", () {}),
      body: LoadingContainer(
        cover: true,
        isLoading: _isLoading,
        child: ListView(
          children: _buildWidget(),
        ),
      ),
    );
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ListTile(
      title: const Text("Batch Num: "),
      subtitle: Text("${widget.inboundBatch.batchNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Sku Code: "),
      subtitle: Text("${widget.inboundBatch.baseSku!['sku_code']}"),
    ));
    widgets.add(ListTile(
      title: const Text("Name: "),
      subtitle: Text("${widget.inboundBatch.baseSku!['en_name']}"),
    ));
    widgets.add(ListTile(
      title: const Text("Quantity: "),
      subtitle: Text("${widget.inboundBatch.quantity}"),
    ));
    widgets.add(ListTile(
      title: const Text("Allocation Space: "),
      subtitle: Text("${widget.inboundBatch.spaceNum}"),
    ));
    widgets.add(ScanInput(
      "Shelf",
      "Scan Shelf's Barcode",
      focusNode,
      textEditingController,
      onChanged: (text) {
        spaceNum = text;
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
    return widgets;
  }

  _mount() async {
    setState(() {
      canSubmit = false;
      _isLoading = true;
    });
    dynamic result;
    try {
      if (spaceNum != null && spaceNum != "") {
        result =
            await InboundDao.mountOperate(widget.inboundBatch.id, spaceNum!);
      } else {
        result = await InboundDao.mountOperate(
            widget.inboundBatch.id, widget.inboundBatch.spaceNum!);
      }
      setState(() {
        _isLoading = false;
      });
      if (result["code"] == 0) {
        player.play('sounds/success01.mp3');
        showToast("Mount Successful");
      } else {
        player.play('sounds/alert.mp3');
        showWarnToast(result['reason'].join(","));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.inboundMountListPage);
  }
}
