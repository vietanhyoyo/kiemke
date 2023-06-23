import 'package:flutter/material.dart';
import 'package:kiemke/provider/user_list_provider.dart';
import 'package:kiemke/user_detail.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  late UserListProvider userListProvider;
  late SharedPreferences prefs;

  Future<void> initSharedPreferences(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    userListProvider =
        Provider.of<UserListProvider>(context, listen: false);
    userListProvider.loadUserList(prefs.getStringList('userList'));
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
              title: Text('User List'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('User List'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<UserListProvider>(
                builder: (context, userListProvider, _) {
                  return ListView.builder(
                    itemCount: userListProvider.userList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(userListProvider.userList[index]["name"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showEditUserDialog(context, index);
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Xác nhận'),
                                        content: Text('Bạn có chắc muốn xóa hộ này?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Perform the delete operation
                                              userListProvider.deleteUser(index);
                                              Navigator.of(context).pop(); // Close the dialog
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
                              IconButton(
                                onPressed: () {
                                  userListProvider.editUserID(index);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => UserDetailScreen(),
                                  ));
                                },
                                icon: Icon(Icons.change_circle),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Xử lý sự kiện khi người dùng nhấn vào một n
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showEditUserDialog(context, null);
              },
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
