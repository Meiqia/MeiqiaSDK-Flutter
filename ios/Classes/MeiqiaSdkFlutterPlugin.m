#import "MeiqiaSdkFlutterPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import <MeiQiaSDK/MQManager.h>
#import "MQChatViewManager.h"

#pragma mark - 暴露给flutter的方法

static NSString *const initMeiQiaSDK = @"init";  // 初始化美洽SDK
static NSString *const setClientInfo = @"setClientInfo";  //设置顾客的自定义信息
static NSString *const configChatViewStyle = @"setStyle";  //美洽UI样式的配置
static NSString *const setScheduledAgentId = @"setScheduledAgent";  //设置分配给指定的客服id
static NSString *const setScheduledGroupId = @"setScheduledGroup";  //设置分配给指定的客服组id
static NSString *const setLoginCustomizedId = @"setCustomizedId";  //设置登录客服的开发者自定义id
static NSString *const setPreSendTextMessage = @"setPreSendTextMessage";  //设置预发送的文本信息
static NSString *const setPreSendProductCardMessage = @"setPreSendProductCardMessage";  //设置预发送的商品卡片信息
static NSString *const setOnLinkClickListener = @"setOnLinkClickListener";  //点击商品卡片的回调
static NSString *const showChatViewController = @"show";  //跳转到聊天页面
static NSString *const dismissChatViewController = @"dismiss";  //退出聊天页面

#pragma mark - 回调给flutter的方法

static NSString *const onLinkClick = @"onLinkClick";  //点击商品卡片的回调

#pragma mark - 所有arguments的参数key

static NSString *const kAppKey = @"appKey";  //appkey
static NSString *const kCustomizedId = @"customizedId";  //顾客的自定义id
static NSString *const kAgentId = @"agentId";  //客服id
static NSString *const kGroupId = @"groupId";  //客服组id
static NSString *const kText = @"text";  //预发送的文本字段
static NSString *const kProductCard = @"productCard";  //预发送的商品卡片信息
static NSString *const kStyle = @"style";  //UI样式的配置
static NSString *const kClientInfo = @"clientInfo";  //顾客的自定义信息
static NSString *const kUpdate = @"update";  // 是否强制更新
static NSString *const kUrl = @"url";  // 点击商品卡片的链接

#pragma mark - UI配置的参数key

static NSString *const kIncomingMsgTextColor = @"incomingMsgTextColor";  // 设置发送过来的message的文字颜色
static NSString *const kIncomingBubbleColor = @"incomingBubbleColor";  // 设置发送过来的message气泡颜色
static NSString *const kOutgoingMsgTextColor = @"outgoingMsgTextColor";  // 设置发送出去的message的文字颜色
static NSString *const kOutgoingBubbleColor = @"outgoingBubbleColor";  // 设置发送出去的message气泡颜色
static NSString *const kEventTextColor = @"eventTextColor";  // 设置事件流的显示文字的颜色
static NSString *const kNavBarColor = @"navBarBackgroundColor";  // 设置导航栏的背景色
static NSString *const kNavTitleFont = @"navTitleFont";  // 设置导航栏上的title的字体大小
static NSString *const kNavTitleColor = @"navBarTitleTxtColor";  // 设置导航栏上的title的颜色
static NSString *const kBackgroundColor = @"backgroundColor";  // 聊天窗口背景色
static NSString *const kEnableRoundAvatar = @"enableRoundAvatar";  // 是否开启圆形头像
static NSString *const kEnableIncomingAvatar = @"enableIncomingAvatar";  // 是否支持左边头像的显示
static NSString *const kEnableOutgoingAvatar = @"enableShowClientAvatar";  // 是否支持当前用户头像的显示

static NSString *const kEnableSendVoiceMessage= @"enableSendVoiceMessage";  // 是否支持发送语音
static NSString *const kEnablePhotoLibraryEdit= @"enablePhotoLibraryEdit";  // 是否裁剪图片

#pragma mark - 商品卡片参数key

static NSString *const kPictureUrl = @"pictureUrl";  //商品图片的url
static NSString *const kTitle= @"title";  // 商品标题
static NSString *const kDescription = @"description";  //商品描述内容
static NSString *const kProductUrl = @"productUrl";  // 商品链接
static NSString *const kSalesCount = @"salesCount";  // 销售量

