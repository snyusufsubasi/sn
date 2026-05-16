package com.araciyok.nativeapp.data

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import com.araciyok.nativeapp.model.AppMessage
import com.araciyok.nativeapp.model.AppNotification
import com.araciyok.nativeapp.model.DemoUser
import com.araciyok.nativeapp.model.DetailState
import com.araciyok.nativeapp.model.JobPost
import com.araciyok.nativeapp.model.JobStatus
import com.araciyok.nativeapp.model.Offer
import com.araciyok.nativeapp.model.OfferStatus
import com.araciyok.nativeapp.model.Review
import com.araciyok.nativeapp.model.Role
import java.time.LocalDate

class DemoViewModel : ViewModel() {
    var isLoggedIn by mutableStateOf(false)
    var currentUserId by mutableStateOf("shipper-demo")
    var currentTab by mutableIntStateOf(0)
    var selectedJobId by mutableStateOf<String?>(null)
    var selectedChatUserId by mutableStateOf<String?>(null)
    var detailState by mutableStateOf(DetailState.Loaded)
    var authError by mutableStateOf<String?>(null)
    var jobFilter by mutableStateOf("Tümü")
    var regionFilter by mutableStateOf("Tüm Bölgeler")
    var successMessage by mutableStateOf<String?>(null)

    val users = mutableStateListOf<DemoUser>()
    val jobs = mutableStateListOf<JobPost>()
    val offers = mutableStateListOf<Offer>()
    val reviews = mutableStateListOf<Review>()
    val notifications = mutableStateListOf<AppNotification>()
    val messages = mutableStateListOf<AppMessage>()

    init {
        seed()
    }

    val currentUser: DemoUser get() = users.first { it.id == currentUserId }
    val role: Role get() = currentUser.role
    val unreadMessages: Int get() = messages.count { it.toUserId == currentUserId && it.unread }
    val unreadNotifications: Int get() = notifications.count { !it.read }
    val myOpenJobs: Int get() = jobs.count { it.shipperId == currentUserId && it.status == JobStatus.Open }
    val myAcceptedJobs: Int get() = acceptedJobsForCurrentUser().size
    val myPendingOffers: Int get() = offers.count { it.carrierId == currentUserId && it.status == OfferStatus.Pending }
    val waitingApprovalJobs: Int get() = acceptedJobsForCurrentUser().count { it.status == JobStatus.PickupApproval || it.status == JobStatus.DeliveryApproval }

    fun login(phone: String, code: String) {
        authError = null
        if (!phone.replace(" ", "").startsWith("+90")) {
            authError = "Telefon numarası +90 ile başlamalı."
            return
        }
        if (code != "123456") {
            authError = "Demo kodu 123456 olmalı."
            return
        }
        isLoggedIn = true
        currentTab = 0
        selectedJobId = null
        selectedChatUserId = null
    }

    fun switchPersona(role: Role, heavy: Boolean = false) {
        currentUserId = when {
            role == Role.Shipper && heavy -> "shipper-heavy"
            role == Role.Carrier && heavy -> "carrier-heavy"
            role == Role.Shipper -> "shipper-demo"
            else -> "carrier-demo"
        }
        currentTab = 0
        selectedJobId = null
        selectedChatUserId = null
        jobFilter = "Tümü"
        regionFilter = "Tüm Bölgeler"
    }

    fun openJob(jobId: String) {
        selectedJobId = jobId
        selectedChatUserId = null
        detailState = if (jobs.any { it.id == jobId }) DetailState.Loaded else DetailState.NotFound
    }

    fun acceptOffer(offerId: String) {
        val offer = offers.firstOrNull { it.id == offerId } ?: return
        val jobIndex = jobs.indexOfFirst { it.id == offer.jobId }
        if (jobIndex < 0) return
        offers.replaceAll { existing ->
            if (existing.jobId == offer.jobId) {
                existing.copy(status = if (existing.id == offerId) OfferStatus.Accepted else OfferStatus.Rejected)
            } else {
                existing
            }
        }
        jobs[jobIndex] = jobs[jobIndex].copy(status = JobStatus.OfferAccepted, acceptedOfferId = offerId)
        notifications.add(0, AppNotification("n-${notifications.size}", "Teklif kabul edildi", "İletişim, açık adres ve operasyon akışı açıldı.", offer.jobId, false))
        messages.add(0, AppMessage("m-${messages.size}", offer.jobId, currentUserId, offer.carrierId, "Teklifinizi kabul ettim. Yükleme detaylarını buradan netleştirebiliriz.", true))
        successMessage = "Teklif kabul edildi. Operasyon akışı açıldı."
    }

