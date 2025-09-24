# meiqia_sdk_flutter

[![Pub](https://img.shields.io/pub/v/meiqia_sdk_flutter.svg)](https://pub.dev/packages/meiqia_sdk_flutter)

| Platform | support |
|----------|---------|
| Android  | ✅       |
| iOS      | ✅       |

## 安装
``` dart
dependencies:
  meiqia_sdk_flutter: ^1.1.9
```

## 使用美洽

### 1.初始化
``` dart
String? errorMsg = await MQManager.init(appKey: '开发者自己的 appKey');
if(errorMsg == null) {
    // success
}
```

### 2.启动对话界面
``` dart
MQManager.instance.show();
```

## 常见使用场景

> 开发者的 App 有自己的账号系统，希望每个账号对应不同的顾客，有不同的聊天记录。那就需要开发者在启动对话的时候，绑定账号：
``` dart
MQManager.instance.show(customizedId:'开发者自己系统的用户 id'); // 相同的 id 会被识别为同一个顾客
```

> 开发者希望顾客上线的时候，能够上传（或者更新）一些用户的自定义信息：

``` dart
Map<String,String> info = {
    'name': '富坚义博',
    'avatar': 'https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/1dee88eabfbd7bd4',
    'gender': '男',
    'tel': '13888888888',
    '技能1': '休刊'
};
// 设置顾客信息 PS: 这个接口只会生效一次,如果需要更新顾客信息,需要设置 update = true
// PS: 如果客服在工作台更改了顾客信息，更新顾客信息覆盖之前的内容
ClientInfo clientInfo = ClientInfo(info: info, update: false);
MQManager.instance.show(clientInfo: clientInfo);
```

> 指定客服分配

``` dart
// agentId 可以从工作台查询
MQManager.instance.show(scheduledAgent: agentId );
```

> 指定客服分组分配

``` dart
// groupId 可以从工作台查询
MQManager.instance.show(scheduledGroup: groupId);
```

> 设置分配规则

``` dart
/// MQScheduleRule.redirectEnterprise 默认，指定分配客服不在线，分配给企业随机一个人，分配失败，则发送留言
/// MQScheduleRule.redirectGroup 指定分配客服不在线，分配给组内的人，分配失败，则发送留言
/// MQScheduleRule.redirectNone 指定分配客服不在线，则发送留言
MQManager.instance.show(scheduleRule: MQScheduleRule.redirectEnterprise);
```

> 设置预发送消息

``` dart
// 预发送文字消息
MQManager.instance.show(preSendTextMessage: '我是预发送文字消息');
    
// productCard 构造
ProductCard productCard = ProductCard(
    title: '商品的标题',
    pictureUrl: 'https://file.pisen.com.cn/QJW3C1000WEB/Product/201701/16305409655404.jpg', // 商品图片的链接
    description: '商品描述的内容',
    productUrl: 'https://meiqia.com', // 商品链接
    salesCount: 50); // 销量
// 预发送文字消息 
MQManager.instance.show(preSendProductCard: productCard);
```

> 设置链接点击监听

``` dart
// ios 目前只支持商品卡片的点击回调
// 开发者自己处理 url 点击，注意：设置监听回调后,将不再跳转网页.如果需要跳转,开发者需要自行处理
MQManager.instance.show(linkTapCallback: (url) {
  debugPrint('clicked url = $url');
});
```

> 配置聊天页面 UI 样式

``` dart
Style style = Style(
    navBarBackgroundColor: '#ffffff', // 设置导航栏的背景色
    navBarTitleTxtColor: '#ffffff', // 设置导航栏上的 title 的颜色
    incomingMsgTextColor: '#FF5733', // 设置接收到的消息文本的颜色
    incomingBubbleColor: '#DAF7A6', // 设置接收到的消息气泡的颜色
    outgoingMsgTextColor: '#3498DB', // 设置发送的消息文本的颜色
    outgoingBubbleColor: '#FFC300', // 设置发送的消息气泡的颜色
    backgroundColor: '#E8DAEF', // 设置聊天页面背景色
    enableShowClientAvatar: false, // 是否支持当前用户头像的显示
    enableSendVoiceMessage: true, // 是否支持发送语音消息
    enablePhotoLibraryEdit: false, // 是否支持相册选择图片可裁剪。默认支持裁剪
);
MQManager.instance.show(style: style);
```

> 关闭聊天页面

``` dart
MQManager.instance.dismiss();
```

> 关闭美洽服务

``` dart
MQManager.instance.closeMeiqiaService();
```

> 获取未读消息（退出界面后收到的消息，都将算作未读消息）

``` dart
final messages = await MQManager.instance.getUnreadMessages();
```

## 相关链接

- [MeiqiaSDK-Android](https://github.com/Meiqia/MeiqiaSDK-Android)
- [MeiqiaSDK-iOS](https://github.com/Meiqia/MeiqiaSDK-iOS)
