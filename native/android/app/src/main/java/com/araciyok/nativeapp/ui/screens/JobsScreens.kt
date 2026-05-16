package com.araciyok.nativeapp.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Inventory2
import androidx.compose.material.icons.outlined.LocalShipping
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.model.JobStatus
import com.araciyok.nativeapp.ui.components.AppCard
import com.araciyok.nativeapp.ui.components.EmptyState
import com.araciyok.nativeapp.ui.components.FilterBar
import com.araciyok.nativeapp.ui.components.HeroHeader
import com.araciyok.nativeapp.ui.components.JobCard
import com.araciyok.nativeapp.ui.components.MetricPill
import com.araciyok.nativeapp.ui.components.PersonaSwitcher
import com.araciyok.nativeapp.ui.components.PrimaryAction
import com.araciyok.nativeapp.ui.components.ScreenList
import com.araciyok.nativeapp.ui.components.SectionHeader
import com.araciyok.nativeapp.ui.components.StatusChip
import com.araciyok.nativeapp.ui.components.statusColor
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.TextMuted

@Composable
fun ShipperHomeScreen(vm: DemoViewModel) {
    val items = vm.jobs.filter { it.shipperId == vm.currentUserId }
    val pendingOffers = items.sumOf { job -> vm.offersFor(job.id).count { it.status.title == "Beklemede" } }
    ScreenList {
        HeroHeader(
            title = "Yük ilanlarınızı yönetin",
            subtitle = "Kamyon ve tır nakliyecilerinden gelen teklifleri, yükleme ve teslim onaylarını takip edin.",
            icon = Icons.Outlined.Inventory2
        )
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            MetricPill("Açık ilan", vm.myOpenJobs.toString(), Modifier.weight(1f))
            MetricPill("Bekleyen teklif", pendingOffers.toString(), Modifier.weight(1f))
            MetricPill("Onay bekleyen", vm.waitingApprovalJobs.toString(), Modifier.weight(1f))
        }
        PrimaryAction("Yeni Yük İlanı Oluştur") {
            vm.successMessage = "Demo form sonraki turda: yük tipi, tonaj, palet, forklift ve kasa bilgileriyle açılacak."
        }
        PersonaSwitcher(vm)
        SectionHeader("Aktif yükler", "Açık, teklifli ve operasyon sürecindeki yükleriniz.")
        if (items.isEmpty()) {
            EmptyState("Henüz yük ilanınız yok.", "Palet, tonaj ve yükleme şartlarını girerek ilan oluşturabilirsiniz.")
        } else {
            items.take(12).forEach { JobCard(vm, it) }
        }
    }
}

@Composable
fun CarrierHomeScreen(vm: DemoViewModel) {
    val recommendations = vm.recommendedJobsForCarrier()
    ScreenList {
        HeroHeader(
            title = "Aracınıza uygun yükler",
            subtitle = "${vm.currentUser.vehicleType} · ${vm.currentUser.capacity} · ${vm.currentUser.trailerType} için en uygun ilanlar.",
            icon = Icons.Outlined.LocalShipping
        )
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            MetricPill("Uygun ilan", recommendations.size.toString(), Modifier.weight(1f))
            MetricPill("Bekleyen teklif", vm.myPendingOffers.toString(), Modifier.weight(1f))
            MetricPill("Onay bekleyen", vm.waitingApprovalJobs.toString(), Modifier.weight(1f))
        }
        AppCard {
            Text("Eşleşme kriterleri", color = Navy, fontWeight = androidx.compose.ui.text.font.FontWeight.Black)
            Text("Araç tipi, tonaj kapasitesi, kasa tipi, çıkış/varış bölgesi ve yükleme yöntemi birlikte değerlendirilir.", color = TextMuted)
        }
        SectionHeader("Önerilen yükler", "En yüksek araç + rota + yük uyumuna göre sıralandı.")
        if (recommendations.isEmpty()) {
            EmptyState("Uygun yük bulunamadı.", "İlanlar sekmesindeki filtreleri değiştirerek tüm açık yükleri görebilirsiniz.")
        } else {
            recommendations.forEach { JobCard(vm, it) }
        }
    }
}

@Composable
fun MyJobsScreen(vm: DemoViewModel) {
    val items = vm.jobs.filter { it.shipperId == vm.currentUserId }
    ScreenList {
        SectionHeader("İlanlar", "Yükveren ilanları ve gelen teklifler.")
        if (items.isEmpty()) {
            EmptyState("Henüz yük ilanınız yok.", "Yeni yük ilanı oluşturarak teklif almaya başlayın.")
        } else {
            items.forEach { JobCard(vm, it) }
        }
    }
}

@Composable
fun CarrierJobsScreen(vm: DemoViewModel) {
    var search by remember { mutableStateOf("") }
    val jobs = vm.filteredCarrierJobs().filter {
        val haystack = "${it.pickupCity} ${it.pickupDistrict} ${it.pickupRegion} ${it.deliveryCity} ${it.deliveryDistrict} ${it.deliveryRegion} ${it.cargoType} ${it.vehicleRequirement} ${it.trailerType}".lowercase()
        haystack.contains(search.lowercase())
    }
    ScreenList {
        SectionHeader("İlanlar", "Şehir, bölge, araç, yük tipi ve yükleme şartlarına göre filtreleyin.")
        OutlinedTextField(
            value = search,
            onValueChange = { search = it },
            label = { Text("Şehir, bölge, yük veya kasa ara") },
            leadingIcon = { Icon(Icons.Outlined.Search, contentDescription = null) },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
            modifier = Modifier.fillMaxWidth()
        )
        FilterBar(
            options = listOf("Tümü", "Komple", "Parsiyel", "Forklift", "Elle Yükleme", "Teklif Verdiklerim"),
            selected = vm.jobFilter,
            onSelect = { vm.jobFilter = it }
        )
        FilterBar(
            options = listOf("Tüm Bölgeler", "Marmara", "Ege", "İç Anadolu", "Akdeniz", "Güneydoğu"),
            selected = vm.regionFilter,
            onSelect = { vm.regionFilter = it }
        )
        SectionHeader("Açık yük ilanları", "${jobs.size} uygun ilan listeleniyor.")
        if (jobs.isEmpty()) {
            EmptyState("Uygun yük bulunamadı.", "Filtreleri gevşeterek veya farklı bölge arayarak tekrar deneyin.")
        } else {
            jobs.take(50).forEach { JobCard(vm, it) }
        }
    }
}
