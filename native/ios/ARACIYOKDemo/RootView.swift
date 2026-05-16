import SwiftUI

private let navy = Color(red: 0.09, green: 0.14, blue: 0.24)
private let accent = Color(red: 0.04, green: 0.50, blue: 0.51)
private let background = Color(red: 0.96, green: 0.97, blue: 0.98)
private let border = Color(red: 0.88, green: 0.91, blue: 0.94)
private let muted = Color(red: 0.39, green: 0.45, blue: 0.55)

struct RootView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                MainTabsView()
            } else {
                LoginView()
            }
        }
        .background(background)
    }
}

struct LoginView: View {
    @EnvironmentObject private var store: DemoStore
    @State private var phone = "+90 532 000 00 01"
    @State private var code = "123456"

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Image(systemName: "checkmark.seal")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(accent)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("ARACIYOK")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(navy)
            Text("Yük veren ve nakliyeci aracısız buluşur.")
                .font(.title3)
                .foregroundStyle(muted)
            AppCard {
                Text("Güvenli demo girişi")
                    .font(.headline)
                    .foregroundStyle(navy)
                TextField("Telefon Numarası", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                TextField("SMS Doğrulama Kodu", text: $code)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                if let error = store.authError {
                    Text(error).font(.footnote.bold()).foregroundStyle(.red)
                }
                Button("Giriş Yap") { store.login(phone: phone, code: code) }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .frame(maxWidth: .infinity)
                Text("Demo kodu: 123456")
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            Text("Demo mod local veriyle çalışır. Supabase üretim akışına yazmaz.")
                .font(.footnote)
                .foregroundStyle(muted)
            Spacer()
        }
        .padding(24)
    }
}

struct MainTabsView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        TabView {
            if store.currentUser.role == .shipper {
                JobsListView(title: "Anasayfa", jobs: store.jobs.filter { $0.shipperId == store.currentUserId })
                    .tabItem { Label("Anasayfa", systemImage: "house") }
                JobsListView(title: "İlanlar", jobs: store.jobs.filter { $0.shipperId == store.currentUserId })
                    .tabItem { Label("İlanlar", systemImage: "shippingbox") }
            } else {
                JobsListView(title: "Anasayfa", jobs: Array(store.jobs.filter { $0.status == .open }.prefix(8)))
                    .tabItem { Label("Anasayfa", systemImage: "house") }
                JobsListView(title: "İlanlar", jobs: store.jobs.filter { $0.status == .open })
                    .tabItem { Label("İlanlar", systemImage: "truck.box") }
            }
            NotificationsView()
                .badge(store.unreadNotifications)
                .tabItem { Label("Bildirimler", systemImage: "bell") }
            MessagesView()
                .badge(store.unreadMessages)
                .tabItem { Label("Mesajlar", systemImage: "bubble.left.and.bubble.right") }
            ProfileView()
                .tabItem { Label("Profil", systemImage: "person") }
        }
        .tint(accent)
    }
}

struct JobsListView: View {
    @EnvironmentObject private var store: DemoStore
    let title: String
    let jobs: [JobPost]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HeaderCard(title: title, subtitle: store.currentUser.role == .shipper ? "Teklifleri ve taşıma durumunu takip edin." : "Rota ve aciliyete göre uygun işleri tarayın.")
                    if jobs.isEmpty {
                        EmptyPanel(title: "Uygun kayıt yok", body: "Yeni hareketler burada görünecek.")
                    } else {
                        ForEach(jobs.prefix(40)) { job in
                            NavigationLink(value: job.id) {
                                JobCard(job: job, offered: store.offers.contains { $0.jobId == job.id && $0.carrierId == store.currentUserId })
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle(title)
            .navigationDestination(for: String.self) { jobId in
                JobDetailView(jobId: jobId)
            }
        }
    }
}

struct JobDetailView: View {
    @EnvironmentObject private var store: DemoStore
    let jobId: String

