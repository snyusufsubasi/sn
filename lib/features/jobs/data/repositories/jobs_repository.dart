import '../../../../core/errors/result.dart';
import '../models/job_post.dart';

abstract class JobsRepository {
  /// Açık ilanlar (carrier için). Filtre + pagination.
  Future<Result<List<JobPost>>> fetchOpenJobs({
    JobFilter filter = const JobFilter(),
    int limit = 20,
    int offset = 0,
  });

  /// Kullanıcının kendi ilanları (shipper için).
  Future<Result<List<JobPost>>> fetchMyJobs({
    int limit = 20,
    int offset = 0,
  });

  /// Nakliyecinin teklif verdiği veya aktif olarak taşıdığı ilanlar.
  Future<Result<List<JobPost>>> fetchMyActiveCarrierJobs();

  /// Nakliyecinin tamamladığı taşıma ilanları.
  Future<Result<List<JobPost>>> fetchMyCompletedCarrierJobs();

  /// Tekil ilan detayı.
  Future<Result<JobPost?>> fetchJobById(String id);

  /// İlan oluştur. Returns: oluşturulan ilan (id ile).
  Future<Result<JobPost>> createJob(JobPostInput input, String shipperId);

  /// İlan güncelle (sadece sahip, sadece status='open' ise izin verilir).
  Future<Result<JobPost>> updateJob(String id, JobPostInput input);

  /// İlan iptal et (RPC cancel_job).
  Future<Result<void>> cancelJob(String id, String reason);

  /// Realtime stream — job_posts tablosundaki bu satır değişirse tetiklenir.
  Stream<JobPost> watchJob(String id);
}
