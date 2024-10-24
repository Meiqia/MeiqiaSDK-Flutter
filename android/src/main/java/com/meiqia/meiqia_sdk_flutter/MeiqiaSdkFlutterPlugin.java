package com.meiqia.meiqia_sdk_flutter;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.meiqia.core.MQManager;
import com.meiqia.core.callback.OnInitCallback;
import com.meiqia.meiqiasdk.activity.MQConversationActivity;
import com.meiqia.meiqiasdk.callback.MQSimpleActivityLifecyleCallback;
import com.meiqia.meiqiasdk.callback.OnLinkClickCallback;
import com.meiqia.meiqiasdk.util.MQConfig;
import com.meiqia.meiqiasdk.util.MQIntentBuilder;

import org.json.JSONObject;

import java.util.HashMap;
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
