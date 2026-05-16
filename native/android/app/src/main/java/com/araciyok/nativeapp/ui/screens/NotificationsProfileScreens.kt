package com.araciyok.nativeapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Description
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.model.Role
import com.araciyok.nativeapp.ui.components.AppCard
import com.araciyok.nativeapp.ui.components.EmptyState
import com.araciyok.nativeapp.ui.components.MetricPill
import com.araciyok.nativeapp.ui.components.PersonaSwitcher
import com.araciyok.nativeapp.ui.components.ScreenList
import com.araciyok.nativeapp.ui.components.SecondaryAction
import com.araciyok.nativeapp.ui.components.SectionHeader
import com.araciyok.nativeapp.ui.components.StatusChip
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.Border
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.Success
import com.araciyok.nativeapp.ui.theme.TextMuted
import com.araciyok.nativeapp.ui.theme.Warning

@Composable
fun NotificationsScreen(vm: DemoViewModel) {
    ScreenList {
        SectionHeader(
            title = "Bildirimler",
            subtitle = "Teklif, yük alındı onayı, yola çıktı ve teslim onayı hareketleri.",
            trailing = {
                TextButton(onClick = { vm.markAllNotificationsRead() }) {
                    Text("Tümünü Okundu İşaretle", color = Accent, fontWeight = FontWeight.Bold)
                }
            }
        )
        if (vm.notifications.isEmpty()) {
            EmptyState("Bildirim yok", "Yeni teklif ve operasyon hareketleri burada görünecek.")
        } else {
            vm.notifications.take(50).forEach { item ->
                AppCard(onClick = {
                    item.read = true
                    item.jobId?.let { vm.openJob(it) }
                }) {
                    Row(verticalAlignment = Alignment.Top) {
                        Box(
                            Modifier
                                .size(12.dp)
                                .clip(CircleShape)
                                .background(if (item.read) Border else Accent)
                        )
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Outlined.Notifications, contentDescription = null, tint = if (item.read) TextMuted else Accent, modifier = Modifier.size(20.dp))
                                Spacer(Modifier.width(6.dp))
                                Text(item.title, color = Navy, fontWeight = FontWeight.Black)
                            }
                            Text(item.body, color = TextMuted, lineHeight = 20.sp)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ProfileScreen(vm: DemoViewModel) {
    val user = vm.currentUser
    ScreenList {
        SectionHeader("Profil", if (user.role == Role.Carrier) "Araç, kasa, tonaj ve bölge uygunluğu." else "Firma ve yükveren güven bilgileri.")
        AppCard(highlighted = true) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.AccountCircle, contentDescription = null, tint = Accent, modifier = Modifier.size(46.dp))
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text(user.name, color = Navy, fontWeight = FontWeight.Black, fontSize = 21.sp)
                    Text(user.companyName.ifBlank { user.role.title }, color = TextMuted)
                }
                StatusChip(if (user.role == Role.Carrier) user.documentStatus else "Aktif", if (user.documentStatus == "Onaylandı") Success else Accent)
            }
            Divider(color = Border)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                MetricPill("Puan", String.format("%.1f", user.rating), Modifier.weight(1f))
                MetricPill("Tamamlanan", user.completedJobs.toString(), Modifier.weight(1f))
            }
            ProfileLine("Telefon", user.phone)
            ProfileLine("Şehir", "${user.city} / ${user.district}")
            if (user.role == Role.Carrier) {
                ProfileLine("Araç", "${user.vehicleType} · ${user.capacity}")
                ProfileLine("Kasa", user.trailerType)
                ProfileLine("Bölgeler", user.preferredRegions)
                ProfileLine("Plaka", user.plate)
                ProfileLine("Belge Durumu", user.documentStatus)
            } else {
                ProfileLine("Firma", user.companyName)
            }
        }
        AppCard {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.Description, contentDescription = null, tint = Warning)
                Spacer(Modifier.width(10.dp))
                Column {
                    Text("Gizlilik kuralı aktif", color = Navy, fontWeight = FontWeight.Black)
                    Text("Telefon, açık adres ve plaka teklif kabulünden önce karşı tarafa gösterilmez.", color = TextMuted, lineHeight = 20.sp)
                }
            }
        }
        PersonaSwitcher(vm)
        SecondaryAction("Çıkış Yap") { vm.isLoggedIn = false }
    }
}

@Composable
private fun ProfileLine(label: String, value: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(Icons.Outlined.Person, contentDescription = null, tint = Accent, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(8.dp))
        Text("$label: ", color = TextMuted, fontWeight = FontWeight.SemiBold)
        Text(value, color = Navy, fontWeight = FontWeight.Medium)
    }
}
