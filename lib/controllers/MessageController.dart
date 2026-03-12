import 'package:flutter/cupertino.dart';

import '../models/NotificationModel.dart';
import '../services/MessageService.dart';

class Messagecontroller extends ChangeNotifier {

  final NotificationService _service = NotificationService();

  List<NotificationModel> notifications = [];

  bool isLoading = false;

  Future<void> fetchNotifications() async {

    isLoading = true;
    notifyListeners();

    final data = await _service.fetchPrivateNotifications();

    notifications = data
        .map((e) => NotificationModel.fromMap(e))
        .toList();

    isLoading = false;
    notifyListeners();
  }


  Future<void> markAsRead(String id) async {

    await _service.markAsRead(id);

    final index = notifications.indexWhere((n) => n.id == id);

    if(index != -1){
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        message: notifications[index].message,
        isRead: true,
        createdAt: notifications[index].createdAt,
      );
    }

    notifyListeners();
  }

}