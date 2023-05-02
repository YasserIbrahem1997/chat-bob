import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bob_app/appConstants/colors.dart';
import 'package:bob_app/auth/login/bloc/login_cubit.dart';
import 'package:bob_app/auth/register/bloc/register_cubit.dart';
import 'package:bob_app/chat/bloc/messages_cubit.dart';
import 'package:bob_app/sherdpref/sherdprefrance.dart';
import 'package:bob_app/nav_bar/service/navBarNotifier.dart';
import 'package:bob_app/rooms/bloc/room_cubit.dart';

import 'package:bob_app/videoCalls/bloc/video_call_cubit.dart';
import 'package:bob_app/voiceCalls/bloc/voice_call_cubit.dart';
import 'package:bob_app/zegoManager/zegoVoiceCubit/zego_voice_cubit.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'auth/login/presentation/login_with_number.dart';
import 'auth/login/presentation/otp.dart';
import 'nav_bar/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await CacheHelper.init();
  var uId = CacheHelper.getData(key: 'uid');
  Widget? widget;

  if (uId != null) {
    widget = const BottomTapBar();
  } else {
    widget = const LoginWithNumber();
  }

  runApp(MyApp(
    startWidget: widget,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.startWidget}) : super(key: key);
  final Widget startWidget;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterCubit(),
        ),
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => MessagesCubit()),
        BlocProvider(create: (context) => VideoCallCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(
          create: (context) => RegisterCubit(),
        ),
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) => MessagesCubit(),
        ),
        BlocProvider(
          create: (context) => VideoCallCubit(),
        ),
        BlocProvider(
          create: (context) => VoiceCallCubit(),
        ),
        BlocProvider(create: (context) => RoomCubit()),
        BlocProvider(create: (context) => ZegoVoiceCubit()),
        ChangeNotifierProvider(
          create: (context) => NavBarNotifier(),
        ),

      ],
      child: MaterialApp(color: PrimaryColor,theme: ThemeData(appBarTheme: AppBarTheme(backgroundColor: PrimaryColor,titleTextStyle: TextStyle(color: Colors.white,fontSize: 17)),iconTheme: IconThemeData(color: Colors.white)),
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          backgroundColor: const Color.fromARGB(255, 254, 254, 254),
          splash: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/splach.png",
                  // fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          nextScreen: startWidget,
          splashIconSize: double.infinity,
          splashTransition: SplashTransition.fadeTransition,
          duration: 3000,
        ),
      ),
    );
  }
}
