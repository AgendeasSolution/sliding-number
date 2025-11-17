package com.fgtp.sliding_tile;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.fgtp.sliding_tile/app_info";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getVersion")) {
                    String version = getVersionName();
                    if (version != null) {
                        result.success(version);
                    } else {
                        result.error("UNAVAILABLE", "Version not available.", null);
                    }
                } else {
                    result.notImplemented();
                }
            });
    }

    private String getVersionName() {
        try {
            PackageInfo packageInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            return packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            return null;
        }
    }
}
