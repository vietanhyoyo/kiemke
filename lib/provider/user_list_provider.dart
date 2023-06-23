import 'dart:convert';
import 'package:flutter/material.dart';

class UserListProvider with ChangeNotifier {
  List<Map<String, dynamic>> userList = [];
  late int userID;

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
    childProperty.add(prop);
    final newUser = {
      "name": userList[userID]["name"],
      "properties": childProperty
    };
    userList[userID] = newUser;
    notifyListeners();
  }
}
