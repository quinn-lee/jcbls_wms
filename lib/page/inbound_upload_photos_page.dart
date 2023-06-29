import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcbls_app/core/hi_state.dart';
import 'package:jcbls_app/http/dao/inbound_dao.dart';
import 'package:jcbls_app/model/inbound_task.dart';
import 'package:jcbls_app/navigator/hi_navigator.dart';
import 'package:jcbls_app/util/toast.dart';
import 'dart:io';
import 'dart:convert';

import 'package:jcbls_app/widget/loading_container.dart';
import 'package:jcbls_app/widget/login_button.dart';

class InboundUploadPhotosPage extends StatefulWidget {
  final InboundTask inboundTask;
  const InboundUploadPhotosPage(this.inboundTask, {Key? key}) : super(key: key);

  @override
  State<InboundUploadPhotosPage> createState() =>
      _InboundUploadPhotosPageState();
}

class _InboundUploadPhotosPageState extends HiState<InboundUploadPhotosPage> {
  List<File> _images = [];
  bool submitEnable = false;
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  Future getImage(bool isTakePhoto) async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: isTakePhoto ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 20); // 图片压缩
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
        submitEnable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Pictures'),
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
          child: ListView(children: _buildListView())),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Select Pictures',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  List<Widget> _buildListView() {
    List<Widget> widgets = [];

    widgets.add(ListTile(
      title: const Text("Inbound Num: "),
      subtitle: Text("${widget.inboundTask.taskNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Customer: "),
      subtitle: Text("${widget.inboundTask.org!['abbr_code']}"),
    ));
    widgets.add(ListTile(
      title: const Text("Pictures: "),
      subtitle: _images.isEmpty ? const Text("No Pictures") : const Text(""),
    ));
    widgets.add(Center(
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: _genImages(),
      ),
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Upload',
        1,
        enable: submitEnable,
        onPressed: upload,
      ),
    ));
    return widgets;
  }

  _pickImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            height: 160,
            child: Column(
              children: <Widget>[
                _item('Photo', true),
                _item('Select Pictures', false)
              ],
            )));
  }

  _item(String title, bool isTakePhoto) {
    return GestureDetector(
      child: ListTile(
        leading: Icon(isTakePhoto ? Icons.camera_alt : Icons.photo_library),
        title: Text(title),
        onTap: () => getImage(isTakePhoto),
      ),
    );
  }

  _genImages() {
    return _images.map((file) {
      return Stack(
        children: <Widget>[
          ClipRRect(
            //圆角效果
            borderRadius: BorderRadius.circular(5),
            child: Image.file(file, width: 120, height: 90, fit: BoxFit.fill),
          ),
          Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.remove(file);
                    if (_images.isEmpty) {
                      submitEnable = false;
                    }
                  });
                },
                child: ClipOval(
                  //圆角删除按钮
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ],
      );
    }).toList();
  }

  void upload() async {
    setState(() {
      submitEnable = false; // 防止重复提交
      _isLoading = true;
    });
    List attachments = [];
    int index = 1;
    try {
      for (var img in _images) {
        final bytes = img.readAsBytesSync();
        // print(bytes.lengthInBytes);
        attachments.add({
          "i": index++,
          "filename": img.path.split("/").last,
          "content": base64.encode(bytes),
        });
      }
      // print(attachments);

      var result = await InboundDao.uploadPhotos(
          widget.inboundTask.id, attachments, "depot");
      setState(() {
        _isLoading = false;
      });
      if (result['code'] == 0) {
        showToast("Upload Pictures Successful");
        player.play('sounds/success01.mp3');
      } else {
        showWarnToast(result['message'].join(","));
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // print(e);
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.inboundTasksPage);
  }
}
