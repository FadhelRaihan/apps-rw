import '../models/user_model.dart';
import '../models/news_model.dart';
import '../models/letter_model.dart';
import '../models/complaint_model.dart';
import '../models/resident_model.dart';
import '../models/finance_model.dart';

class MockData {
  // Pre-configured profiles for instant role switching during demo
  static const UserProfile mockResident = UserProfile(
    id: 'user_01',
    name: 'Bambang Sutrisno',
    nik: '3201123456780001',
    noKk: '3201123456780099',
    rtNumber: '02',
    rwNumber: '05',
    phone: '0812-3456-7890',
    address: 'Jl. Flamboyan No. 14, RT 02 / RW 05',
    role: UserRole.warga,
  );

  static const UserProfile mockKetuaRt = UserProfile(
    id: 'rt_02_chief',
    name: 'H. Suherman S.Pd',
    nik: '3201123456780002',
    noKk: '3201123456780088',
    rtNumber: '02',
    rwNumber: '05',
    phone: '0813-8899-0011',
    address: 'Jl. Flamboyan No. 01, RT 02 / RW 05',
    role: UserRole.ketuaRt,
  );

  static const UserProfile mockKetuaRw = UserProfile(
    id: 'rw_05_chief',
    name: 'Ir. Hendra Gunawan',
    nik: '3201123456780003',
    noKk: '3201123456780077',
    rtNumber: '01',
    rwNumber: '05',
    phone: '0811-2233-4455',
    address: 'Jl. Melati Utama No. 05, RT 01 / RW 05',
    role: UserRole.ketuaRw,
  );

  static const UserProfile mockBendaharaRw = UserProfile(
    id: 'rw_05_treasurer',
    name: 'Dra. Hj. Nurjanah',
    nik: '3201123456780004',
    noKk: '3201123456780066',
    rtNumber: '03',
    rwNumber: '05',
    phone: '0815-6677-8899',
    address: 'Jl. Anggrek No. 08, RT 03 / RW 05',
    role: UserRole.bendaharaRw,
  );

  // Initial News / Announcements
  static List<NewsItem> get initialNews => [
        NewsItem(
          id: 'news_1',
          title: 'Kerja Bakti Massal Bersih Saluran Drainase',
          content:
              'Menyambut musim penghujan, pengurus RW 05 mengimbau seluruh warga RT 01 s.d RT 06 untuk berpartisipasi dalam kerja bakti normalisasi selokan air. Konsumsi disediakan oleh pengurus PKK RW.',
          category: NewsCategory.agenda,
          authorName: 'Ir. Hendra Gunawan',
          authorRole: 'Ketua RW 05',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          eventDate: DateTime.now().add(const Duration(days: 3)),
          location: 'Sepanjang Jalan Utama RW 05',
          status: NewsStatus.published,
        ),
        NewsItem(
          id: 'news_2',
          title: 'Jadwal Posyandu Balita & Lansia Cempaka Putih',
          content:
              'Pelayanan penimbangan balita, imunisasi dasar, dan cek gula darah/tensi lansia akan dilaksanakan di Balai Warga RW 05. Harap membawa buku KIA dan fotokopi KTP/KK.',
          category: NewsCategory.pengumuman,
          authorName: 'Ibu Rahayu',
          authorRole: 'Koordinator Posyandu RW 05',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          eventDate: DateTime.now().add(const Duration(days: 5)),
          location: 'Balai RW 05',
          status: NewsStatus.published,
        ),
        NewsItem(
          id: 'news_3',
          title: 'Semarak Peringatan HUT RI & Jalan Sehat RW 05',
          content:
              'Dokumentasi kemeriahan rangkaian pesta rakyat dan pembagian doorprize jalan sehat yang dihadiri oleh lebih dari 350 warga di wilayah RW 05.',
          category: NewsCategory.galeri,
          authorName: 'Karang Taruna RW 05',
          authorRole: 'Pengurus Pemuda',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          status: NewsStatus.published,
        ),
        NewsItem(
          id: 'news_4',
          title: 'Usulan Turnamen Tenis Meja Antar RT oleh Warga RT 02',
          content:
              'Pengajuan kegiatan olahraga persahabatan antar bapak-bapak dan pemuda RT guna mempererat tali silaturahmi antar rukun tetangga.',
          category: NewsCategory.agenda,
          authorName: 'Bambang Sutrisno',
          authorRole: 'Warga RT 02',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          status: NewsStatus.pending,
        ),
      ];

