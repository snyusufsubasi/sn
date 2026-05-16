package com.araciyok.nativeapp.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ChatBubbleOutline
import androidx.compose.material.icons.outlined.ErrorOutline
import androidx.compose.material.icons.outlined.LocalShipping
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.Star
import androidx.compose.material.icons.outlined.Verified
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.model.DetailState
import com.araciyok.nativeapp.model.JobPost
import com.araciyok.nativeapp.model.JobStatus
import com.araciyok.nativeapp.model.Offer
import com.araciyok.nativeapp.model.OfferStatus
import com.araciyok.nativeapp.model.Role
import com.araciyok.nativeapp.ui.components.AppCard
import com.araciyok.nativeapp.ui.components.EmptyState
import com.araciyok.nativeapp.ui.components.PrimaryAction
import com.araciyok.nativeapp.ui.components.PrivacyNotice
import com.araciyok.nativeapp.ui.components.RouteSummary
import com.araciyok.nativeapp.ui.components.ScreenList
import com.araciyok.nativeapp.ui.components.SecondaryAction
import com.araciyok.nativeapp.ui.components.SectionHeader
import com.araciyok.nativeapp.ui.components.StatusChip
import com.araciyok.nativeapp.ui.components.offerColor
import com.araciyok.nativeapp.ui.components.statusColor
import com.araciyok.nativeapp.ui.components.yesNo
import com.araciyok.nativeapp.ui.moneyText
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.Error
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.Success
import com.araciyok.nativeapp.ui.theme.TextMuted
import com.araciyok.nativeapp.ui.theme.Warning

@Composable
fun JobDetailScreen(vm: DemoViewModel, jobId: String) {
    val job = vm.jobs.firstOrNull { it.id == jobId }
    if (vm.detailState != DetailState.Loaded || job == null) {
        ErrorState { vm.selectedJobId = null }
        return
    }

    val isOwner = job.shipperId == vm.currentUserId
    val acceptedCarrierId = vm.acceptedCarrierId(job)
    val isAcceptedCarrier = acceptedCarrierId == vm.currentUserId
    val canSeePrivate = isOwner || isAcceptedCarrier

    ScreenList {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text("İlan Detayı", fontSize = 24.sp, fontWeight = FontWeight.Black, color = Navy)
                Text("${job.loadMode} · ${job.vehicleRequirement} · ${job.trailerType}", color = TextMuted)
            }
            StatusChip(job.status.title, statusColor(job.status))
        }
        LoadSummaryCard(job)
        RouteSummary(job)
        if (canSeePrivate) PrivateInfoCard(vm, job) else PrivacyNotice(locked = true)
        if (canSeePrivate && job.status != JobStatus.Open && job.status != JobStatus.Cancelled) {
            OperationFlow(vm, job)
        }
        when {
            isOwner && job.status == JobStatus.Open -> OwnerOffers(vm, job)
            vm.role == Role.Carrier && job.status == JobStatus.Open -> CarrierOfferActions(vm, job)
            job.status == JobStatus.Completed -> EmptyState("Teslim tamamlandı", "İki taraf teslimi onayladı. Değerlendirme kaydedildi veya yapılabilir.")
            job.status == JobStatus.Cancelled -> EmptyState("İlan iptal edildi", "Bu yük için yeni teklif veya mesajlaşma yapılamaz.")
        }
        SecondaryAction("Geri Dön") { vm.selectedJobId = null }
    }
}

