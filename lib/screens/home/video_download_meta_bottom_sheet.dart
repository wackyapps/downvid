import 'package:downvid/models/video_meta_model/video_model.dart';
import 'package:downvid/providers/home_download_provider/home_download_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> bottomVideoMetaBottomSheet({
  required BuildContext context,
  required double sheetHeight,
  required String userUrl,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Consumer<HomeAndDownloadProvider>(
              builder: (context, provider, _) {
                final meta = provider.videoMetaDataModel;
                if (meta == null || meta.hasScrappingError == true) {
                  return _buildErrorState(sheetContext, sheetHeight);
                }
                return _buildDownloadOptions(
                  sheetContext: sheetContext,
                  provider: provider,
                  meta: meta,
                  modalSetState: modalSetState,
                  sheetHeight: sheetHeight,
                  userUrl: userUrl,
                );
              },
            ),
          );
        },
      );
    },
  );
}

// ───────────────────────────────────────────── Error State
Widget _buildErrorState(BuildContext context, double sheetHeight) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;

  return Container(
    height: sheetHeight,
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
    child: Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Download Options", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: textColor)),
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: textColor)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
        const SizedBox(height: 16),
        Text('No video found.\nCheck the link and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700])),
        const SizedBox(height: 24),
        SizedBox(
          width: 50.w,
          height: 5.5.h,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}

// ───────────────────────────────────────────── Main UI + FULL SCREEN PROGRESS
Widget _buildDownloadOptions({
  required BuildContext sheetContext,
  required HomeAndDownloadProvider provider,
  required VideoMetaDataModel meta,
  required StateSetter modalSetState,
  required double sheetHeight,
  required String userUrl,
}) {
  final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
  final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
  final textColor = isDark ? Colors.white : Colors.black87;

  return Container(
    height: sheetHeight,
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grabber bar
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Header + Close
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Download Options", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: textColor)),
            IconButton(onPressed: () => Navigator.pop(sheetContext), icon: Icon(Icons.close_rounded, color: textColor)),
          ],
        ),
        SizedBox(height: 2.h),

        // Thumbnail + Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                meta.thumbnail ?? '',
                width: 32.w,
                height: 12.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 32.w,
                  height: 12.h,
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.title ?? 'Untitled Video',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: textColor, height: 1.3),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meta.duration ?? '--:--',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Resolutions
        Text(
          "Resolutions",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.grey[800])
        ),
        SizedBox(height: 1.5.h),

        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: meta.videoLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final link = entry.value;
              if (!link.quality.toLowerCase().contains('hd') && !link.quality.toLowerCase().contains('sd')) {
                return const SizedBox.shrink();
              }
              final isSelected = provider.selectedLinkIndex == index;
              return Container(
                margin: EdgeInsets.symmetric(vertical: 0.8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? (isDark ? const Color(0xFF2563EB).withOpacity(0.15) : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade50),
                  border: Border.all(
                    color: isSelected ? primaryColor : (isDark ? Colors.white10 : Colors.grey.shade200),
                    width: 1.5,
                  ),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: provider.selectedLinkIndex,
                  activeColor: primaryColor,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    link.quality.toUpperCase(),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: isSelected ? primaryColor : textColor),
                  ),
                  onChanged: (int? val) {
                    provider.selectedLinkIndex = val!;
                    modalSetState(() {});
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // ONLY DOWNLOAD BUTTON — NO PROGRESS BAR HERE
        SizedBox(
          width: double.infinity,
          height: 6.5.h,
          child: ElevatedButton.icon(
            onPressed: provider.isDownloading
                ? null
                : () async {
                    Navigator.pop(sheetContext); // Close bottom sheet
                    _showDownloadProgressDialog(sheetContext); // Show full-screen progress
                    await provider.downloadVideo(
                      userUrl: userUrl,
                      selectedLinkIndex: provider.selectedLinkIndex,
                      context: sheetContext,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.isDownloading ? Colors.grey : primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              provider.isDownloading ? "Downloading..." : "Download Video",
              style: TextStyle(color: Colors.white, fontSize: 13.5.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ),
  );
}

// ───────────────────────────────────────────── FULL SCREEN PROGRESS DIALOG
void _showDownloadProgressDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => WillPopScope(
      onWillPop: () async => false,
      child: Consumer<HomeAndDownloadProvider>(
        builder: (context, provider, _) {
          // Auto close when download completes
          if (provider.downloadProgress >= 1.0) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
          }

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF2563EB)),
                  SizedBox(height: 3.h),
                  Text(
                    "Downloading Video...",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)
                  ),
                  SizedBox(height: 2.5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: provider.downloadProgress > 0 && provider.downloadProgress < 1
                          ? provider.downloadProgress
                          : null,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    provider.downloadProgress >= 1
                        ? "Download Complete!"
                        : "${(provider.downloadProgress * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: provider.downloadProgress >= 1 ? Colors.green : (isDark ? Colors.white70 : Colors.black54)
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}