    var body: some View {
        if let job = store.jobs.first(where: { $0.id == jobId }) {
            let isOwner = job.shipperId == store.currentUserId
            let isAcceptedCarrier = store.acceptedCarrierId(for: job) == store.currentUserId
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    AppCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(job.cargoType).font(.title2.bold()).foregroundStyle(navy)
                                Text(job.description).foregroundStyle(muted)
                            }
                            Spacer()
                            StatusCapsule(job.status.title, color: statusColor(job.status))
                        }
                    }
                    RoutePanel(job: job)
                    if isOwner || isAcceptedCarrier {
                        PrivateInfoPanel(job: job)
                    } else {
                        PrivacyPanel()
                    }
                    if isOwner && job.status == .open {
                        OffersForJob(job: job)
                    } else if store.currentUser.role == .carrier && job.status == .open {
                        Button("Teklif Ver") { store.createOffer(jobId: job.id) }
                            .buttonStyle(.borderedProminent)
                            .tint(accent)
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("İlan Detayı")
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.red)
                Text("İlan bulunamadı").font(.title2.bold()).foregroundStyle(navy)
                Text("Bu ilan silinmiş olabilir veya erişim yetkiniz olmayabilir.").foregroundStyle(muted)
            }
            .padding(24)
        }
    }
}

struct OffersView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HeaderCard(title: "Bildirimler", subtitle: "Bekleyen, kabul edilen ve kapanan teklif hareketleri.")
                    ForEach(store.offers.filter { $0.carrierId == store.currentUserId }.prefix(60)) { offer in
                        AppCard {
                            HStack {
                                Text("\(offer.amount) TL").font(.title3.bold()).foregroundStyle(accent)
                                Spacer()
                                StatusCapsule(offer.status.title, color: offerColor(offer.status))
                            }
                            Text(offer.note).foregroundStyle(muted)
                        }
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Bildirimler")
        }
    }
}

struct MessagesView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HeaderCard(title: "Mesajlar", subtitle: "Sadece kabul edilmiş işler için konuşma açılır.")
                    if store.conversations().isEmpty {
                        EmptyPanel(title: "Henüz mesaj yok", body: "Mesajlaşma teklif kabul edildikten sonra açılır.")
                    } else {
                        ForEach(store.conversations()) { user in
                            AppCard {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right").foregroundStyle(accent)
                                    VStack(alignment: .leading) {
                                        Text(user.name).font(.headline).foregroundStyle(navy)
                                        Text("Kabul edilmiş iş konuşması").foregroundStyle(muted)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Mesajlar")
        }
    }
}

struct NotificationsView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HeaderCard(title: "Bildirimler", subtitle: "Teklif, mesaj ve taşıma durumları.")
                    ForEach(store.notifications) { item in
                        AppCard {
                            HStack(alignment: .top) {
                                Circle().fill(item.read ? border : accent).frame(width: 10, height: 10).padding(.top, 6)
                                VStack(alignment: .leading) {
                                    Text(item.title).font(.headline).foregroundStyle(navy)
                                    Text(item.body).foregroundStyle(muted)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Bildirimler")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    AppCard {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 44))
                                .foregroundStyle(accent)
                            VStack(alignment: .leading) {
                                Text(store.currentUser.name).font(.title3.bold()).foregroundStyle(navy)
                                Text(store.currentUser.role.title).foregroundStyle(muted)
                            }
                            Spacer()
                        }
                        Divider()
                        Text("Telefon: \(store.currentUser.phone)").foregroundStyle(muted)
                        Text("Şehir: \(store.currentUser.city) / \(store.currentUser.district)").foregroundStyle(muted)
                        Text("Puan: \(store.currentUser.rating, specifier: "%.1f") · Tamamlanan iş: \(store.currentUser.completedJobs)").foregroundStyle(muted)
                        if store.currentUser.role == .carrier {
                            Text("Araç: \(store.currentUser.vehicleType) · \(store.currentUser.capacity)").foregroundStyle(muted)
                            Text("Plaka: \(store.currentUser.plate)").foregroundStyle(muted)
                            Text("Belge Durumu: \(store.currentUser.documentStatus)").font(.headline).foregroundStyle(accent)
                        }
                    }
                    AppCard {
                        Text("Demo kullanıcı değiştir").font(.headline).foregroundStyle(navy)
                        Button("Demo Yükveren") { store.switchPersona(.shipper) }
                        Button("Demo Nakliyeci") { store.switchPersona(.carrier) }
                        Button("Yoğun Yükveren") { store.switchPersona(.shipper, heavy: true) }
                        Button("Çok Teklifli Nakliyeci") { store.switchPersona(.carrier, heavy: true) }
                    }
                    Button("Çıkış Yap") { store.isLoggedIn = false }
                        .buttonStyle(.bordered)
                        .tint(accent)
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Profil")
        }
    }
}

