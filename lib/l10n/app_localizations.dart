import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'ARACIYOK'**
  String get appName;

  /// No description provided for @commonContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get commonEdit;

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// No description provided for @commonBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get commonNext;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get commonFilter;

  /// No description provided for @commonAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get commonAll;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get commonSuccess;

  /// No description provided for @commonRequired.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In tr, this message translates to:
  /// **'Opsiyonel'**
  String get commonOptional;

  /// No description provided for @commonSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get commonSend;

  /// No description provided for @commonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get commonConfirm;

  /// No description provided for @commonReject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get commonReject;

  /// No description provided for @commonAccept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Et'**
  String get commonAccept;

  /// No description provided for @tabHome.
  ///
  /// In tr, this message translates to:
  /// **'Anasayfa'**
  String get tabHome;

  /// No description provided for @tabJobs.
  ///
  /// In tr, this message translates to:
  /// **'İlanlar'**
  String get tabJobs;

  /// No description provided for @tabNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get tabNotifications;

  /// No description provided for @tabMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get tabMessages;

  /// No description provided for @tabProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @roleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Yükveren'**
  String get roleShipper;

  /// No description provided for @roleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Nakliyeci'**
  String get roleCarrier;

  /// No description provided for @rolePickTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangisi sensin?'**
  String get rolePickTitle;

  /// No description provided for @rolePickSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Daha sonra değiştiremezsin, dikkatli seç.'**
  String get rolePickSubtitle;

  /// No description provided for @roleShipperDesc.
  ///
  /// In tr, this message translates to:
  /// **'Taşınacak yüküm var'**
  String get roleShipperDesc;

  /// No description provided for @roleCarrierDesc.
  ///
  /// In tr, this message translates to:
  /// **'Aracım var, yük arıyorum'**
  String get roleCarrierDesc;

  /// No description provided for @userTypeIndividual.
  ///
  /// In tr, this message translates to:
  /// **'Bireysel'**
  String get userTypeIndividual;

  /// No description provided for @userTypeCompany.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get userTypeCompany;

  /// No description provided for @authPhoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numaranı gir'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sana doğrulama kodu göndereceğiz'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneHint.
  ///
  /// In tr, this message translates to:
  /// **'5XX XXX XX XX'**
  String get authPhoneHint;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir Türkiye GSM numarası gir'**
  String get authPhoneInvalid;

  /// No description provided for @authSendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Gönder'**
  String get authSendCode;

  /// No description provided for @authOtpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{phone} numarasına gönderdiğimiz 6 haneli kodu gir'**
  String authOtpSubtitle(String phone);

  /// No description provided for @authOtpResend.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder'**
  String get authOtpResend;

  /// No description provided for @authOtpResendIn.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn içinde tekrar gönderebilirsin'**
  String authOtpResendIn(int seconds);

  /// No description provided for @authOtpInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Kod hatalı'**
  String get authOtpInvalid;

  /// No description provided for @authOtpExpired.
  ///
  /// In tr, this message translates to:
  /// **'Kod süresi doldu'**
  String get authOtpExpired;

  /// No description provided for @profileSetupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını tamamla'**
  String get profileSetupTitle;

  /// No description provided for @profileFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get profileFullName;

  /// No description provided for @profileFullNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad gerekli'**
  String get profileFullNameRequired;

  /// No description provided for @profileCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get profileCity;

  /// No description provided for @profileDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get profileDistrict;

  /// No description provided for @profileCompanyName.
  ///
  /// In tr, this message translates to:
  /// **'Firma adı'**
  String get profileCompanyName;

  /// No description provided for @profileTaxNumber.
  ///
  /// In tr, this message translates to:
  /// **'Vergi numarası'**
  String get profileTaxNumber;

  /// No description provided for @profileTaxNumberInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Vergi numarası 10 haneli olmalı'**
  String get profileTaxNumberInvalid;

  /// No description provided for @carrierVehicleType.
  ///
  /// In tr, this message translates to:
  /// **'Araç tipi'**
  String get carrierVehicleType;

  /// No description provided for @carrierCapacity.
  ///
  /// In tr, this message translates to:
  /// **'Tonaj kapasitesi'**
  String get carrierCapacity;

  /// No description provided for @carrierTrailerType.
  ///
  /// In tr, this message translates to:
  /// **'Kasa tipi'**
  String get carrierTrailerType;

  /// No description provided for @carrierPreferredRegions.
  ///
  /// In tr, this message translates to:
  /// **'Tercih edilen bölgeler'**
  String get carrierPreferredRegions;

  /// No description provided for @carrierPlate.
  ///
  /// In tr, this message translates to:
  /// **'Plaka'**
  String get carrierPlate;

  /// No description provided for @carrierPlateInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir plaka gir'**
  String get carrierPlateInvalid;

  /// No description provided for @jobsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ilan yok'**
  String get jobsEmpty;

  /// No description provided for @jobsEmptyShipperSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yük taşıtmak için yeni bir ilan oluştur'**
  String get jobsEmptyShipperSubtitle;

  /// No description provided for @jobsEmptyCarrierSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakında uygun yükler burada görünür'**
  String get jobsEmptyCarrierSubtitle;

  /// No description provided for @jobsEmptyWithFilters.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtrelerle eşleşen ilan bulunamadı'**
  String get jobsEmptyWithFilters;

  /// No description provided for @jobsClearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get jobsClearFilters;

  /// No description provided for @jobsCreateNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlan Oluştur'**
  String get jobsCreateNew;

  /// No description provided for @jobsTabAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut'**
  String get jobsTabAvailable;

  /// No description provided for @jobsTabActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Taşımalarım'**
  String get jobsTabActive;

  /// No description provided for @jobsNoActiveCarrierJobs.
  ///
  /// In tr, this message translates to:
  /// **'Aktif taşıman yok'**
  String get jobsNoActiveCarrierJobs;

  /// No description provided for @jobsNoActiveCarrierJobsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kabul edilen tekliflerin burada listelenecek'**
  String get jobsNoActiveCarrierJobsSubtitle;

  /// No description provided for @jobStatusOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get jobStatusOpen;

  /// No description provided for @jobStatusOfferAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Teklif Kabul Edildi'**
  String get jobStatusOfferAccepted;

  /// No description provided for @jobStatusPickupApproval.
  ///
  /// In tr, this message translates to:
  /// **'Yük Alındı Onayı'**
  String get jobStatusPickupApproval;

  /// No description provided for @jobStatusLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Yük Alındı'**
  String get jobStatusLoaded;

  /// No description provided for @jobStatusOnRoad.
  ///
  /// In tr, this message translates to:
  /// **'Yolda'**
  String get jobStatusOnRoad;

  /// No description provided for @jobStatusDeliveryApproval.
  ///
  /// In tr, this message translates to:
  /// **'Teslim Onayı'**
  String get jobStatusDeliveryApproval;

  /// No description provided for @jobStatusAwaitingPayment.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Bekleniyor'**
  String get jobStatusAwaitingPayment;

  /// No description provided for @jobStatusCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Teslim Edildi'**
  String get jobStatusCompleted;

  /// No description provided for @jobStatusCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal Edildi'**
  String get jobStatusCancelled;

  /// No description provided for @paymentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get paymentTitle;

  /// No description provided for @paymentNotReady.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme adımı henüz açılmadı. Teslim onaylarını tamamlayın.'**
  String get paymentNotReady;

  /// No description provided for @paymentAwaitingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bekleniyor'**
  String get paymentAwaitingTitle;

  /// No description provided for @paymentCompletedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme tamamlandı'**
  String get paymentCompletedTitle;

  /// No description provided for @paymentCarrierTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme onayı'**
  String get paymentCarrierTitle;

  /// No description provided for @paymentAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get paymentAmount;

  /// No description provided for @paymentCommission.
  ///
  /// In tr, this message translates to:
  /// **'Komisyon'**
  String get paymentCommission;

  /// No description provided for @paymentZeroCommission.
  ///
  /// In tr, this message translates to:
  /// **'₺0 — sıfır komisyon'**
  String get paymentZeroCommission;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get paymentStatusLabel;

  /// No description provided for @paymentStatusAwaiting.
  ///
  /// In tr, this message translates to:
  /// **'Havale bekleniyor'**
  String get paymentStatusAwaiting;

  /// No description provided for @paymentStatusConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get paymentStatusConfirmed;

  /// No description provided for @paymentStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get paymentStatusPending;

  /// No description provided for @paymentIbanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nakliyeci IBAN'**
  String get paymentIbanTitle;

  /// No description provided for @paymentIbanHint.
  ///
  /// In tr, this message translates to:
  /// **'Banka uygulamanızdan havale veya EFT yapın.'**
  String get paymentIbanHint;

  /// No description provided for @paymentIbanMissing.
  ///
  /// In tr, this message translates to:
  /// **'Nakliyeci henüz IBAN eklemedi.'**
  String get paymentIbanMissing;

  /// No description provided for @paymentCopyIban.
  ///
  /// In tr, this message translates to:
  /// **'IBAN Kopyala'**
  String get paymentCopyIban;

  /// No description provided for @paymentIbanCopied.
  ///
  /// In tr, this message translates to:
  /// **'IBAN panoya kopyalandı'**
  String get paymentIbanCopied;

  /// No description provided for @paymentWaitingCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Nakliyecinin ödeme onayı bekleniyor…'**
  String get paymentWaitingCarrier;

  /// No description provided for @paymentCarrierHint.
  ///
  /// In tr, this message translates to:
  /// **'Tutar hesabına geçtiğinde aşağıdan onayla.'**
  String get paymentCarrierHint;

  /// No description provided for @paymentConfirmReceived.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme alındı, işi tamamla'**
  String get paymentConfirmReceived;

  /// No description provided for @paymentConfirmSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme onaylandı, iş tamamlandı'**
  String get paymentConfirmSuccess;

  /// No description provided for @paymentConfirmDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme onayı'**
  String get paymentConfirmDialogTitle;

  /// No description provided for @paymentConfirmDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'Tutarın hesabına geçtiğinden emin misin? Bu işlem geri alınamaz.'**
  String get paymentConfirmDialogBody;

  /// No description provided for @carrierIban.
  ///
  /// In tr, this message translates to:
  /// **'IBAN'**
  String get carrierIban;

  /// No description provided for @carrierIbanInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir TR IBAN gir (26 karakter)'**
  String get carrierIbanInvalid;

  /// No description provided for @homePaymentPending.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bekliyor'**
  String get homePaymentPending;

  /// No description provided for @homePaymentPendingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Havale yap veya nakliyeci onayını bekle'**
  String get homePaymentPendingSubtitle;

  /// No description provided for @homePaymentPendingAction.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeye git'**
  String get homePaymentPendingAction;

  /// No description provided for @paymentReportTransfer.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeyi yaptım'**
  String get paymentReportTransfer;

  /// No description provided for @paymentReportTransferSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bildirimin alındı'**
  String get paymentReportTransferSuccess;

  /// No description provided for @paymentReportTransferDone.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bildirimin kayıtlı'**
  String get paymentReportTransferDone;

  /// No description provided for @paymentEscrowTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli ödeme (escrow)'**
  String get paymentEscrowTitle;

  /// No description provided for @paymentEscrowHint.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme platformda tutuluyor. Teslim onayından sonra serbest bırakılabilir.'**
  String get paymentEscrowHint;

  /// No description provided for @paymentEscrowRelease.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeyi serbest bırak'**
  String get paymentEscrowRelease;

  /// No description provided for @paymentEscrowReleased.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme nakliyeciye aktarıldı'**
  String get paymentEscrowReleased;

  /// No description provided for @offerZeroCommissionNote.
  ///
  /// In tr, this message translates to:
  /// **'Platform komisyonu yok; anlaşılan tutar nakliyeciye gider.'**
  String get offerZeroCommissionNote;

  /// No description provided for @offerStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get offerStatusPending;

  /// No description provided for @offerStatusAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Edildi'**
  String get offerStatusAccepted;

  /// No description provided for @offerStatusRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get offerStatusRejected;

  /// No description provided for @offerStatusWithdrawn.
  ///
  /// In tr, this message translates to:
  /// **'Geri Çekildi'**
  String get offerStatusWithdrawn;

  /// No description provided for @offerStatusExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi Doldu'**
  String get offerStatusExpired;

  /// No description provided for @offerGiveOffer.
  ///
  /// In tr, this message translates to:
  /// **'Teklif Ver'**
  String get offerGiveOffer;

  /// No description provided for @offerYourOffer.
  ///
  /// In tr, this message translates to:
  /// **'Senin teklifin'**
  String get offerYourOffer;

  /// No description provided for @offerEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz teklif yok'**
  String get offerEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim yok'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildirimlerin burada görünecek'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü okundu işaretle'**
  String get notificationsMarkAllRead;

  /// No description provided for @notifEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim yok'**
  String get notifEmpty;

  /// No description provided for @notifEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildirimlerin burada görünecek'**
  String get notifEmptySubtitle;

  /// No description provided for @msgEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok'**
  String get msgEmpty;

  /// No description provided for @msgEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif kabul edildikten sonra karşı tarafla mesajlaşabilirsin'**
  String get msgEmptySubtitle;

  /// No description provided for @msgLockedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlaşma kilidi'**
  String get msgLockedTitle;

  /// No description provided for @msgLockedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif kabul edilince mesajlaşma açılır'**
  String get msgLockedSubtitle;

  /// No description provided for @msgComposeHint.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yaz...'**
  String get msgComposeHint;

  /// No description provided for @msgStartConversation.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlaşmaya başla'**
  String get msgStartConversation;

  /// No description provided for @msgStartConversationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk mesajı sen yaz; yük ve teslimat hakkında konuşun.'**
  String get msgStartConversationSubtitle;

  /// No description provided for @reviewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendir'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu taşıma için deneyimini değerlendir'**
  String get reviewSubtitle;

  /// No description provided for @reviewSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get reviewSubmit;

  /// No description provided for @reviewCommentHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum (opsiyonel)'**
  String get reviewCommentHint;

  /// No description provided for @reviewSaved.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmen kaydedildi'**
  String get reviewSaved;

  /// No description provided for @reviewRatingRequired.
  ///
  /// In tr, this message translates to:
  /// **'En az 1 yıldız ver'**
  String get reviewRatingRequired;

  /// No description provided for @profileLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinden emin misin?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileEdit.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get profileEdit;

  /// No description provided for @profileSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get profileSettings;

  /// No description provided for @profileSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get profileSupport;

  /// No description provided for @profilePrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get profilePrivacy;

  /// No description provided for @profileTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get profileTerms;

  /// No description provided for @profileVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String profileVersion(String version);

  /// No description provided for @errorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantın yok'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İstek zaman aşımına uğradı'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası, lütfen tekrar dene'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir hata oluştu'**
  String get errorUnknown;

  /// No description provided for @errorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın şey bulunamadı'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok'**
  String get errorUnauthorized;

  /// No description provided for @carrierSetupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Araç Bilgileri'**
  String get carrierSetupTitle;

  /// No description provided for @carrierCapacityRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kapasite gerekli'**
  String get carrierCapacityRequired;

  /// No description provided for @carrierCapacityInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir kapasite gir'**
  String get carrierCapacityInvalid;

  /// No description provided for @carrierVehicleTruck.
  ///
  /// In tr, this message translates to:
  /// **'Kamyon'**
  String get carrierVehicleTruck;

  /// No description provided for @carrierVehicleSemi.
  ///
  /// In tr, this message translates to:
  /// **'Tır'**
  String get carrierVehicleSemi;

  /// No description provided for @carrierTrailerCurtainsider.
  ///
  /// In tr, this message translates to:
  /// **'Tenteli'**
  String get carrierTrailerCurtainsider;

  /// No description provided for @carrierTrailerOpenBed.
  ///
  /// In tr, this message translates to:
  /// **'Açık Kasa'**
  String get carrierTrailerOpenBed;

  /// No description provided for @carrierTrailerClosedBox.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı Kasa'**
  String get carrierTrailerClosedBox;

  /// No description provided for @carrierTrailerReefer.
  ///
  /// In tr, this message translates to:
  /// **'Frigorifik'**
  String get carrierTrailerReefer;

  /// No description provided for @carrierTrailerTipper.
  ///
  /// In tr, this message translates to:
  /// **'Damperli'**
  String get carrierTrailerTipper;

  /// No description provided for @carrierTrailerLowbed.
  ///
  /// In tr, this message translates to:
  /// **'Lowbed'**
  String get carrierTrailerLowbed;

  /// No description provided for @adminTitle.
  ///
  /// In tr, this message translates to:
  /// **'Admin Paneli'**
  String get adminTitle;

  /// No description provided for @adminUsers.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get adminUsers;

  /// No description provided for @adminUsersList.
  ///
  /// In tr, this message translates to:
  /// **'Liste ve doğrulama'**
  String get adminUsersList;

  /// No description provided for @adminUsersBody.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı listesi ve ban/verify işlemleri staging ortamında Supabase admin politikaları ile açılır.'**
  String get adminUsersBody;

  /// No description provided for @adminDisputes.
  ///
  /// In tr, this message translates to:
  /// **'Anlaşmazlıklar'**
  String get adminDisputes;

  /// No description provided for @adminDisputesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme uyuşmazlığı kuyruğu'**
  String get adminDisputesSubtitle;

  /// No description provided for @adminDisputeDemo.
  ///
  /// In tr, this message translates to:
  /// **'Örnek kayıt (demo)'**
  String get adminDisputeDemo;

  /// No description provided for @adminDisputeDemoBody.
  ///
  /// In tr, this message translates to:
  /// **'Yükveren ödemedim / nakliyeci almadım — karar ver, iş ve ödeme durumunu güncelle.'**
  String get adminDisputeDemoBody;

  /// No description provided for @adminMetricUsers.
  ///
  /// In tr, this message translates to:
  /// **'Toplam kullanıcı'**
  String get adminMetricUsers;

  /// No description provided for @adminMetricJobs.
  ///
  /// In tr, this message translates to:
  /// **'Açık ilan'**
  String get adminMetricJobs;

  /// No description provided for @adminMetricDisputes.
  ///
  /// In tr, this message translates to:
  /// **'Açık dispute'**
  String get adminMetricDisputes;

  /// No description provided for @adminMetricPayments.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen ödeme'**
  String get adminMetricPayments;

  /// No description provided for @paymentCancelledTitle.
  ///
  /// In tr, this message translates to:
  /// **'İş iptal edildi'**
  String get paymentCancelledTitle;

  /// No description provided for @paymentCancelledBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu iş iptal edildiği için ödeme adımı mevcut değil.'**
  String get paymentCancelledBody;

  /// No description provided for @offerGiveOfferTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif Ver'**
  String get offerGiveOfferTitle;

  /// No description provided for @offerPriceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatın (₺)'**
  String get offerPriceLabel;

  /// No description provided for @offerPriceRequired.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat gerekli'**
  String get offerPriceRequired;

  /// No description provided for @offerPriceInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir fiyat gir'**
  String get offerPriceInvalid;

  /// No description provided for @offerPriceTooHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek'**
  String get offerPriceTooHigh;

  /// No description provided for @offerMessageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj (opsiyonel)'**
  String get offerMessageLabel;

  /// No description provided for @offerMessageHint.
  ///
  /// In tr, this message translates to:
  /// **'Aracın, deneyimin, hızın hakkında kısa bir not...'**
  String get offerMessageHint;

  /// No description provided for @offerSent.
  ///
  /// In tr, this message translates to:
  /// **'Teklifin gönderildi'**
  String get offerSent;

  /// No description provided for @offerBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get offerBudget;

  /// No description provided for @offerBudgetWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu teklif yükverenin bütçesini (₺{budget}) aşıyor'**
  String offerBudgetWarning(String budget);

  /// No description provided for @createJobTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlan'**
  String get createJobTitle;

  /// No description provided for @createJobTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get createJobTitleLabel;

  /// No description provided for @createJobTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. İstanbul – Konya tekstil yükü'**
  String get createJobTitleHint;

  /// No description provided for @createJobTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Başlık gerekli'**
  String get createJobTitleRequired;

  /// No description provided for @createJobDescLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (opsiyonel)'**
  String get createJobDescLabel;

  /// No description provided for @createJobDescHint.
  ///
  /// In tr, this message translates to:
  /// **'Yük hakkında ek detaylar'**
  String get createJobDescHint;

  /// No description provided for @createJobCargoSectionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kargo'**
  String get createJobCargoSectionLabel;

  /// No description provided for @createJobCargoTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kargo tipi'**
  String get createJobCargoTypeLabel;

  /// No description provided for @createJobWeightLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ağırlık (ton)'**
  String get createJobWeightLabel;

  /// No description provided for @createJobWeightRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ağırlık gerekli'**
  String get createJobWeightRequired;

  /// No description provided for @createJobWeightInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir değer gir'**
  String get createJobWeightInvalid;

  /// No description provided for @createJobVolumeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hacim (m³)'**
  String get createJobVolumeLabel;

  /// No description provided for @createJobTrailerLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tercih edilen kasa (opsiyonel)'**
  String get createJobTrailerLabel;

  /// No description provided for @createJobTrailerAny.
  ///
  /// In tr, this message translates to:
  /// **'Fark etmez'**
  String get createJobTrailerAny;

  /// No description provided for @createJobOriginLabel.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get createJobOriginLabel;

  /// No description provided for @createJobDestLabel.
  ///
  /// In tr, this message translates to:
  /// **'Varış'**
  String get createJobDestLabel;

  /// No description provided for @createJobCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get createJobCityLabel;

  /// No description provided for @createJobDistrictLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get createJobDistrictLabel;

  /// No description provided for @createJobDistrictRequired.
  ///
  /// In tr, this message translates to:
  /// **'İlçe gerekli'**
  String get createJobDistrictRequired;

  /// No description provided for @createJobAddressOriginLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres (opsiyonel, teklif kabul edilince görünür)'**
  String get createJobAddressOriginLabel;

  /// No description provided for @createJobAddressDestLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres (opsiyonel)'**
  String get createJobAddressDestLabel;

  /// No description provided for @createJobDatesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarihler ve bütçe'**
  String get createJobDatesLabel;

  /// No description provided for @createJobPickupDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yükleme'**
  String get createJobPickupDateLabel;

  /// No description provided for @createJobDeliveryDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Teslim'**
  String get createJobDeliveryDateLabel;

  /// No description provided for @createJobSelectDate.
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get createJobSelectDate;

  /// No description provided for @createJobBudgetMinLabel.
  ///
  /// In tr, this message translates to:
  /// **'Min bütçe ₺'**
  String get createJobBudgetMinLabel;

  /// No description provided for @createJobBudgetMaxLabel.
  ///
  /// In tr, this message translates to:
  /// **'Maks bütçe ₺'**
  String get createJobBudgetMaxLabel;

  /// No description provided for @createJobPublish.
  ///
  /// In tr, this message translates to:
  /// **'Yayına Al'**
  String get createJobPublish;

  /// No description provided for @createJobPublishing.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get createJobPublishing;

  /// No description provided for @createJobPublished.
  ///
  /// In tr, this message translates to:
  /// **'İlan yayına alındı'**
  String get createJobPublished;

  /// No description provided for @createJobPickupRequired.
  ///
  /// In tr, this message translates to:
  /// **'Yükleme tarihi seç'**
  String get createJobPickupRequired;

  /// No description provided for @createJobCitiesRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şehirleri seç'**
  String get createJobCitiesRequired;

  /// No description provided for @createJobBudgetError.
  ///
  /// In tr, this message translates to:
  /// **'Maks bütçe, min bütçeden büyük olmalı'**
  String get createJobBudgetError;

  /// No description provided for @createJobDeliveryBeforePickup.
  ///
  /// In tr, this message translates to:
  /// **'Teslim tarihi, yükleme tarihinden sonra olmalı'**
  String get createJobDeliveryBeforePickup;

  /// No description provided for @msgUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get msgUnknown;

  /// No description provided for @msgNoConversation.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok'**
  String get msgNoConversation;

  /// No description provided for @trackingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Takip'**
  String get trackingTitle;

  /// No description provided for @trackingJobNotFound.
  ///
  /// In tr, this message translates to:
  /// **'İlan bulunamadı'**
  String get trackingJobNotFound;

  /// No description provided for @trackingWaiting.
  ///
  /// In tr, this message translates to:
  /// **'Konum bekleniyor'**
  String get trackingWaiting;

  /// No description provided for @trackingLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı'**
  String get trackingLive;

  /// No description provided for @trackingLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {time}'**
  String trackingLastUpdate(String time);

  /// No description provided for @trackingWebTitle.
  ///
  /// In tr, this message translates to:
  /// **'Web takip görünümü'**
  String get trackingWebTitle;

  /// No description provided for @trackingWebSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ortamda gömülü harita yerine güvenli yedek görünüm kullanılıyor.'**
  String get trackingWebSubtitle;

  /// No description provided for @trackingWebPingCount.
  ///
  /// In tr, this message translates to:
  /// **'Toplam ping: {count}'**
  String trackingWebPingCount(int count);

  /// No description provided for @trackingLastLocation.
  ///
  /// In tr, this message translates to:
  /// **'Son konum: {coords}'**
  String trackingLastLocation(String coords);

  /// No description provided for @trackingWebNote.
  ///
  /// In tr, this message translates to:
  /// **'Canlı takip bu ekranda uygulama içi olarak devam eder.'**
  String get trackingWebNote;

  /// No description provided for @profileNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Profil bulunamadı'**
  String get profileNotFound;

  /// No description provided for @profileRoleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Yükveren'**
  String get profileRoleShipper;

  /// No description provided for @profileRoleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Nakliyeci'**
  String get profileRoleCarrier;

  /// No description provided for @profileTagCompany.
  ///
  /// In tr, this message translates to:
  /// **'Kurumsal'**
  String get profileTagCompany;

  /// No description provided for @profileStatRating.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama puan'**
  String get profileStatRating;

  /// No description provided for @profileStatJobsShipper.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan ilan'**
  String get profileStatJobsShipper;

  /// No description provided for @profileStatJobsCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan taşıma'**
  String get profileStatJobsCarrier;

  /// No description provided for @profileInfoLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get profileInfoLocation;

  /// No description provided for @profileInfoCompany.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get profileInfoCompany;

  /// No description provided for @profileInfoTaxNumber.
  ///
  /// In tr, this message translates to:
  /// **'Vergi No'**
  String get profileInfoTaxNumber;

  /// No description provided for @profileReviewsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Değerlendirmeler'**
  String get profileReviewsTitle;

  /// No description provided for @profileNoReviews.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değerlendirme yok'**
  String get profileNoReviews;

  /// No description provided for @profileReviewAnon.
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get profileReviewAnon;

  /// No description provided for @profileSettingsEdit.
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get profileSettingsEdit;

  /// No description provided for @profileSettingsTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get profileSettingsTerms;

  /// No description provided for @profileSettingsPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik / KVKK'**
  String get profileSettingsPrivacy;

  /// No description provided for @profileSettingsHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yardım & Destek'**
  String get profileSettingsHelp;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In tr, this message translates to:
  /// **'Hesabından çıkış yapmak istediğinden emin misin?'**
  String get profileSignOutBody;

  /// No description provided for @profileSignOutCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get profileSignOutCancel;

  /// No description provided for @profileSignOutAction.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get profileSignOutAction;

  /// No description provided for @profileFooter.
  ///
  /// In tr, this message translates to:
  /// **'ARACIYOK'**
  String get profileFooter;

  /// No description provided for @homeGreetingHintShipper.
  ///
  /// In tr, this message translates to:
  /// **'İlanlarını yönet, aktif taşımanı takip et.'**
  String get homeGreetingHintShipper;

  /// No description provided for @homeGreetingHintCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Aktif taşımanı yönet, uygun yükleri yakala.'**
  String get homeGreetingHintCarrier;

  /// No description provided for @homeHeroTitleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü durum'**
  String get homeHeroTitleShipper;

  /// No description provided for @homeHeroSubtitleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Operasyon merkezin'**
  String get homeHeroSubtitleShipper;

  /// No description provided for @homeHeroTitleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü fırsatlar'**
  String get homeHeroTitleCarrier;

  /// No description provided for @homeHeroSubtitleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Nakliye paneli'**
  String get homeHeroSubtitleCarrier;

  /// No description provided for @homeHeroPrimaryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aktif taşıma'**
  String get homeHeroPrimaryLabel;

  /// No description provided for @homeHeroSecondaryLabelShipper.
  ///
  /// In tr, this message translates to:
  /// **'Toplam ilan'**
  String get homeHeroSecondaryLabelShipper;

  /// No description provided for @homeHeroSecondaryLabelCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Açık ilan'**
  String get homeHeroSecondaryLabelCarrier;

  /// No description provided for @homeHeroHintShipper.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden taşımalara öncelik ver.'**
  String get homeHeroHintShipper;

  /// No description provided for @homeHeroHintShipperEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Yeni ilan açarak teklif toplamayı hızlandır.'**
  String get homeHeroHintShipperEmpty;

  /// No description provided for @homeHeroHintCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Uygun ilanları kaçırmadan teklif ver.'**
  String get homeHeroHintCarrier;

  /// No description provided for @homeHeroHintCarrierEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Yeni ilanlar için filtrelerini güncelle.'**
  String get homeHeroHintCarrierEmpty;

  /// No description provided for @homeCtaTitleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir ilan oluştur'**
  String get homeCtaTitleShipper;

  /// No description provided for @homeCtaSubtitleShipper.
  ///
  /// In tr, this message translates to:
  /// **'Yüklerini hızlıca ilan et, teklifleri karşılaştır.'**
  String get homeCtaSubtitleShipper;

  /// No description provided for @homeCtaButtonShipper.
  ///
  /// In tr, this message translates to:
  /// **'İlan Oluştur'**
  String get homeCtaButtonShipper;

  /// No description provided for @homeCtaTitleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Bugün yeni yük bul'**
  String get homeCtaTitleCarrier;

  /// No description provided for @homeCtaSubtitleCarrier.
  ///
  /// In tr, this message translates to:
  /// **'Şehir ve yük tipine göre filtreleyip hemen teklif ver.'**
  String get homeCtaSubtitleCarrier;

  /// No description provided for @homeCtaButtonCarrierJobs.
  ///
  /// In tr, this message translates to:
  /// **'İlanlara Git'**
  String get homeCtaButtonCarrierJobs;

  /// No description provided for @homeCtaButtonCarrierFilter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get homeCtaButtonCarrierFilter;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı işlemler'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeQuickActionNewJob.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlan Oluştur'**
  String get homeQuickActionNewJob;

  /// No description provided for @homeQuickActionNewJobSub.
  ///
  /// In tr, this message translates to:
  /// **'Hızlıca yeni bir yük ilanı aç'**
  String get homeQuickActionNewJobSub;

  /// No description provided for @homeQuickActionMyJobs.
  ///
  /// In tr, this message translates to:
  /// **'İlanlarım'**
  String get homeQuickActionMyJobs;

  /// No description provided for @homeQuickActionMyJobsSub.
  ///
  /// In tr, this message translates to:
  /// **'Tüm ilanlarını ve durumlarını gör'**
  String get homeQuickActionMyJobsSub;

  /// No description provided for @homeQuickActionActive.
  ///
  /// In tr, this message translates to:
  /// **'Aldığım işler'**
  String get homeQuickActionActive;

  /// No description provided for @homeQuickActionActiveSub.
  ///
  /// In tr, this message translates to:
  /// **'Aktif taşıma süreçlerini aç'**
  String get homeQuickActionActiveSub;

  /// No description provided for @homeQuickActionCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Yaptığım işler'**
  String get homeQuickActionCompleted;

  /// No description provided for @homeQuickActionCompletedSub.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan taşıma geçmişin'**
  String get homeQuickActionCompletedSub;

  /// No description provided for @homeQuickActionOffers.
  ///
  /// In tr, this message translates to:
  /// **'Tekliflerim'**
  String get homeQuickActionOffers;

  /// No description provided for @homeQuickActionOffersSub.
  ///
  /// In tr, this message translates to:
  /// **'Verdiğin tüm teklifleri görüntüle'**
  String get homeQuickActionOffersSub;

  /// No description provided for @homeEmptyJobsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ilanın yok'**
  String get homeEmptyJobsTitle;

  /// No description provided for @homeEmptyJobsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk ilanını oluştur, nakliyecilerden teklif almaya başla.'**
  String get homeEmptyJobsSubtitle;

  /// No description provided for @homeEmptyOpenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık ilan yok'**
  String get homeEmptyOpenTitle;

  /// No description provided for @homeEmptyOpenSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an için açık bir ilan bulunamadı. Birazdan tekrar dene.'**
  String get homeEmptyOpenSubtitle;

  /// No description provided for @homeSectionActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden taşımaların'**
  String get homeSectionActiveTitle;

  /// No description provided for @homeSectionActiveSub.
  ///
  /// In tr, this message translates to:
  /// **'En kritik operasyonlar'**
  String get homeSectionActiveSub;

  /// No description provided for @homeSectionRecentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son ilanların'**
  String get homeSectionRecentTitle;

  /// No description provided for @homeSectionRecentSub.
  ///
  /// In tr, this message translates to:
  /// **'Hızlıca açıp işlem yap'**
  String get homeSectionRecentSub;

  /// No description provided for @homeSectionCarrierActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif taşımaların'**
  String get homeSectionCarrierActiveTitle;

  /// No description provided for @homeSectionCarrierActiveSub.
  ///
  /// In tr, this message translates to:
  /// **'Önce bunları tamamla'**
  String get homeSectionCarrierActiveSub;

  /// No description provided for @homeSectionRecommendedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen ilanlar'**
  String get homeSectionRecommendedTitle;

  /// No description provided for @homeSectionRecommendedSub.
  ///
  /// In tr, this message translates to:
  /// **'Sana uygun açık ilanlar'**
  String get homeSectionRecommendedSub;

  /// No description provided for @actionAll.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get actionAll;

  /// No description provided for @actionAllJobs.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get actionAllJobs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
