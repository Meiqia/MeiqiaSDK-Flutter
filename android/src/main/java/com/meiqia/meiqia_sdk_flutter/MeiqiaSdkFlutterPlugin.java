package com.meiqia.meiqia_sdk_flutter;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.meiqia.core.MQManager;
import com.meiqia.core.MQScheduleRule;
import com.meiqia.core.bean.MQMessage;
import com.meiqia.core.callback.OnGetMessageListCallback;
import com.meiqia.core.callback.OnInitCallback;
import com.meiqia.meiqiasdk.activity.MQConversationActivity;
import com.meiqia.meiqiasdk.callback.MQSimpleActivityLifecyleCallback;
import com.meiqia.meiqiasdk.util.MQConfig;
import com.meiqia.meiqiasdk.util.MQIntentBuilder;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MeiqiaSdkFlutterPlugin
 */
public class MeiqiaSdkFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Activity context; // flutter Activity
    private MQConversationActivity mQConversationActivity;

    private HashMap<String, String> clientInfo;
    private boolean updateClientInfo = false;
    private String customizedId;
    private String agentId;
    private String groupId;
    private String preSendText;
    private Bundle preSendProductCard;
    private MQScheduleRule scheduleRule = MQScheduleRule.REDIRECT_ENTERPRISE;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "meiqia_sdk_flutter");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            Map<String, Object> sdkInfo = new HashMap<>();
            sdkInfo.put("channel", "flutter");
            MQManager.getInstance(context).setSDKInfo(sdkInfo);
            String appKey = call.argument("appKey");
            MQManager.init(context, appKey, new OnInitCallback() {
                @Override
                public void onSuccess(String s) {
                    result.success(null);
                }

                @Override
                public void onFailure(int i, String s) {
                    result.success(s);
                }
            });
        } else if (call.method.equals("dismiss")) {
            if (mQConversationActivity != null) {
                mQConversationActivity.finish();
            }
        } else if (call.method.equals("show")) {
            MQConfig.setActivityLifecycleCallback(new MQSimpleActivityLifecyleCallback() {

                @Override
                public void onActivityCreated(MQConversationActivity activity, Bundle savedInstanceState) {
                    mQConversationActivity = activity;
                }

                @Override
                public void onActivityDestroyed(MQConversationActivity activity) {
                    mQConversationActivity = null;
                }
            });
            MQIntentBuilder intentBuilder = new MQIntentBuilder(context);
            if (updateClientInfo) {
                intentBuilder.updateClientInfo(clientInfo);
            } else {
                intentBuilder.setClientInfo(clientInfo);
            }
            if (!TextUtils.isEmpty(customizedId)) {
                intentBuilder.setCustomizedId(customizedId);
            }
            intentBuilder.setScheduledAgent(agentId);
            intentBuilder.setScheduledGroup(groupId);
            intentBuilder.setScheduleRule(scheduleRule);
            intentBuilder.setPreSendTextMessage(preSendText);
            intentBuilder.setPreSendProductCardMessage(preSendProductCard);
            Intent intent = intentBuilder.build();
            context.startActivity(intent);
            reset();
        } else if (call.method.equals("setClientInfo")) {
            clientInfo = call.argument("clientInfo");
            updateClientInfo = Boolean.TRUE.equals(call.argument("update"));
        } else if (call.method.equals("setCustomizedId")) {
            customizedId = call.argument("customizedId");
        } else if (call.method.equals("setScheduledAgent")) {
            agentId = call.argument("agentId");
        } else if (call.method.equals("setScheduledGroup")) {
            groupId = call.argument("groupId");
        } else if (call.method.equals("setScheduleRule")) {
            int value = call.argument("rule");
            scheduleRule = MQScheduleRule.fromValue(value);
        } else if (call.method.equals("setPreSendTextMessage")) {
            preSendText = call.argument("text");
        } else if (call.method.equals("setPreSendProductCardMessage")) {
            preSendProductCard = new Bundle();
            preSendProductCard.putString("title", call.argument("title"));
            preSendProductCard.putString("pic_url", call.argument("pictureUrl"));
            preSendProductCard.putString("description", call.argument("description"));
            preSendProductCard.putString("product_url", call.argument("productUrl"));
            long salesCount = -1;
            try {
                Object salesCountObj = call.argument("salesCount");
                if (salesCountObj != null) {
                    salesCount = Long.parseLong(salesCountObj.toString());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (salesCount > 0) {
                preSendProductCard.putLong("sales_count", salesCount);
            }
        } else if (call.method.equals("setStyle")) {
            MQConfig.ui.titleBackgroundColor = call.argument("navBarBackgroundColor");
            MQConfig.ui.titleTextColor = call.argument("navBarTitleTxtColor");
            MQConfig.ui.leftChatTextColor = call.argument("incomingMsgTextColor");
            MQConfig.ui.leftChatBubbleColor = call.argument("incomingBubbleColor");
            MQConfig.ui.rightChatTextColor = call.argument("outgoingMsgTextColor");
            MQConfig.ui.rightChatBubbleColor = call.argument("outgoingBubbleColor");
            MQConfig.ui.backgroundColor = call.argument("backgroundColor");

            MQConfig.isShowClientAvatar = Boolean.TRUE.equals(call.argument("enableShowClientAvatar"));
            MQConfig.isVoiceSwitchOpen = Boolean.TRUE.equals(call.argument("enableSendVoiceMessage"));
        } else if (call.method.equals("setOnLinkClickListener")) {
            MQConfig.setOnLinkClickCallback((conversationActivity, intent, url) -> {
                Map<String, String> params = new HashMap<>();
                params.put("url", url);
                channel.invokeMethod("onLinkClick", params);
            });
        } else if (call.method.equals("closeMeiqiaService")) {
            MQManager.getInstance(context).closeMeiqiaService();
        } else if (call.method.equals("getUnreadMessages")) {
            OnGetMessageListCallback callback = new OnGetMessageListCallback() {
                @Override
                public void onSuccess(List<MQMessage> list) {
                    List<Map<String, Object>> resultList = new ArrayList<>();
                    for (int i = 0; i < list.size(); i++) {
                        MQMessage mqMessage = list.get(i);
                        Map<String, Object> message = new HashMap<>();
                        message.put("content", mqMessage.getContent());
                        message.put("content_type", mqMessage.getContent_type());
                        message.put("conversation_id", mqMessage.getConversation_id());
                        message.put("created_on", mqMessage.getCreated_on());
                        message.put("enterprise_id", mqMessage.getEnterprise_id());
                        message.put("from_type", mqMessage.getFrom_type());
                        message.put("id", mqMessage.getId());
                        message.put("track_id", mqMessage.getTrack_id());
                        message.put("type", mqMessage.getType());
                        resultList.add(message);
                    }
                    result.success(resultList);
                }

                @Override
                public void onFailure(int i, String s) {
                    result.success(new ArrayList<>());
                }
            };
            String customizedId = call.argument("customizedId");
            if (TextUtils.isEmpty(customizedId)) {
                MQManager.getInstance(context).getUnreadMessages(callback);
            } else {
                MQManager.getInstance(context).getUnreadMessages(customizedId, callback);
            }
        } else {
            result.notImplemented();
        }
    }

    private void reset() {
        clientInfo = null;
        updateClientInfo = false;
        customizedId = null;
        agentId = null;
        groupId = null;
        preSendText = null;
        preSendProductCard = null;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        context = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        context = null;
    }
}
