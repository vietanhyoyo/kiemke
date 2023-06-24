import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiemke/provider/user_list_provider.dart';
import 'package:kiemke/user_detail.dart';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  late UserListProvider userListProvider;
  late SharedPreferences prefs;

  Future<void> initSharedPreferences(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    userListProvider = Provider.of<UserListProvider>(context, listen: false);
    userListProvider.loadUserList(prefs.getStringList('userList'));
    // Lưu file Excel vào bộ nhớ thiết bị
    var directory = await getExternalStorageDirectory();
    var path = '${directory?.path}/kiemke.xlsx';
    userListProvider.changeExcelPath(path.toString());
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
          title: const Text('Cập nhật hộ dân'),
          content: TextField(
            onChanged: (value) {
              editedName = value;
            },
            decoration: const InputDecoration(hintText: 'Nhập tên hộ dân'),
            controller: TextEditingController(text: editedName),
            minLines: 1,
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                userListProvider = Provider.of<UserListProvider>(
                  context,
                  listen: false,
                );
                if (index != null) {
                  userListProvider.userList[index]["name"] = editedName;
                  userListProvider.editUser(
                      index, userListProvider.userList[index]);
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

  Future<void> exportToExcel() async {
    // Tạo một workbook mới
    var excel = Excel.createExcel();

    // Tạo một sheet mới
    Sheet sheetObject = excel['Sheet1'];

    for (var i = 0; i < userListProvider.userList.length; i++) {
      var user = userListProvider.userList[i];
      sheetObject.appendRow(['']);
      sheetObject.appendRow(['Hộ số: ' + i.toString(), user["name"].toString()]);
      print(user);
      for (var item in user['properties']) {
        print(user);
        sheetObject.appendRow([
          item['code'].toString(),
          item['name'].toString(),
          item['quantity'].toString()
        ]);
      }
    }

    //stopwatch.reset();
    List<int>? fileBytes = excel.save();
    //print('saving executed in ${stopwatch.elapsed}');
    if (fileBytes != null) {
      File(join(userListProvider.excelPath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    // Hiển thị thông báo xuất file thành công
    Fluttertoast.showToast(
      msg: '"File excel được xuất ra ở: ${userListProvider.excelPath}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Mở file Excel
    OpenFile.open(userListProvider.excelPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initSharedPreferences(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Danh sách hộ'),
              leading: null,
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Danh sách hộ'),
              leading: null,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<UserListProvider>(
                builder: (context, userListProvider, _) {
                  return ListView.builder(
                    itemCount: userListProvider.userList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == userListProvider.userList.length) {
                        return Column(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await exportToExcel();
                                },
                                child: Text('Xuất excel')),
                            Text(userListProvider.excelPath != ""
                                ? "File excel sẽ nằm ở: ${userListProvider.excelPath}"
                                : "---", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10),),
                            SizedBox(height: 40,),
                            Text('-2023-', style: TextStyle(color: Colors.blue, fontSize: 10),),
                            Text('Copyright: vietanh.ctu', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10),),
                          ],
                        );
                      } else {
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 10, right: 10, bottom: 10),
                                child: Text(
                                    userListProvider.userList[index]["name"]),
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      minimumSize:
                                          MaterialStateProperty.all(Size(0, 0)),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.only(left: 10, top: 0)),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Xác nhận'),
                                            content: Text(
                                                'Bạn có chắc muốn xóa hộ này?'),
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
                                                  // Perform the delete operation
                                                  userListProvider
                                                      .deleteUser(index);
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          showEditUserDialog(context, index);
                                        },
                                        child: Text(
                                          'Đổi tên',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        style: ButtonStyle(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  Size(0, 0)),
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.only(
                                                  right: 20, top: 0)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          userListProvider.editUserID(index);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserDetailScreen(),
                                              ));
                                        },
                                        child: Text('Cập nhật'),
                                        style: ButtonStyle(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  Size(20, 20)),
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.only(
                                                  right: 10, top: 0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
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
