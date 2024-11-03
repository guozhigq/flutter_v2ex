// ignore_for_file: unused_element, avoid_print

import 'dart:io';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/http/user.dart';

class LocalNoticeService {
  int noticeId = 0; //  通知id
  String title = ''; // 标题
  String body = ''; // 内容
  String channel = '';
  String channelDescription = 'your channel description'; // 渠道描述
  String payload = '';

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
        '重要通知', // title
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
        AndroidInitializationSettings('@drawable/ic_stat_name');
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
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     Get.toNamed('/search');
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     // if (notificationResponse.actionId == navigationActionId) {
        //     //   selectNotificationStream.add(notificationResponse.payload);
        //     // }
        //     break;
        // }
        /// 除了回复提醒，都跳转至消息列表页面
        Map noticeQuery = Utils.stringToMap(notificationResponse.payload);
        if (noticeQuery.isNotEmpty) {
          Get.toNamed('/t/${noticeQuery['topicId']}');
        } else {
          Get.toNamed('/notifications');
        }
      },
      // 文本回复
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    ).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });

    //  Android 13 (API level 33)
    // _localNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .requestPermission();

    await _isAndroidPermissionGranted();
    await _requestPermissions();
  }

  // 安卓通知授权
  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
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
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  void show(count) async {
    /// 消息通知开关
    bool noticeOn = GStorage().getNoticeOn();
    if (!noticeOn) {
      print('local_notice 162 Line: 不接收消息通知');
    }

    /// 发送通知前检查目前通知状态、数量
    print('local notice: $count');
    int noticeCount = await _getActive();
    print(noticeCount);
    if (noticeCount >= count) {
      return;
    } else {
      var res = await UserWebApi.queryNotice(1);
      Iterable<MemberNoticeItem> noticeList = res.noticeList.take(count);
      for (var i in noticeList) {
        var title = '你有新的消息提醒';
        var body = '点击查看';
        String payload = '';
        if (i.noticeType == NoticeType.reply) {
          title = '${i.memberId}回复了你';
          body = i.replyContent;
          payload = 'noticeId:${noticeId + 1}#topicId:${i.topicId}';
        }
        if (i.noticeType == NoticeType.favTopic) {
          title = '${i.memberId}收藏了你发布的主题';
          body = i.topicTitle;
        }
        if (i.noticeType == NoticeType.thanksTopic) {
          title = '${i.memberId}感谢了你的主题';
          body = i.topicTitle;
        }
        if (i.noticeType == NoticeType.thanksReply) {
          title = '${i.memberId}感谢了你的回复';
          body = i.replyContent;
        }
        send(title: title, body: body, payload: payload);
      }
    }
  }

  // 下发消息
  void send(
      {String title = '您有新的消息提醒', // 标题
      String body = '点击查看', // 内容
      bool customSound = false, // 是否自定义通知声
      bool delayed = false, // 是否延长
      Duration endTime = const Duration(seconds: 1), // 默认延时1s
      String sound = 'slow_spring_board.mp3', // 自定义通知声文件
      String channel = '消息提醒', // 渠道 在「设置」中展示
      String channelDescription = 'your channel description',
      payload}) async {
    LocalNoticeService().title = title;
    LocalNoticeService().body = body;
    LocalNoticeService().channel = channel;
    LocalNoticeService().channelDescription = channelDescription;
    LocalNoticeService().payload = payload;

    // 默认通知
    if (!customSound && !delayed) {
      _showNotification();
    }
    // 延时通知
    if (!customSound && delayed) {
      _zonedScheduleNotification(endTime);
    }
    // 自定义通知声
    if (customSound && !delayed) {
      _showNotificationCustomSound(sound);
    }
  }

  // 默认展示
  Future<void> _showNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('high_importance_channel', channel,
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_name',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_round'),
            ticker: 'ticker');
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _localNotificationsPlugin.show(
      noticeId++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // 延迟展示
  Future<void> _zonedScheduleNotification(endTime) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      channel,
      channelDescription: channelDescription,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _localNotificationsPlugin.zonedSchedule(noticeId++, title, body,
        tz.TZDateTime.now(tz.local).add(endTime), notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  // 自定义通知声音
  Future<void> _showNotificationCustomSound(sound) async {
    final soundFile = sound.replaceAll('.mp3', '');
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      channel,
      channelDescription: 'your other channel description',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundFile),
    );
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: true, sound: sound);

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );
    await _localNotificationsPlugin
        .show(noticeId++, title, body, notificationDetails, payload: payload);
  }

  // 可回复通知
  Future<void> _showNotificationWithTextAction() async {
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
  Future<void> _repeatNotification() async {
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

  Future<void> _showNotificationCustomVibrationIconLed() async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel', channel,
      channelDescription: 'Order related notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_name',
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
      // color: AppColors.green
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _localNotificationsPlugin.show(
        noticeId++,
        'title of notification with custom vibration pattern, LED and icon',
        'body of notification with custom vibration pattern, LED and icon',
        notificationDetails);
  }

  // 清除最近一条通知
  void cancelLast() {
    // 传入id
    _localNotificationsPlugin.cancel(noticeId--);
  }

  // 清除所有
  void cancelAll() {
    _localNotificationsPlugin.cancelAll();
  }

  // 是否有正在进行中的通知
  Future<void> checkPending() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _localNotificationsPlugin.pendingNotificationRequests();
    print(pendingNotificationRequests.length);
  }

  Future<int> _getActive() async {
    final List<ActiveNotification> activeNotifications =
        await _localNotificationsPlugin.getActiveNotifications();
    return activeNotifications.length;
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }
}
