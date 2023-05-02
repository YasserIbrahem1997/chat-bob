// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';
// import '../sherdpref/sherdprefrance.dart';

// class RecordingScreen extends StatefulWidget {
//   const RecordingScreen({Key? key}) : super(key: key);
//   @override
//   State<RecordingScreen> createState() => _RecordingScreenState();
// }

// class _RecordingScreenState extends State<RecordingScreen> {
//   final recoder = FlutterSoundRecorder();
//   bool isRecorderReady = false;

//   var audioFile;

//   Future record() async {
//     if (!isRecorderReady) return;
//     await recoder.startRecorder(toFile: 'audio');
//   }

//   sendMessage(context, String message, String receiver, chatId, bool isImage,
//       bool isRecord) {
//     String userId = CacheHelper.getData(key: 'uid');
//     FirebaseFirestore.instance.collection('chats').doc(chatId).update({
//       'messages': FieldValue.arrayUnion([
//         {
//           "message": message,
//           "isImage": isImage,
//           "isVideo": false,
//           "isRecord": isRecord,
//           'sender': userId,
//           "receiver": receiver,
//           'dateTime': Timestamp.now(),
//         }
//       ])
//     });
//   }

//   String chatId = '69b53f56-c546-415e-bc2b-85f9b48aa189';
//   var receiverId = "0qTSlsj42QhIw7PwFh4EgNC5Mvz1";
//   void uploadRecord(context, audioFile) async {
//     try {
//       String recordId = const Uuid().v4();
//       firebase_storage.FirebaseStorage.instance
//           .ref()
//           .child('record/')
//           .child(recordId)
//           .putFile(audioFile)
//           .then((value) {
//         print('qqqqqqqqq');
//         value.ref.getDownloadURL().then((value) {
//           //sendMessage(context, value, receiverId, chatId, false, true);
//         }).catchError((e) {
//           print(e.toString() + 'zzzzzzzmmmmmmmmm');
//         });
//       });
//     } catch (e) {
//       print(e.toString() + 'zzzzzzzz');
//     }
//   }

//   Future stop() async {
//     if (!isRecorderReady) return;
//     final path = await recoder.stopRecorder();
//     audioFile = File(path!);
//     uploadRecord(context, audioFile);
//     if (kDebugMode) {
//       print('===================================');
//     }

//     Navigator.pop(context);
//     if (kDebugMode) {
//       print(audioFile.toString());
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     initRecoder();
//   }

//   Future initRecoder() async {
//     final status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       throw 'Microphone Premission Not Granted';
//     }
//     await recoder.openRecorder();
//     isRecorderReady = true;

//     recoder.setSubscriptionDuration(
//       const Duration(milliseconds: 500),
//     );
//   }

//   @override
//   void dispose() {
//     recoder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           StreamBuilder<RecordingDisposition>(
//               stream: recoder.onProgress,
//               builder: (context, snapshot) {
//                 final duration =
//                     snapshot.hasData ? snapshot.data!.duration : Duration.zero;
//                 return Text(
//                   '${duration.inSeconds} s',
//                   style: const TextStyle(color: Colors.white, fontSize: 40),
//                 );
//               }),
//           const SizedBox(height: 40),
//           Center(
//             child: ElevatedButton(
//               onPressed: () async {
//                 if (recoder.isRecording) {
//                   await stop();
//                 } else {
//                   await record();
//                 }
//                 setState(() {});
//               },
//               child: Icon(
//                 recoder.isRecording ? Icons.stop : Icons.mic,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
