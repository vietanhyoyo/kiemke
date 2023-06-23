import 'package:flutter/material.dart';
import 'package:kiemke/add_property.dart';
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

  void showEditUserDialog(BuildContext context, int? index) {
    String editedName =
    index != null ? userListProvider.userList[index]["name"] : "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: TextField(
            onChanged: (value) {
              editedName = value;
            },
            decoration:
            const InputDecoration(hintText: 'Nhập tên người dùng'),
            controller: TextEditingController(text: editedName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                userListProvider = Provider.of<UserListProvider>(
                  context,
                  listen: false,
                );
                if (index != null) {
                  userListProvider.userList[index]["name"] = editedName;
                  userListProvider.editUser(index, userListProvider.userList[index]);
                } else {
                  userListProvider
                      .addUser({"name": editedName, "properties": []});
                }
                // Lưu danh sách người dùng vào SharedPreferences
                await saveUserList();

                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initSharedPreferences(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('User'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('User ${userListProvider.userID.toString()}'),
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
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(userListProvider.userList[userListProvider.userID]["properties"][index]["code"]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
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
                                                onPressed: () {
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
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Xử lý sự kiện khi người dùng nhấn vào một n
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(userListProvider.userList[userListProvider.userID]["properties"][index]["name"]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
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