@Composable
private fun LoadSummaryCard(job: JobPost) {
    AppCard(highlighted = job.status == JobStatus.OfferAccepted || job.status == JobStatus.PickupApproval || job.status == JobStatus.DeliveryApproval) {
        Text(job.cargoType, fontSize = 22.sp, color = Navy, fontWeight = FontWeight.Black)
        Text(job.description, color = TextMuted, lineHeight = 20.sp)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            StatusChip(job.loadMode, Accent)
            StatusChip("${job.weightTons} ton", Navy)
            StatusChip("${job.palletCount} palet", Accent)
        }
        Text("Hacim: ${job.volumeM3} m³ · Adet/Koli: ${job.packageCount}", color = TextMuted)
        Text("Araç: ${job.vehicleRequirement} · Kasa: ${job.trailerType}", color = TextMuted)
        Text("Forklift: yükleme ${yesNo(job.forkliftAtPickup)}, teslim ${yesNo(job.forkliftAtDelivery)}", color = TextMuted)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Outlined.Lock, contentDescription = null, tint = Accent, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(6.dp))
            Text("Açık adres, telefon, plaka ve mesajlaşma kabul sonrası görünür.", color = TextMuted, fontSize = 13.sp)
        }
    }
}

@Composable
private fun PrivateInfoCard(vm: DemoViewModel, job: JobPost) {
    AppCard(highlighted = true) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Outlined.Verified, contentDescription = null, tint = Success)
            Spacer(Modifier.width(8.dp))
            Text("Özel bilgiler açıldı", color = Navy, fontWeight = FontWeight.Black, fontSize = 18.sp)
        }
        Divider()
        Text("Yükleme: ${job.pickupAddress}", color = Navy, fontWeight = FontWeight.SemiBold)
        Text("Teslim: ${job.deliveryAddress}", color = Navy, fontWeight = FontWeight.SemiBold)
        vm.otherPartyFor(job.id)?.let {
            Text("Telefon: ${it.phone}", color = TextMuted)
            if (it.role == Role.Carrier) {
                Text("Araç: ${it.vehicleType} · ${it.capacity} · ${it.trailerType}", color = TextMuted)
                Text("Plaka: ${it.plate}", color = TextMuted)
            }
        }
    }
}

@Composable
private fun OperationFlow(vm: DemoViewModel, job: JobPost) {
    AppCard {
        SectionHeader("Operasyon akışı", "Yük alındı ve teslim edildi aşamaları çift taraflı onay ister.")
        OperationLine("1", "Teklif kabul edildi", true, "İletişim ve açık adres açıldı.")
        OperationLine("2", "Yük alındı", job.status in listOf(JobStatus.Loaded, JobStatus.OnRoad, JobStatus.DeliveryApproval, JobStatus.Completed), pickupApprovalText(job))
        OperationLine("3", "Yolda", job.status in listOf(JobStatus.OnRoad, JobStatus.DeliveryApproval, JobStatus.Completed), "Nakliyeci yükün yolda olduğunu bildirir.")
        OperationLine("4", "Teslim edildi", job.status == JobStatus.Completed, deliveryApprovalText(job))
        when (job.status) {
            JobStatus.OfferAccepted, JobStatus.PickupApproval -> PrimaryAction("Yük Alındı Onayı Ver") { vm.confirmPickup(job.id) }
            JobStatus.Loaded -> PrimaryAction("Yola Çıktım") { vm.markOnRoad(job.id) }
            JobStatus.OnRoad, JobStatus.DeliveryApproval -> PrimaryAction("Teslim Onayı Ver") { vm.confirmDelivery(job.id) }
            else -> {}
        }
        SecondaryAction("Mesajlaşmayı Aç") {
            vm.selectedChatUserId = vm.otherPartyFor(job.id)?.id
        }
    }
}

@Composable
private fun OperationLine(step: String, title: String, done: Boolean, body: String) {
    Row(verticalAlignment = Alignment.Top) {
        StatusChip(step, if (done) Success else Warning)
        Spacer(Modifier.width(10.dp))
        Column {
            Text(title, color = Navy, fontWeight = FontWeight.Black)
            Text(body, color = TextMuted, lineHeight = 19.sp)
        }
    }
}

private fun pickupApprovalText(job: JobPost): String =
    "Nakliyeci: ${if (job.pickupConfirmedByCarrier) "onayladı" else "bekliyor"} · Yükveren: ${if (job.pickupConfirmedByShipper) "onayladı" else "bekliyor"}"

