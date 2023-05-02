// import 'package:bob_app/auth/login/presentation/loginScreen.dart';
// import 'package:bob_app/auth/register/bloc/register_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../search_screen/widgets/componants.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     GlobalKey<FormState> formKey = GlobalKey();
//     TextEditingController nameController = TextEditingController();
//     TextEditingController emailController = TextEditingController();
//     TextEditingController passwordController = TextEditingController();
//     return Scaffold(
//       body: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         child: Form(
//             key: formKey,
//             child: BlocConsumer<RegisterCubit, RegisterState>(
//               builder: (context, state) {
//                 if (state is RegisterLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else {
//                   return Column(children: [
//                     SizedBox(
//                       height: 350,
//                       width: double.infinity,
//                       child: Stack(
//                         children: [
//                           Container(
//                             height: 200.0,
//                             width: double.infinity,
//                             decoration: const BoxDecoration(
//                               image: DecorationImage(
//                                 image:
//                                     AssetImage('assets/images/profile_top.png'),
//                                 fit: BoxFit.fill,
//                               ),
//                             ),
//                           ),
//                           const Positioned(
//                             top: 70,
//                             left: 50,
//                             child: Text(
//                               'Register',
//                               style: TextStyle(
//                                 fontSize: 25,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.end,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     textForm(nameController, 'Name', 10, TextInputType.name),
//                     const SizedBox(height: 15),
//                     textForm(emailController, 'Email', 10,
//                         TextInputType.emailAddress),
//                     const SizedBox(height: 15),
//                     textForm(passwordController, 'Password', 10,
//                         TextInputType.visiblePassword),
//                     const SizedBox(height: 15),
//                     ElevatedButton(
//                         onPressed: () {
//                           if (formKey.currentState!.validate()) {
//                             BlocProvider.of<RegisterCubit>(context,
//                                     listen: false)
//                                 .register(
//                                     email: emailController.text,
//                                     name: nameController.text,
//                                     password: passwordController.text);
//                           }
//                         },
//                         child: Text("Register")),
//                     TextButton(
//                         onPressed: () {
//                           Navigator.of(context)
//                               .pushReplacement(MaterialPageRoute(
//                             builder: (context) => LoginScreen(),
//                           ));
//                         },
//                         child: const Text('already have an account?Login'))
//                   ]);
//                 }
//               },
//               listener: (context, state) {
//                 if (state is RegisterError) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message),
//                     backgroundColor: Colors.red,
//                   ));
//                 } else if (state is Registered) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => LoginScreen(),
//                         ));
//                   });
//                 }
//               },
//             )),
//       ),
//     );
//   }
// }
