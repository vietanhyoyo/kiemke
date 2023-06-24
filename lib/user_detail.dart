import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiemke/add_property.dart';
import 'package:kiemke/home.dart';
import 'package:kiemke/provider/user_list_provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailScreen extends StatelessWidget {
  late UserListProvider userListProvider;
  late SharedPreferences prefs;

  Future<void> initSharedPreferences(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    userListProvider = Provider.of<UserListProvider>(context, listen: false);
  }

  Future<void> saveUserList() async {
    final jsonList =
        userListProvider.userList.map((user) => jsonEncode(user)).toList();
    await prefs.setStringList('userList', jsonList);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initSharedPreferences(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Hộ dân'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                },
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(userListProvider.userList[userListProvider.userID]["name"] ?? "Hộ dân"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<UserListProvider>(
                builder: (context, userListProvider, _) {
                  return ListView.builder(
                    itemCount: userListProvider
                        .userList[userListProvider.userID]["properties"].length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: (userListProvider
                            .userList[userListProvider.userID]["properties"].length - 1) == index
                            ? EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 70)
                            : EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(userListProvider
                                            .userList[userListProvider.userID]
                                        ["properties"][index]["code"],
                                        style: TextStyle(fontWeight: FontWeight.bold),),
                                        TextButton(
                                          style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(0, 0)),
                                            padding: MaterialStateProperty.all(EdgeInsets.only(left: 10, top: 0)),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Xác nhận'),
                                                  content: Text(
                                                      'Bạn có chắc muốn xóa tài sản này?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Hủy'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        userListProvider
                                                            .deleteProperty(index);

                                                        await saveUserList();

                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Xóa'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Xóa', style: TextStyle(color: Colors.redAccent),),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4), // Thu nhỏ khoảng cách
                                        ),
                                        controller: TextEditingController(
                                            text: userListProvider
                                                .userList[userListProvider.userID]
                                            ["properties"][index]["quantity"]
                                                .toString()),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        onChanged: (value) async {
                                          try {
                                            int number = int.parse(value);
                                            userListProvider.changePropertyNumber(
                                                index, number);
                                          } catch (e) {
                                            userListProvider.changePropertyNumber(
                                                index, 0);
                                            print(e);
                                          }
                                          await saveUserList();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              Text(userListProvider
                                      .userList[userListProvider.userID]
                                  ["properties"][index]["name"]),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPropertyScreen(),
                    ));
              },
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