private fun deliveryApprovalText(job: JobPost): String =
    "Nakliyeci: ${if (job.deliveryConfirmedByCarrier) "onayladı" else "bekliyor"} · Yükveren: ${if (job.deliveryConfirmedByShipper) "onayladı" else "bekliyor"}"

@Composable
private fun OwnerOffers(vm: DemoViewModel, job: JobPost) {
    val list = vm.offersFor(job.id)
    SectionHeader("Gelen teklifler", "${list.count { it.status == OfferStatus.Pending }} bekleyen teklif")
    if (list.isEmpty()) {
        EmptyState("Henüz teklif gelmedi.", "Nakliyeciler teklif verdiğinde burada görünecek.")
    } else {
        list.forEach { offer -> OfferCardForOwner(vm, offer) }
    }
}

@Composable
private fun OfferCardForOwner(vm: DemoViewModel, offer: Offer) {
    val carrier = vm.user(offer.carrierId)
    AppCard(highlighted = offer.status == OfferStatus.Accepted) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(carrier.name, color = Navy, fontWeight = FontWeight.Black, fontSize = 17.sp)
                Text("${carrier.vehicleType} · ${carrier.capacity} · ${carrier.trailerType}", color = TextMuted)
                Text("Bölgeler: ${carrier.preferredRegions}", color = TextMuted)
            }
            Text(moneyText(offer.amount), color = Accent, fontWeight = FontWeight.Black, fontSize = 18.sp)
        }
        Text(offer.note, color = TextMuted, lineHeight = 20.sp)
        Row(verticalAlignment = Alignment.CenterVertically) {
            StatusChip(offer.status.title, offerColor(offer.status))
            Spacer(Modifier.width(8.dp))
            Icon(Icons.Outlined.Star, contentDescription = null, tint = Accent, modifier = Modifier.size(18.dp))
            Text("${carrier.completedJobs} tamamlanan yük", color = TextMuted, fontSize = 13.sp)
        }
        if (offer.status == OfferStatus.Pending) {
            PrimaryAction("Teklifi Kabul Et") { vm.acceptOffer(offer.id) }
        }
    }
}

@Composable
private fun CarrierOfferActions(vm: DemoViewModel, job: JobPost) {
    val offer = vm.myOffer(job.id)
    if (offer == null || offer.status == OfferStatus.Withdrawn) {
        AppCard {
            SectionHeader("Teklif ver", "Açık adres ve telefon teklif kabulünden sonra açılır.")
            Text("Bu yük ${job.vehicleRequirement} ve ${job.trailerType} kasa istiyor. Yükleme: ${job.loadingMethod}.", color = TextMuted)
            PrimaryAction("Teklif Ver") { vm.createOffer(job.id) }
        }
    } else {
        AppCard(highlighted = offer.status == OfferStatus.Accepted) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Teklifiniz", color = Navy, fontWeight = FontWeight.Black, fontSize = 18.sp, modifier = Modifier.weight(1f))
                StatusChip(offer.status.title, offerColor(offer.status))
            }
            Text(moneyText(offer.amount), color = Accent, fontWeight = FontWeight.Black, fontSize = 22.sp)
            Text(offer.note, color = TextMuted)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                SecondaryAction("Düzenle", Modifier.weight(1f)) { vm.editOffer(job.id) }
                SecondaryAction("Geri Çek", Modifier.weight(1f)) { vm.withdrawOffer(job.id) }
            }
        }
    }
}

@Composable
private fun ErrorState(onBack: () -> Unit) {
    Box(Modifier.fillMaxSize().padding(24.dp), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Icon(Icons.Outlined.ErrorOutline, contentDescription = null, tint = Error, modifier = Modifier.size(58.dp))
            Text("İlan bulunamadı", color = Navy, fontWeight = FontWeight.Black, fontSize = 22.sp)
            Text("Bu ilan silinmiş olabilir veya erişim yetkiniz olmayabilir.", color = TextMuted)
            PrimaryAction("Listeye Dön") { onBack() }
        }
    }
}
