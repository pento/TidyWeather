package net.pento.tidyweather

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import androidx.annotation.NonNull
import com.transistorsoft.flutter.backgroundfetch.HeadlessTask
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel

class Application: FlutterApplication() {
    val channel = "net.pento.tidyweather/widget"
    private val prefsFilename = "net.pento.tidyweather.prefs"
    private lateinit var preferences: SharedPreferences

    override fun onCreate() {
        super.onCreate()

        Log.d( "TidyWeather", "*********** Application Created" )

        preferences = applicationContext.getSharedPreferences( prefsFilename, 0 )

        HeadlessTask.onInitialized {
            engine ->
            Log.d( "TidyWeather", "*********** Engine Started" )

            MethodChannel( engine.dartExecutor.binaryMessenger, channel ).setMethodCallHandler {
                call, result -> methodCallHandler( call, result )
            }
        }
    }

    fun methodCallHandler(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result ) {
        Log.d( "TidyWeather", "*********** Application call handler: " + call.method )
        if ( call.method == "updateWeatherData" ) {
            val editor = preferences.edit()

            val current: String? = call.argument( "current" )
            val min: String? = call.argument( "min" )
            val max: String? = call.argument( "max" )
            val code: String? = call.argument( "code" )
            val sunrise: String? = call.argument( "sunrise" )
            val sunset: String? = call.argument( "sunset" )

            editor.putString( "current", current!!.toString() )
            editor.putString( "min", min!!.toString() )
            editor.putString( "max", max!!.toString() )
            editor.putString( "code", code!!.toString() )
            editor.putString( "sunrise", sunrise!!.toString() )
            editor.putString( "sunset", sunset!!.toString() )

            editor.commit()

            val intent = Intent( this, WeatherWidget::class.java )
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance( this ).getAppWidgetIds(ComponentName( this, WeatherWidget::class.java ) )
            intent.putExtra( AppWidgetManager.EXTRA_APPWIDGET_IDS, ids )
            sendBroadcast( intent )

            result.success( true )
        } else {
            result.notImplemented()
        }

    }
}