    fun confirmPickup(jobId: String) {
        val job = jobs.firstOrNull { it.id == jobId } ?: return
        val isCarrier = acceptedCarrierId(job) == currentUserId
        val updated = job.copy(
            status = JobStatus.PickupApproval,
            pickupConfirmedByCarrier = job.pickupConfirmedByCarrier || isCarrier,
            pickupConfirmedByShipper = job.pickupConfirmedByShipper || !isCarrier
        )
        val finalStatus = if (updated.pickupConfirmedByCarrier && updated.pickupConfirmedByShipper) JobStatus.Loaded else JobStatus.PickupApproval
        updateJob(jobId) { updated.copy(status = finalStatus) }
        successMessage = if (finalStatus == JobStatus.Loaded) "Yük alındı iki tarafça onaylandı." else "Yük alındı onayı karşı tarafı bekliyor."
    }

    fun markOnRoad(jobId: String) {
        updateJob(jobId) { it.copy(status = JobStatus.OnRoad) }
        notifications.add(0, AppNotification("n-${notifications.size}", "Yük yola çıktı", "Nakliyeci yükün yolda olduğunu bildirdi.", jobId, false))
        successMessage = "Yük yolda olarak işaretlendi."
    }

    fun confirmDelivery(jobId: String) {
        val job = jobs.firstOrNull { it.id == jobId } ?: return
        val isCarrier = acceptedCarrierId(job) == currentUserId
        val updated = job.copy(
            status = JobStatus.DeliveryApproval,
            deliveryConfirmedByCarrier = job.deliveryConfirmedByCarrier || isCarrier,
            deliveryConfirmedByShipper = job.deliveryConfirmedByShipper || !isCarrier
        )
        val finalStatus = if (updated.deliveryConfirmedByCarrier && updated.deliveryConfirmedByShipper) JobStatus.Completed else JobStatus.DeliveryApproval
        updateJob(jobId) { updated.copy(status = finalStatus) }
        if (finalStatus == JobStatus.Completed) {
            reviews.add(Review(jobId, otherPartyFor(jobId)?.id ?: currentUserId, 5, "Yük zamanında ve sorunsuz teslim edildi."))
        }
        successMessage = if (finalStatus == JobStatus.Completed) "Teslim iki tarafça onaylandı." else "Teslim onayı karşı tarafı bekliyor."
    }

    fun createOffer(jobId: String) {
        if (offers.any { it.jobId == jobId && it.carrierId == currentUserId && it.status == OfferStatus.Pending }) return
        val job = jobs.firstOrNull { it.id == jobId }
        offers.add(
            0,
            Offer(
                id = "offer-new-${offers.size}",
                jobId = jobId,
                carrierId = currentUserId,
                amount = suggestedOfferAmount(jobId),
                note = "${currentUser.vehicleType} ${currentUser.trailerType} aracım uygun. ${job?.loadingMethod ?: "Yükleme"} şartlarına göre gelebilirim.",
                status = OfferStatus.Pending
            )
        )
        notifications.add(0, AppNotification("n-${notifications.size}", "Yeni teklif verildi", "Teklifiniz yükverene iletildi.", jobId, false))
        successMessage = "Teklifiniz yükverene gönderildi."
    }

    fun editOffer(jobId: String) {
        val index = offers.indexOfFirst { it.jobId == jobId && it.carrierId == currentUserId && it.status == OfferStatus.Pending }
        if (index >= 0) {
            offers[index] = offers[index].copy(amount = offers[index].amount + 1250, note = "Güncellendi: araç, kasa ve yükleme şartları uygun.")
            successMessage = "Teklifiniz güncellendi."
        }
    }

