import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/news_model.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';
import '../widgets/status_badge.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isPengurus = user.role.isRwLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi & Agenda RW 05', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            const Tab(text: 'Semua'),
            const Tab(text: 'Pengumuman'),
            const Tab(text: 'Agenda Kegiatan'),
            Tab(text: isPengurus ? 'Moderasi (${state.pendingNews.length})' : 'Galeri RW'),
          ],
        ),
      ),
      body: Column(
        children: [
          const RoleSwitcherBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsList(context, state.publishedNews),
                _buildNewsList(context, state.publishedNews.where((n) => n.category == NewsCategory.pengumuman).toList()),
                _buildNewsList(context, state.publishedNews.where((n) => n.category == NewsCategory.agenda).toList()),
                isPengurus ? _buildModerationList(context, state) : _buildGalleryList(context, state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.post_add_rounded, color: Colors.white),
        label: const Text('Kirim Berita/Agenda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateNewsDialog(context, state),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List<NewsItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Belum ada informasi di kategori ini.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.displayName,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    Text(
                      DateFormatter.formatShort(item.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(item.content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                if (item.eventDate != null || item.location != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      if (item.eventDate != null) ...[
                        const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(DateFormatter.formatShort(item.eventDate!), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 14),
                      ],
                      if (item.location != null) ...[
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.emergencyRed),
                        const SizedBox(width: 4),
                        Expanded(child: Text(item.location!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1)),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Oleh: ${item.authorName} (${item.authorRole})', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModerationList(BuildContext context, AppState state) {
    final pending = state.pendingNews;
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.accentGreen),
            SizedBox(height: 8),
            Text('Semua usulan berita warga telah ditinjau!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final item = pending[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Usulan dari: ${item.authorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    StatusBadge.fromNewsStatus(item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item.content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emergencyRed,
                          side: const BorderSide(color: AppColors.emergencyRed),
                        ),
                        onPressed: () {
                          state.rejectNews(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usulan berita ditolak.')));
                        },
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                        onPressed: () {
                          state.approveNews(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berita disetujui dan ditayangkan ke seluruh warga RW 05!'), backgroundColor: AppColors.accentGreen),
                          );
                        },
                        child: const Text('Setujui & Terbitkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryList(BuildContext context, AppState state) {
    final galleries = state.publishedNews.where((n) => n.category == NewsCategory.galeri).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: galleries.length,
      itemBuilder: (context, index) {
        final item = galleries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_rounded, size: 48, color: AppColors.primary),
                    SizedBox(height: 6),
                    Text('Dokumentasi Kegiatan RW 05', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item.content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateNewsDialog(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    NewsCategory selectedCategory = NewsCategory.pengumuman;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Kirim Berita / Informasi RW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<NewsCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori Konten'),
                  items: NewsCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Informasi')),
                const SizedBox(height: 10),
                TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Isi Informasi')),
                const SizedBox(height: 10),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Lokasi Kegiatan (Opsional)')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    state.currentUser.role.isRwLevel
                        ? 'Sebagai Pengurus RW, konten Anda akan langsung tayang ke seluruh warga.'
                        : 'Sebagai Warga, konten Anda akan dimoderasi terlebih dahulu oleh Pengurus RW.',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan isi tidak boleh kosong!')));
                  return;
                }
                state.submitNews(
                  title: title,
                  content: content,
                  category: selectedCategory,
                  location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
                );
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.currentUser.role.isRwLevel
                          ? 'Pengumuman resmi berhasil diterbitkan!'
                          : 'Usulan berita terkirim! Menunggu moderasi pengurus RW.',
                    ),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
