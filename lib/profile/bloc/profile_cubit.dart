import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../sherdpref/sherdprefrance.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  static ProfileCubit get(context) => BlocProvider.of(context);

  final ImagePicker picker = ImagePicker();
  String imagePath = '';
  File? imageFile;

  Future<void> getProfileImage(userID) async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        imagePath = image.path;
        imageFile = File(image.path);
        String imageName = '$userID.jpg';
        print('DownLoad Link : $userID');
        uploadProfileImage(imageName, userID.toString());
        emit(ProfileImagePickedSuccess());
      } else {
        print("No Image Selected");
      }
    } catch (e) {
      emit(ProfileImagePickedError());
    }
  }

// this fut with uplode image in fairbase

  void uploadProfileImage(imageName, userId) async {
    try {
      emit(UploadImageToFireBaseLoding());
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/')
          .child(imageName)
          .putFile(imageFile!)
          .then((value) {
        emit(UploadImageToFireBaseSacsec());
        value.ref.getDownloadURL().then((value) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'image': value});
        }).catchError((e) {
          emit(UploadImageToFireBaseErorre());
          if (kDebugMode) {
            print(e.toString() + 'zzzzzzzz');
          }
        });
      });
    } catch (e) {
      emit(UploadImageToFireBaseErorre());
      if (kDebugMode) {
        print(e.toString() + 'zzzzzzzz');
      }
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    CacheHelper.removeData(key: 'uid');
  }
}