  // Initial Letters
  static List<LetterRequest> get initialLetters => [
        LetterRequest(
          id: 'SURAT-2026-001',
          letterType: LetterType.keteranganUsaha,
          residentName: 'Bambang Sutrisno',
          nik: '3201123456780001',
          rtNumber: '02',
          rwNumber: '05',
          purpose: 'Pengajuan kredit usaha rakyat (KUR) Bank BRI',
          requestDate: DateTime.now().subtract(const Duration(days: 1)),
          status: LetterStatus.diverifikasiRt,
          approvedByRtAt: DateTime.now().subtract(const Duration(hours: 12)),
          qrCodeVerification: 'VERIF-RW05-KU-2026-9812',
        ),
        LetterRequest(
          id: 'SURAT-2026-002',
          letterType: LetterType.pengantarRtRw,
          residentName: 'Bambang Sutrisno',
          nik: '3201123456780001',
          rtNumber: '02',
          rwNumber: '05',
          purpose: 'Perpanjangan e-KTP & Pembaruan Kartu Keluarga',
          requestDate: DateTime.now().subtract(const Duration(days: 5)),
          status: LetterStatus.disetujuiRw,
          approvedByRtAt: DateTime.now().subtract(const Duration(days: 4)),
          approvedByRwAt: DateTime.now().subtract(const Duration(days: 3)),
          qrCodeVerification: 'VERIF-RW05-PENGANTAR-2026-3321',
        ),
        LetterRequest(
          id: 'SURAT-2026-003',
          letterType: LetterType.keteranganDomisili,
          residentName: 'Agus Setiawan',
          nik: '3201987654320005',
          rtNumber: '02',
          rwNumber: '05',
          purpose: 'Syarat lamaran pekerjaan di Kawasan Industri',
          requestDate: DateTime.now().subtract(const Duration(hours: 2)),
          status: LetterStatus.diajukan,
        ),
      ];

