import 'package:bob_app/auth/login/bloc/login_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/login/presentation/loginScreen.dart';
import '../../../sherdpref/sherdprefrance.dart';
import '../../bloc/profile_cubit.dart';
import '../../data/userModel.dart';

Widget profileImageWidget(context) {
  var cubit = ProfileCubit.get(context);
  var userId = CacheHelper.getData(key: 'uid');
  var imageProfile = cubit.imagePath;
  return Align(
    alignment: Alignment.bottomCenter,
    child: InkWell(
      onTap: () {
        cubit.getProfileImage(userId);
      },
      child: SizedBox(
        width: 170,
        height: 200,
        child: Card(
          elevation: 20,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                UserModel user = UserModel.fromJson(
                    snapshot.data!.data() as Map<String, dynamic>);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 160, 158, 158),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: user.image.toString(),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: ((context, url, error) => Image.asset(
                                'assets/images/person.svg.png',
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(user.name.toString()),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    ),
  );
}

Widget profileItem(context, index) {
  return InkWell(
    onTap: () {
      profileItemsOnTap(context, index);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors[index],
          radius: 18,
          child: Icon(
            icons[index],
            color: Colors.white,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        title: Text(titles[index]),
      ),
    ),
  );
}

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
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

List<Color> colors = const [
  Color.fromARGB(255, 95, 197, 185),
  Color.fromARGB(255, 113, 196, 221),
  Color.fromARGB(255, 200, 122, 33),
  Color.fromARGB(255, 104, 198, 107),
  Color.fromARGB(255, 179, 19, 72),
];

List<IconData> icons = [
  Icons.person,
  Icons.chat,
  Icons.notification_add,
  Icons.help,
  Icons.logout,
];
List<String> titles = [
  'Account',
  'Chat',
  'Notifications',
  'Help Center',
  'Logout',
];

profileItemsOnTap(context, int index) {
  LoginCubit cubit = BlocProvider.of<LoginCubit>(context, listen: false);
  switch (index) {
    case 4:
      {
        //cubit.logout();
        // navigateAndFinish(context, const LoginScreen());
      }
  }
}