@interface MeiqiaSdkFlutterPlugin ()

@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) FlutterMethodCall *call;

@property (nonatomic, strong) MQChatViewManager *chatViewManager;

@end

@implementation MeiqiaSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"meiqia_sdk_flutter"
              binaryMessenger:[registrar messenger]];
    MeiqiaSdkFlutterPlugin* instance = [[MeiqiaSdkFlutterPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    self.call = call;
    NSString *method = call.method;
    NSDictionary *argument = [NSDictionary dictionaryWithDictionary:[call arguments]];
    if ([method isEqualToString:initMeiQiaSDK]) {
        NSString *appKey = @"";
        if ([argument objectForKey:kAppKey] && ![[argument objectForKey:kAppKey] isEqual:[NSNull null]]) {
            appKey = argument[kAppKey];
        }
        [self initMeiqiaSDKWith:appKey result:(FlutterResult)result];
    } else if ([method isEqualToString:setClientInfo]) {
        [self setClientInfo:argument];
    } else if ([method isEqualToString:configChatViewStyle]) {
        [self configChatViewStyle:argument];
    } else if ([method isEqualToString:setScheduledAgentId]) {
        if ([argument objectForKey:kAgentId] && ![[argument objectForKey:kAgentId] isEqual:[NSNull null]]) {
            NSString *agentId = argument[kAgentId];
            [self setScheduledAgentId:agentId];
        }
    } else if ([method isEqualToString:setScheduledGroupId]) {
        if ([argument objectForKey:kGroupId] && ![[argument objectForKey:kGroupId] isEqual:[NSNull null]]) {
            NSString *groupId = argument[kGroupId];
            [self setScheduledGroupId:groupId];
        }
    } else if ([method isEqualToString:setLoginCustomizedId]) {
        if ([argument objectForKey:kCustomizedId] && ![[argument objectForKey:kCustomizedId] isEqual:[NSNull null]]) {
            NSString *customizedId = argument[kCustomizedId];
            [self setLoginCustomizedId:customizedId];
        }
    } else if ([method isEqualToString:setPreSendTextMessage]) {
        if ([argument objectForKey:kText] && ![[argument objectForKey:kText] isEqual:[NSNull null]]) {
            NSString *preText = argument[kText];
            [self setPreSendTextMessage:preText];
        }
    } else if ([method isEqualToString:setPreSendProductCardMessage]) {
        [self setPreSendProductCardMessage:argument];
    } else if ([method isEqualToString:setOnLinkClickListener]) {
        [self handleSetOnLinkClickListener];
    } else if ([method isEqualToString:showChatViewController]) {
        [self showMeiQiaChatView];
    } else if ([method isEqualToString:dismissChatViewController]) {
        [self dismissMeiQiaChatView];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark Public Function

/**
 *
 * 初始化美洽的sdk,并回调初始化结果
 */
-(void)initMeiqiaSDKWith:(NSString *)appKey result:(FlutterResult)result {
    [MQManager configSourceChannel:MQSDKSourceChannelFlutter];
    [MQManager initWithAppkey:appKey completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            result(nil);
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            result(error.description);
        }
        
    }];
}

/**
 *
 * 初始化美洽的配置管理器
 */
-(MQChatViewManager *)chatViewManager {
    if (!_chatViewManager) {
        _chatViewManager = [[MQChatViewManager alloc] init];
    }
    return _chatViewManager;
}

/**
 *  跳转到聊天页面
 *
 */
- (void)showMeiQiaChatView {
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [self.chatViewManager presentMQChatViewControllerInViewController:rootController];
    self.chatViewManager = nil;
}

/**
 *  退出聊天页面
 *
 */
- (void)dismissMeiQiaChatView {
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootController dismissViewControllerAnimated:NO completion:nil];
}

/**
 *
 * 美洽UI样式的配置
 */
