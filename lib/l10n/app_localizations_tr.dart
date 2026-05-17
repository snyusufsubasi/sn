// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'ARACIYOK';

  @override
  String get commonContinue => 'Devam Et';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonOk => 'Tamam';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonNext => 'İleri';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonFilter => 'Filtrele';

  @override
  String get commonAll => 'Tümü';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonError => 'Bir sorun oluştu';

  @override
  String get commonSuccess => 'Başarılı';

  @override
  String get commonRequired => 'Zorunlu';

  @override
  String get commonOptional => 'Opsiyonel';

  @override
  String get commonSend => 'Gönder';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get commonReject => 'Reddet';

  @override
  String get commonAccept => 'Kabul Et';

  @override
  String get tabHome => 'Anasayfa';

  @override
  String get tabJobs => 'İlanlar';

  @override
  String get tabNotifications => 'Bildirimler';

  @override
  String get tabMessages => 'Mesajlar';

  @override
  String get tabProfile => 'Profil';

  @override
  String get roleShipper => 'Yükveren';

  @override
  String get roleCarrier => 'Nakliyeci';

  @override
  String get rolePickTitle => 'Hangisi sensin?';

  @override
  String get rolePickSubtitle => 'Daha sonra değiştiremezsin, dikkatli seç.';

  @override
  String get roleShipperDesc => 'Taşınacak yüküm var';

  @override
  String get roleCarrierDesc => 'Aracım var, yük arıyorum';

  @override
  String get userTypeIndividual => 'Bireysel';

  @override
  String get userTypeCompany => 'Şirket';

  @override
  String get authPhoneTitle => 'Telefon numaranı gir';

  @override
  String get authPhoneSubtitle => 'Sana doğrulama kodu göndereceğiz';

  @override
  String get authPhoneHint => '5XX XXX XX XX';

  @override
  String get authPhoneInvalid => 'Geçerli bir Türkiye GSM numarası gir';

  @override
  String get authSendCode => 'Kodu Gönder';

  @override
  String get authOtpTitle => 'Doğrulama kodu';

  @override
  String authOtpSubtitle(String phone) {
    return '$phone numarasına gönderdiğimiz 6 haneli kodu gir';
  }

  @override
  String get authOtpResend => 'Kodu tekrar gönder';

  @override
  String authOtpResendIn(int seconds) {
    return '$seconds sn içinde tekrar gönderebilirsin';
  }

  @override
  String get authOtpInvalid => 'Kod hatalı';

  @override
  String get authOtpExpired => 'Kod süresi doldu';

  @override
  String get profileSetupTitle => 'Hesabını tamamla';

  @override
  String get profileFullName => 'Ad Soyad';

  @override
  String get profileFullNameRequired => 'Ad soyad gerekli';

  @override
  String get profileCity => 'Şehir';

  @override
  String get profileDistrict => 'İlçe';

  @override
  String get profileCompanyName => 'Firma adı';

  @override
  String get profileTaxNumber => 'Vergi numarası';

  @override
  String get profileTaxNumberInvalid => 'Vergi numarası 10 haneli olmalı';

  @override
  String get carrierVehicleType => 'Araç tipi';

  @override
  String get carrierCapacity => 'Tonaj kapasitesi';

  @override
  String get carrierTrailerType => 'Kasa tipi';

  @override
  String get carrierPreferredRegions => 'Tercih edilen bölgeler';

  @override
  String get carrierPlate => 'Plaka';

  @override
  String get carrierPlateInvalid => 'Geçerli bir plaka gir';

  @override
  String get jobsEmpty => 'Henüz ilan yok';

  @override
  String get jobsEmptyShipperSubtitle =>
      'Yük taşıtmak için yeni bir ilan oluştur';

  @override
  String get jobsEmptyCarrierSubtitle => 'Yakında uygun yükler burada görünür';

  @override
  String get jobsEmptyWithFilters => 'Bu filtrelerle eşleşen ilan bulunamadı';

  @override
  String get jobsClearFilters => 'Filtreleri temizle';

  @override
  String get jobsCreateNew => 'Yeni İlan Oluştur';

  @override
  String get jobsTabAvailable => 'Mevcut';

  @override
  String get jobsTabActive => 'Aktif Taşımalarım';

  @override
  String get jobsNoActiveCarrierJobs => 'Aktif taşıman yok';

  @override
  String get jobsNoActiveCarrierJobsSubtitle =>
      'Kabul edilen tekliflerin burada listelenecek';

  @override
  String get jobStatusOpen => 'Açık';

  @override
  String get jobStatusOfferAccepted => 'Teklif Kabul Edildi';

  @override
  String get jobStatusPickupApproval => 'Yük Alındı Onayı';

  @override
  String get jobStatusLoaded => 'Yük Alındı';

  @override
  String get jobStatusOnRoad => 'Yolda';

  @override
  String get jobStatusDeliveryApproval => 'Teslim Onayı';

  @override
  String get jobStatusAwaitingPayment => 'Ödeme Bekleniyor';

  @override
  String get jobStatusCompleted => 'Teslim Edildi';

  @override
  String get jobStatusCancelled => 'İptal Edildi';

  @override
  String get paymentTitle => 'Ödeme';

  @override
  String get paymentNotReady =>
      'Ödeme adımı henüz açılmadı. Teslim onaylarını tamamlayın.';

  @override
  String get paymentAwaitingTitle => 'Ödeme bekleniyor';

  @override
  String get paymentCompletedTitle => 'Ödeme tamamlandı';

  @override
  String get paymentCarrierTitle => 'Ödeme onayı';

  @override
  String get paymentAmount => 'Tutar';

  @override
  String get paymentCommission => 'Komisyon';

  @override
  String get paymentZeroCommission => '₺0 — sıfır komisyon';

  @override
  String get paymentStatusLabel => 'Durum';

  @override
  String get paymentStatusAwaiting => 'Havale bekleniyor';

  @override
  String get paymentStatusConfirmed => 'Onaylandı';

  @override
  String get paymentStatusPending => 'Beklemede';

  @override
  String get paymentIbanTitle => 'Nakliyeci IBAN';

  @override
  String get paymentIbanHint => 'Banka uygulamanızdan havale veya EFT yapın.';

  @override
  String get paymentIbanMissing => 'Nakliyeci henüz IBAN eklemedi.';

  @override
  String get paymentCopyIban => 'IBAN Kopyala';

  @override
  String get paymentIbanCopied => 'IBAN panoya kopyalandı';

  @override
  String get paymentWaitingCarrier => 'Nakliyecinin ödeme onayı bekleniyor…';

  @override
  String get paymentCarrierHint => 'Tutar hesabına geçtiğinde aşağıdan onayla.';

  @override
  String get paymentConfirmReceived => 'Ödeme alındı, işi tamamla';

  @override
  String get paymentConfirmSuccess => 'Ödeme onaylandı, iş tamamlandı';

  @override
  String get paymentConfirmDialogTitle => 'Ödeme onayı';

  @override
  String get paymentConfirmDialogBody =>
      'Tutarın hesabına geçtiğinden emin misin? Bu işlem geri alınamaz.';

  @override
  String get carrierIban => 'IBAN';

  @override
  String get carrierIbanInvalid => 'Geçerli bir TR IBAN gir (26 karakter)';

  @override
  String get homePaymentPending => 'Ödeme bekliyor';

  @override
  String get homePaymentPendingSubtitle =>
      'Havale yap veya nakliyeci onayını bekle';

  @override
  String get homePaymentPendingAction => 'Ödemeye git';

  @override
  String get paymentReportTransfer => 'Ödemeyi yaptım';

  @override
  String get paymentReportTransferSuccess => 'Ödeme bildirimin alındı';

  @override
  String get paymentReportTransferDone => 'Ödeme bildirimin kayıtlı';

  @override
  String get paymentEscrowTitle => 'Güvenli ödeme (escrow)';

  @override
  String get paymentEscrowHint =>
      'Ödeme platformda tutuluyor. Teslim onayından sonra serbest bırakılabilir.';

  @override
  String get paymentEscrowRelease => 'Ödemeyi serbest bırak';

  @override
  String get paymentEscrowReleased => 'Ödeme nakliyeciye aktarıldı';

  @override
  String get offerZeroCommissionNote =>
      'Platform komisyonu yok; anlaşılan tutar nakliyeciye gider.';

  @override
  String get offerStatusPending => 'Beklemede';

  @override
  String get offerStatusAccepted => 'Kabul Edildi';

  @override
  String get offerStatusRejected => 'Reddedildi';

  @override
  String get offerStatusWithdrawn => 'Geri Çekildi';

  @override
  String get offerStatusExpired => 'Süresi Doldu';

  @override
  String get offerGiveOffer => 'Teklif Ver';

  @override
  String get offerYourOffer => 'Senin teklifin';

  @override
  String get offerEmpty => 'Henüz teklif yok';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsEmpty => 'Bildirim yok';

  @override
  String get notificationsEmptySubtitle =>
      'Yeni bildirimlerin burada görünecek';

  @override
  String get notificationsMarkAllRead => 'Tümünü okundu işaretle';

  @override
  String get notifEmpty => 'Bildirim yok';

  @override
  String get notifEmptySubtitle => 'Yeni bildirimlerin burada görünecek';

  @override
  String get msgEmpty => 'Henüz mesaj yok';

  @override
  String get msgEmptySubtitle =>
      'Teklif kabul edildikten sonra karşı tarafla mesajlaşabilirsin';

  @override
  String get msgLockedTitle => 'Mesajlaşma kilidi';

  @override
  String get msgLockedSubtitle => 'Teklif kabul edilince mesajlaşma açılır';

  @override
  String get msgComposeHint => 'Mesaj yaz...';

  @override
  String get msgStartConversation => 'Mesajlaşmaya başla';

  @override
  String get msgStartConversationSubtitle =>
      'İlk mesajı sen yaz; yük ve teslimat hakkında konuşun.';

  @override
  String get reviewTitle => 'Değerlendir';

  @override
  String get reviewSubtitle => 'Bu taşıma için deneyimini değerlendir';

  @override
  String get reviewSubmit => 'Gönder';

  @override
  String get reviewCommentHint => 'Yorum (opsiyonel)';

  @override
  String get reviewSaved => 'Değerlendirmen kaydedildi';

  @override
  String get reviewRatingRequired => 'En az 1 yıldız ver';

  @override
  String get profileLogout => 'Çıkış Yap';

  @override
  String get profileLogoutConfirm => 'Çıkış yapmak istediğinden emin misin?';

  @override
  String get profileEdit => 'Profili Düzenle';

  @override
  String get profileSettings => 'Ayarlar';

  @override
  String get profileSupport => 'Destek';

  @override
  String get profilePrivacy => 'Gizlilik Politikası';

  @override
  String get profileTerms => 'Kullanım Koşulları';

  @override
  String profileVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get errorNetwork => 'İnternet bağlantın yok';

  @override
  String get errorTimeout => 'İstek zaman aşımına uğradı';

  @override
  String get errorServer => 'Sunucu hatası, lütfen tekrar dene';

  @override
  String get errorUnknown => 'Beklenmedik bir hata oluştu';

  @override
  String get errorNotFound => 'Aradığın şey bulunamadı';

  @override
  String get errorUnauthorized => 'Bu işlem için yetkin yok';

  @override
  String get carrierSetupTitle => 'Araç Bilgileri';

  @override
  String get carrierCapacityRequired => 'Kapasite gerekli';

  @override
  String get carrierCapacityInvalid => 'Geçerli bir kapasite gir';

  @override
  String get carrierVehicleTruck => 'Kamyon';

  @override
  String get carrierVehicleSemi => 'Tır';

  @override
  String get carrierTrailerCurtainsider => 'Tenteli';

  @override
  String get carrierTrailerOpenBed => 'Açık Kasa';

  @override
  String get carrierTrailerClosedBox => 'Kapalı Kasa';

  @override
  String get carrierTrailerReefer => 'Frigorifik';

  @override
  String get carrierTrailerTipper => 'Damperli';

  @override
  String get carrierTrailerLowbed => 'Lowbed';

  @override
  String get adminTitle => 'Admin Paneli';

  @override
  String get adminUsers => 'Kullanıcılar';

  @override
  String get adminUsersList => 'Liste ve doğrulama';

  @override
  String get adminUsersBody =>
      'Kullanıcı listesi ve ban/verify işlemleri staging ortamında Supabase admin politikaları ile açılır.';

  @override
  String get adminDisputes => 'Anlaşmazlıklar';

  @override
  String get adminDisputesSubtitle => 'Ödeme uyuşmazlığı kuyruğu';

  @override
  String get adminDisputeDemo => 'Örnek kayıt (demo)';

  @override
  String get adminDisputeDemoBody =>
      'Yükveren ödemedim / nakliyeci almadım — karar ver, iş ve ödeme durumunu güncelle.';

  @override
  String get adminMetricUsers => 'Toplam kullanıcı';

  @override
  String get adminMetricJobs => 'Açık ilan';

  @override
  String get adminMetricDisputes => 'Açık dispute';

  @override
  String get adminMetricPayments => 'Bekleyen ödeme';

  @override
  String get paymentCancelledTitle => 'İş iptal edildi';

  @override
  String get paymentCancelledBody =>
      'Bu iş iptal edildiği için ödeme adımı mevcut değil.';

  @override
  String get offerGiveOfferTitle => 'Teklif Ver';

  @override
  String get offerPriceLabel => 'Fiyatın (₺)';

  @override
  String get offerPriceRequired => 'Fiyat gerekli';

  @override
  String get offerPriceInvalid => 'Geçerli bir fiyat gir';

  @override
  String get offerPriceTooHigh => 'Çok yüksek';

  @override
  String get offerMessageLabel => 'Mesaj (opsiyonel)';

  @override
  String get offerMessageHint =>
      'Aracın, deneyimin, hızın hakkında kısa bir not...';

  @override
  String get offerSent => 'Teklifin gönderildi';

  @override
  String get offerBudget => 'Bütçe';

  @override
  String offerBudgetWarning(String budget) {
    return 'Bu teklif yükverenin bütçesini (₺$budget) aşıyor';
  }

  @override
  String get createJobTitle => 'Yeni İlan';

  @override
  String get createJobTitleLabel => 'Başlık';

  @override
  String get createJobTitleHint => 'Örn. İstanbul – Konya tekstil yükü';

  @override
  String get createJobTitleRequired => 'Başlık gerekli';

  @override
  String get createJobDescLabel => 'Açıklama (opsiyonel)';

  @override
  String get createJobDescHint => 'Yük hakkında ek detaylar';

  @override
  String get createJobCargoSectionLabel => 'Kargo';

  @override
  String get createJobCargoTypeLabel => 'Kargo tipi';

  @override
  String get createJobWeightLabel => 'Ağırlık (ton)';

  @override
  String get createJobWeightRequired => 'Ağırlık gerekli';

  @override
  String get createJobWeightInvalid => 'Geçerli bir değer gir';

  @override
  String get createJobVolumeLabel => 'Hacim (m³)';

  @override
  String get createJobTrailerLabel => 'Tercih edilen kasa (opsiyonel)';

  @override
  String get createJobTrailerAny => 'Fark etmez';

  @override
  String get createJobOriginLabel => 'Çıkış';

  @override
  String get createJobDestLabel => 'Varış';

  @override
  String get createJobCityLabel => 'Şehir';

  @override
  String get createJobDistrictLabel => 'İlçe';

  @override
  String get createJobDistrictRequired => 'İlçe gerekli';

  @override
  String get createJobAddressOriginLabel =>
      'Açık adres (opsiyonel, teklif kabul edilince görünür)';

  @override
  String get createJobAddressDestLabel => 'Açık adres (opsiyonel)';

  @override
  String get createJobDatesLabel => 'Tarihler ve bütçe';

  @override
  String get createJobPickupDateLabel => 'Yükleme';

  @override
  String get createJobDeliveryDateLabel => 'Teslim';

  @override
  String get createJobSelectDate => 'Seç';

  @override
  String get createJobBudgetMinLabel => 'Min bütçe ₺';

  @override
  String get createJobBudgetMaxLabel => 'Maks bütçe ₺';

  @override
  String get createJobPublish => 'Yayına Al';

  @override
  String get createJobPublishing => 'Gönderiliyor...';

  @override
  String get createJobPublished => 'İlan yayına alındı';

  @override
  String get createJobPickupRequired => 'Yükleme tarihi seç';

  @override
  String get createJobCitiesRequired => 'Şehirleri seç';

  @override
  String get createJobBudgetError => 'Maks bütçe, min bütçeden büyük olmalı';

  @override
  String get createJobDeliveryBeforePickup =>
      'Teslim tarihi, yükleme tarihinden sonra olmalı';

  @override
  String get msgUnknown => 'Bilinmeyen';

  @override
  String get msgNoConversation => 'Henüz mesaj yok';

  @override
  String get trackingTitle => 'Canlı Takip';

  @override
  String get trackingJobNotFound => 'İlan bulunamadı';

  @override
  String get trackingWaiting => 'Konum bekleniyor';

  @override
  String get trackingLive => 'Canlı';

  @override
  String trackingLastUpdate(String time) {
    return 'Son güncelleme: $time';
  }

  @override
  String get trackingWebTitle => 'Web takip görünümü';

  @override
  String get trackingWebSubtitle =>
      'Bu ortamda gömülü harita yerine güvenli yedek görünüm kullanılıyor.';

  @override
  String trackingWebPingCount(int count) {
    return 'Toplam ping: $count';
  }

  @override
  String trackingLastLocation(String coords) {
    return 'Son konum: $coords';
  }

  @override
  String get trackingWebNote =>
      'Canlı takip bu ekranda uygulama içi olarak devam eder.';

  @override
  String get profileNotFound => 'Profil bulunamadı';

  @override
  String get profileRoleShipper => 'Yükveren';

  @override
  String get profileRoleCarrier => 'Nakliyeci';

  @override
  String get profileTagCompany => 'Kurumsal';

  @override
  String get profileStatRating => 'Ortalama puan';

  @override
  String get profileStatJobsShipper => 'Tamamlanan ilan';

  @override
  String get profileStatJobsCarrier => 'Tamamlanan taşıma';

  @override
  String get profileInfoLocation => 'Konum';

  @override
  String get profileInfoCompany => 'Şirket';

  @override
  String get profileInfoTaxNumber => 'Vergi No';

  @override
  String get profileReviewsTitle => 'Son Değerlendirmeler';

  @override
  String get profileNoReviews => 'Henüz değerlendirme yok';

  @override
  String get profileReviewAnon => 'Anonim';

  @override
  String get profileSettingsEdit => 'Profili düzenle';

  @override
  String get profileSettingsTerms => 'Kullanım Koşulları';

  @override
  String get profileSettingsPrivacy => 'Gizlilik / KVKK';

  @override
  String get profileSettingsHelp => 'Yardım & Destek';

  @override
  String get profileSignOutTitle => 'Çıkış yap?';

  @override
  String get profileSignOutBody =>
      'Hesabından çıkış yapmak istediğinden emin misin?';

  @override
  String get profileSignOutCancel => 'Vazgeç';

  @override
  String get profileSignOutAction => 'Çıkış yap';

  @override
  String get profileFooter => 'ARACIYOK';

  @override
  String get homeGreetingHintShipper =>
      'İlanlarını yönet, aktif taşımanı takip et.';

  @override
  String get homeGreetingHintCarrier =>
      'Aktif taşımanı yönet, uygun yükleri yakala.';

  @override
  String get homeHeroTitleShipper => 'Bugünkü durum';

  @override
  String get homeHeroSubtitleShipper => 'Operasyon merkezin';

  @override
  String get homeHeroTitleCarrier => 'Bugünkü fırsatlar';

  @override
  String get homeHeroSubtitleCarrier => 'Nakliye paneli';

  @override
  String get homeHeroPrimaryLabel => 'Aktif taşıma';

  @override
  String get homeHeroSecondaryLabelShipper => 'Toplam ilan';

  @override
  String get homeHeroSecondaryLabelCarrier => 'Açık ilan';

  @override
  String get homeHeroHintShipper => 'Devam eden taşımalara öncelik ver.';

  @override
  String get homeHeroHintShipperEmpty =>
      'Yeni ilan açarak teklif toplamayı hızlandır.';

  @override
  String get homeHeroHintCarrier => 'Uygun ilanları kaçırmadan teklif ver.';

  @override
  String get homeHeroHintCarrierEmpty =>
      'Yeni ilanlar için filtrelerini güncelle.';

  @override
  String get homeCtaTitleShipper => 'Yeni bir ilan oluştur';

  @override
  String get homeCtaSubtitleShipper =>
      'Yüklerini hızlıca ilan et, teklifleri karşılaştır.';

  @override
  String get homeCtaButtonShipper => 'İlan Oluştur';

  @override
  String get homeCtaTitleCarrier => 'Bugün yeni yük bul';

  @override
  String get homeCtaSubtitleCarrier =>
      'Şehir ve yük tipine göre filtreleyip hemen teklif ver.';

  @override
  String get homeCtaButtonCarrierJobs => 'İlanlara Git';

  @override
  String get homeCtaButtonCarrierFilter => 'Filtrele';

  @override
  String get homeQuickActionsTitle => 'Hızlı işlemler';

  @override
  String get homeQuickActionNewJob => 'Yeni İlan Oluştur';

  @override
  String get homeQuickActionNewJobSub => 'Hızlıca yeni bir yük ilanı aç';

  @override
  String get homeQuickActionMyJobs => 'İlanlarım';

  @override
  String get homeQuickActionMyJobsSub => 'Tüm ilanlarını ve durumlarını gör';

  @override
  String get homeQuickActionActive => 'Aldığım işler';

  @override
  String get homeQuickActionActiveSub => 'Aktif taşıma süreçlerini aç';

  @override
  String get homeQuickActionCompleted => 'Yaptığım işler';

  @override
  String get homeQuickActionCompletedSub => 'Tamamlanan taşıma geçmişin';

  @override
  String get homeQuickActionOffers => 'Tekliflerim';

  @override
  String get homeQuickActionOffersSub => 'Verdiğin tüm teklifleri görüntüle';

  @override
  String get homeEmptyJobsTitle => 'Henüz ilanın yok';

  @override
  String get homeEmptyJobsSubtitle =>
      'İlk ilanını oluştur, nakliyecilerden teklif almaya başla.';

  @override
  String get homeEmptyOpenTitle => 'Açık ilan yok';

  @override
  String get homeEmptyOpenSubtitle =>
      'Şu an için açık bir ilan bulunamadı. Birazdan tekrar dene.';

  @override
  String get homeSectionActiveTitle => 'Devam eden taşımaların';

  @override
  String get homeSectionActiveSub => 'En kritik operasyonlar';

  @override
  String get homeSectionRecentTitle => 'Son ilanların';

  @override
  String get homeSectionRecentSub => 'Hızlıca açıp işlem yap';

  @override
  String get homeSectionCarrierActiveTitle => 'Aktif taşımaların';

  @override
  String get homeSectionCarrierActiveSub => 'Önce bunları tamamla';

  @override
  String get homeSectionRecommendedTitle => 'Önerilen ilanlar';

  @override
  String get homeSectionRecommendedSub => 'Sana uygun açık ilanlar';

  @override
  String get actionAll => 'Hepsi';

  @override
  String get actionAllJobs => 'Tümü';
}
