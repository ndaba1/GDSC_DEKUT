// ignore_for_file: avoid_print

import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_app/Firebase_Logic/EventFirebase.dart';
import 'package:gdsc_app/UI/Authentication/user_logic.dart';
import 'package:gdsc_app/Util/App_Constants.dart';
import 'package:gdsc_app/Util/App_components.dart';
import 'package:gdsc_app/main.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../UI/Events/Model/Event_model.dart';

class AppController extends GetxController {
  var isDark = false.obs;
  var events = <EventModel>[].obs;
  var isSignedIn = false.obs;
  var currentPage = 0.obs;
  var isSent = false.obs;
  var isLoading = true.obs;
  var selectedDate = 'Date'.obs;
  var selectTime = '5:00'.obs;
  Rx<File> image = File(Constants.logo).obs;
  final picker = ImagePicker();
  Rx<TimeOfDay> time = TimeOfDay.now().obs;
  var i = 0.0.obs;
  var docsLength = 5.obs;
  var stack = "No Stacking".obs;
  var profileImage = Constants.defaultIcon.obs;
  var profileName = "User".obs;
  var profileEmail = "".obs;
  var profilePhone = "".obs;
  var profileGithub = "".obs;
  var profileTwitter = "".obs;
  var profileLinkedin = "".obs;
  var adminPassword = '1234'.obs;
  var isEventEnabled = true.obs;
  var isResourceEnabled = true.obs;
  var isAnnouncementEnabled = false.obs;
  var isMeetingEnabled = false.obs;
  var isLeadsEnabled = false.obs;
  var initialProfileName = "User".obs;
  var isObscured = false.obs;
  var hasConnection = false.obs;
  var selectedCategory = "news".obs;

  @override
  void onInit() {
    super.onInit();
    getThemeStatus();
  }

  // void sendScheduledNotification(int id, String channelKey, String title,
  //     String body, DateTime interval) async {
  //   String localTZ = await AwesomeNotifications().getLocalTimeZoneIdentifier();

  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: id,
  //       channelKey: channelKey,
  //       title: "We are about to start.....",
  //       body: "Looking forward to see you there",
  //       locked: true,
  //       criticalAlert: true,
  //       category: NotificationCategory.Alarm,
  //     ),
  //     schedule: NotificationCalendar.fromDate(date: interval),
  //     actionButtons: <NotificationActionButton>[
  //       NotificationActionButton(
  //           key: 'remove',
  //           label: 'Stop',
  //           buttonType: ActionButtonType.DisabledAction),
  //     ],
  //   );
  // }

  void sendSpecific() async {
    print("Sending scheduled notfication has started");
    await FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs.map((doc) => {
                    AwesomeNotifications().createNotification(
                      content: NotificationContent(
                        id: 1,
                        title: " Today we have an upcoming event.....",
                        body: "Looking forward to see you there",
                        locked: true,
                        criticalAlert: true,
                        category: NotificationCategory.Alarm,
                        channelKey: 'base',
                      ),
                      schedule: NotificationCalendar.fromDate(
                          // ignore: unrelated_type_equality_checks
                          date: (DateFormat.yMMMd()
                                          .parse(doc['date'])
                                          .toString())
                                      .substring(0, 10) ==
                                  (DateFormat.yMMMd()
                                          .parse(Components.now)
                                          .toString())
                                      .substring(0, 10)
                              ? DateTime.now().add(const Duration(seconds: 5))
                              : DateFormat.yMMMd().parse(doc['date'])),
                      actionButtons: <NotificationActionButton>[
                        NotificationActionButton(
                            key: 'remove',
                            label: 'Stop',
                            buttonType: ActionButtonType.DisabledAction),
                      ],
                    ),
                  })
            });
  }

  //   await AwesomeNotifications().createNotification(
  //   content: NotificationContent(
  //     id: 1,
  //     //channelKey: channelKey,
  //     title: " Today we have an upcoming event.....",
  //     body: "Looking forward to see you there",
  //     locked: true,
  //     criticalAlert: true,
  //     category: NotificationCategory.Alarm, channelKey: 'base',
  //   ),
  //   schedule: NotificationCalendar.fromDate(
  //       // ignore: unrelated_type_equality_checks
  //       date: (DateFormat.yMMMd().parse(data['date']).toString())
  //                             .substring(0, 10) ==
  //                         (DateFormat.yMMMd().parse(Components.now).toString())
  //                             .substring(0, 10)
  //                     ? DateTime.now().add(const Duration(seconds: 5))
  //                     : DateFormat.yMMMd().parse(data['date'])),
  //   actionButtons: <NotificationActionButton>[
  //     NotificationActionButton(
  //         key: 'remove',
  //         label: 'Stop',
  //         buttonType: ActionButtonType.DisabledAction),
  //   ],
  // );

  getPassword() async {
    await FirebaseFirestore.instance
        .collection('password')
        .doc('9Sr6EDDtf2icFY4XX3Sh')
        .get()
        .then((value) {
      adminPassword.value = value['password'];
    });
  }

  getTechology() async {
    print("Running the function");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((snapshot) async {
      print("The tech is ${snapshot['technology']}");
      initialProfileName.value = snapshot['username'];
      stack.value = snapshot['technology'];
      nameDetails.text = snapshot['username'];
      emailDetails.text = snapshot['email'];
      phoneDetails.text = snapshot['phone'];
      githubDetails.text = snapshot['github'];
      linkedinDetails.text = snapshot['linkedin'];
      twitterDetails.text = snapshot['twitter'];
      technologyDetails.text = snapshot['technology'];
      urlDetails = snapshot['imageUrl'];
      SharedPreferences pref = await _prefs;
      pref.setString('image', urlDetails!);
      pref.setString('name', snapshot['username']);
      pref.setString('email', snapshot['email']);
      pref.setString('phone', snapshot['phone']);
      pref.setString('github', snapshot['github']);
      pref.setString('linkedin', snapshot['linkedin']);
      pref.setString('twitter', snapshot['twitter']);
    });
  }

  Future queryData(String queryString) {
    return FirebaseFirestore.instance
        .collection('resources')
        .where('title', isEqualTo: queryString)
        .get();
  }

  void fetchEvents() async {
    try {
      isLoading(true);
      isLoading(false);
    } catch (e) {
      print(e);
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      image.value = File(pickedFile.path);
      print("THe image value is : ${image.value}");
      update();
    } else {
      print('No image selected.');
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  saveThemeStatus() async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', isDark.value);
  }

  getThemeStatus() async {
    var isDarkTheme = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('theme') ?? true;
    }).obs;
    isDark.value = (await isDarkTheme.value);
  }

  getProfileImage() async {
    var image = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('image') ?? Constants.announceLogo;
    }).obs;

    profileImage.value = (await image.value);
  }

  getProfileDetails() async {
    var name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('name') ?? "User";
    }).obs;
    var email = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('email') ?? "";
    }).obs;
    var phone = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('phone') ?? "";
    }).obs;
    var github = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('github') ?? "";
    }).obs;
    var linkedin = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('linkedin') ?? "";
    }).obs;
    var twitter = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('twitter') ?? "";
    }).obs;

    profileName.value = (await name.value);
    initialProfileName.value = (await name.value);
    profileEmail.value = (await email.value);
    profilePhone.value = (await phone.value);
    profileGithub.value = (await github.value);
    profileLinkedin.value = (await linkedin.value);
    profileTwitter.value = (await twitter.value);
  }

  saveProfileImage() async {
    SharedPreferences pref = await _prefs;
    pref.setString('image', urlDetails!);
  }
}
