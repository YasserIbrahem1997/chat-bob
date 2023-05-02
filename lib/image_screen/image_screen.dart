import 'package:flutter/material.dart';

import '../chat/data/chatModel.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({Key? key, this.messageModel}) : super(key: key);
  final MessageModel? messageModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: ((details) {
        Navigator.pop(context);
      }),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.network(
              messageModel!.image.toString(),
            )),
      ),
    );
  }
}