  // Initial Complaints
  static List<ComplaintItem> get initialComplaints => [
        ComplaintItem(
          id: 'CMP-01',
          title: 'Lampu Penerangan Jalan Umum Mati di Gang Mawar',
          description:
              'Sudah 3 malam lampu tiang no. 4 di Gang Mawar mati, kondisi jalan gelap dan membahayakan pengendara motor saat malam hari.',
          category: ComplaintCategory.infrastruktur,
          isAnonymous: true,
          reporterName: 'Bambang Sutrisno',
          reporterRt: 'RT 02',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: ComplaintStatus.diproses,
          adminResponse:
              'Petugas PJU dari Dinas sudah dihubungi oleh Ketua RT 02 dan sedang menunggu jadwal pergantian lampu LED.',
        ),
        ComplaintItem(
          id: 'CMP-02',
          title: 'Sampah Ranting Pohon Menumpuk Depan Lapangan',
          description:
              'Bekas pemangkasan dahan pohon kemarin belum diangkut oleh truk kebersihan sehingga memakan separuh badan jalan.',
          category: ComplaintCategory.kebersihan,
          isAnonymous: false,
          reporterName: 'Wawan Prasetyo',
          reporterRt: 'RT 04',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: ComplaintStatus.selesai,
          adminResponse: 'Sudah diangkut armada kebersihan RW pada Selasa pagi.',
          resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  // Family Card & Sensus Mandiri
  static FamilyCard get initialFamilyCard => const FamilyCard(
        noKk: '3201123456780099',
        headOfFamilyName: 'Bambang Sutrisno',
        address: 'Jl. Flamboyan No. 14, RT 02 / RW 05',
        rtNumber: '02',
        rwNumber: '05',
        members: [
          FamilyMember(
            nik: '3201123456780001',
            name: 'Bambang Sutrisno',
            relation: 'Kepala Keluarga',
            gender: 'Laki-laki',
            birthDate: '14-08-1980',
            occupation: 'Wiraswasta',
            isVerified: true,
          ),
          FamilyMember(
            nik: '3201123456780002',
            name: 'Siti Aminah',
            relation: 'Istri',
            gender: 'Perempuan',
            birthDate: '21-11-1984',
            occupation: 'Ibu Rumah Tangga',
            isVerified: true,
          ),
          FamilyMember(
            nik: '3201123456780003',
            name: 'Rizky Ramadhan',
            relation: 'Anak',
            gender: 'Laki-laki',
            birthDate: '05-03-2008',
            occupation: 'Pelajar',
            isVerified: true,
          ),
        ],
      );

  // Financial Ledger & Transactions
  static List<CashflowTransaction> get initialTransactions => [
        CashflowTransaction(
          id: 'TRX-001',
          title: 'Iuran Keamanan Warga RT 02 (32 KK)',
          amount: 1120000,
          type: TransactionType.income,
          scope: WalletScope.rt,
          rtNumber: '02',
          date: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Iuran Bulanan',
          note: 'Penerimaan rutin iuran pos kamling Oktober 2026',
        ),
        CashflowTransaction(
          id: 'TRX-002',
          title: 'Honor Petugas Jaga Pos Ronda RT 02',
          amount: 800000,
          type: TransactionType.expense,
          scope: WalletScope.rt,
          rtNumber: '02',
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Operasional Keamanan',
          note: 'Pembayaran honor 2 linmas shift malam',
        ),
        CashflowTransaction(
          id: 'TRX-003',
          title: 'Penerimaan Iuran Sampah RW 05 (RT 01 - RT 06)',
          amount: 5400000,
          type: TransactionType.income,
          scope: WalletScope.rw,
          rtNumber: '00',
          date: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Iuran Kebersihan',
          note: 'Setoran kolektif dari 6 RT',
        ),
        CashflowTransaction(
          id: 'TRX-004',
          title: 'Operasional Armada Truk Pengangkut Sampah RW',
          amount: 3200000,
          type: TransactionType.expense,
          scope: WalletScope.rw,
          rtNumber: '00',
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Pengelolaan Sampah',
          note: 'Biaya BBM & retribusi TPA regional',
        ),
      ];

  // Bills for Resident (Ready to simulate payment)
  static List<DuesBill> get initialBills => [
        const DuesBill(
          id: 'BILL-RT-10',
          title: 'Iuran Keamanan & Kamling RT 02',
          amount: 35000,
          scope: WalletScope.rt,
          rtNumber: '02',
          month: 'Oktober',
          year: 2026,
          isPaid: false,
        ),
        const DuesBill(
          id: 'BILL-RW-10',
          title: 'Iuran Pengelolaan Sampah & Fogging RW 05',
          amount: 25000,
          scope: WalletScope.rw,
          rtNumber: '02',
          month: 'Oktober',
          year: 2026,
          isPaid: false,
        ),
        DuesBill(
          id: 'BILL-RT-09',
          title: 'Iuran Keamanan & Kamling RT 02',
          amount: 35000,
          scope: WalletScope.rt,
          rtNumber: '02',
          month: 'September',
          year: 2026,
          isPaid: true,
          paidAt: DateTime.now().subtract(const Duration(days: 35)),
          paymentMethod: 'QRIS',
        ),
      ];
}
