import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/core/router.dart';
import 'package:tasima_app/core/theme.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:tasima_app/features/jobs/data/job_repository.dart';
import 'package:tasima_app/features/jobs/data/job_state.dart';
import 'package:tasima_app/features/offers/data/offer_repository.dart';
import 'package:tasima_app/features/offers/data/offer_state.dart';
import 'package:tasima_app/features/offers/screens/submit_offer_sheet.dart';
import 'package:tasima_app/features/reviews/data/review_repository.dart';
import 'package:tasima_app/features/reviews/data/review_state.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  JobPost? _job;
  List<JobPhoto>? _photos;
  // ignore: unused_field
  JobPrivateInfo? _privateInfo;
  String? _error;
  bool _loading = true;
  bool _isOwner = false;
  String? _userRole;
  String? _userId;
  Offer? _myOffer;
  List<OfferWithCarrier>? _incomingOffers;
  OfferWithCarrier? _acceptedOffer;
  Map<String, dynamic>? _carrierContact;
  Map<String, dynamic>? _shipperContact;
  Map<String, dynamic>? _jobAddressesForCarrier;
  bool _hasReviewed = false;
  Review? _myReview;
  bool get _isCarrier => _userRole == 'carrier';
  bool get _isOpen => _job?.status == JobStatus.open;
  bool get _isAccepted => _job?.status == JobStatus.offer_accepted;
  bool get _isInProgress => _job?.status == JobStatus.in_progress;
  bool get _isCompleted => _job?.status == JobStatus.completed;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final jobRepo = ref.read(jobRepositoryProvider);
      final offerRepo = ref.read(offerRepositoryProvider);
      final uid = DevAuthService.isActive ? DevAuthService.devUserId : SupabaseClientManager.instance.client.auth.currentUser?.id;
      if (uid != null) {
        final p = DevAuthService.isActive ? await DevAuthService.getProfileForUser(uid) : await SupabaseClientManager.instance.client.from('profiles').select('role').eq('id', uid).maybeSingle();
        if (mounted) setState(() { _userRole = p?['role']; _userId = uid; });
      }
      final job = await jobRepo.getJobPostById(widget.jobId);
      if (job == null && mounted) { setState(() { _error = 'Ilan bulunamadi.'; _loading = false; }); return; }
      final j = job!;
      final photos = await jobRepo.getJobPhotos(widget.jobId);
      final isOwner = uid != null && j.shipperId == uid;
      JobPrivateInfo? privateInfo;
      if (isOwner) privateInfo = await jobRepo.getJobPrivateInfoForOwner(widget.jobId);
      Offer? myOffer;
      if (uid != null && !isOwner) myOffer = await offerRepo.getMyOfferForJob(widget.jobId);
      List<OfferWithCarrier>? incomingOffers;
      if (isOwner) incomingOffers = await offerRepo.getOffersForJob(widget.jobId);
      OfferWithCarrier? acceptedOffer;
      Map<String, dynamic>? carrierContact, shipperContact, jobAddressesForCarrier;
      if ((j.status == JobStatus.offer_accepted || j.status == JobStatus.in_progress || j.status == JobStatus.completed) && j.acceptedOfferId != null) {
        acceptedOffer = await offerRepo.getAcceptedOfferForJob(widget.jobId);
        if (acceptedOffer != null && uid != null) {
          if (isOwner) carrierContact = await offerRepo.getCarrierContactInfo(acceptedOffer.offer.carrierId);
          if (uid == acceptedOffer.offer.carrierId) { shipperContact = await offerRepo.getShipperContactInfo(j.shipperId); jobAddressesForCarrier = await offerRepo.getJobPrivateInfoForAccepted(widget.jobId); }
        }
      }
      bool hasReviewed = false; Review? myReview;
      if (j.status == JobStatus.completed && uid != null && j.acceptedOfferId != null) {
        final reviewRepo = ref.read(reviewRepositoryProvider);
        final revieweeId = isOwner ? acceptedOffer?.offer.carrierId : j.shipperId;
        if (revieweeId != null) { hasReviewed = await reviewRepo.hasReviewed(widget.jobId, revieweeId); if (hasReviewed) myReview = await reviewRepo.getMyReviewForJob(widget.jobId, revieweeId); }
      }
      if (!mounted) return;
      setState(() { _job = job; _photos = photos; _privateInfo = privateInfo; _isOwner = isOwner; _error = null; _myOffer = myOffer; _incomingOffers = incomingOffers; _acceptedOffer = acceptedOffer; _carrierContact = carrierContact; _shipperContact = shipperContact; _jobAddressesForCarrier = jobAddressesForCarrier; _hasReviewed = hasReviewed; _myReview = myReview; _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = 'Ilan detaylari yuklenemedi.'; _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()), title: const Text('İş Detayı')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48, color: AppColors.error), const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: AppColors.textSecondary)), const SizedBox(height: 16), OutlinedButton(onPressed: _load, child: const Text('Tekrar Dene'))]));
    if (_job == null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.search_off, size: 48, color: AppColors.textHint), const SizedBox(height: 16), const Text('Ilan bulunamadi.', style: TextStyle(color: AppColors.textSecondary))]));
    final job = _job!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          _WorkflowStepper(currentStatus: job.status).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          const SizedBox(height: 16),
          _buildInfoCard(job).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.05),
          const SizedBox(height: 16),
          _buildDynamicSection(job).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
          if (_photos != null && _photos!.isNotEmpty) ...[const SizedBox(height: 16), _buildPhotos().animate().fadeIn(duration: 400.ms, delay: 300.ms)],
          if (!_isOwner && _userId != null) ...[const SizedBox(height: 16), GestureDetector(onTap: () => context.push('${AppRoutes.report}?jobPostId=${widget.jobId}'), child: const Row(children: [Icon(Icons.flag_outlined, size: 15, color: AppColors.textHint), SizedBox(width: 6), Text('Bu ilanı bildir', style: TextStyle(fontSize: 12, color: AppColors.textHint, decoration: TextDecoration.underline))]))],
          const SizedBox(height: 48),
        ]),
      ),
    );
  }

  Widget _buildInfoCard(JobPost job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [_cargoIcon(job.cargoType), const SizedBox(width: 10), Expanded(child: Text(job.cargoType.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.textPrimary))), _urgencyBadge(job.urgencyLevel)]),
        if (job.cargoDescription != null && job.cargoDescription!.isNotEmpty) ...[const SizedBox(height: 8), Text(job.cargoDescription!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3))],
        const SizedBox(height: 14),
        _infoRow(Icons.location_on_outlined, '${job.pickupCity}/${job.pickupDistrict}'),
        const SizedBox(height: 4),
        const Row(children: [SizedBox(width: 22), Icon(Icons.south, size: 16, color: AppColors.accent)]),
        const SizedBox(height: 4),
        _infoRow(Icons.flag_outlined, '${job.deliveryCity}/${job.deliveryDistrict}'),
        const SizedBox(height: 10),
        Row(children: [_infoRow(Icons.calendar_today_outlined, job.pickupDate), if (job.pickupTimeWindow != null) ...[const SizedBox(width: 16), _infoRow(Icons.access_time, job.pickupTimeWindow!)]]),
        if (job.extraNotes != null && job.extraNotes!.isNotEmpty) ...[const SizedBox(height: 10), Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: Text(job.extraNotes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)))],
      ]),
    );
  }

  Widget _buildDynamicSection(JobPost job) {
    if (job.status == JobStatus.cancelled) return _buildCancelledCard(job);
    if (_isOpen && _isOwner) return _buildShipperOpenSection();
    if (_isOpen && !_isOwner && _isCarrier) return _buildCarrierOpenSection();
    if (_isOpen && !_isOwner && !_isCarrier) return _infoCard('Bu ilana sadece nakliyeciler teklif verebilir.');
    if (_isAccepted) return _buildAcceptedSection();
    if (_isInProgress) return _buildInProgressCard();
    if (_isCompleted) return _buildCompletedSection();
    return const SizedBox();
  }

  Widget _buildCancelledCard(JobPost job) => _statusCard(icon: Icons.cancel_outlined, color: AppColors.error, title: 'Ilan Iptal Edildi', children: [if (job.cancelledReason != null) Text(job.cancelledReason!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))]);

  Widget _buildInProgressCard() {
    return _statusCard(icon: Icons.local_shipping, color: AppColors.primary, title: 'Taşıma Devam Ediyor', children: [
      const SizedBox(height: 12),
      Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 12), const Text('Tasima sureci devam ediyor...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))]),
      const SizedBox(height: 16),
      if (_isOwner && _carrierContact != null) _buildContactSection('Nakliyeci İletişim', _carrierContact!),
      if (!_isOwner && _userId == _acceptedOffer?.offer.carrierId && _shipperContact != null) _buildContactSection('Yuk Veren Iletisim', _shipperContact!),
      if (_isOwner) ...[const SizedBox(height: 12), _actionButton('Taşımayı Tamamla', AppColors.success, _confirmComplete)],
    ]);
  }

  Widget _buildShipperOpenSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Gelen Teklifler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      if (_incomingOffers == null) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
      else if (_incomingOffers!.isEmpty) _infoCard('Henuz teklif gelmedi.')
      else ...(_incomingOffers!.map((oc) => _offerCard(oc)).toList()),
      const SizedBox(height: 12),
      _actionButton('İlanı İptal Et', AppColors.error, _showCancelDialog),
    ]);
  }

  Widget _offerCard(OfferWithCarrier oc) {
    final o = oc.offer; final isPending = o.status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(oc.carrierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary))), _badge(o.status, _offerStatusMap)]),
        if (oc.vehicleType != null) ...[const SizedBox(height: 4), Text('${oc.vehicleType}  ${oc.capacityText ?? ""}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))],
        if (oc.ratingAvg != null) ...[const SizedBox(height: 4), Row(children: [const Icon(Icons.star, size: 14, color: AppColors.warning), const SizedBox(width: 4), Text('${oc.ratingAvg!.toStringAsFixed(1)} (${oc.completedJobsCount ?? 0} is)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))])],
        const SizedBox(height: 8), Text('${o.amount.toStringAsFixed(0)} TL', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.accent)),
        if (o.note != null && o.note!.isNotEmpty) ...[const SizedBox(height: 4), Text(o.note!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))],
        if (isPending) ...[const SizedBox(height: 10), SizedBox(width: double.infinity, height: 40, child: ElevatedButton(onPressed: () => _confirmAccept(o.id, oc.carrierName, o.amount), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white), child: const Text('Teklifi Kabul Et')))],
      ]),
    );
  }

  static const _offerStatusMap = {'pending': ('Beklemede', AppColors.warning), 'accepted': ('Kabul Edildi', AppColors.success), 'rejected': ('Reddedildi', AppColors.error), 'withdrawn': ('Geri Çekildi', AppColors.textHint), 'expired': ('Süresi Doldu', AppColors.textHint)};

  Widget _buildCarrierOpenSection() {
    return Column(children: [
      if (_myOffer != null) ...[
        _statusCard(icon: Icons.check_circle_outline, color: AppColors.success, title: 'Teklif Verdiniz', children: [
          const SizedBox(height: 4),
          Text('${_myOffer!.amount.toStringAsFixed(0)} TL  ${_offerStatusLabel(_myOffer!.status)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
          if (_myOffer!.note != null && _myOffer!.note!.isNotEmpty) ...[const SizedBox(height: 4), Text(_myOffer!.note!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))],
          if (_myOffer!.status == 'pending') ...[const SizedBox(height: 10), Row(children: [Expanded(child: OutlinedButton(onPressed: _editOffer, child: const Text('Düzenle'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => _withdrawOffer(_myOffer!.id), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Geri Çek')))])],
        ]),
      ] else ...[
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: _showSubmitOfferSheet, icon: const Icon(Icons.send), label: const Text('Teklif Ver'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white))),
      ],
    ]);
  }

  String _offerStatusLabel(String s) { const m = {'pending': 'Beklemede', 'accepted': 'Kabul Edildi', 'rejected': 'Reddedildi', 'withdrawn': 'Geri Çekildi'}; return m[s] ?? s; }

  Widget _buildAcceptedSection() {
    if (_isOwner) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _statusCard(icon: Icons.check_circle, color: AppColors.success, title: 'Nakliyeci Seçildi', children: [
          if (_acceptedOffer != null) ...[
            const SizedBox(height: 8), Text(_acceptedOffer!.carrierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: AppColors.textPrimary)),
            if (_acceptedOffer!.vehicleType != null) ...[const SizedBox(height: 2), Text('${_acceptedOffer!.vehicleType}  ${_acceptedOffer!.capacityText ?? ""}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))],
            const SizedBox(height: 6), Text('${_acceptedOffer!.offer.amount.toStringAsFixed(0)} TL', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.accent)),
          ],
        ]),
        if (_carrierContact != null) ...[const SizedBox(height: 12), _buildContactSection('İletişim Bilgileri', _carrierContact!)],
        const SizedBox(height: 12), _actionButton('Taşımayı Başlat', AppColors.success, _confirmStart),
        const SizedBox(height: 8), _actionButton('İşi İptal Et', AppColors.error, _showCancelDialog),
      ]);
    }
    if (_acceptedOffer != null && _userId == _acceptedOffer!.offer.carrierId) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _statusCard(icon: Icons.check_circle, color: AppColors.success, title: 'Teklifiniz Kabul Edildi', children: [
          const SizedBox(height: 6), Text('${_acceptedOffer!.offer.amount.toStringAsFixed(0)} TL', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textPrimary)),
        ]),
        if (_shipperContact != null) ...[const SizedBox(height: 12), _buildContactSection('Yuk Veren Bilgileri', _shipperContact!)],
        if (_jobAddressesForCarrier != null) ...[const SizedBox(height: 12), _buildAddressSection(_jobAddressesForCarrier!)],
        const SizedBox(height: 12), _actionButton('Taşımayı Başlat', AppColors.success, _confirmStart),
      ]);
    }
    return _infoCard('Bu ilan icin baska bir nakliyeci secildi.');
  }

  Widget _buildCompletedSection() {
    return _statusCard(icon: Icons.check_circle, color: AppColors.success, title: 'Tamamlandı', children: [
      const SizedBox(height: 8), const Text('Bu is basariyla tamamlandi.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      if (_hasReviewed) ...[const SizedBox(height: 8), _buildReviewDisplay()] else ...[const SizedBox(height: 12), _buildReviewForm()],
    ]);
  }

  Widget _buildPhotos() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Fotoğraflar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      SizedBox(height: 100, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: _photos!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _photos![i].photoUrl.isNotEmpty
              ? Image.network(_photos![i].photoUrl, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: AppColors.shimmerBase, child: const Icon(Icons.broken_image, color: AppColors.textHint)))
              : Container(width: 100, height: 100, color: AppColors.shimmerBase, child: const Icon(Icons.image, color: AppColors.textHint)),
        ),
      )),
    ]);
  }

  Widget _buildContactSection(String title, Map<String, dynamic> contact) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.accent)), const SizedBox(height: 8),
      if (contact['full_name'] != null) _contactRow(Icons.person_outline, contact['full_name']),
      if (contact['phone'] != null) _contactRow(Icons.phone_outlined, contact['phone'], onTap: () => _call(contact['phone']), actionLabel: 'Ara'),
      if (contact['plate_number'] != null) _contactRow(Icons.numbers_outlined, contact['plate_number']),
    ]);
  }

  Widget _buildAddressSection(Map<String, dynamic> a) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Adres Bilgileri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.accent)), const SizedBox(height: 8),
      if (a['pickup_address']?.toString().isNotEmpty == true) _contactRow(Icons.location_on_outlined, 'Yukleme: ${a['pickup_address']}'),
      if (a['delivery_address']?.toString().isNotEmpty == true) _contactRow(Icons.flag_outlined, 'Teslim: ${a['delivery_address']}'),
    ]);
  }

  Widget _buildReviewDisplay() {
    if (_myReview == null) return const SizedBox();
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.warning.withAlpha(12), borderRadius: BorderRadius.circular(10)), child: Row(children: [...List.generate(5, (i) => Icon(i < _myReview!.rating ? Icons.star : Icons.star_border, size: 18, color: AppColors.warning)), const SizedBox(width: 8), const Text('Puanınız', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))]));
  }

  Widget _buildReviewForm() {
    return _ReviewForm(revieweeId: _isOwner ? (_acceptedOffer?.offer.carrierId ?? '') : (_job?.shipperId ?? ''), onSubmit: (rating, comment) async {
      try {
        final repo = ref.read(reviewRepositoryProvider);
        await repo.createReview(jobPostId: widget.jobId, revieweeId: _isOwner ? (_acceptedOffer!.offer.carrierId) : (_job!.shipperId), rating: rating, comment: comment);
        if (mounted) { _load(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Degerlendirmeniz alindi.'))); }
      } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Degerlendirme gonderilemedi.'))); }
    });
  }

  Future<void> _confirmAccept(String offerId, String carrierName, double amount) async {
    final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Teklifi Kabul Et'), content: Text('$carrierName tarafindan verilen ${amount.toStringAsFixed(0)} TL teklifi kabul edilsin mi?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kabul Et'))]));
    if (c != true) return;
    try { await ref.read(offerRepositoryProvider).acceptOffer(offerId); if (mounted) _load(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif kabul edilemedi.'))); }
  }

  Future<void> _confirmStart() async {
    final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Taşımayı Başlat'), content: const Text('Tasima surecini baslatmak istediginize emin misiniz?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Başlat'))]));
    if (c != true) return;
    try { await ref.read(jobRepositoryProvider).startJob(widget.jobId); if (mounted) _load(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tasima baslatilamadi.'))); }
  }

  Future<void> _confirmComplete() async {
    final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Taşımayı Tamamla'), content: const Text('Tasimayi tamamlamak istediginize emin misiniz?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tamamla'))]));
    if (c != true) return;
    try { await ref.read(jobRepositoryProvider).completeJob(widget.jobId); if (mounted) _load(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tamamlanamadi.'))); }
  }

  Future<void> _showCancelDialog() async {
    final reason = TextEditingController();
    final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('İptal Et'), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('İptal nedenini kisaca belirtin (opsiyonel):'), const SizedBox(height: 8), TextField(controller: reason, decoration: const InputDecoration(hintText: 'İptal nedeni...'))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')), TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('İptal Et'))]));
    if (c != true) { reason.dispose(); return; }
    try { await ref.read(jobRepositoryProvider).cancelJob(widget.jobId, reason: reason.text.isNotEmpty ? reason.text : null); reason.dispose(); if (mounted) _load(); } catch (e) { reason.dispose(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iptal edilemedi.'))); }
  }

  Future<void> _editOffer() async { final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, builder: (_) => SubmitOfferSheet(jobPostId: widget.jobId, existingOffer: _myOffer)); if (result == true) _load(); }
  Future<void> _showSubmitOfferSheet() async { final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, builder: (_) => SubmitOfferSheet(jobPostId: widget.jobId)); if (result == true) _load(); }

  Future<void> _withdrawOffer(String offerId) async {
    final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Teklifi Geri Çek'), content: const Text('Teklifinizi geri cekmek istediginize emin misiniz?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Geri Çek'))]));
    if (c != true) return;
    try { await ref.read(offerRepositoryProvider).withdrawOffer(offerId); if (mounted) _load(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geri cekilemedi.'))); }
  }

  Future<void> _call(String? phone) async { if (phone == null || phone.isEmpty) return; final uri = Uri.parse('tel:$phone'); if (await canLaunchUrl(uri)) await launchUrl(uri); }

  Widget _statusCard({required IconData icon, required Color color, required String title, List<Widget> children = const []}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withAlpha(12), borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: color.withAlpha(40))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 22, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color))]), ...children]));
  }

  Widget _infoCard(String text) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)));

  Widget _actionButton(String label, Color color, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 44, child: OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color)), child: Text(label)));

  Widget _infoRow(IconData icon, String text) => Row(children: [Icon(icon, size: 16, color: AppColors.textHint), const SizedBox(width: 6), Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)))]);

  Widget _contactRow(IconData icon, String text, {VoidCallback? onTap, String? actionLabel}) {
    return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(icon, size: 18, color: AppColors.accent), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))), if (onTap != null && actionLabel != null) TextButton(onPressed: onTap, child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w600)))]));
  }

  Widget _cargoIcon(CargoType type) { const map = {'ev_esyasi': Icons.chair, 'parca_esya': Icons.inventory_2, 'paletli_urun': Icons.pallet, 'insaat_malzemesi': Icons.construction, 'makine': Icons.precision_manufacturing, 'mobilya': Icons.weekend, 'gida_disi': Icons.local_shipping, 'Diğer': Icons.category}; return Icon(map[type.name] ?? Icons.category, size: 22, color: AppColors.accent); }

  Widget _urgencyBadge(UrgencyLevel level) {
    if (level == UrgencyLevel.normal) return const SizedBox();
    const map = {'urgent': ('Acil', AppColors.warning), 'very_urgent': ('Çok Acil', AppColors.error)};
    final info = map[level.name]!;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: info.$2.withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(info.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: info.$2)));
  }

  Widget _badge(String status, Map<String, (String, Color)> map) { final info = map[status] ?? (status, AppColors.textHint); return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: info.$2.withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(info.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: info.$2))); }
}

