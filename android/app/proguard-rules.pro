# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.BuildConfig { *; }

# Isar database
-keep class com.isar.** { *; }
-keep class io.isar.** { *; }
-dontwarn com.isar.**
-dontwarn io.isar.**

# Google Maps
-keep class com.google.maps.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.maps.**
-dontwarn com.google.android.gms.**

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Permission Handler
-keep class com.baseflow.permission_handler.** { *; }
-dontwarn com.baseflow.permission_handler.**

# Local Auth
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn io.flutter.plugins.localauth.**

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
-dontwarn dev.fluttercommunity.plus.connectivity.**

# Keep generic signatures and annotations
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep model classes for serialization
-keepclassmembers class * {
    @com.isar.api.IsarSerializable <methods>;
}

# Suppress warnings
-dontwarn io.flutter.**
-dontwarn com.google.**
-dontwarn androidx.**
-dontwarn io.reactivex.**
-dontwarn com.squareup.**
