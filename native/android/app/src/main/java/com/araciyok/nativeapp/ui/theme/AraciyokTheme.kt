package com.araciyok.nativeapp.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val Navy = Color(0xFF17233C)
val NavySoft = Color(0xFF263852)
val Accent = Color(0xFF0B7F83)
val AccentDark = Color(0xFF08666A)
val SoftAccent = Color(0xFFDDF4F2)
val Background = Color(0xFFF5F7FA)
val Surface = Color(0xFFFFFFFF)
val SurfaceSoft = Color(0xFFF9FBFC)
val Border = Color(0xFFE1E7EF)
val Warning = Color(0xFFE87817)
val WarningSoft = Color(0xFFFFF0DD)
val Success = Color(0xFF168A4A)
val SuccessSoft = Color(0xFFE5F6EC)
val Error = Color(0xFFC93636)
val ErrorSoft = Color(0xFFFFE8E8)
val TextMuted = Color(0xFF64748B)

@Composable
fun AraciyokTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Accent,
            onPrimary = Color.White,
            secondary = Navy,
            background = Background,
            surface = Surface,
            error = Error
        ),
        content = content
    )
}