class _WorkflowStepper extends StatelessWidget {
  final JobStatus currentStatus;
  const _WorkflowStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [JobStatus.open, JobStatus.offer_accepted, JobStatus.in_progress, JobStatus.completed];
    final labels = ['Teklif', 'Seçildi', 'Taşımada', 'Tamam'];
    final icons = [Icons.send_outlined, Icons.check_circle_outline, Icons.local_shipping_outlined, Icons.flag_outlined];
    final currentIdx = steps.indexOf(currentStatus);
    final activeIdx = currentIdx < 0 ? -1 : currentIdx;
    final isCancelled = currentStatus == JobStatus.cancelled;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) Expanded(child: Container(height: 3, color: i <= activeIdx && !isCancelled ? AppColors.accent : AppColors.border)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: isCancelled ? 36 : (i <= activeIdx ? 36 : 32),
              height: isCancelled ? 36 : (i <= activeIdx ? 36 : 32),
              decoration: BoxDecoration(
                color: isCancelled ? AppColors.error.withAlpha(15) : (i <= activeIdx ? AppColors.accent : AppColors.border),
                shape: BoxShape.circle,
              ),
              child: Icon(isCancelled ? Icons.close : icons[i], size: isCancelled ? 18 : (i <= activeIdx ? 17 : 15), color: isCancelled ? AppColors.error : (i <= activeIdx ? Colors.white : AppColors.textHint)),
            ),
            const SizedBox(height: 4),
            Text(labels[i], style: TextStyle(fontSize: 10, fontWeight: i <= activeIdx && !isCancelled ? FontWeight.w600 : FontWeight.w400, color: isCancelled ? AppColors.error : (i <= activeIdx ? AppColors.accent : AppColors.textHint))),
          ]),
        ],
      ]),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String revieweeId;
  final Future<void> Function(int rating, String comment) onSubmit;
  const _ReviewForm({required this.revieweeId, required this.onSubmit});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Değerlendirme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: AppColors.warning, size: 32), onPressed: () => setState(() => _rating = i + 1)))),
      TextField(controller: _commentController, decoration: const InputDecoration(hintText: 'Yorumunuz (opsiyonel)', border: OutlineInputBorder()), maxLines: 2),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, height: 40, child: ElevatedButton(
        onPressed: _submitting ? null : () async { setState(() => _submitting = true); await widget.onSubmit(_rating, _commentController.text); if (mounted) setState(() => _submitting = false); },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
        child: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Gönder'),
      )),
    ]);
  }
}
