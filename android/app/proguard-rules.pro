## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Hive/ObjectBox (you have mixed references - choose one)
# If you're using Hive:
-keep class * extends com.hivedb.model.** { *; }
-keep class * implements com.hivedb.model.** { *; }

# If you're using ObjectBox (based on your rules):
-keep class * extends io.objectbox.annotation.Entity { *; }
-keep class * implements io.objectbox.EntityInfo { *; }
-keep class io.objectbox.** { *; }
-keepclassmembers class * {
    @io.objectbox.annotation.* <fields>;
}

# Keep Hive Type Adapters if using Hive
-keep class * extends com.hivedb.model.Model
-keep @com.hivedb.model.Model class *
-keepclassmembers class * extends com.hivedb.model.Model {
    <fields>;
    <methods>;
}

## Gson
-keepattributes Signature
-keepattributes Annotation
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

## Dio
-keep class io.flutter.plugins.** { *; }

## Your app models
-keep class dev.nareph.gymgenius.models.** { *; }

## Retrofit (if you're using it)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

## Kotlin Coroutines
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

## Flutter-specific additional rules
-keep class androidx.lifecycle.DefaultLifecycleObserver

# For platform channels
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep annotations
-keepattributes *Annotation*

# Keep R8 from stripping important info
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep serialization
-keepclassmembers class **.R$* {
    public static <fields>;
}