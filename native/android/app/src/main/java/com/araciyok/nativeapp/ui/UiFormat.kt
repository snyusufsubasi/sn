package com.araciyok.nativeapp.ui

import java.text.NumberFormat
import java.util.Locale

private val TurkishLocale = Locale("tr", "TR")

fun moneyText(amount: Int): String = NumberFormat.getNumberInstance(TurkishLocale).format(amount) + " TL"

fun routeText(fromCity: String, fromDistrict: String, toCity: String, toDistrict: String): String =
    "$fromCity/$fromDistrict → $toCity/$toDistrict"
