import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_block_service.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  String _search = '';

  // Icon map for popular apps
  static const Map<String, IconData> _appIcons = {
    'com.instagram.android': Icons.camera_alt_rounded,
    'com.google.android.youtube': Icons.play_circle_filled_rounded,
    'com.zhiliaoapp.musically': Icons.music_note_rounded,
    'com.facebook.katana': Icons.facebook_rounded,
    'com.twitter.android': Icons.tag_rounded,
    'com.snapchat.android': Icons.circle_rounded,
    'com.whatsapp': Icons.chat_rounded,
    'com.reddit.frontpage': Icons.forum_rounded,
    'com.netflix.mediaclient': Icons.movie_rounded,
    'com.spotify.music': Icons.headphones_rounded,
    'com.discord': Icons.games_rounded,
    'org.telegram.messenger': Icons.send_rounded,
    'com.linkedin.android': Icons.work_rounded,
    'com.pinterest': Icons.push_pin_rounded,
    'com.amazon.mShop.android.shopping': Icons.shopping_bag_rounded,
    'com.android.chrome': Icons.public_rounded,
  };

  static const Map<String, Color> _appColors = {
    'com.instagram.android': Color(0xFFE1306C),
    'com.google.android.youtube': Color(0xFFFF0000),
    'com.zhiliaoapp.musically': Color(0xFF010101),
    'com.facebook.katana': Color(0xFF1877F2),
    'com.twitter.android': Color(0xFF1DA1F2),
    'com.snapchat.android': Color(0xFFFFFC00),
    'com.whatsapp': Color(0xFF25D366),
    'com.reddit.frontpage': Color(0xFFFF4500),
    'com.netflix.mediaclient': Color(0xFFE50914),
    'com.spotify.music': Color(0xFF1DB954),
    'com.discord': Color(0xFF5865F2),
    'org.telegram.messenger': Color(0xFF2AABEE),
    'com.linkedin.android': Color(0xFF0A66C2),
    'com.pinterest': Color(0xFFE60023),
    'com.amazon.mShop.android.shopping': Color(0xFFFF9900),
    'com.android.chrome': Color(0xFF4285F4),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppBlockService>(
      builder: (context, block, _) {
        final filtered = block.installedApps
            .where((a) => a.appName.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFF07070F),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(block),
                _buildSearch(),
                _buildSelectedChips(block),
                Expanded(child: _buildAppList(filtered, block)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppBlockService block) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Blocker',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '${block.blockedCount} apps selected',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          if (block.blockedCount > 0)
            GestureDetector(
              onTap: () => _showBlockDurationSheet(context, block),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Block Now',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search apps...',
            hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChips(AppBlockService block) {
    final selected = block.installedApps.where((a) => a.isBlocked).toList();
    if (selected.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: selected.length,
        itemBuilder: (_, i) {
          final app = selected[i];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Text(
                  app.appName,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => block.toggleAppBlock(app.packageName),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFFF6B35), size: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppList(List<AppInfo> apps, AppBlockService block) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
        final color = _appColors[app.packageName] ?? const Color(0xFF555577);
        final icon = _appIcons[app.packageName] ?? Icons.android_rounded;

        return GestureDetector(
          onTap: () => block.toggleAppBlock(app.packageName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: app.isBlocked
                  ? const Color(0xFFFF6B35).withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: app.isBlocked
                    ? const Color(0xFFFF6B35).withOpacity(0.35)
                    : Colors.white.withOpacity(0.07),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    app.appName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: app.isBlocked ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: app.isBlocked
                        ? const Color(0xFFFF6B35)
                        : Colors.transparent,
                    border: Border.all(
                      color: app.isBlocked
                          ? const Color(0xFFFF6B35)
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: app.isBlocked
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBlockDurationSheet(BuildContext context, AppBlockService block) {
    int selectedMinutes = 25;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Block Duration',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'How long do you want to block ${block.blockedCount} apps?',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [15, 25, 30, 45, 60, 90, 120].map((mins) {
                    final selected = selectedMinutes == mins;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedMinutes = mins),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFF6B35)
                              : Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mins >= 60 ? '${mins ~/ 60}h' : '${mins}m',
                          style: GoogleFonts.spaceGrotesk(
                            color: selected ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      block.startBlocking(selectedMinutes);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${block.blockedCount} apps blocked for ${selectedMinutes}m',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: const Color(0xFFFF6B35),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Start Blocking',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
