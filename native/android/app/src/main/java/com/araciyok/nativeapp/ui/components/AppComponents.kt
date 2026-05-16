package com.araciyok.nativeapp.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material.icons.outlined.KeyboardArrowRight
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.LocationOn
import androidx.compose.material.icons.outlined.Verified
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.model.JobPost
import com.araciyok.nativeapp.model.JobStatus
import com.araciyok.nativeapp.model.OfferStatus
import com.araciyok.nativeapp.model.Role
import com.araciyok.nativeapp.ui.routeText
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.Background
import com.araciyok.nativeapp.ui.theme.Border
import com.araciyok.nativeapp.ui.theme.Error
import com.araciyok.nativeapp.ui.theme.ErrorSoft
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.SoftAccent
import com.araciyok.nativeapp.ui.theme.Success
import com.araciyok.nativeapp.ui.theme.SuccessSoft
import com.araciyok.nativeapp.ui.theme.Surface
import com.araciyok.nativeapp.ui.theme.SurfaceSoft
import com.araciyok.nativeapp.ui.theme.TextMuted
import com.araciyok.nativeapp.ui.theme.Warning
import com.araciyok.nativeapp.ui.theme.WarningSoft

@Composable
fun ScreenList(content: @Composable ColumnScope.() -> Unit) {
    androidx.compose.foundation.lazy.LazyColumn(
        modifier = Modifier
            .background(Background)
            .fillMaxSize()
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(4.dp)) }
        item { Column(verticalArrangement = Arrangement.spacedBy(12.dp), content = content) }
        item { Spacer(Modifier.height(28.dp)) }
    }
}

@Composable
fun AppCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    highlighted: Boolean = false,
    content: @Composable ColumnScope.() -> Unit
) {
    AnimatedVisibility(
        visible = true,
        enter = fadeIn() + slideInVertically(initialOffsetY = { it / 8 }),
        exit = fadeOut()
    ) {
        Card(
            modifier = modifier
                .fillMaxWidth()
                .animateContentSize()
                .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = if (highlighted) SoftAccent else Surface),
            border = BorderStroke(1.dp, if (highlighted) Accent.copy(alpha = 0.25f) else Border),
            elevation = CardDefaults.cardElevation(defaultElevation = if (highlighted) 3.dp else 1.dp)
        ) {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp), content = content)
        }
    }
}

@Composable
fun SectionHeader(title: String, subtitle: String? = null, trailing: @Composable (() -> Unit)? = null) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
        Column(Modifier.weight(1f)) {
            Text(title, color = Navy, fontWeight = FontWeight.Black, fontSize = 21.sp)
            if (subtitle != null) Text(subtitle, color = TextMuted, fontSize = 14.sp, lineHeight = 18.sp)
        }
        trailing?.invoke()
    }
}

@Composable
fun HeroHeader(title: String, subtitle: String, icon: ImageVector) {
    AppCard(highlighted = true) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Surface(color = Surface, shape = CircleShape, border = BorderStroke(1.dp, Border)) {
                Icon(icon, contentDescription = null, tint = Accent, modifier = Modifier.padding(12.dp).size(30.dp))
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(title, color = Navy, fontSize = 23.sp, fontWeight = FontWeight.Black)
                Text(subtitle, color = TextMuted, fontSize = 15.sp, lineHeight = 20.sp)
            }
        }
    }
}

@Composable
fun StatusChip(text: String, color: Color) {
    val background = when (color) {
        Success -> SuccessSoft
        Error -> ErrorSoft
        Warning -> WarningSoft
        else -> SoftAccent
    }
    AssistChip(
        onClick = {},
        label = { Text(text, color = color, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1) },
        border = BorderStroke(0.dp, Color.Transparent),
        colors = androidx.compose.material3.AssistChipDefaults.assistChipColors(containerColor = background)
    )
}

