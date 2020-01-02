package net.pento.tidyweather

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.os.PersistableBundle
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val channel = "net.pento.tidyweather/widget"
    private val prefsFilename = "net.pento.tidyweather.prefs"
    private lateinit var preferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        preferences = activity.getSharedPreferences( prefsFilename, 0 )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
            call, result ->
            if ( call.method == "updateWeatherData" ) {
                val editor = preferences.edit()

                val current: String? = call.argument( "current" )
                val min: String? = call.argument( "min" )
                val max: String? = call.argument( "max" )

                editor.putString( "current", current!!.toString() )
                editor.putString( "min", min!!.toString() )
                editor.putString( "max", max!!.toString() )

                editor.commit()
            } else {
                result.notImplemented()
            }
        }
    }
}
