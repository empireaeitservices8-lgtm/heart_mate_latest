# ProGuard Rules for HeartMate
# Add any custom rules here to prevent R8 from stripping or obfuscating specific classes.

# Flutter default rules are automatically applied by the Flutter SDK.

# Agora RTC SDK rules (if needed, though Agora usually packages its own rules):
# -keep class io.agora.** { *; }
# -dontwarn io.agora.**