struct AppCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border))
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
}

struct HeaderCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        AppCard {
            Text(title).font(.title2.bold()).foregroundStyle(navy)
            Text(subtitle).foregroundStyle(muted)
        }
    }
}

struct JobCard: View {
    let job: JobPost
    let offered: Bool

    var body: some View {
        AppCard {
            HStack {
                StatusCapsule(job.status.title, color: statusColor(job.status))
                if offered { StatusCapsule("Teklif verdiniz", color: .green) }
                Spacer()
                if job.urgency != "Normal" { StatusCapsule(job.urgency, color: .orange) }
            }
            Text(job.cargoType).font(.headline).foregroundStyle(navy)
            Text("\(job.pickupCity)/\(job.pickupDistrict) → \(job.deliveryCity)/\(job.deliveryDistrict)")
                .font(.subheadline.bold())
                .foregroundStyle(navy)
            Text(job.description).foregroundStyle(muted).lineLimit(2)
        }
    }
}

struct RoutePanel: View {
    let job: JobPost

    var body: some View {
        AppCard {
            Text("Rota").font(.headline).foregroundStyle(navy)
            Text("Yükleme: \(job.pickupCity) / \(job.pickupDistrict)").foregroundStyle(navy)
            Text("Teslim: \(job.deliveryCity) / \(job.deliveryDistrict)").foregroundStyle(navy)
            Text("Tarih: \(job.pickupDate)").foregroundStyle(muted)
        }
    }
}

struct PrivateInfoPanel: View {
    let job: JobPost

    var body: some View {
        AppCard {
            Label("Özel bilgiler açıldı", systemImage: "checkmark.seal").font(.headline).foregroundStyle(accent)
            Text("Yükleme: \(job.pickupAddress)").foregroundStyle(navy)
            Text("Teslim: \(job.deliveryAddress)").foregroundStyle(navy)
        }
    }
}

struct PrivacyPanel: View {
    var body: some View {
        AppCard {
            Label("Gizli bilgiler korunuyor", systemImage: "lock").font(.headline).foregroundStyle(navy)
            Text("Adres, telefon, plaka ve mesajlaşma sadece teklif kabulünden sonra açılır.")
                .foregroundStyle(muted)
        }
    }
}

struct OffersForJob: View {
    @EnvironmentObject private var store: DemoStore
    let job: JobPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gelen teklifler").font(.headline).foregroundStyle(navy)
            ForEach(store.offers.filter { $0.jobId == job.id }) { offer in
                AppCard {
                    HStack {
                        Text("\(offer.amount) TL").font(.title3.bold()).foregroundStyle(accent)
                        Spacer()
                        StatusCapsule(offer.status.title, color: offerColor(offer.status))
                    }
                    Text(offer.note).foregroundStyle(muted)
                    if offer.status == .pending {
                        Button("Teklifi Kabul Et") { store.acceptOffer(offer.id) }
                            .buttonStyle(.borderedProminent)
                            .tint(accent)
                    }
                }
            }
        }
    }
}

struct EmptyPanel: View {
    let title: String
    let body: String

    var body: some View {
        AppCard {
            Image(systemName: "checkmark.circle").foregroundStyle(accent)
            Text(title).font(.headline).foregroundStyle(navy)
            Text(body).foregroundStyle(muted)
        }
    }
}

struct StatusCapsule: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

private func statusColor(_ status: JobStatus) -> Color {
    switch status {
    case .open: return .orange
    case .offerAccepted: return accent
    case .inProgress: return navy
    case .completed: return .green
    case .cancelled: return .red
    }
}

private func offerColor(_ status: OfferStatus) -> Color {
    switch status {
    case .pending: return .orange
    case .accepted: return .green
    case .rejected: return .red
    case .withdrawn: return muted
    }
}
