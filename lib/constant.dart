import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:vms/global/function/page_mover.dart';
import 'package:vms/global/widget/popup_handler.dart';

MovePageHandler pageMover = MovePageHandler();
var primaryColor = const Color.fromARGB(255, 98, 98, 230);
var secondaryColor = const Color.fromARGB(255, 249, 91, 91);
var thirdColor = const Color(0xFF29ADB2);
const fourthColor = Color.fromARGB(255, 255, 162, 0);
Color? textColor = Colors.grey[700];
var logger = Logger();
var height = 0.0;
var width = 0.0;
final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
final localStorage = GetStorage();
PopupHandler popupHandler = PopupHandler();
var tokenKey = 'token';
var isDriverKey = 'isDriver';
var offlineStatus = 'offline';
var onlineStatus = 'online';
var parkingStatus = 'parking';
var uidKey = 'uid';
var usernameKey = 'username';

var mbId = 'mapbox.mapbox-streets-v8';
var mbToken =
    'pk.eyJ1IjoiZXJhcHJpbWEiLCJhIjoiY2s4N2NzdWp4MHJibzNsbGtzdXNzZXpsayJ9.x6vRcez0Apisc5oCkUzQ3Q';
var mapKey =
    'https://api.mapbox.com/styles/v1/eraprima/ckxh14eyg0et614tasuponnyt/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZXJhcHJpbWEiLCJhIjoiY2s4N2NzdWp4MHJibzNsbGtzdXNzZXpsayJ9.x6vRcez0Apisc5oCkUzQ3Q';

List<Map<String, String>> generateAnimeCharactersData(int count) {
  List<String> animeCharacterNames = [
    'Goku',
    'Naruto Uzumaki',
    'Monkey D. Luffy',
    'Ichigo Kurosaki',
    'Light Yagami',
    'Edward Elric',
    'Lelouch Lamperouge',
    'Saitama',
    'Eren Yeager',
    'Gon Freecss',
    'Killua Zoldyck',
    'Inuyasha',
    'Vegeta',
    'Sasuke Uchiha',
    'Luffy Monkey',
    'Natsu Dragneel',
    'Levi Ackerman',
    'Son Goku',
    'Spike Spiegel',
    'Roronoa Zoro',
    'Alucard',
    'Kakashi Hatake',
    'Itachi Uchiha',
    'Sesshomaru',
    'Gintoki Sakata',
    'Ken Kaneki',
    'Koro-sensei',
    'Gon Freecss',
    'Lelouch Vi Britannia',
    'Naruto Uzumaki',
    'Saitama',
    'Guts',
    'Vegeta',
    'Roy Mustang',
    'Himura Kenshin',
    'Izuku Midoriya',
    'Light Yagami',
    'Simon',
    'Shinji Ikari',
    'Ash Ketchum',
    'Vash the Stampede',
    'Allen Walker',
    'Kenpachi Zaraki',
    'L Lawliet',
    'Shanks',
    'Brook',
    'Trafalgar Law',
  ];

  List<Map<String, String>> charactersData = [];

  for (int i = 0; i < count; i++) {
    String characterName = animeCharacterNames[i % animeCharacterNames.length];
    String username =
        characterName.toLowerCase().replaceAll(' ', '_') + (i + 1).toString();

    charactersData.add({
      'name': characterName,
      'username': username,
    });
  }

  return charactersData;
}