-(void)configChatViewStyle:(NSDictionary *)styleDic {
    
    MQChatViewStyle *chatStyle = [self.chatViewManager chatViewStyle];
    if (styleDic && ![styleDic isEqual:[NSNull null]]) {
        if ([styleDic objectForKey:kIncomingMsgTextColor] && ![[styleDic objectForKey:kIncomingMsgTextColor] isEqual:[NSNull null]]) {
            [chatStyle setIncomingMsgTextColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kIncomingMsgTextColor]]];
        }
        
        if ([styleDic objectForKey:kIncomingBubbleColor] && ![[styleDic objectForKey:kIncomingBubbleColor] isEqual:[NSNull null]]) {
            [chatStyle setIncomingBubbleColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kIncomingBubbleColor]]];
        }
        
        if ([styleDic objectForKey:kOutgoingMsgTextColor] && ![[styleDic objectForKey:kOutgoingMsgTextColor] isEqual:[NSNull null]]) {
            [chatStyle setOutgoingMsgTextColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kOutgoingMsgTextColor]]];
        }
        
        if ([styleDic objectForKey:kOutgoingBubbleColor] && ![[styleDic objectForKey:kOutgoingBubbleColor] isEqual:[NSNull null]]) {
            [chatStyle setOutgoingBubbleColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kOutgoingBubbleColor]]];
        }
        
        if ([styleDic objectForKey:kEventTextColor] && ![[styleDic objectForKey:kEventTextColor] isEqual:[NSNull null]]) {
            [chatStyle setEventTextColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kEventTextColor]]];
        }
        
        if ([styleDic objectForKey:kNavBarColor] && ![[styleDic objectForKey:kNavBarColor] isEqual:[NSNull null]]) {
            [chatStyle setNavBarColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kNavBarColor]]];
        }
        
        if ([styleDic objectForKey:kNavTitleColor] && ![[styleDic objectForKey:kNavTitleColor] isEqual:[NSNull null]]) {
            [chatStyle setNavTitleColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kNavTitleColor]]];
        }
        
        if ([styleDic objectForKey:kBackgroundColor] && ![[styleDic objectForKey:kBackgroundColor] isEqual:[NSNull null]]) {
            [chatStyle setBackgroundColor:[UIColor mq_colorWithHexString:[styleDic objectForKey:kBackgroundColor]]];
        }
        
        if ([styleDic objectForKey:kNavTitleFont] && ![[styleDic objectForKey:kNavTitleFont] isEqual:[NSNull null]]) {
            [chatStyle setNavTitleFont:[UIFont systemFontOfSize:[[styleDic objectForKey:kNavTitleFont] doubleValue]]];
        }
        
        if ([styleDic objectForKey:kEnableRoundAvatar] != nil && ![[styleDic objectForKey:kEnableRoundAvatar] isEqual:[NSNull null]]) {
            [chatStyle setEnableRoundAvatar:[[styleDic objectForKey:kEnableRoundAvatar] boolValue]];
        }
        
        if ([styleDic objectForKey:kEnableIncomingAvatar] != nil && ![[styleDic objectForKey:kEnableIncomingAvatar] isEqual:[NSNull null]]) {
            [chatStyle setEnableIncomingAvatar:[[styleDic objectForKey:kEnableIncomingAvatar] boolValue]];
        }
        
        if ([styleDic objectForKey:kEnableOutgoingAvatar] != nil && ![[styleDic objectForKey:kEnableOutgoingAvatar] isEqual:[NSNull null]]) {
            [chatStyle setEnableOutgoingAvatar:[[styleDic objectForKey:kEnableOutgoingAvatar] boolValue]];
        }
        
        if ([styleDic objectForKey:kEnableSendVoiceMessage] != nil && ![[styleDic objectForKey:kEnableSendVoiceMessage] isEqual:[NSNull null]]) {
            [self.chatViewManager enableSendVoiceMessage:[[styleDic objectForKey:kEnableSendVoiceMessage] boolValue]];
        }

        if ([styleDic objectForKey:kEnablePhotoLibraryEdit] != nil && ![[styleDic objectForKey:kEnablePhotoLibraryEdit] isEqual:[NSNull null]]) {
            [self.chatViewManager enablePhotoLibraryEdit:[[styleDic objectForKey:kEnablePhotoLibraryEdit] boolValue]];
        }


    }
}

/**
 *  设置顾客的自定义信息
 */
