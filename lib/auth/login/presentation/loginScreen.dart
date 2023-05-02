// import 'package:bob_app/auth/login/bloc/login_cubit.dart';
// import 'package:bob_app/auth/login/services/loginProvider.dart';
// import 'package:bob_app/auth/register/presentation/registerScreen.dart';
// import 'package:bob_app/nav_bar/nav_bar.dart';
// import 'package:bob_app/profile/presentation/account_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';

// import '../../../search_screen/presentation/SearchPage.dart';
// import '../../../sherdpref/sherdprefrance.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     GlobalKey<FormState> formKey = GlobalKey();
//     TextEditingController emailController = TextEditingController();
//     TextEditingController passwordController = TextEditingController();
//     var cubit = LoginCubit().get(context);
//     return Scaffold(
//       backgroundColor: Colors.lightBlue,
//       body: Form(
//         key: formKey,
//         child: BlocConsumer<LoginCubit, LoginState>(
//           listener: (context, state) {
//             if (state is LoginError) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ));
//             } else if (state is LoggedIn) {
//               CacheHelper.saveData(key: "uid", value: state.user.uid);
//               WidgetsBinding.instance.addPostFrameCallback(
//                 (_) {
//                   Navigator.of(context).pushReplacement(MaterialPageRoute(
//                     builder: (context) => BottomTapBar(),
//                   ));
//                 },
//               );
//             }
//           },
//           builder: (context, state) {
//             if (state is LoginLoading) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else {
//               return SingleChildScrollView(
//                 child: Center(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 350,
//                         width: double.infinity,
//                         child: Stack(
//                           children: [
//                             Container(
//                               height: 200.0,
//                               //width: double.infinity,
//                               decoration: const BoxDecoration(
//                                 image: DecorationImage(
//                                   image: AssetImage(
//                                       'assets/images/profile_top.png'),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                             ),
//                             const Positioned(
//                               top: 70,
//                               left: 50,
//                               child: Text(
//                                 'Profile',
//                                 style: TextStyle(
//                                   fontSize: 25,
//                                   color: Colors.white,
//                                 ),
//                                 textAlign: TextAlign.end,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               keyboardType: TextInputType.emailAddress,
//                               controller: emailController,
//                               decoration: const InputDecoration(
//                                 hintText: 'email',
//                                 hintStyle: TextStyle(color: Colors.white),
//                                 fillColor: Colors.white,
//                                 counterStyle: TextStyle(color: Colors.white),
//                                 labelStyle: TextStyle(color: Colors.white),
//                                 enabledBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Colors.white), //<-- SEE HERE
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value != null) {
//                                   if (value.isNotEmpty) {
//                                     return null;
//                                   }
//                                 } else
//                                   return 'please enter corrent email';
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             TextFormField(
//                               obscureText: cubit.isPassword,
//                               controller: passwordController,
//                               decoration: InputDecoration(
//                                 hintText: 'Password',
//                                 suffixIcon: IconButton(
//                                     onPressed: () {
//                                       cubit.ChangePasswordVisibility();
//                                     },
//                                     icon: Icon(cubit.suffix)),
//                                 hintStyle: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.normal),
//                                 fillColor: Colors.white,
//                                 counterStyle:
//                                     const TextStyle(color: Colors.white),
//                                 labelStyle:
//                                     const TextStyle(color: Colors.white),
//                                 enabledBorder: const UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Colors.white), //<-- SEE HERE
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value != null) {
//                                   if (value.isNotEmpty) {
//                                     return null;
//                                   }
//                                 } else {
//                                   return 'please enter correct password';
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               height: 50,
//                               width: 300,
//                               child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 0,
//                                     primary: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     BlocProvider.of<LoginCubit>(context,
//                                             listen: false)
//                                         .login(emailController.text,
//                                             passwordController.text);
//                                   },
//                                   child: const Text(
//                                     'Login',
//                                     style: TextStyle(color: Colors.blue),
//                                   )),
//                             ),
//                             const SizedBox(height: 30),
//                             TextButton(
//                                 onPressed: () {},
//                                 child: const Text('Forgot password?',
//                                     style: TextStyle(color: Colors.white))),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context)
//                                     .pushReplacement(MaterialPageRoute(
//                                   builder: (context) => const RegisterScreen(),
//                                 ));
//                               },
//                               child: const Text(
//                                 'Create account',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.normal,
//                                     decoration: TextDecoration.underline),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
