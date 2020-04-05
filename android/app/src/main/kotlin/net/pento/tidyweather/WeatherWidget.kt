package net.pento.tidyweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import java.time.LocalDateTime
import kotlin.collections.HashMap

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
    Log.d( "TidyWeather", "*********** Updating Widget " )
    val prefs = context.getSharedPreferences( "net.pento.tidyweather.prefs", 0 )

    val current = prefs.getString( "current", "-" )
    val min = prefs.getString( "min", "" )
    val max = prefs.getString( "max", "" )
    val code = prefs.getString( "code", "" )
    val sunrise = prefs.getString( "sunrise", "" )
    val sunset = prefs.getString( "sunset", "" )

    val now = LocalDateTime.now()

    val night = ( now.isBefore( LocalDateTime.parse( sunrise?.replace( ' ', 'T' ) ) ) || now.isAfter( LocalDateTime.parse( sunset?.replace( ' ', 'T' ) ) ) )

    // Construct the RemoteViews object
    val views = RemoteViews( context.packageName, R.layout.weather_widget )

    val intent = Intent( context, MainActivity::class.java )

    views.setOnClickPendingIntent( R.id.current_temp, PendingIntent.getActivity( context, 1, intent, 0 ) )
    views.setOnClickPendingIntent( R.id.temp_range, PendingIntent.getActivity( context, 1, intent, 0 ) )
    views.setOnClickPendingIntent( R.id.weather_icon, PendingIntent.getActivity( context, 1, intent, 0 ) )

    views.setTextViewText( R.id.current_temp, current )
    views.setTextViewText( R.id.temp_range, "$min-$max" )

    views.setImageViewResource( R.id.weather_icon, weatherIcon( "$code", night ) )

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

internal fun weatherIcon( iconCode: String, night: Boolean ): Int {
    val iconCodes = HashMap<String, Int>()

    iconCodes[ "chance-shower-cloud" ] = R.drawable.weather_rainy
    iconCodes[ "chance-snow-cloud" ] = R.drawable.weather_snowy
    iconCodes[ "chance-thunderstorm-cloud" ] = R.drawable.weather_lightning
    iconCodes[ "chance-thunderstorm-showers" ] = R.drawable.weather_lightning_rainy
    iconCodes[ "cloudy" ] = R.drawable.weather_cloudy
    iconCodes[ "drizzle" ] = R.drawable.weather_rainy
    iconCodes[ "dust" ] = R.drawable.weather_hazy
    iconCodes[ "few-showers" ] = R.drawable.weather_rainy
    iconCodes[ "fog" ] = R.drawable.weather_fog
    iconCodes[ "frost" ] = R.drawable.weather_frost
    iconCodes[ "hail" ] = R.drawable.weather_hail
    iconCodes[ "heavy-showers-rain" ] = R.drawable.weather_pouring
    iconCodes[ "heavy-snow" ] = R.drawable.weather_snowy_heavy
    iconCodes[ "light-snow" ] = R.drawable.weather_snowy
    iconCodes[ "mostly-cloudy" ] = R.drawable.weather_cloudy
    iconCodes[ "overcast" ] = R.drawable.weather_cloudy
    iconCodes[ "showers-rain" ] = R.drawable.weather_rainy
    iconCodes[ "snow" ] = R.drawable.weather_snowy
    iconCodes[ "snow-and-rain" ] = R.drawable.weather_snowy_rainy
    iconCodes[ "thunderstorm" ] = R.drawable.weather_lightning
    iconCodes[ "wind" ] = R.drawable.weather_windy

    if ( night ) {
        iconCodes[ "fine" ] = R.drawable.weather_fine_night
        iconCodes[ "chance-shower-fine" ] = R.drawable.weather_partly_rainy_night
        iconCodes[ "chance-snow-fine" ] = R.drawable.weather_partly_snowy_night
        iconCodes[ "chance-thunderstorm-fine" ] = R.drawable.weather_partly_lightning_night
        iconCodes[ "high-cloud" ] = R.drawable.weather_partly_cloudy_night
        iconCodes[ "mostly-fine" ] = R.drawable.weather_partly_cloudy_night
        iconCodes[ "partly-cloudy" ] = R.drawable.weather_partly_cloudy_night
        iconCodes[ "shower-or-two" ] = R.drawable.weather_partly_rainy_night
    } else {
        iconCodes[ "fine" ] = R.drawable.weather_fine
        iconCodes[ "chance-shower-fine" ] = R.drawable.weather_partly_rainy
        iconCodes[ "chance-snow-fine" ] = R.drawable.weather_partly_snowy
        iconCodes[ "chance-thunderstorm-fine" ] = R.drawable.weather_partly_lightning
        iconCodes[ "high-cloud" ] = R.drawable.weather_partly_cloudy
        iconCodes[ "mostly-fine" ] = R.drawable.weather_partly_cloudy
        iconCodes[ "partly-cloudy" ] = R.drawable.weather_partly_cloudy
        iconCodes[ "shower-or-two" ] = R.drawable.weather_partly_rainy
    }

  if ( iconCodes.containsKey( iconCode ) ) {
    return iconCodes[ iconCode ]!!
  }

  return -1
}
