// import 'package:bob_app/profile/presentation/profileScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../../appConstants/widgets/loadingPage.dart';
// import '../../search_screen/widgets/componants.dart';
// import '../../sherdpref/sherdprefrance.dart';
// import '../widgets/componants.dart';
//
// class SearchPage extends StatefulWidget {
//   SearchPage({Key? key}) : super(key: key);
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   var searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     String userId = CacheHelper.getData(key: 'uid');
//
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(
//             height: 230,
//             width: double.infinity,
//             child: Stack(
//               children: [
//                 Container(
//                   height: 200.0,
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/images/profile_top.png'),
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 70,
//                   left: 50,
//                   child: Text(
//                     'Chat',
//                     style: TextStyle(
//                       fontSize: 25,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.end,
//                   ),
//                 ),
//                 Positioned(
//                   top: 150,
//                   left: 30,
//                   child: textForm(searchController, 'Search', 5),
//                 )
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Color(0xff00D3C1),
//                       maxRadius: 40,
//                       minRadius: 40,
//                       child: Icon(
//                         Icons.person_add,
//                         color: Colors.white,
//                       ),
//                     ),
//                     title: Text(
//                       'Add contact',
//                       style:
//                           TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('users')
//                         .where('userId', isNotEqualTo: userId)
//                         .snapshots(),
//                     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasData) {
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: snapshot.data!.docs.length,
//                           itemBuilder: (context, index) {
//                             return labelChat(snapshot.data!.docs[index]['name'],
//                                 snapshot.data!.docs[index]['userId'], context);
//                           },
//                         );
//                       } else {
//                         return const LoadingPage();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
