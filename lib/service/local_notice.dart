import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int noticeId = 0;

class LocalNoticeService {
  static final LocalNoticeService _notificationService =
      LocalNoticeService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory LocalNoticeService() {
    return _notificationService;
  }

  LocalNoticeService._internal();

  noticeCase<FlutterLocalNotificationsPlugin>() {
    return _localNotificationsPlugin;
  }

  Future<void> init() async {
    // 前台通知配置
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
      );
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(channel);
    }
    if (Platform.isIOS) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    const AndroidInitializationSettings androidSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
      macOS: iosSetting,
      // so on
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Get.toNamed('/search');
            break;
          case NotificationResponseType.selectedNotificationAction:
            // if (notificationResponse.actionId == navigationActionId) {
            //   selectNotificationStream.add(notificationResponse.payload);
            // }
            print('77: ${notificationResponse.payload}');
            break;
        }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    ).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
    //  Android 13 (API level 33)
// _localNotificationsPlugin.resolvePlatformSpecificImplementation<
//     AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();

    await _configureLocalTimeZone();
    await _isAndroidPermissionGranted();
    await _requestPermissions();
  }

  // 安卓通知授权
  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      // setState(() {
      //   _notificationsEnabled = granted;
      // });
    }
  }

  // 通知权限
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
      //   _notificationsEnabled = granted ?? false;
      // });
    }
  }

  // 下发消息
  void send(
    String title,
    String body,
     {Duration endTime = const Duration(seconds: 1),
    String sound = 'slow_spring_board.aiff',
    String channel = 'default',
  }) async {
    // final scheduleTime =
    //     tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
    final scheduleTime = tz.TZDateTime.now(tz.local).add(endTime);
    // ios端额外配置 DarwinNotificationDetails
    final iosDetail = sound == ''
        ? null
        : DarwinNotificationDetails(presentSound: true, sound: sound);

    // Android端额外配置 AndroidNotificationDetails
    // 自定义提示音
    final soundFile = sound.replaceAll('.mp3', '');
    final notificationSound =
        sound == '' ? null : RawResourceAndroidNotificationSound(soundFile);

    final AndroidNotificationDetails androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: notificationSound,
    );

    final NotificationDetails noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
      // so on
    );

    // zonedSchedule  延时
    // show
    await _localNotificationsPlugin.zonedSchedule(
      noticeId++,
      title, // null
      body, // null
      // scheduleTime,
      scheduleTime,
      noticeDetail, // 传入配置项
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: 'item x', //传参
    );

    // await _localNotificationsPlugin.show(
    //   noticeId++,
    //   title, // null
    //   body, // null
    //   noticeDetail, // 传入配置项
    //   payload: 'item x', //传参
    // );
    print('notice send');
  }

  // 可回复通知
  void showNotificationWithTextAction() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'text_id_1',
          'Enter Text',
          icon: DrawableResourceAndroidBitmap('food'),
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: 'Enter a message',
            ),
          ],
        ),
      ],
    );

    const DarwinNotificationDetails iosDetail = DarwinNotificationDetails(
      categoryIdentifier: 'textCategory',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosDetail,
      // macOS: iosDetail,
    );

    await _localNotificationsPlugin.show(noticeId++, 'Text Input Notification',
        'Expand to see input action', notificationDetails,
        payload: 'item x');
  }

  // 定时消息
  Future<void> repeatNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _localNotificationsPlugin.periodicallyShow(noticeId++, '重复消息 title',
        '重复消息 body', RepeatInterval.everyMinute, notificationDetails,
        androidAllowWhileIdle: true);
  }

  // 清除最近一条通知
  void cancelLast() {
    // 传入id
    // _localNotificationsPlugin.cancel();
  }

  // 清除所有
  void cancelAll() {
    _localNotificationsPlugin.cancelAll();
  }

  // 是否有正在进行中的通知
  Future<void> checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _localNotificationsPlugin.pendingNotificationRequests();
    print(pendingNotificationRequests.length);
  }

  // 当前时区
  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }
}
