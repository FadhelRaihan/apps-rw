import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/models/news_model.dart';
import '../data/models/letter_model.dart';
import '../data/models/complaint_model.dart';
import '../data/models/resident_model.dart';
import '../data/models/finance_model.dart';
import '../data/models/emergency_model.dart';
import '../data/mock/mock_data.dart';

/// Central state manager using ChangeNotifier for interactive pitching demo.
/// Handles role switching and simulated bidirectional workflows.
class AppState extends ChangeNotifier {
  // --------------------------------------------------------------------------
  // User Authentication & Role State
  // --------------------------------------------------------------------------
  UserProfile _currentUser = MockData.mockResident;
  UserProfile get currentUser => _currentUser;

  void switchRole(UserRole role) {
    switch (role) {
      case UserRole.warga:
        _currentUser = MockData.mockResident;
        break;
      case UserRole.ketuaRt:
        _currentUser = MockData.mockKetuaRt;
        break;
      case UserRole.ketuaRw:
        _currentUser = MockData.mockKetuaRw;
        break;
      case UserRole.bendaharaRt:
        _currentUser = MockData.mockKetuaRt.copyWith(role: UserRole.bendaharaRt);
        break;
      case UserRole.bendaharaRw:
        _currentUser = MockData.mockBendaharaRw;
        break;
    }
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // News & Information State
  // --------------------------------------------------------------------------
  final List<NewsItem> _newsList = List.from(MockData.initialNews);
  List<NewsItem> get allNews => List.unmodifiable(_newsList);

  List<NewsItem> get publishedNews =>
      _newsList.where((n) => n.status == NewsStatus.published).toList();

  List<NewsItem> get pendingNews =>
      _newsList.where((n) => n.status == NewsStatus.pending).toList();

  void submitNews({
    required String title,
    required String content,
    required NewsCategory category,
    DateTime? eventDate,
    String? location,
  }) {
    final newItem = NewsItem(
      id: 'news_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: category,
      authorName: _currentUser.name,
      authorRole: _currentUser.role.displayName,
      createdAt: DateTime.now(),
      eventDate: eventDate,
      location: location,
      // Official announcements by RW chief are auto-published; residents need approval
      status: _currentUser.role.isRwLevel ? NewsStatus.published : NewsStatus.pending,
    );
    _newsList.insert(0, newItem);
    notifyListeners();
  }

  void approveNews(String newsId) {
    final index = _newsList.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _newsList[index] = _newsList[index].copyWith(status: NewsStatus.published);
      notifyListeners();
    }
  }