    fun withdrawOffer(jobId: String) {
        val index = offers.indexOfFirst { it.jobId == jobId && it.carrierId == currentUserId && it.status == OfferStatus.Pending }
        if (index >= 0) {
            offers[index] = offers[index].copy(status = OfferStatus.Withdrawn)
            successMessage = "Teklif geri çekildi."
        }
    }

    fun markAllNotificationsRead() {
        notifications.replaceAll { it.copy(read = true) }
    }

    fun clearSuccessMessage() {
        successMessage = null
    }

    fun markConversationRead(otherUserId: String) {
        messages.replaceAll {
            if (it.fromUserId == otherUserId && it.toUserId == currentUserId) it.copy(unread = false) else it
        }
    }

    fun sendMessage(text: String) {
        val other = selectedChatUserId ?: return
        val job = acceptedJobsForCurrentUser().firstOrNull {
            it.shipperId == currentUserId || acceptedCarrierId(it) == currentUserId
        }
        messages.add(AppMessage("m-${messages.size}", job?.id ?: "job-000", currentUserId, other, text, false))
    }

    fun acceptedJobsForCurrentUser(): List<JobPost> = jobs.filter { job ->
        job.status != JobStatus.Open && job.status != JobStatus.Cancelled &&
            (job.shipperId == currentUserId || acceptedCarrierId(job) == currentUserId)
    }

    fun conversations(): List<DemoUser> {
        val ids = messages
            .filter { it.fromUserId == currentUserId || it.toUserId == currentUserId }
            .flatMap { listOf(it.fromUserId, it.toUserId) }
            .filter { it != currentUserId }
            .distinct()
        return users.filter { it.id in ids }
    }

    fun recommendedJobsForCarrier(limit: Int = 6): List<JobPost> =
        jobs.filter { it.status == JobStatus.Open && it.shipperId != currentUserId }
            .sortedByDescending { matchScore(it) }
            .take(limit)

    fun filteredCarrierJobs(): List<JobPost> {
        val openJobs = jobs.filter { it.status == JobStatus.Open && it.shipperId != currentUserId }
        return openJobs.filter { job ->
            val filterOk = when (jobFilter) {
                "Komple" -> job.loadMode == "Komple"
                "Parsiyel" -> job.loadMode == "Parsiyel"
                "Forklift" -> job.forkliftAtPickup || job.forkliftAtDelivery
                "Elle Yükleme" -> job.loadingMethod.contains("Elle") || job.unloadingMethod.contains("Elle")
                "Teklif Verdiklerim" -> myOffer(job.id) != null
                else -> true
            }
            val regionOk = regionFilter == "Tüm Bölgeler" || job.pickupRegion == regionFilter || job.deliveryRegion == regionFilter
            filterOk && regionOk
        }.sortedByDescending { matchScore(it) }
    }

    fun matchScore(job: JobPost): Int {
        val user = currentUser
        var score = 0
        if (job.vehicleRequirement == user.vehicleType) score += 35
        if (job.trailerType == user.trailerType) score += 25
        if (user.preferredRegions.contains(job.pickupRegion) || user.preferredRegions.contains(job.deliveryRegion)) score += 25
        if (parseCapacity(user.capacity) >= job.weightTons) score += 15
        return score
    }

    fun otherPartyFor(jobId: String): DemoUser? {
        val job = jobs.firstOrNull { it.id == jobId } ?: return null
        return if (job.shipperId == currentUserId) {
            acceptedCarrierId(job)?.let { id -> users.firstOrNull { it.id == id } }
        } else {
            users.firstOrNull { it.id == job.shipperId }
        }
    }

    fun myOffer(jobId: String): Offer? = offers.firstOrNull { it.jobId == jobId && it.carrierId == currentUserId }
    fun offersFor(jobId: String): List<Offer> = offers.filter { it.jobId == jobId }
    fun user(id: String): DemoUser = users.firstOrNull { it.id == id } ?: users.first()
    fun acceptedCarrierId(job: JobPost): String? = offers.firstOrNull { it.id == job.acceptedOfferId }?.carrierId

    private fun updateJob(jobId: String, update: (JobPost) -> JobPost) {
        val index = jobs.indexOfFirst { it.id == jobId }
        if (index >= 0) jobs[index] = update(jobs[index])
    }

