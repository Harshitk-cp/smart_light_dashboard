package com.example.smart_light_dashboard;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;
import im.zego.media_projection_creator.MediaProjectionCreatorCallback;
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager;
import android.media.projection.MediaProjection;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import main.java.com.example.smart_light_dashboard.ScreenCaptureManager;
import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;
import android.content.res.Resources;
import android.graphics.SurfaceTexture;
import android.content.Context;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.smart_light_dashboard/get-rgb";

    private static MediaProjection mediaProjection;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getRGBValue")) {
                                int rgb = ScreenCaptureManager.getInstance().getRGB();
                                result.success(rgb);
                            } else if(call.method.equals("music/color")){
                                int color = ScreenCaptureManager.getInstance().getMusicColor();
                                result.success(color);
                            } else if(call.method.equals("music/brightness")){
                                int brightness = ScreenCaptureManager.getInstance().getMusicBrightness();
                                result.success(brightness);
                            } else if(call.method.equals("stopCapture")){
                                ScreenCaptureManager.getInstance().stopCapture();
                                result.success(0);
                            }
                            else {
                                result.notImplemented();
                            }
                        });
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RequestMediaProjectionPermissionManager.getInstance()
                .setForegroundServiceNotificationStyle(R.mipmap.ic_launcher, "Screen is being captured");

        RequestMediaProjectionPermissionManager.getInstance()
                .setRequestPermissionCallback(mediaProjectionCreatorCallback);
    }

    private final MediaProjectionCreatorCallback mediaProjectionCreatorCallback = new MediaProjectionCreatorCallback() {

        @Override
        public void onMediaProjectionCreated(MediaProjection projection, int errorCode) {
            if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_SUCCEED) {
                Log.i("MEDIA_PROJECTION_CREATOR", "Create media projection succeeded!");
                Context context = getApplicationContext();

                ScreenCaptureManager.getInstance().setScreenCaptureInfo(projection, getScreenWidth(),
                        getScreenHeight(), context);
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_USER_CANCELED) {
                Log.e("MEDIA_PROJECTION_CREATOR", "Create media projection failed because can not get permission");
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW) {
                Log.e("MEDIA_PROJECTION_CREATOR",
                        "Create media projection failed because system api level is lower than 21");
            }
        }
    };

    private int getScreenWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    private int getScreenHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }
}