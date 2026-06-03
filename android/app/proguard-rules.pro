# Keep ML Kit common and barcode internals used by mobile_scanner.
-keep class com.google.mlkit.common.internal.** { *; }
-keep class com.google.mlkit.common.sdkinternal.** { *; }
-keep class com.google.mlkit.vision.barcode.internal.** { *; }
-keep class com.google.mlkit.vision.common.internal.** { *; }
-keepclassmembers class com.google.mlkit.vision.barcode.internal.** {
    native <methods>;
}

# ML Kit component discovery via reflection.
-keep class com.google.mlkit.common.internal.CommonComponentRegistrar { *; }

# JNI bridge classes.
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Parcelable implementations referenced by reflection.
-keep class * implements android.os.Parcelable { *; }

# Reduce noise from ML Kit/GMS warnings.
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
