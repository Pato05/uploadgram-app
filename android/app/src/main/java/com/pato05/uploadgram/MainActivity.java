package com.pato05.uploadgram;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.pm.PackageManager;

import java.io.File;
import java.util.ArrayList;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_NAME = "com.pato05.uploadgram";
    private SharedPreferences _sharedPrefs;
    private MethodChannel.Result _pendingResult;
    private static final int REQUEST_CODE_OPEN = MainActivity.class.hashCode() + 30;
    private static final int REQUEST_CODE_SAVE = MainActivity.class.hashCode() + 60;
    private static final int REQUEST_CODE_PERMISSIONS = MainActivity.class.hashCode() + 120;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        Context context = getApplicationContext();
        _sharedPrefs = context.getSharedPreferences("UploadgramPreferences", context.MODE_PRIVATE);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    String name;
                    switch(call.method) {
                        case "saveString":
                            result.success(_sharedPrefs.edit().putString(call.argument("name"), call.argument("content")).commit());
                            break;
                        case "getString":
                            result.success(
                                    _sharedPrefs.getString(call.argument("name"), call.argument("default")));
                            break;
                        case "getFile":
                            _pendingResult = result;
                            if(requestPermissionIfNeeded()) break;
                            getFile();
                            break;
                        case "saveFile":
                            _pendingResult = result;
                            if (requestPermissionIfNeeded()) break;
                            saveFile(call.argument("filename"), result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private boolean requestPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return false;
        if (ActivityCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            System.out.println("Asking for permissions");
            ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, REQUEST_CODE_PERMISSIONS);
            return true;
        }
        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (resultCode == RESULT_CANCELED) {
            _pendingResult.success(null);
            return;
        }
        if (intent == null) {
            _pendingResult.success(null);
            return;
        }
        Uri uri = intent.getData();
        // TODO: handle correctly Uris from other directories than the phone's one
        if (requestCode == REQUEST_CODE_OPEN || requestCode == REQUEST_CODE_SAVE)
            _pendingResult.success(FileUtils.getPath(getApplicationContext(), uri));
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grants) {
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (grants[0] != PackageManager.PERMISSION_GRANTED)
                _pendingResult.success("PERMISSION_NOT_GRANTED");
        }
    }

    private void getFile() {
        // TODO: ask for external storage permission if not granted
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.setType("*/*");

        startActivityForResult(intent, REQUEST_CODE_OPEN);
    }

    private void saveFile(String filename, MethodChannel.Result result) {
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.setType("application/json");
        intent.putExtra(Intent.EXTRA_TITLE, filename);

        startActivityForResult(intent, REQUEST_CODE_SAVE);
    }
}