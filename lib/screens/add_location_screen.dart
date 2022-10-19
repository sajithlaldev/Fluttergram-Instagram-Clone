import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instagram_clone_flutter/providers/user_provider.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';

import '../models/place.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({Key? key}) : super(key: key);

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  ValueNotifier<List<Place>> places = ValueNotifier([]);
  ValueNotifier<Position?> position = ValueNotifier(null);

  void clearImage() {}

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  void initState() {
    super.initState();
    position.addListener(
      () async {
        // From coordinates
        if (position.value != null) {
          setState(() {
            isLoading = true;
          });
          GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: position.value!.latitude,
            longitude: position.value!.longitude,
            googleMapApiKey: "AIzaSyD7pU2EiAYpZM_tLmp-MhQ7vm1MIQhZsmw",
          );

          places.value = [
            Place(
              place_id: "",
              description: data.city + ", " + data.state,
            )
          ];
          setState(() {
            isLoading = false;
          });
        }
      },
    );
    _determinePosition();
    _descriptionController.addListener(() async {
      if (_descriptionController.text.trim().isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        try {
          places.value = await UserProvider()
                  .getPlacesList(_descriptionController.text.trim()) ??
              places.value;
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context, e.toString());
        }
      }
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    setState(() {
      isLoading = true;
    });
    var pos = await Geolocator.getCurrentPosition();
    position.value = pos;
    setState(() {
      isLoading = false;
    });
    return pos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: isLoading
            ? const CupertinoActivityIndicator(
                radius: 10,
              )
            : IconButton(
                icon: const Icon(
                  Icons.my_location,
                ),
                onPressed: () {
                  _determinePosition();
                },
              ),
        title: const Text(
          'Location',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          )
        ],
      ),
      // POST FORM
      body: Column(
        children: <Widget>[
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Search place...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          ValueListenableBuilder(
            valueListenable: places,
            builder: (context, List<Place> value, child) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pop(
                        context,
                        value[index].description,
                      );
                    },
                    title: Text(
                      value[index].description,
                    ),
                  );
                },
                separatorBuilder: ((context, index) => const Divider()),
                itemCount: value.length,
                shrinkWrap: true,
              );
            },
          )
        ],
      ),
    );
  }
}
