import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:kiemke/provider/user_list_provider.dart';
import 'package:kiemke/user_detail.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyScreen extends StatefulWidget {
  @override
  AddPropertyScreenState createState() => AddPropertyScreenState();
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  late UserListProvider userListProvider;
  late SharedPreferences prefs;
  String inputValue = '';
  late List<Map<String, dynamic>> dataList = [];

  List<dynamic> resultList = [];

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userListProvider = Provider.of<UserListProvider>(context, listen: false);
  }

  Future<void> saveUserList() async {
    final jsonList =
    userListProvider.userList.map((user) => jsonEncode(user)).toList();
    await prefs.setStringList('userList', jsonList);
  }

  void readExcelData() async {
    ByteData data = await rootBundle
        .load('assets/tt.xlsx'); // Thay đổi đường dẫn tới file Excel của bạn
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Excel excel = Excel.decodeBytes(bytes);
    List<String> sheetNames = excel.tables.keys.toList();

    // Lấy dữ liệu từ sheet đầu tiên
    Sheet? sheet = excel.tables[sheetNames[0]];

    List<Map<String, dynamic>> rows = [];
    for (var row in sheet!.rows) {
      List<dynamic> rowData = [];
      for (var cell in row) {
        rowData.add(cell?.value);
      }
      rows.add({'name': rowData[0].toString(), 'code': rowData[1].toString()});
    }

    dataList = rows;
  }

  void searchString(List<Map<String, dynamic>> data, String searchQuery) {
    String lowercaseSearchQuery = searchQuery.toLowerCase();
    resultList.clear(); // Xóa danh sách kết quả trước khi tìm kiếm mới

    for (Map<String, dynamic> stringItem in data) {
      try {
        String lowercaseStringItem = stringItem['name']!.toLowerCase();

        // Split the search query into a list of words
        List<String> searchWords = lowercaseSearchQuery.split(" ");

        bool allWordsExist = true;
        for (String word in searchWords) {
          if (!lowercaseStringItem.contains(word)) {
            allWordsExist = false;
            break;
          }
        }

        if (allWordsExist) {
          // If all words exist in the string item, add it to the resultList
          setState(() {
            resultList.add(stringItem);
          });
        }
      } catch (e) {
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    readExcelData();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài sản'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  inputValue = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Nhập loại tài sản...',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () {
                  searchString(dataList, inputValue);
                },
                child: Text('Tìm kiếm')),
            Expanded(
              child: ListView.builder(
                itemCount: resultList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(resultList[index]['code'], style: TextStyle(fontWeight: FontWeight.bold),),
                              Container(
                                width: 30,
                                height: 30,
                                child: IconButton(
                                  onPressed: () async {
                                    userListProvider.addProperty(resultList[index]);
                                    await saveUserList();
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => UserDetailScreen(),
                                    ));
                                  },
                                  icon: Icon(Icons.add, color: Colors.blue,),
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          Text(resultList[index]['name'])
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