@Composable
fun MetricPill(title: String, value: String, modifier: Modifier = Modifier) {
    Surface(modifier = modifier, color = SurfaceSoft, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, Border)) {
        Column(Modifier.padding(12.dp)) {
            Text(value, color = Navy, fontWeight = FontWeight.Black, fontSize = 20.sp)
            Text(title, color = TextMuted, fontSize = 12.sp, maxLines = 1)
        }
    }
}

@Composable
fun FilterBar(options: List<String>, selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        options.forEach { option ->
            FilterChip(
                selected = selected == option,
                onClick = { onSelect(option) },
                label = { Text(option, fontWeight = if (selected == option) FontWeight.Bold else FontWeight.Medium) }
            )
        }
    }
}

@Composable
fun PrimaryAction(text: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = modifier.fillMaxWidth().height(52.dp),
        shape = RoundedCornerShape(14.dp),
        colors = ButtonDefaults.buttonColors(containerColor = Accent)
    ) {
        Text(text, fontWeight = FontWeight.Bold, fontSize = 16.sp)
    }
}

@Composable
fun SecondaryAction(text: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.fillMaxWidth().height(50.dp),
        shape = RoundedCornerShape(14.dp),
        border = BorderStroke(1.dp, Border)
    ) {
        Text(text, color = Navy, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun EmptyState(title: String, body: String) {
    AppCard {
        Icon(Icons.Outlined.CheckCircle, contentDescription = null, tint = Accent, modifier = Modifier.size(30.dp))
        Text(title, color = Navy, fontWeight = FontWeight.Bold, fontSize = 17.sp)
        Text(body, color = TextMuted, lineHeight = 20.sp)
    }
}

@Composable
fun PrivacyNotice(locked: Boolean = true) {
    AppCard(highlighted = !locked) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(if (locked) Icons.Outlined.Lock else Icons.Outlined.Verified, contentDescription = null, tint = if (locked) Warning else Success)
            Spacer(Modifier.width(10.dp))
            Column {
                Text(if (locked) "Gizli bilgiler korunuyor" else "Özel bilgiler açıldı", color = Navy, fontWeight = FontWeight.Bold)
                Text(
                    if (locked) "Açık adres, telefon, plaka ve mesajlaşma sadece teklif kabulünden sonra açılır."
                    else "Eşleşme tamamlandı. İki taraf da gerekli iletişim ve adres bilgilerini görebilir.",
                    color = TextMuted,
                    lineHeight = 20.sp
                )
            }
        }
    }
}

@Composable
fun RouteSummary(job: JobPost) {
    AppCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Outlined.LocationOn, contentDescription = null, tint = Accent)
            Spacer(Modifier.width(8.dp))
            Text("Rota ve yükleme", color = Navy, fontWeight = FontWeight.Black, fontSize = 18.sp)
        }
        Divider(color = Border)
        Text("Yükleme: ${job.pickupCity} / ${job.pickupDistrict} (${job.pickupRegion})", color = Navy, fontWeight = FontWeight.SemiBold)
        Text("Teslim: ${job.deliveryCity} / ${job.deliveryDistrict} (${job.deliveryRegion})", color = Navy, fontWeight = FontWeight.SemiBold)
        Text("Yükleme tipi: ${job.loadingMethod}", color = TextMuted)
        Text("Boşaltma tipi: ${job.unloadingMethod}", color = TextMuted)
        Text("Forklift: yükleme ${yesNo(job.forkliftAtPickup)}, teslim ${yesNo(job.forkliftAtDelivery)}", color = TextMuted)
        Text("Tarih: ${job.pickupDate}", color = TextMuted)
    }
}

@Composable
fun MessageBubble(text: String, mine: Boolean) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = if (mine) Arrangement.End else Arrangement.Start) {
        Surface(
            color = if (mine) Accent else Surface,
            shape = RoundedCornerShape(
                topStart = 18.dp,
                topEnd = 18.dp,
                bottomStart = if (mine) 18.dp else 4.dp,
                bottomEnd = if (mine) 4.dp else 18.dp
            ),
            border = if (mine) null else BorderStroke(1.dp, Border),
            shadowElevation = 1.dp,
            modifier = Modifier.fillMaxWidth(0.82f)
        ) {
            Text(text, color = if (mine) Color.White else Navy, modifier = Modifier.padding(13.dp), lineHeight = 20.sp)
        }
    }
}

