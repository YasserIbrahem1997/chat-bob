import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier{
  bool visible=false;
  togglePassword(){
    visible=!visible;
  }
}