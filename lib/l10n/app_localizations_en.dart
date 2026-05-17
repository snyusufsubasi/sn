// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ARACIYOK';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonOk => 'OK';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonAll => 'All';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonSend => 'Send';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonAccept => 'Accept';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJobs => 'Jobs';

  @override
  String get tabNotifications => 'Notifications';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabProfile => 'Profile';

  @override
  String get roleShipper => 'Shipper';

  @override
  String get roleCarrier => 'Carrier';

  @override
  String get rolePickTitle => 'Which one are you?';

  @override
  String get rolePickSubtitle =>
      'You can\'t change this later, choose carefully.';

  @override
  String get roleShipperDesc => 'I have cargo to ship';

  @override
  String get roleCarrierDesc => 'I have a vehicle, looking for cargo';

  @override
  String get userTypeIndividual => 'Individual';

  @override
  String get userTypeCompany => 'Company';

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
  String get carrierSetupTitle => 'Vehicle Details';

  @override
  String get carrierCapacityRequired => 'Capacity is required';

  @override
  String get carrierCapacityInvalid => 'Enter a valid capacity';

  @override
  String get carrierVehicleTruck => 'Truck';

  @override
  String get carrierVehicleSemi => 'Semi-trailer';

  @override
  String get carrierTrailerCurtainsider => 'Curtainsider';

  @override
  String get carrierTrailerOpenBed => 'Open bed';

  @override
  String get carrierTrailerClosedBox => 'Closed box';

  @override
  String get carrierTrailerReefer => 'Reefer';

  @override
  String get carrierTrailerTipper => 'Tipper';

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
  String get paymentCancelledTitle => 'Job cancelled';

  @override
  String get paymentCancelledBody =>
      'This job was cancelled, so no payment is available.';

  @override
  String get offerGiveOfferTitle => 'Make Offer';

  @override
  String get offerPriceLabel => 'Your price (₺)';

  @override
  String get offerPriceRequired => 'Price is required';

  @override
  String get offerPriceInvalid => 'Enter a valid price';

  @override
  String get offerPriceTooHigh => 'Too high';

  @override
  String get offerMessageLabel => 'Message (optional)';

  @override
  String get offerMessageHint =>
      'A short note about your vehicle, experience, speed...';

  @override
  String get offerSent => 'Your offer has been sent';

  @override
  String get offerBudget => 'Budget';

  @override
  String offerBudgetWarning(String budget) {
    return 'This offer exceeds the shipper\'s budget (₺$budget)';
  }

  @override
  String get createJobTitle => 'New Listing';

  @override
  String get createJobTitleLabel => 'Title';

  @override
  String get createJobTitleHint => 'E.g. Istanbul – Konya textile cargo';

  @override
  String get createJobTitleRequired => 'Title is required';

  @override
  String get createJobDescLabel => 'Description (optional)';

  @override
  String get createJobDescHint => 'Additional details about the cargo';

  @override
  String get createJobCargoSectionLabel => 'Cargo';

  @override
  String get createJobCargoTypeLabel => 'Cargo type';

  @override
  String get createJobWeightLabel => 'Weight (tons)';

  @override
  String get createJobWeightRequired => 'Weight is required';

  @override
  String get createJobWeightInvalid => 'Enter a valid value';

  @override
  String get createJobVolumeLabel => 'Volume (m³)';

  @override
  String get createJobTrailerLabel => 'Preferred trailer (optional)';

  @override
  String get createJobTrailerAny => 'Doesn\'t matter';

  @override
  String get createJobOriginLabel => 'Origin';

  @override
  String get createJobDestLabel => 'Destination';

  @override
  String get createJobCityLabel => 'City';

  @override
  String get createJobDistrictLabel => 'District';

  @override
  String get createJobDistrictRequired => 'District is required';

  @override
  String get createJobAddressOriginLabel =>
      'Full address (optional, shown after offer accepted)';

  @override
  String get createJobAddressDestLabel => 'Full address (optional)';

  @override
  String get createJobDatesLabel => 'Dates & budget';

  @override
  String get createJobPickupDateLabel => 'Pickup';

  @override
  String get createJobDeliveryDateLabel => 'Delivery';

  @override
  String get createJobSelectDate => 'Select';

  @override
  String get createJobBudgetMinLabel => 'Min budget ₺';

  @override
  String get createJobBudgetMaxLabel => 'Max budget ₺';

  @override
  String get createJobPublish => 'Publish';

  @override
  String get createJobPublishing => 'Sending...';

  @override
  String get createJobPublished => 'Listing published';

  @override
  String get createJobPickupRequired => 'Select a pickup date';

  @override
  String get createJobCitiesRequired => 'Select cities';

  @override
  String get createJobBudgetError =>
      'Max budget must be greater than min budget';

  @override
  String get createJobDeliveryBeforePickup =>
      'Delivery date must be after pickup date';

  @override
  String get msgUnknown => 'Unknown';

  @override
  String get msgNoConversation => 'No messages yet';

  @override
  String get trackingTitle => 'Live Tracking';

  @override
  String get trackingJobNotFound => 'Listing not found';

  @override
  String get trackingWaiting => 'Waiting for location';

  @override
  String get trackingLive => 'Live';

  @override
  String trackingLastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get trackingWebTitle => 'Web tracking view';

  @override
  String get trackingWebSubtitle =>
      'Using fallback view instead of embedded map in this environment.';

  @override
  String trackingWebPingCount(int count) {
    return 'Total pings: $count';
  }

  @override
  String trackingLastLocation(String coords) {
    return 'Last location: $coords';
  }

  @override
  String get trackingWebNote =>
      'Live tracking continues in the app on this screen.';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profileRoleShipper => 'Shipper';

  @override
  String get profileRoleCarrier => 'Carrier';

  @override
  String get profileTagCompany => 'Corporate';

  @override
  String get profileStatRating => 'Average rating';

  @override
  String get profileStatJobsShipper => 'Completed listings';

  @override
  String get profileStatJobsCarrier => 'Completed shipments';

  @override
  String get profileInfoLocation => 'Location';

  @override
  String get profileInfoCompany => 'Company';

  @override
  String get profileInfoTaxNumber => 'Tax No.';

  @override
  String get profileReviewsTitle => 'Recent Reviews';

  @override
  String get profileNoReviews => 'No reviews yet';

  @override
  String get profileReviewAnon => 'Anonymous';

  @override
  String get profileSettingsEdit => 'Edit profile';

  @override
  String get profileSettingsTerms => 'Terms of Use';

  @override
  String get profileSettingsPrivacy => 'Privacy / GDPR';

  @override
  String get profileSettingsHelp => 'Help & Support';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'Are you sure you want to sign out of your account?';

  @override
  String get profileSignOutCancel => 'Cancel';

  @override
  String get profileSignOutAction => 'Sign out';

  @override
  String get profileFooter => 'ARACIYOK';

  @override
  String get homeGreetingHintShipper =>
      'Manage your listings, track your active shipments.';

  @override
  String get homeGreetingHintCarrier =>
      'Manage your active shipments, find suitable cargo.';

  @override
  String get homeHeroTitleShipper => 'Today\'s status';

  @override
  String get homeHeroSubtitleShipper => 'Your operations center';

  @override
  String get homeHeroTitleCarrier => 'Today\'s opportunities';

  @override
  String get homeHeroSubtitleCarrier => 'Carrier panel';

  @override
  String get homeHeroPrimaryLabel => 'Active shipments';

  @override
  String get homeHeroSecondaryLabelShipper => 'Total listings';

  @override
  String get homeHeroSecondaryLabelCarrier => 'Open listings';

  @override
  String get homeHeroHintShipper => 'Prioritize ongoing shipments.';

  @override
  String get homeHeroHintShipperEmpty =>
      'Publish a listing to start collecting offers.';

  @override
  String get homeHeroHintCarrier =>
      'Don\'t miss suitable listings — offer now.';

  @override
  String get homeHeroHintCarrierEmpty =>
      'Update your filters for new listings.';

  @override
  String get homeCtaTitleShipper => 'Create a new listing';

  @override
  String get homeCtaSubtitleShipper =>
      'Quickly post your cargo and compare offers.';

  @override
  String get homeCtaButtonShipper => 'Create Listing';

  @override
  String get homeCtaTitleCarrier => 'Find new cargo today';

  @override
  String get homeCtaSubtitleCarrier =>
      'Filter by city and cargo type, make an offer right away.';

  @override
  String get homeCtaButtonCarrierJobs => 'Go to Listings';

  @override
  String get homeCtaButtonCarrierFilter => 'Filter';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String get homeQuickActionNewJob => 'Create New Listing';

  @override
  String get homeQuickActionNewJobSub => 'Quickly open a new cargo listing';

  @override
  String get homeQuickActionMyJobs => 'My Listings';

  @override
  String get homeQuickActionMyJobsSub =>
      'See all your listings and their status';

  @override
  String get homeQuickActionActive => 'My active jobs';

  @override
  String get homeQuickActionActiveSub => 'Open your active shipment processes';

  @override
  String get homeQuickActionCompleted => 'My completed jobs';

  @override
  String get homeQuickActionCompletedSub => 'Your completed shipment history';

  @override
  String get homeQuickActionOffers => 'My offers';

  @override
  String get homeQuickActionOffersSub => 'View all offers you\'ve submitted';

  @override
  String get homeEmptyJobsTitle => 'No listings yet';

  @override
  String get homeEmptyJobsSubtitle =>
      'Create your first listing to start receiving offers.';

  @override
  String get homeEmptyOpenTitle => 'No open listings';

  @override
  String get homeEmptyOpenSubtitle =>
      'No open listings found right now. Try again soon.';

  @override
  String get homeSectionActiveTitle => 'Your ongoing shipments';

  @override
  String get homeSectionActiveSub => 'Most critical operations';

  @override
  String get homeSectionRecentTitle => 'Your recent listings';

  @override
  String get homeSectionRecentSub => 'Open and take action quickly';

  @override
  String get homeSectionCarrierActiveTitle => 'Your active shipments';

  @override
  String get homeSectionCarrierActiveSub => 'Complete these first';

  @override
  String get homeSectionRecommendedTitle => 'Recommended listings';

  @override
  String get homeSectionRecommendedSub => 'Open listings suitable for you';

  @override
  String get actionAll => 'All';

  @override
  String get actionAllJobs => 'All';
}
