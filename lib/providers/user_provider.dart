import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:instagram_clone_flutter/models/user.dart';
import 'package:instagram_clone_flutter/resources/auth_methods.dart';

import '../models/place.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<List<Place>?> getPlacesList(String searchString) async {
    try {
      var res = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchString&key=AIzaSyD7pU2EiAYpZM_tLmp-MhQ7vm1MIQhZsmw"));

      if (res.statusCode == 200) {
        return (jsonDecode(res.body)['predictions'] as List)
            .map((e) => Place.fromJson(e))
            .toList();
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