- (void)setClientInfo:(NSDictionary *)clientInfo {
    NSDictionary *infoDic = [NSDictionary new];
    bool override = false;
    if ([clientInfo objectForKey:kClientInfo] && ![[clientInfo objectForKey:kClientInfo] isEqual:[NSNull null]] && [[clientInfo objectForKey:kClientInfo] isKindOfClass:[NSDictionary class]]) {
        infoDic = [clientInfo objectForKey:kClientInfo];
    }
    if ([clientInfo objectForKey:kUpdate] != nil && ![[clientInfo objectForKey:kUpdate] isEqual:[NSNull null]]) {
        override = [clientInfo objectForKey:kUpdate];
    }
    [self.chatViewManager setClientInfo:infoDic override:override];
}

/**
 *  设置分配给指定的客服id
 *
 *  @param agentId 客服id
 */
- (void)setScheduledAgentId:(NSString *)agentId {
    [self.chatViewManager setScheduledAgentId:agentId];
}

/**
 *  设置分配给指定的客服组id
 *
 *  @warning 如果设置了分配给客服id，以分配给客服id为优先
 *  @param groupId 客服组id
 */
- (void)setScheduledGroupId:(NSString *)groupId {
    [self.chatViewManager setScheduledGroupId:groupId];
}

/**
 *  设置登录客服的开发者自定义id，设置该id后，聊天将会以该自定义id的顾客上线
 *
 *  @warning 如果setLoginMQClientId接口，优先使用setLoginMQClientId来进行登录
 *  @param customizedId 开发者自定义id
 */
- (void)setLoginCustomizedId:(NSString *)customizedId {
    [self.chatViewManager setLoginCustomizedId:customizedId];
}

/**
 *
 * 设置预发送的文本信息
 */
- (void)setPreSendTextMessage:(NSString *)contentStr {
    [self.chatViewManager setPreSendMessages:@[contentStr]];
}

/**
 *
 * 设置预发送的商品卡片信息
 */
- (void)setPreSendProductCardMessage:(NSDictionary *)dic {
    NSString *pictureUrl = @"";
    NSString *title = @"";
    NSString *desc = @"";
    NSString *productUrl = @"";
    long salesCount = 0;
    
    if ([dic objectForKey:kPictureUrl] && ![[dic objectForKey:kPictureUrl] isEqual:[NSNull null]]) {
        pictureUrl = [dic objectForKey:kPictureUrl];
    }
    
    if ([dic objectForKey:kTitle] && ![[dic objectForKey:kTitle] isEqual:[NSNull null]]) {
        title = [dic objectForKey:kTitle];
    }
    
    if ([dic objectForKey:kDescription] && ![[dic objectForKey:kDescription] isEqual:[NSNull null]]) {
        desc = [dic objectForKey:kDescription];
    }
    
    if ([dic objectForKey:kProductUrl] && ![[dic objectForKey:kProductUrl] isEqual:[NSNull null]]) {
        productUrl = [dic objectForKey:kProductUrl];
    }
    
    if ([dic objectForKey:kSalesCount] && ![[dic objectForKey:kSalesCount] isEqual:[NSNull null]]) {
        salesCount = [[dic objectForKey:kSalesCount] longValue];
    }
    
    MQProductCardMessage *productCard = [[MQProductCardMessage alloc] initWithPictureUrl:pictureUrl title:title description:desc productUrl:productUrl andSalesCount:salesCount];
    [self.chatViewManager setPreSendMessages: @[productCard]];
}

/**
 *
 * 设置商品卡片的点击回调
 */
-(void)handleSetOnLinkClickListener {
    __weak typeof(self) weakSelf = self;
    [self.chatViewManager didTapProductCard:^(NSString *productUrl) {
        [weakSelf.channel invokeMethod:onLinkClick arguments:@{kUrl: productUrl}];
    }];
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //推送注册
    [self requestAuthorizeation:application];
    
    return YES;
}

//MARK:注册远程推送通知
- (void)requestAuthorizeation:(UIApplication *)application {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error && granted) {
            //远程通知注册成功
        } else {
            //远程通知注册失败error
        }
    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
#pragma mark  集成第二步: 进入前台 打开meiqia服务
    [MQManager openMeiqiaService];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
#pragma mark  集成第三步: 进入后台 关闭美洽服务
    [MQManager closeMeiqiaService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#pragma mark  集成第四步: 上传设备deviceToken
    [MQManager registerDeviceToken:deviceToken];
}

@end
