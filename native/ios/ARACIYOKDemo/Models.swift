import Foundation

enum UserRole: String {
    case shipper
    case carrier

    var title: String {
        switch self {
        case .shipper: return "Yükveren"
        case .carrier: return "Nakliyeci"
        }
    }
}

enum JobStatus: String {
    case open
    case offerAccepted
    case inProgress
    case completed
    case cancelled

    var title: String {
        switch self {
        case .open: return "Açık"
        case .offerAccepted: return "Teklif Kabul Edildi"
        case .inProgress: return "Taşıma Başladı"
        case .completed: return "Tamamlandı"
        case .cancelled: return "İptal Edildi"
        }
    }
}

enum OfferStatus: String {
    case pending
    case accepted
    case rejected
    case withdrawn

    var title: String {
        switch self {
        case .pending: return "Beklemede"
        case .accepted: return "Kabul Edildi"
        case .rejected: return "Reddedildi"
        case .withdrawn: return "Geri Çekildi"
        }
    }
}

struct DemoUser: Identifiable {
    let id: String
    let role: UserRole
    let name: String
    let phone: String
    let city: String
    let district: String
    var vehicleType: String = ""
    var capacity: String = ""
    var plate: String = ""
    var documentStatus: String = "Yüklenmedi"
    var rating: Double = 4.6
    var completedJobs: Int = 0
}

struct JobPost: Identifiable {
    let id: String
    let shipperId: String
    let cargoType: String
    let description: String
    let pickupCity: String
    let pickupDistrict: String
    let deliveryCity: String
    let deliveryDistrict: String
    let pickupDate: String
    let urgency: String
    var status: JobStatus
    var acceptedOfferId: String?
    let pickupAddress: String
    let deliveryAddress: String
}

struct Offer: Identifiable {
    let id: String
    let jobId: String
    let carrierId: String
    var amount: Int
    var note: String
    var status: OfferStatus
}

struct DemoMessage: Identifiable {
    let id: String
    let jobId: String
    let fromUserId: String
    let toUserId: String
    let text: String
    var unread: Bool
}

struct DemoNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let jobId: String?
    var read: Bool
}
