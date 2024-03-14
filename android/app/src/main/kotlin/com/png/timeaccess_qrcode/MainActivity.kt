package com.png.timeaccess_qrcode

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ComponentName
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.admin.DevicePolicyManager
import android.util.Log

class MainActivity : FlutterActivity() {
    private val kioskModeChannel = "kioskModeLocked"
    private lateinit var mAdminComponentName: ComponentName
    private lateinit var mDevicePolicyManager: DevicePolicyManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, kioskModeChannel).setMethodCallHandler { call, result ->
            if (call.method == "startKioskMode") {
                try {
                    manageKioskMode(true)
                } catch (e: Exception) {
                }
            } else if (call.method == "stopKioskMode") {
                try {
                    manageKioskMode(false)
                } catch (e: Exception) {
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun manageKioskMode(enable: Boolean) {
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            mDevicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            mAdminComponentName = MyDeviceAdminReceiver.getComponentName(this)
            mDevicePolicyManager.setLockTaskPackages(mAdminComponentName, arrayOf(packageName))
            if (enable) {
                this.startLockTask()
            } else {
                this.stopLockTask()
            }
            return
        }
    }
}
