import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../profile/presentation/account_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

//for the top 3
List<IconData> icons = [
  Icons.whatsapp,
  Icons.person_add,
  Icons.chat_bubble,
];
List<String> titels = [
  'Invite Friends',
  'New Contacts',
  'Create new Group',
];
List<Color> colors = const [
  Color(0xFF08AD17),
  Color(0xFFFDA400),
  Color(0xFFB49312),
];
//for the netx 3
List<IconData> icons2 = [
  Icons.bookmark_outline,
  Icons.person_add_alt,
  Icons.group,
];
List<String> titels2 = [
  'Channel',
  'Follow',
  'Group',
];
List<Color> colors2 = const [
  Color.fromARGB(255, 75, 116, 198),
  Color.fromARGB(255, 85, 151, 216),
  Color.fromARGB(255, 41, 185, 152),
];

List<Contact> contacts = [];
bool permissionDenied = false;

class _ContactScreenState extends State<ContactScreen> {
  Future fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(
            () => permissionDenied = true,
      );
    } else {
      final contactsFetch = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(
            () {
          contacts = contactsFetch;
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 240, 236, 236),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: const Padding(
          padding: EdgeInsets.all(15.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Color.fromARGB(255, 120, 119, 113),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(
              Icons.search,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: contacts.isNotEmpty
          ? SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.only(
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
                      icons[index], titels[index], colors[index], () {}),
                  itemCount: icons.length,
                  separatorBuilder: (context, index) => myDivider(),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.only(
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
                      icons2[index],
                      titels2[index],
                      colors2[index],
                          () {}),
                  itemCount: icons.length,
                  separatorBuilder: (context, index) => myDivider(),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.only(
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      contacItem(index, contacts.toList()),
                  separatorBuilder: (context, index) => myDivider(),
                  itemCount: contacts.length,
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

Widget contacItem(index, List<Contact> contacts) {
  Uint8List? image = contacts[index].photo;
  String number = contacts[index].phones.isNotEmpty?contacts[index].phones.first.number:'';
  return ListTile(
    leading: (image == null)
        ? CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: 18,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
    )
        : CircleAvatar(
      backgroundColor: Colors.grey[300],
      radius: 18,
      backgroundImage: MemoryImage(image),
    ),
    trailing: const Icon(Icons.phone),
    title: Text(
      contacts[index].displayName,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    subtitle: Text(
      number,
      style: const TextStyle(fontWeight: FontWeight.w500),
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
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
);