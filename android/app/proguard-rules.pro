# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep annotations
-keepattributes *Annotation*

# Suppress warnings for missing classes that the Android build might reference
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