  void rejectNews(String newsId) {
    final index = _newsList.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _newsList[index] = _newsList[index].copyWith(status: NewsStatus.rejected);
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Letter Service State (Surat Menyurat)
  // --------------------------------------------------------------------------
  final List<LetterRequest> _letterList = List.from(MockData.initialLetters);
  List<LetterRequest> get allLetters => List.unmodifiable(_letterList);

  List<LetterRequest> get residentLetters => _letterList
      .where((l) => l.nik == _currentUser.nik || _currentUser.role.isPengurus)
      .toList();

  List<LetterRequest> get pendingRtLetters => _letterList
      .where((l) => l.status == LetterStatus.diajukan && l.rtNumber == _currentUser.rtNumber)
      .toList();

  List<LetterRequest> get pendingRwLetters =>
      _letterList.where((l) => l.status == LetterStatus.diverifikasiRt).toList();

  void submitLetterRequest({
    required LetterType letterType,
    required String purpose,
  }) {
    final newLetter = LetterRequest(
      id: 'SURAT-${DateTime.now().year}-${_letterList.length + 101}',
      letterType: letterType,
      residentName: _currentUser.name,
      nik: _currentUser.nik,
      rtNumber: _currentUser.rtNumber,
      rwNumber: _currentUser.rwNumber,
      purpose: purpose,
      requestDate: DateTime.now(),
      status: LetterStatus.diajukan,
    );
    _letterList.insert(0, newLetter);
    notifyListeners();
  }

  void verifyLetterByRt(String letterId) {
    final index = _letterList.indexWhere((l) => l.id == letterId);
    if (index != -1) {
      _letterList[index] = _letterList[index].copyWith(
        status: LetterStatus.diverifikasiRt,
        approvedByRtAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void approveLetterByRw(String letterId) {
    final index = _letterList.indexWhere((l) => l.id == letterId);
    if (index != -1) {
      final code = 'VERIF-RW05-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _letterList[index] = _letterList[index].copyWith(
        status: LetterStatus.disetujuiRw,
        approvedByRwAt: DateTime.now(),
        qrCodeVerification: code,
      );
      notifyListeners();
    }
  }

  void rejectLetter(String letterId, String reason) {
    final index = _letterList.indexWhere((l) => l.id == letterId);
    if (index != -1) {
      _letterList[index] = _letterList[index].copyWith(
        status: LetterStatus.ditolak,
        rejectionReason: reason,
      );
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Complaint State (Pengaduan Warga)
  // --------------------------------------------------------------------------
  final List<ComplaintItem> _complaintList = List.from(MockData.initialComplaints);
  List<ComplaintItem> get allComplaints => List.unmodifiable(_complaintList);

  void submitComplaint({
    required String title,
    required String description,
    required ComplaintCategory category,
    required bool isAnonymous,
  }) {
    final newComplaint = ComplaintItem(
      id: 'CMP-${_complaintList.length + 10}',
      title: title,
      description: description,
      category: category,
      isAnonymous: isAnonymous,
      reporterName: _currentUser.name,
      reporterRt: 'RT ${_currentUser.rtNumber}',
      createdAt: DateTime.now(),
      status: ComplaintStatus.menunggu,
    );
    _complaintList.insert(0, newComplaint);
    notifyListeners();
  }

  void respondComplaint({
    required String complaintId,
    required String responseNote,
    required ComplaintStatus newStatus,
  }) {
    final index = _complaintList.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _complaintList[index] = _complaintList[index].copyWith(
        adminResponse: responseNote,
        status: newStatus,
        resolvedAt: newStatus == ComplaintStatus.selesai ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Resident & Census State (Sensus Mandiri)
  // --------------------------------------------------------------------------
  FamilyCard _familyCard = MockData.initialFamilyCard;
  FamilyCard get familyCard => _familyCard;

  void addFamilyMember(FamilyMember member) {
    final updatedMembers = List<FamilyMember>.from(_familyCard.members)..add(member);
    _familyCard = _familyCard.copyWith(members: updatedMembers);
    notifyListeners();
  }

  void verifyFamilyMember(String nik) {
    final updatedMembers = _familyCard.members.map((m) {
      if (m.nik == nik) {
        return m.copyWith(isVerified: true);
      }
      return m;
    }).toList();
    _familyCard = _familyCard.copyWith(members: updatedMembers);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Financial Ledger & Multi-Wallet State (Kas RT & RW)
  // --------------------------------------------------------------------------
  final List<CashflowTransaction> _transactions = List.from(MockData.initialTransactions);
  List<CashflowTransaction> get allTransactions => List.unmodifiable(_transactions);

  final List<DuesBill> _duesBills = List.from(MockData.initialBills);
  List<DuesBill> get allBills => List.unmodifiable(_duesBills);

  List<DuesBill> get pendingBills => _duesBills.where((b) => !b.isPaid).toList();

  double get rtBalance {
    double total = 3450000;
    for (var tx in _transactions.where((t) => t.scope == WalletScope.rt)) {
      if (tx.type == TransactionType.income) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double get rwBalance {
    double total = 18250000;
    for (var tx in _transactions.where((t) => t.scope == WalletScope.rw)) {
      if (tx.type == TransactionType.income) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  /// Simulates payment gateway webhook/completion
  void payBillSimulated({
    required String billId,
    required String paymentMethod,
  }) {
    final index = _duesBills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      final bill = _duesBills[index];
      _duesBills[index] = bill.copyWith(
        isPaid: true,
        paidAt: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      // Instantly credit corresponding wallet and log transparent transaction
      final tx = CashflowTransaction(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        title: '${bill.title} (${_currentUser.name})',
        amount: bill.amount,
        type: TransactionType.income,
        scope: bill.scope,
        rtNumber: bill.rtNumber,
        date: DateTime.now(),
        category: 'Iuran Warga Digital',
        note: 'Pembayaran otomatis via $paymentMethod',
      );
      _transactions.insert(0, tx);
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Emergency Siren & Panic Button State (IoT Siren)
  // --------------------------------------------------------------------------
  EmergencyAlert? _activeEmergency;
  EmergencyAlert? get activeEmergency => _activeEmergency;
  bool get isEmergencyActive => _activeEmergency != null && _activeEmergency!.isActive;

  void triggerEmergency({
    required EmergencyScope scope,
    required String reason,
  }) {
    _activeEmergency = EmergencyAlert(
      id: 'ALARM-${DateTime.now().millisecondsSinceEpoch}',
      initiatorName: _currentUser.name,
      initiatorRt: 'RT ${_currentUser.rtNumber}',
      scope: scope,
      triggerTime: DateTime.now(),
      reason: reason,
      isActive: true,
      affectedHousesCount: scope.sirenDeviceCount,
    );
    notifyListeners();
  }

  void resolveEmergency() {
    if (_activeEmergency != null) {
      _activeEmergency = _activeEmergency!.copyWith(isActive: false);
      _activeEmergency = null;
      notifyListeners();
    }
  }
}