    private fun suggestedOfferAmount(jobId: String): Int {
        val job = jobs.firstOrNull { it.id == jobId } ?: return 8500
        return (6500 + (job.weightTons * 900).toInt() + job.palletCount * 180 + job.volumeM3 * 35).coerceAtLeast(7500)
    }

    private fun parseCapacity(capacity: String): Double =
        capacity.substringBefore(" ").replace(",", ".").toDoubleOrNull() ?: 0.0

    private fun seed() {
        val routes = listOf(
            Triple("İstanbul" to "Tuzla", "Marmara", "Ankara" to "Sincan"),
            Triple("Kocaeli" to "Gebze", "Marmara", "Konya" to "Karatay"),
            Triple("Bursa" to "Nilüfer", "Marmara", "İzmir" to "Kemalpaşa"),
            Triple("İzmir" to "Aliağa", "Ege", "Adana" to "Seyhan"),
            Triple("Ankara" to "Kazan", "İç Anadolu", "Gaziantep" to "Şehitkamil"),
            Triple("Mersin" to "Tarsus", "Akdeniz", "Kayseri" to "Melikgazi"),
            Triple("Sakarya" to "Arifiye", "Marmara", "Antalya" to "Döşemealtı"),
            Triple("Manisa" to "Turgutlu", "Ege", "Eskişehir" to "OSB")
        )
        val deliveryRegions = listOf("İç Anadolu", "İç Anadolu", "Ege", "Akdeniz", "Güneydoğu", "İç Anadolu", "Akdeniz", "İç Anadolu")
        val companies = listOf("Demir Çelik Lojistik", "Anka Gıda Deposu", "Mavi Palet Sanayi", "Kuzey Makine", "Ege Tekstil", "Beta Yapı Market", "Atlas Ambalaj", "Tuna Kimya")
        val loadTypes = listOf("Paletli Ürün", "Sanayi Yükü", "Makine", "İnşaat Malzemesi", "Tekstil Kolisi", "Ambalaj Malzemesi", "Gıda Dışı Ürün", "Kimyasal Olmayan Hammadde")
        val trailerTypes = listOf("Tenteli", "Frigorifik Değil", "Açık Kasa", "Kapalı Kasa")
        val loadModes = listOf("Komple", "Parsiyel")
        val loadingMethods = listOf("Forklift ile yükleme", "Elle + transpalet", "Rampa yükleme", "Vinç sahada hazır")

        users.add(DemoUser("shipper-demo", Role.Shipper, "Demo Yükveren", "+90 532 000 00 01", "İstanbul", "Tuzla", companyName = "Marmara Üretim AŞ", rating = 4.8, completedJobs = 18))
        users.add(DemoUser("shipper-heavy", Role.Shipper, "Yoğun Yükveren", "+90 532 000 00 02", "Bursa", "Nilüfer", companyName = "Bursa Sanayi Depo", rating = 4.7, completedJobs = 34))
        users.add(DemoUser("carrier-demo", Role.Carrier, "Demo Nakliyeci", "+90 532 000 00 03", "İstanbul", "Ümraniye", companyName = "Yıldız Taşıma", vehicleType = "Kamyon", capacity = "10 ton", trailerType = "Tenteli", preferredRegions = "Marmara, İç Anadolu", plate = "34 ARY 034", documentStatus = "Onaylandı", rating = 4.9, completedJobs = 42))
        users.add(DemoUser("carrier-heavy", Role.Carrier, "Tır Nakliyecisi", "+90 532 000 00 04", "Kocaeli", "Gebze", companyName = "Gebze Ağır Nakliye", vehicleType = "Tır", capacity = "24 ton", trailerType = "Tenteli", preferredRegions = "Marmara, Ege, Akdeniz", plate = "41 ARY 041", documentStatus = "Onaylandı", rating = 4.6, completedJobs = 27))

        repeat(96) { i ->
            val role = if (i < 38) Role.Shipper else Role.Carrier
            val route = routes[i % routes.size]
            val city = if (role == Role.Shipper) route.first else route.third
            val vehicle = if (i % 3 == 0) "Tır" else "Kamyon"
            users.add(
                DemoUser(
                    id = "${if (role == Role.Shipper) "shipper" else "carrier"}-$i",
                    role = role,
                    name = if (role == Role.Shipper) "${companies[i % companies.size]} Yetkilisi" else "Nakliyeci ${i + 1}",
                    phone = "+90 532 ${100 + i} ${10 + (i % 80)} ${10 + (i % 70)}",
                    city = city.first,
                    district = city.second,
                    companyName = if (role == Role.Shipper) companies[i % companies.size] else "Bireysel Nakliyeci",
                    vehicleType = if (role == Role.Carrier) vehicle else "",
                    capacity = if (role == Role.Carrier) if (vehicle == "Tır") "24 ton" else "10 ton" else "",
                    trailerType = if (role == Role.Carrier) trailerTypes[i % trailerTypes.size] else "",
                    preferredRegions = if (role == Role.Carrier) listOf("Marmara, İç Anadolu", "Ege, Akdeniz", "Marmara, Ege", "İç Anadolu, Güneydoğu")[i % 4] else "",
                    plate = if (role == Role.Carrier) "${(34 + i) % 81} YUK ${100 + i}" else "",
                    documentStatus = if (role == Role.Carrier) listOf("Onaylandı", "Onay Bekliyor", "Yüklenmedi")[i % 3] else "Yüklenmedi",
                    rating = 3.9 + ((i % 10) / 10.0),
                    completedJobs = 3 + (i % 60)
                )
            )
        }

        repeat(80) { i ->
            val route = routes[i % routes.size]
            val deliveryRegion = deliveryRegions[i % deliveryRegions.size]
            val status = listOf(JobStatus.Open, JobStatus.Open, JobStatus.Open, JobStatus.OfferAccepted, JobStatus.PickupApproval, JobStatus.Loaded, JobStatus.OnRoad, JobStatus.DeliveryApproval, JobStatus.Completed, JobStatus.Cancelled)[i % 10]
            val shipperId = when {
                i < 10 -> "shipper-demo"
                i < 22 -> "shipper-heavy"
                else -> "shipper-${i % 38}"
            }
            val accepted = if (status == JobStatus.Open || status == JobStatus.Cancelled) null else "offer-accepted-$i"
            val loadMode = loadModes[i % loadModes.size]
            val vehicle = if (i % 3 == 0 || i % 5 == 0) "Tır" else "Kamyon"
            val pallet = if (loadMode == "Komple") 18 + (i % 16) else 4 + (i % 8)
            val weight = if (vehicle == "Tır") 14.0 + (i % 11) else 3.5 + (i % 7)
            val pickupConfirmedByCarrier = status in listOf(JobStatus.Loaded, JobStatus.OnRoad, JobStatus.DeliveryApproval, JobStatus.Completed) || (status == JobStatus.PickupApproval && i % 2 == 0)
            val pickupConfirmedByShipper = status in listOf(JobStatus.Loaded, JobStatus.OnRoad, JobStatus.DeliveryApproval, JobStatus.Completed) || (status == JobStatus.PickupApproval && i % 2 == 1)
            val deliveryConfirmedByCarrier = status == JobStatus.Completed || (status == JobStatus.DeliveryApproval && i % 2 == 0)
            val deliveryConfirmedByShipper = status == JobStatus.Completed || (status == JobStatus.DeliveryApproval && i % 2 == 1)
            jobs.add(
                JobPost(
                    id = "job-$i",
                    shipperId = shipperId,
                    cargoType = loadTypes[i % loadTypes.size],
                    description = "${loadTypes[i % loadTypes.size]} taşınacak. $loadMode yük, $pallet palet, ${String.format("%.1f", weight)} ton. ${loadingMethods[i % loadingMethods.size]} yapılacak.",
                    loadMode = loadMode,
                    weightTons = weight,
                    volumeM3 = if (vehicle == "Tır") 72 - (i % 12) else 38 - (i % 8),
                    palletCount = pallet,
                    packageCount = pallet * (8 + (i % 5)),
                    vehicleRequirement = vehicle,
                    trailerType = trailerTypes[i % trailerTypes.size],
                    loadingMethod = loadingMethods[i % loadingMethods.size],
                    unloadingMethod = loadingMethods[(i + 1) % loadingMethods.size],
                    forkliftAtPickup = i % 4 != 1,
                    forkliftAtDelivery = i % 5 != 2,
                    pickupCity = route.first.first,
                    pickupDistrict = route.first.second,
                    pickupRegion = route.second,
                    deliveryCity = route.third.first,
                    deliveryDistrict = route.third.second,
                    deliveryRegion = deliveryRegion,
                    pickupDate = LocalDate.now().plusDays((i + 1).toLong()).toString(),
                    urgency = listOf("Normal", "Acil", "Çok Acil")[i % 3],
                    status = status,
                    acceptedOfferId = accepted,
                    pickupAddress = "${route.first.second} OSB ${10 + i}. Cadde Yükleme Kapısı ${i % 4 + 1}",
                    deliveryAddress = "${route.third.second} Lojistik Depo ${20 + i}. Sokak",
                    pickupConfirmedByCarrier = pickupConfirmedByCarrier,
                    pickupConfirmedByShipper = pickupConfirmedByShipper,
                    deliveryConfirmedByCarrier = deliveryConfirmedByCarrier,
                    deliveryConfirmedByShipper = deliveryConfirmedByShipper
                )
            )
        }

        var offerNo = 0
        jobs.forEachIndexed { index, job ->
            repeat(index % 5) { k ->
                val accepted = job.acceptedOfferId != null && k == 0
                val carrierId = if (index < 20 || offerNo < 35) "carrier-demo" else if (offerNo < 70) "carrier-heavy" else "carrier-${38 + (offerNo % 58)}"
                offers.add(
                    Offer(
                        id = if (accepted) job.acceptedOfferId!! else "offer-$offerNo",
                        jobId = job.id,
                        carrierId = carrierId,
                        amount = suggestedSeedAmount(job, k),
                        note = "${job.vehicleRequirement} ${job.trailerType} uygun. ${job.loadingMethod.lowercase()} şartına göre araç hazır.",
                        status = if (accepted) OfferStatus.Accepted else listOf(OfferStatus.Pending, OfferStatus.Pending, OfferStatus.Rejected, OfferStatus.Withdrawn)[offerNo % 4]
                    )
                )
                offerNo++
            }
        }
        while (offers.size < 160) {
            val i = offers.size
            val job = jobs[i % jobs.size]
            offers.add(Offer("offer-extra-$i", job.id, if (i % 2 == 0) "carrier-heavy" else "carrier-demo", suggestedSeedAmount(job, i % 4), "Demo teklif: araç, kasa ve tonaj uyumu var.", listOf(OfferStatus.Pending, OfferStatus.Accepted, OfferStatus.Rejected, OfferStatus.Withdrawn)[i % 4]))
        }
        repeat(80) { i ->
            reviews.add(Review(jobs[i % jobs.size].id, users[(i + 5) % users.size].id, 1 + (i % 5), listOf("Yükleme saatine uydu.", "İletişim netti.", "Teslimat sorunsuzdu.", "Araç yük tipine uygundu.", "Tekrar çalışırım.")[i % 5]))
        }
        repeat(50) { i ->
            notifications.add(AppNotification("notif-$i", listOf("Yeni teklif geldi", "Teklif kabul edildi", "Yük alındı onayı bekliyor", "Teslim onayı bekliyor")[i % 4], "İlgili ilana dokunarak operasyon detayına gidebilirsiniz.", jobs[i % jobs.size].id, i % 3 == 0))
        }
        repeat(24) { i ->
            val other = if (i % 2 == 0) "carrier-demo" else "shipper-demo"
            messages.add(
                AppMessage(
                    id = "msg-$i",
                    jobId = jobs[i % jobs.size].id,
                    fromUserId = if (i % 3 == 0) other else currentUserId,
                    toUserId = if (i % 3 == 0) currentUserId else other,
                    text = listOf("Merhaba, yükleme saatini netleştirelim.", "Forklift sahada hazır olacak.", "Araç tonaj ve kasa olarak uygun.", "Teslim onayını buradan takip edelim.")[i % 4],
                    unread = i % 4 == 0
                )
            )
        }
    }

    private fun suggestedSeedAmount(job: JobPost, extra: Int): Int =
        7000 + (job.weightTons * 950).toInt() + job.palletCount * 220 + extra * 1250
}
