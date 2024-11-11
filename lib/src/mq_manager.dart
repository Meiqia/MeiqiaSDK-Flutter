import 'dart:async';

import 'package:flutter/services.dart';

typedef LinkTapCallback = void Function(String url);

typedef MessageCallback = void Function(List<MQMessage> messages);

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
    final String? errorMsg =
        await _channel.invokeMethod('init', {'appKey': appKey});
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
      _channel.invokeMethod('setClientInfo',
          {'clientInfo': clientInfo.info, 'update': clientInfo.update});
    }
    if (scheduledAgent != null) {
      _channel.invokeMethod('setScheduledAgent', {'agentId': scheduledAgent});
    }
    if (scheduledGroup != null) {
      _channel.invokeMethod('setScheduledGroup', {'groupId': scheduledGroup});
    }
    if (preSendTextMessage != null) {
      _channel
          .invokeMethod('setPreSendTextMessage', {'text': preSendTextMessage});
    }
    if (preSendProductCard != null) {
      _channel.invokeMethod(
          'setPreSendProductCardMessage', preSendProductCard.toMap());
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

  closeMeiqiaService() {
    _channel.invokeMethod('closeMeiqiaService');
  }

  /// 获取未读消息
  /// [isOnlyMessageType] 是否只包含人工消息
  Future<List<MQMessage>> getUnreadMessages(
      {bool isOnlyMessageType = true, String? customizedId}) async {
    final List<dynamic> messages = await _channel
        .invokeMethod('getUnreadMessages', {'customizedId': customizedId});
    List<MQMessage> list = messages
        .map((e) => MQMessage.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (isOnlyMessageType) {
      list = list.where((e) => e.type == 'message').toList();
    }
    return list;
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
  String? incomingMsgTextColor;
  String? incomingBubbleColor;
  String? outgoingMsgTextColor;
  String? outgoingBubbleColor;
  String? backgroundColor;
  bool enableShowClientAvatar;
  bool enableSendVoiceMessage;
  bool enablePhotoLibraryEdit;

  Style(
      {this.navBarBackgroundColor,
      this.navBarTitleTxtColor,
      this.incomingMsgTextColor,
      this.incomingBubbleColor,
      this.outgoingMsgTextColor,
      this.outgoingBubbleColor,
      this.backgroundColor,
      this.enableShowClientAvatar = false,
      this.enableSendVoiceMessage = true,
      this.enablePhotoLibraryEdit = true});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'navBarBackgroundColor': navBarBackgroundColor,
      'navBarTitleTxtColor': navBarTitleTxtColor,
      'incomingMsgTextColor': incomingMsgTextColor,
      'incomingBubbleColor': incomingBubbleColor,
      'outgoingMsgTextColor': outgoingMsgTextColor,
      'outgoingBubbleColor': outgoingBubbleColor,
      'backgroundColor': backgroundColor,
      'enableShowClientAvatar': enableShowClientAvatar,
      'enableSendVoiceMessage': enableSendVoiceMessage,
      'enablePhotoLibraryEdit': enablePhotoLibraryEdit,
    };
    return map;
  }
}

class MQMessage {
  String content = '';
  String contentType = '';
  int conversationId = 0;
  int createdOn = 0;
  String fromType = '';
  int id = 0;
  String trackId = '';
  String type = '';

  MQMessage.fromMap(Map<String, dynamic> map) {
    content = map['content'];
    contentType = map['content_type'];
    conversationId = map['conversation_id'];
    createdOn = map['created_on'];
    fromType = map['from_type'];
    id = map['id'];
    trackId = map['track_id'];
    type = map['type'];
  }
}
