import 'package:bob_app/appConstants/colors.dart';
import 'package:bob_app/recharge/data/packageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'as UrlLauncher;

import '../../sherdpref/sherdprefrance.dart';
class PackagesScreen extends StatelessWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recharge')),
      body: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15,),
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('packages').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                List docs = snapshot.data!.docs;
                return Container(color: Colors.white,
                  child: ListView.separated(shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        PackageModel package = PackageModel.fromJson(
                            docs[index].data() as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal:15.0,vertical: 10.0),
                          child: InkWell(onTap: () async{
                            int phone = 01099649169;
                            String uid=CacheHelper.getData(key: 'uid');
                            var whatsappUrl = Uri.parse("whatsapp://send?phone=+20$phone&text=${Uri.encodeComponent('i want to buy ${package.coins} coin uid is:${uid}')}");

                            await UrlLauncher.canLaunchUrl(whatsappUrl) != null
                                ? UrlLauncher.launchUrl(whatsappUrl)
                                :  ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("WhatsApp is not installed on the device"),
                              ),
                            );
                          },
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                               const  Icon(
                                    Icons.monetization_on,
                                    color: Colors.amber,
                                  ),
                                  Text(package.coins.toString())
                                ]),
                                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),shape: BoxShape.rectangle,color: Colors.white,border:Border.all(color: PrimaryColor,width: 1)),child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('EGP ${package.cash}',style:const TextStyle(color: PrimaryColor,fontWeight: FontWeight.bold)),
                                ),)
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: PrimaryColor,
                        );
                      },
                      itemCount: docs.length),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          )
        ],
      )),
    );
  }
}
