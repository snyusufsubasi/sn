package com.araciyok.nativeapp.model

enum class Role(val title: String) {
    Shipper("Yükveren"),
    Carrier("Nakliyeci")
}

enum class JobStatus(val title: String) {
    Open("Açık"),
    OfferAccepted("Teklif Kabul Edildi"),
    PickupApproval("Yük Alındı Onayı"),
    Loaded("Yük Alındı"),
    OnRoad("Yolda"),
    DeliveryApproval("Teslim Onayı"),
    Completed("Teslim Edildi"),
    Cancelled("İptal Edildi")
}

enum class OfferStatus(val title: String) {
    Pending("Beklemede"),
    Accepted("Kabul Edildi"),
    Rejected("Reddedildi"),
    Withdrawn("Geri Çekildi")
}

enum class DetailState {
    Loading,
    Loaded,
    NotFound,
    Unauthorized,
    Timeout,
    Error
}

data class DemoUser(
    val id: String,
    val role: Role,
    val name: String,
    val phone: String,
    val city: String,
    val district: String,
    val companyName: String = "",
    val vehicleType: String = "",
    val capacity: String = "",
    val trailerType: String = "",
    val preferredRegions: String = "",
    val plate: String = "",
    val documentStatus: String = "Yüklenmedi",
    val rating: Double = 4.6,
    val completedJobs: Int = 0
)

data class JobPost(
    val id: String,
    val shipperId: String,
    val cargoType: String,
    val description: String,
    val loadMode: String,
    val weightTons: Double,
    val volumeM3: Int,
    val palletCount: Int,
    val packageCount: Int,
    val vehicleRequirement: String,
    val trailerType: String,
    val loadingMethod: String,
    val unloadingMethod: String,
    val forkliftAtPickup: Boolean,
    val forkliftAtDelivery: Boolean,
    val pickupCity: String,
    val pickupDistrict: String,
    val pickupRegion: String,
    val deliveryCity: String,
    val deliveryDistrict: String,
    val deliveryRegion: String,
    val pickupDate: String,
    val urgency: String,
    val status: JobStatus,
    val acceptedOfferId: String? = null,
    val pickupAddress: String,
    val deliveryAddress: String,
    val pickupConfirmedByCarrier: Boolean = false,
    val pickupConfirmedByShipper: Boolean = false,
    val deliveryConfirmedByCarrier: Boolean = false,
    val deliveryConfirmedByShipper: Boolean = false
)

data class Offer(
    val id: String,
    val jobId: String,
    val carrierId: String,
    val amount: Int,
    val note: String,
    val status: OfferStatus
)

data class Review(
    val jobId: String,
    val userId: String,
    val rating: Int,
    val comment: String
)

data class AppMessage(
    val id: String,
    val jobId: String,
    val fromUserId: String,
    val toUserId: String,
    val text: String,
    val unread: Boolean
)

data class AppNotification(
    val id: String,
    val title: String,
    val body: String,
    val jobId: String?,
    var read: Boolean
)
