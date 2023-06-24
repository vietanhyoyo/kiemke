import 'dart:convert';
import 'package:flutter/material.dart';

class UserListProvider with ChangeNotifier {
  List<Map<String, dynamic>> userList = [];
  late int userID;
  String excelPath = "";

  void loadUserList(List<String>? savedUserList) {
    userList = savedUserList != null
        ? savedUserList
            .map((json) => jsonDecode(json))
            .toList()
            .cast<Map<String, dynamic>>()
        : [];
    notifyListeners();
  }

  void addUser(Map<String, dynamic> user) {
    userList.add(user);
    notifyListeners();
  }

  void editUser(int index, Map<String, dynamic> user) {
    userList[index] = user;
    notifyListeners();
  }

  void deleteUser(int index) {
    userList.removeAt(index);
    notifyListeners();
  }

  void editUserID(int index) {
    userID = index;
    notifyListeners();
  }

  void addProperty(Map<String, dynamic> prop) {
    final childProperty = userList[userID]["properties"];
    final newProp = {
      "name": prop["name"],
      "code": prop["code"],
      "quantity": 0
    };
    childProperty.add(newProp);
    final newUser = {
      "name": userList[userID]["name"],
      "properties": childProperty
    };
    userList[userID] = newUser;
    notifyListeners();
  }

  void deleteProperty(int index){
    userList[userID]["properties"].removeAt(index);
    notifyListeners();
  }

  void changePropertyNumber(int index, int number){
    userList[userID]["properties"][index]["quantity"] = number;
  }

  void changeExcelPath(String path){
    excelPath = path.toString();
    notifyListeners();
  }
}
