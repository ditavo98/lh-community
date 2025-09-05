package lh.community.lh_community

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Activity
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi

/** LhCommunityPlugin */
class LhCommunityPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will handle communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lh_community")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
      }
      "createFileInPublicDownload" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          val path = call.argument<String>("path")
          val displayName = call.argument<String>("display_name")
          val mimeType = call.argument<String?>("mine_type") // Note: 'mine_type' seems to be a typo; consider renaming to 'mime_type' in Flutter
          val uri = createFileInPublicDownloadsDir(path, displayName, mimeType)
          if (uri != null) {
            val mediaStorePath = getMediaStoreEntryPathApi29(uri)
            result.success(
              mapOf(
                "uri" to uri.toString(), // Use toString() for Uri to ensure full path
                "media_store_path" to mediaStorePath
              )
            )
          } else {
            result.error("500", "Failed to create file in Downloads", null)
          }
        } else {
          result.error("404", "Only supported on Build.VERSION_CODES.Q or higher", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  /**
   * Create a file inside the Download folder using MediaStore API
   */
  @RequiresApi(Build.VERSION_CODES.Q)
  private fun createFileInPublicDownloadsDir(path: String?, displayName: String?, mimeType: String?): Uri? {
    val collection: Uri = MediaStore.Downloads.EXTERNAL_CONTENT_URI
    val values = ContentValues().apply {
      put(MediaStore.Downloads.DISPLAY_NAME, displayName)
      put(MediaStore.Downloads.MIME_TYPE, mimeType)
      put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}${path ?: ""}")
    }
    val contentResolver = activity?.contentResolver ?: return null
    return try {
      contentResolver.insert(collection, values)
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }
  }

  /**
   * Get a path for a MediaStore entry as it's needed when calling MediaScanner
   */
  @RequiresApi(Build.VERSION_CODES.Q)
  private fun getMediaStoreEntryPathApi29(uri: Uri): String? {
    return try {
      activity?.contentResolver?.query(
        uri,
        arrayOf(MediaStore.Files.FileColumns.DATA),
        null,
        null,
        null
      )?.use { cursor: android.database.Cursor ->
        if (cursor.moveToFirst()) {
          cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATA))
        } else {
          null
        }
      }
    } catch (e: IllegalArgumentException) {
      e.printStackTrace()
      null
    }
  }
}