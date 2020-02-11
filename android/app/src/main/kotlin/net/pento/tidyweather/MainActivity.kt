package net.pento.tidyweather

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine( @NonNull flutterEngine: FlutterEngine ) {
        GeneratedPluginRegistrant.registerWith( flutterEngine )

        var app = application as Application

        MethodChannel( flutterEngine.dartExecutor.binaryMessenger, app.channel ).setMethodCallHandler {
            call, result ->
            Log.d( "TidyWeather", "*********** Activity call handler: " + call.method )
                app.methodCallHandler( call, result )
        }
    }
}
