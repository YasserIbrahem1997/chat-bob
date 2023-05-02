import 'package:flutter/material.dart';

class NavBarNotifier extends ChangeNotifier{
  int pageIndex=0;
  List<bool> selections = [true,false,false];
  int seatIndex=0;
  int seatNum=3;
  setIndex(index){
    print(index.toString());
    pageIndex=index;
    notifyListeners();
  }

  selectSeat(index){
    selections = List.generate(3, (_) => false);
      selections[index] = !selections[index];
      seatIndex=index;
      notifyListeners();

  }

 int getSeatNumber(){
    switch(seatIndex){
      case 0:
        return 3;
      case 1:
      return 6;
      case 2:
        return 9;
      default:
        return 9;
    }
 }

}