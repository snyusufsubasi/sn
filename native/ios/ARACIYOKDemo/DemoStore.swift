import Foundation

final class DemoStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUserId = "shipper-demo"
    @Published var selectedJobId: String?
    @Published var selectedChatUserId: String?
    @Published var authError: String?

    @Published var users: [DemoUser] = []
    @Published var jobs: [JobPost] = []
    @Published var offers: [Offer] = []
    @Published var messages: [DemoMessage] = []
    @Published var notifications: [DemoNotification] = []

    init() {
        seed()
    }

    var currentUser: DemoUser { users.first { $0.id == currentUserId }! }
    var unreadMessages: Int { messages.filter { $0.toUserId == currentUserId && $0.unread }.count }
    var unreadNotifications: Int { notifications.filter { !$0.read }.count }

    func login(phone: String, code: String) {
        authError = nil
        guard phone.replacingOccurrences(of: " ", with: "").hasPrefix("+90") else {
            authError = "Telefon numarası +90 ile başlamalı."
            return
        }
        guard code == "123456" else {
            authError = "Demo kodu 123456 olmalı."
            return
        }
        isLoggedIn = true
    }

    func switchPersona(_ role: UserRole, heavy: Bool = false) {
        if role == .shipper {
            currentUserId = heavy ? "shipper-heavy" : "shipper-demo"
        } else {
            currentUserId = heavy ? "carrier-heavy" : "carrier-demo"
        }
        selectedJobId = nil
        selectedChatUserId = nil
    }

    func acceptOffer(_ offerId: String) {
        guard let offerIndex = offers.firstIndex(where: { $0.id == offerId }),
              let jobIndex = jobs.firstIndex(where: { $0.id == offers[offerIndex].jobId }) else { return }
        let jobId = offers[offerIndex].jobId
        for index in offers.indices where offers[index].jobId == jobId {
            offers[index].status = offers[index].id == offerId ? .accepted : .rejected
        }
        jobs[jobIndex].status = .offerAccepted
        jobs[jobIndex].acceptedOfferId = offerId
        messages.insert(DemoMessage(id: "m-\(messages.count)", jobId: jobId, fromUserId: currentUserId, toUserId: offers[offerIndex].carrierId, text: "Teklifinizi kabul ettim. Detayları buradan konuşabiliriz.", unread: true), at: 0)
    }

    func createOffer(jobId: String) {
        offers.append(Offer(id: "offer-new-\(offers.count)", jobId: jobId, carrierId: currentUserId, amount: 8500, note: "Uygun tarihte sigortalı taşıma yapabilirim.", status: .pending))
    }

    func acceptedCarrierId(for job: JobPost) -> String? {
        guard let offerId = job.acceptedOfferId else { return nil }
        return offers.first { $0.id == offerId }?.carrierId
    }

    func conversations() -> [DemoUser] {
        let ids = Set(messages.filter { $0.fromUserId == currentUserId || $0.toUserId == currentUserId }.flatMap { [$0.fromUserId, $0.toUserId] }.filter { $0 != currentUserId })
        return users.filter { ids.contains($0.id) }
    }

    private func seed() {
        users = [
            DemoUser(id: "shipper-demo", role: .shipper, name: "Demo Yükveren", phone: "+90 532 000 00 01", city: "İstanbul", district: "Tuzla", rating: 4.8, completedJobs: 18),
            DemoUser(id: "shipper-heavy", role: .shipper, name: "Yoğun Yükveren", phone: "+90 532 000 00 02", city: "Bursa", district: "Nilüfer", rating: 4.7, completedJobs: 34),
            DemoUser(id: "carrier-demo", role: .carrier, name: "Demo Nakliyeci", phone: "+90 532 000 00 03", city: "İstanbul", district: "Ümraniye", vehicleType: "Kamyon", capacity: "10 ton", plate: "34 ARY 034", documentStatus: "Onaylandı", rating: 4.9, completedJobs: 42),
            DemoUser(id: "carrier-heavy", role: .carrier, name: "Tır Nakliyecisi", phone: "+90 532 000 00 04", city: "Kocaeli", district: "Gebze", vehicleType: "Tır", capacity: "24 ton", plate: "41 ARY 041", documentStatus: "Onaylandı", rating: 4.6, completedJobs: 27)
        ]
        let cities = [("İstanbul", "Kadıköy"), ("Ankara", "Çankaya"), ("İzmir", "Bornova"), ("Bursa", "Nilüfer"), ("Kocaeli", "Gebze"), ("Sakarya", "Adapazarı"), ("Konya", "Selçuklu"), ("Antalya", "Muratpaşa"), ("Adana", "Seyhan"), ("Gaziantep", "Şahinbey")]
        let cargo = ["Paletli Ürün", "Sanayi Yükü", "Makine", "İnşaat Malzemesi", "Tekstil Kolisi", "Ambalaj Malzemesi", "Gıda Dışı Ürün", "Hammadde"]
        for index in 0..<80 {
            let pickup = cities[index % cities.count]
            let delivery = cities[(index + 3) % cities.count]
            let status: JobStatus = [.open, .open, .open, .offerAccepted, .inProgress, .completed, .cancelled][index % 7]
            jobs.append(JobPost(id: "job-\(index)", shipperId: index < 12 ? "shipper-demo" : "shipper-heavy", cargoType: cargo[index % cargo.count], description: "\(cargo[index % cargo.count]) taşınacak. Paketleme, kat ve zaman bilgileri ilanda belirtilmiştir.", pickupCity: pickup.0, pickupDistrict: pickup.1, deliveryCity: delivery.0, deliveryDistrict: delivery.1, pickupDate: "2026-06-\(String(format: "%02d", (index % 20) + 1))", urgency: ["Normal", "Acil", "Çok Acil"][index % 3], status: status, acceptedOfferId: status == .open || status == .cancelled ? nil : "offer-accepted-\(index)", pickupAddress: "\(pickup.1) Mahallesi \(10 + index). Sokak", deliveryAddress: "\(delivery.1) Mahallesi \(20 + index). Cadde"))
        }
        for index in 0..<200 {
            let job = jobs[index % jobs.count]
            offers.append(Offer(id: job.acceptedOfferId ?? "offer-\(index)", jobId: job.id, carrierId: index % 2 == 0 ? "carrier-demo" : "carrier-heavy", amount: 1500 + ((index * 947) % 42000), note: "Sigortalı ve zamanında taşıma yapabilirim.", status: job.acceptedOfferId != nil && index % 5 == 0 ? .accepted : [.pending, .accepted, .rejected, .withdrawn][index % 4]))
        }
        for index in 0..<50 {
            notifications.append(DemoNotification(id: "notification-\(index)", title: ["Yeni teklif geldi", "Teklif kabul edildi", "Taşıma başladı", "İş tamamlandı"][index % 4], body: "İlgili ilana dokunarak detaya gidebilirsiniz.", jobId: jobs[index % jobs.count].id, read: index % 3 == 0))
        }
        for index in 0..<24 {
            messages.append(DemoMessage(id: "message-\(index)", jobId: jobs[index % jobs.count].id, fromUserId: index % 3 == 0 ? "carrier-demo" : currentUserId, toUserId: index % 3 == 0 ? currentUserId : "carrier-demo", text: ["Merhaba, detayları konuşabiliriz.", "Adres bilgisi kabul sonrası görünür.", "Uygun saatte taşıma yapabilirim.", "Teşekkürler, teklifinizi değerlendiriyorum."][index % 4], unread: index % 4 == 0))
        }
    }
}
