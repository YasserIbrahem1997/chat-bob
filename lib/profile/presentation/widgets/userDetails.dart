import 'package:bob_app/profile/data/userModel.dart';
import 'package:bob_app/rooms/data/roomModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../appConstants/colors.dart';
import '../../../sherdpref/sherdprefrance.dart';

Widget userDetails(context, UserModel userModel) {
  String userId = CacheHelper.getData(key: 'uid');
  return  Stack(alignment: Alignment.center,
    children: [
      Padding(
        padding:  EdgeInsets.only(top:(MediaQuery.of(context).size.height / 1.4-MediaQuery.of(context).size.height / 1.5)),
        child: Container(alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:   BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(color: PrimaryColor, blurRadius: 3, spreadRadius: 3)
              ]),
          height: MediaQuery.of(context).size.height / 1.5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:Column(mainAxisSize: MainAxisSize.min,)
          ),
        ),
      ),
      Positioned(top: 5,child:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              fit: BoxFit.cover,imageBuilder: (context, imageProvider) {
              return Container(    width: 70,
                height: 70,decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.white,image: DecorationImage(image: imageProvider)),);
            },
              imageUrl: userModel.image.toString(),
              errorWidget: (context, url, error) {
                return Container(    width: 80,
                  height: 80,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,boxShadow: [BoxShadow(blurRadius: 2,color: PrimaryColor)]),child:const  Icon(Icons.person,color: PrimaryColor,),);
              },
            ),
            const SizedBox(height: 8,),
            Text(
              userModel.name.toString(),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),)
    ],
  );
}
