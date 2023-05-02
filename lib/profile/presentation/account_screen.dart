import 'dart:io';

import 'package:bob_app/auth/login/presentation/loginScreen.dart';
import 'package:bob_app/profile/bloc/profile_cubit.dart';
import 'package:bob_app/profile/presentation/profile_screen.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../nav_bar/nav_bar.dart';
import '../../recharge/presentation/packages.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userID = CacheHelper.getData(key: 'uid');
    List<IconData> icons = [
      Icons.account_balance_wallet_outlined,
      Icons.folder_open,
      Icons.workspace_premium_outlined,
    ];
    List<String> titels = [
      'My Wallet',
      'My Files',
      'My Noble',
    ];
    List<Color> colors = const [
      Color(0xFF08AD17),
      Color(0xFFFDA400),
      Color(0xFFB49312),
    ];

    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = ProfileCubit.get(context);
          var userUid = CacheHelper.getData(key: 'uid');
          var imageProfile = cubit.imagePath;
          return Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.grey.withOpacity(0),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () {
                  navigateAndFinish(context, BottomTapBar());
                },
              ),
              title: Text(
                "Me",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                InkWell(
                  //onTap: () => navigateTo(context, const ProfileScreen()),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userID)
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                    height: 75,
                                    width: 75,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 160, 158, 158),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: snapshot.data['image']
                                              .toString()
                                              .isEmpty
                                          ? Image.asset(
                                              'assets/images/person.svg.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              "${snapshot.data['image']}",
                                            ),
                                    ));
                              } else {
                                return const CircularProgressIndicator(
                                  color: Color.fromARGB(255, 169, 74, 80),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userID)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data['name'],
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userID)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return const Text(
                                      "Phone:+",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    // this button in Settings
                    InkWell(
                      onTap: () {
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 13, bottom: 13),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 25),
                                  Text(
                                    "Settings",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 2,
                          right: 15,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => profileItem(
                              icons[index], titels[index], colors[index], () {
                                if(index==0){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PackagesScreen(),));

                                }
                              }),
                          itemCount: icons.length,
                          separatorBuilder: (context, index) => myDivider(),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    top: 5.0,
                    bottom: 10.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 13, bottom: 13),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.share_outlined,
                                color: Colors.blue,
                                size: 30,
                              ),
                              const SizedBox(width: 20),
                              const Text(
                                "Share App",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                        myDivider(),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.feedback_outlined,
                                color: Colors.blue,
                                size: 30,
                              ),
                              const SizedBox(width: 20),
                              const Text(
                                "Help & FeedBack",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  print("acteved");
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileItem(icon, titel, color, onTap) => InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0),
            radius: 18,
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          title: Text(
            titel,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
}

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 55.0,
        end: 0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (Route<dynamic> route) => false,
    );

/*Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 125, 196, 232),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                ),



                StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userID)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return
                            Container(
                              height: 200.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(snapshot.data['image']),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),




*/