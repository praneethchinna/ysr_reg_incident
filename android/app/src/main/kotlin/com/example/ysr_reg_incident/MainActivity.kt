package com.example.ysr_reg_incident

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.database.Cursor

class MainActivity: FlutterActivity() {
    // The channel name must match the one used on the Dart side of the Flutter app.
    private val CHANNEL = "custom_video_recorder"
    private val VIDEO_REQUEST_CODE = 1001

    // A unique request code for the camera and audio permissions.
    private val PERMISSION_REQUEST_CODE = 1002

    // A reference to the result callback. This is used to send the result back to Flutter
    // once the video recording activity is finished.
    private var resultCallback: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel to listen for calls from Flutter.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "recordLowQualityVideo" -> {
                    // Store the result callback for later use in onActivityResult.
                    // This is important because the recording process is asynchronous.
                    if (resultCallback != null) {
                        result.error("BUSY", "The video recording is already in progress.", null)
                        return@setMethodCallHandler
                    }
                    resultCallback = result

                    // Before opening the video recorder, check and request permissions.
                    if (checkAndRequestPermissions()) {
                        openLowQualityVideoRecorder()
                    }
                }
                "getFilePathFromUri" -> {
                    val uriString = call.argument<String>("uriString")
                    if (uriString != null) {
                        val filePath = getFilePathFromUri(Uri.parse(uriString))
                        result.success(filePath)
                    } else {
                        result.error("INVALID_ARGUMENT", "uriString cannot be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Helper function to check and request camera and audio permissions.
     * @return Boolean indicating if permissions are already granted.
     */
    private fun checkAndRequestPermissions(): Boolean {
        // Check for CAMERA permission
        val cameraPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)

        // Check for RECORD_AUDIO permission
        val audioPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)

        val permissionsToRequest = mutableListOf<String>()
        if (cameraPermission != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.CAMERA)
        }
        if (audioPermission != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.RECORD_AUDIO)
        }

        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), PERMISSION_REQUEST_CODE)
            return false
        }
        return true
    }

    /**
     * This method is called after the user responds to the permission request dialog.
     */
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                // All permissions were granted, so we can proceed.
                openLowQualityVideoRecorder()
            } else {
                // Permissions were denied. We should inform the user and clear the callback.
                resultCallback?.error("PERMISSION_DENIED", "Camera and/or microphone permissions were denied.", null)
                resultCallback = null
            }
        }
    }

    /**
     * This function creates and launches an Intent to open the system's video recorder.
     * The `MediaStore.EXTRA_VIDEO_QUALITY` extra is set to 0 for low quality.
     */
    private fun openLowQualityVideoRecorder() {
        val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
        // 0 = low quality, 1 = high quality. This is the key part of the request.
        intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 0)
        // Set an optional duration limit for the video in seconds.
        intent.putExtra(MediaStore.EXTRA_DURATION_LIMIT, 60)

        // Check if there is an activity that can handle this intent.
        if (intent.resolveActivity(packageManager) != null) {
            startActivityForResult(intent, VIDEO_REQUEST_CODE)
        } else {
            resultCallback?.error("UNAVAILABLE", "No video recording app is available.", null)
            resultCallback = null
        }
    }

    /**
     * This method receives the result from the video recording activity.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // Check if the request code matches our video recorder request.
        if (requestCode == VIDEO_REQUEST_CODE) {
            // Check if the recording was successful.
            if (resultCode == Activity.RESULT_OK && data != null) {
                val videoUri: Uri? = data.data
                // Return the URI of the recorded video to Flutter.
                resultCallback?.success(videoUri.toString())
            } else {
                // Return null to Flutter if the recording was cancelled or failed.
                resultCallback?.success(null)
            }
            // Clear the callback to prevent memory leaks and handle future calls.
            resultCallback = null
        }
    }

    /**
     * Helper function to get the file path from a Content URI.
     * This method queries the MediaStore to find the actual file path.
     */
    private fun getFilePathFromUri(uri: Uri): String? {
        var filePath: String? = null
        val projection = arrayOf(MediaStore.Video.Media.DATA)
        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(uri, projection, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                val columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                filePath = cursor.getString(columnIndex)
            }
        } catch (e: Exception) {
            // Handle any exceptions that occur during the query
            e.printStackTrace()
        } finally {
            cursor?.close()
        }
        return filePath
    }
}
