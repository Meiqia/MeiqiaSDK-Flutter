import 'dart:async';

import 'package:flutter/services.dart';

typedef LinkTapCallback = void Function(String url);

class MQManager {
  static final MQManager instance = MQManager._internal();

  LinkTapCallback? _linkTapCallback;

  MQManager._internal() {
    _channel.setMethodCallHandler((call) => _handleMethod(call));
  }

  factory MQManager() {
    return instance;
  }

  static const MethodChannel _channel = MethodChannel('meiqia_sdk_flutter');

  static Future<String?> init({required String appKey}) async {
    final String? errorMsg = await _channel.invokeMethod('init', {'appKey': appKey});
    return errorMsg;
  }

  // 处理从原生过来的方法
  _handleMethod(MethodCall call) {
    if (call.method == 'onLinkClick') {
      _linkTapCallback?.call(call.arguments['url']);
    }
  }

  show({
    String? customizedId,
    ClientInfo? clientInfo,
    String? scheduledAgent,
    String? scheduledGroup,
    String? preSendTextMessage,
    ProductCard? preSendProductCard,
    Style? style,
    LinkTapCallback? linkTapCallback,
  }) {
    if (customizedId != null) {
      _channel.invokeMethod('setCustomizedId', {'customizedId': customizedId});
    }
    if (clientInfo != null) {
      _channel.invokeMethod(
          'setClientInfo', {'clientInfo': clientInfo.info, 'update': clientInfo.update});
    }
    if (scheduledAgent != null) {
      _channel.invokeMethod('setScheduledAgent', {'agentId': scheduledAgent});
    }
    if (scheduledGroup != null) {
      _channel.invokeMethod('setScheduledGroup', {'groupId': scheduledGroup});
    }
    if (preSendTextMessage != null) {
      _channel.invokeMethod('setPreSendTextMessage', {'text': preSendTextMessage});
    }
    if (preSendProductCard != null) {
      _channel.invokeMethod('setPreSendProductCardMessage', preSendProductCard.toMap());
    }
    if (style != null) {
      _channel.invokeMethod('setStyle', style.toMap());
    }
    if (linkTapCallback != null) {
      _linkTapCallback = linkTapCallback;
      _channel.invokeMethod('setOnLinkClickListener');
    }
    _channel.invokeMethod('show');
  }

  dismiss() {
    _channel.invokeMethod('dismiss');
  }
}

class ClientInfo {
  Map<String, String> info;
  bool update = false;

  ClientInfo({required this.info, this.update = false});
}

class ProductCard {
  String title;
  String pictureUrl;
  String description;
  String productUrl;
  int salesCount;

  ProductCard(
      {required this.title,
      required this.pictureUrl,
      required this.description,
      required this.productUrl,
      required this.salesCount});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'pictureUrl': pictureUrl,
      'description': description,
      'productUrl': productUrl,
      'salesCount': salesCount
    };
    return map;
  }
}

class Style {
  String? navBarBackgroundColor;
  String? navBarTitleTxtColor;
  bool enableShowClientAvatar;
  bool enableSendVoiceMessage;
  bool enablePhotoLibraryEdit;

  Style(
      {this.navBarBackgroundColor,
      this.navBarTitleTxtColor,
      this.enableShowClientAvatar = false,
      this.enableSendVoiceMessage = true,
      this.enablePhotoLibraryEdit = true});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'navBarBackgroundColor': navBarBackgroundColor,
      'navBarTitleTxtColor': navBarTitleTxtColor,
      'enableShowClientAvatar': enableShowClientAvatar,
      'enableSendVoiceMessage': enableSendVoiceMessage,
      'enablePhotoLibraryEdit': enablePhotoLibraryEdit,
    };
    return map;
  }
}