@Composable
fun AnimatedBadge(count: Int, content: @Composable () -> Unit) {
    val scale by animateFloatAsState(targetValue = if (count > 0) 1.08f else 1f, label = "badgeScale")
    if (count > 0) {
        BadgedBox(
            badge = {
                Badge(containerColor = Error) {
                    Text(if (count > 99) "99+" else count.toString(), color = Color.White)
                }
            },
            modifier = Modifier.scale(scale)
        ) { content() }
    } else {
        content()
    }
}

@Composable
fun PersonaSwitcher(vm: DemoViewModel) {
    AppCard {
        Text("Demo kullanıcı değiştir", color = Navy, fontWeight = FontWeight.Bold)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            SecondaryAction("Yükveren", Modifier.weight(1f)) { vm.switchPersona(Role.Shipper) }
            SecondaryAction("Nakliyeci", Modifier.weight(1f)) { vm.switchPersona(Role.Carrier) }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            SecondaryAction("Yoğun Yükveren", Modifier.weight(1f)) { vm.switchPersona(Role.Shipper, heavy = true) }
            SecondaryAction("Tır Nakliyecisi", Modifier.weight(1f)) { vm.switchPersona(Role.Carrier, heavy = true) }
        }
    }
}

@Composable
fun JobCard(vm: DemoViewModel, job: JobPost) {
    val offered = vm.myOffer(job.id) != null
    AppCard(onClick = { vm.openJob(job.id) }, highlighted = job.status == JobStatus.OfferAccepted || job.status == JobStatus.PickupApproval || job.status == JobStatus.DeliveryApproval) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            StatusChip(job.status.title, statusColor(job.status))
            if (offered) {
                Spacer(Modifier.width(6.dp))
                StatusChip("Teklif verdiniz", Success)
            }
            Spacer(Modifier.weight(1f))
            if (job.urgency != "Normal") StatusChip(job.urgency, Warning)
        }
        Text(job.cargoType, color = Navy, fontWeight = FontWeight.Black, fontSize = 18.sp)
        Text(routeText(job.pickupCity, job.pickupDistrict, job.deliveryCity, job.deliveryDistrict), color = Navy, fontWeight = FontWeight.SemiBold)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            StatusChip(job.loadMode, Accent)
            StatusChip("${job.weightTons} ton", Navy)
            StatusChip("${job.palletCount} palet", Accent)
        }
        Text("${job.vehicleRequirement} · ${job.trailerType} · ${job.loadingMethod}", color = TextMuted, maxLines = 1, overflow = TextOverflow.Ellipsis)
        Text(job.description, color = TextMuted, maxLines = 2, overflow = TextOverflow.Ellipsis, lineHeight = 20.sp)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(job.pickupDate, color = TextMuted, modifier = Modifier.weight(1f))
            Icon(Icons.Outlined.KeyboardArrowRight, contentDescription = null, tint = TextMuted)
        }
    }
}

fun statusColor(status: JobStatus): Color = when (status) {
    JobStatus.Open -> Warning
    JobStatus.OfferAccepted -> Accent
    JobStatus.PickupApproval -> Warning
    JobStatus.Loaded -> Accent
    JobStatus.OnRoad -> Navy
    JobStatus.DeliveryApproval -> Warning
    JobStatus.Completed -> Success
    JobStatus.Cancelled -> Error
}

fun offerColor(status: OfferStatus): Color = when (status) {
    OfferStatus.Accepted -> Success
    OfferStatus.Rejected -> Error
    OfferStatus.Withdrawn -> TextMuted
    OfferStatus.Pending -> Warning
}

fun yesNo(value: Boolean): String = if (value) "var" else "yok"
