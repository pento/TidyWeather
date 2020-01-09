package net.pento.tidyweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.widget.RemoteViews
import net.steamcrafted.materialiconlib.MaterialDrawableBuilder

/**
 * Implementation of App Widget functionality.
 */
class WeatherWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val prefs = context.getSharedPreferences( "net.pento.tidyweather.prefs", 0 )

    val current = prefs.getString( "current", "-" )
    val min = prefs.getString( "min", "" )
    val max = prefs.getString( "max", "" )
    val code = prefs.getString( "code", "" )

    // Construct the RemoteViews object
    val views = RemoteViews( context.packageName, R.layout.weather_widget )

    val intent = Intent( context, MainActivity::class.java )

    views.setOnClickPendingIntent( R.id.current_temp, PendingIntent.getActivity( context, 1, intent, 0 ) )
    views.setOnClickPendingIntent( R.id.temp_range, PendingIntent.getActivity( context, 1, intent, 0 ) )
    views.setOnClickPendingIntent( R.id.weather_icon, PendingIntent.getActivity( context, 1, intent, 0 ) )

    views.setTextViewText( R.id.current_temp, current )
    views.setTextViewText( R.id.temp_range, "$min-$max" )

    views.setImageViewResource( R.id.weather_icon, weatherIcon( "$code" ) )

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

internal fun weatherIcon( iconCode: String ): Int {
    val iconCodes = HashMap<String, Int>()


    iconCodes[ "chance-shower-cloud" ] = R.drawable.weather_rainy
    iconCodes[ "chance-shower-fine" ] = R.drawable.weather_partly_rainy
    iconCodes[ "chance-snow-cloud" ] = R.drawable.weather_snowy
    iconCodes[ "chance-snow-fine" ] = R.drawable.weather_partly_snowy
    iconCodes[ "chance-thunderstorm-cloud" ] = R.drawable.weather_lightning
    iconCodes[ "chance-thunderstorm-fine" ] = R.drawable.weather_partly_lightning
    iconCodes[ "chance-thunderstorm-showers" ] = R.drawable.weather_lightning_rainy
    iconCodes[ "cloudy" ] = R.drawable.weather_cloudy
    iconCodes[ "drizzle" ] = R.drawable.weather_rainy
    iconCodes[ "dust" ] = R.drawable.weather_hazy
    iconCodes[ "few-showers" ] = R.drawable.weather_rainy
    iconCodes[ "fine" ] = R.drawable.weather_sunny
    iconCodes[ "fog" ] = R.drawable.weather_fog
    iconCodes[ "frost" ] = R.drawable.snowflake_variant
    iconCodes[ "hail" ] = R.drawable.weather_hail
    iconCodes[ "heavy-showers-rain" ] = R.drawable.weather_pouring
    iconCodes[ "heavy-snow" ] = R.drawable.weather_snowy_heavy
    iconCodes[ "high-cloud" ] = R.drawable.weather_partly_cloudy
    iconCodes[ "light-snow" ] = R.drawable.weather_snowy
    iconCodes[ "mostly-cloudy" ] = R.drawable.weather_cloudy
    iconCodes[ "mostly-fine" ] = R.drawable.weather_partly_cloudy
    iconCodes[ "overcast" ] = R.drawable.weather_cloudy
    iconCodes[ "partly-cloudy" ] = R.drawable.weather_partly_cloudy
    iconCodes[ "shower-or-two" ] = R.drawable.weather_partly_rainy
    iconCodes[ "showers-rain" ] = R.drawable.weather_rainy
    iconCodes[ "snow" ] = R.drawable.weather_snowy
    iconCodes[ "snow-and-rain" ] = R.drawable.weather_snowy_rainy
    iconCodes[ "thunderstorm" ] = R.drawable.weather_lightning
    iconCodes[ "wind" ] = R.drawable.weather_windy

  if ( iconCodes.containsKey( iconCode ) ) {
    return iconCodes[ iconCode ]!!
  }

  return -1
}

internal fun drawableToBitmap( drawable: Drawable ): Bitmap {
    var bitmap: Bitmap

    if ( drawable is BitmapDrawable ) {
        var bitmapDrawable: BitmapDrawable = drawable
        if ( bitmapDrawable.bitmap != null ) {
            return bitmapDrawable.bitmap
        }
    }

    if ( drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0 ) {
        bitmap = Bitmap.createBitmap( 1, 1, Bitmap.Config.ARGB_8888 )
    } else {
        bitmap = Bitmap.createBitmap( drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888 )
    }

    var canvas = Canvas( bitmap )
    drawable.setBounds( 0, 0, canvas.width, canvas.height )
    drawable.draw( canvas )

    return bitmap
}