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
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
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

// ───────────────────────────────────────────── Error State (unchanged)
Widget _buildErrorState(BuildContext context, double sheetHeight) {
  return Container(
    height: sheetHeight,
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Download Options", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          ],
        ),
        const Spacer(),
        Text('No video found.\nCheck the link and try again.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Retry"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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
  return Container(
    height: sheetHeight,
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + Close
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Download Options", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close_rounded)),
          ],
        ),
        SizedBox(height: 2.h),

        // Thumbnail + Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                meta.thumbnail ?? '',
                width: 30.w,
                height: 20.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 30.w,
                  height: 20.h,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.title ?? 'Untitled', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 0.5.h),
                  Text(meta.duration ?? '--', style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Resolutions
        Text("Resolutions", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.grey[800])),
        SizedBox(height: 1.h),
        ...meta.videoLinks.asMap().entries.map((entry) {
          final index = entry.key;
          final link = entry.value;
          if (!link.quality.toLowerCase().contains('hd') && !link.quality.toLowerCase().contains('sd')) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 0.8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: provider.selectedLinkIndex == index ? Colors.blue.shade50 : Colors.grey.shade100,
              border: Border.all(
                color: provider.selectedLinkIndex == index ? Colors.blueAccent : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: RadioListTile<int>(
              value: index,
              groupValue: provider.selectedLinkIndex,
              activeColor: Colors.blueAccent,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(link.quality, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
              onChanged: (int? val) {
                provider.selectedLinkIndex = val!;
                modalSetState(() {});
              },
            ),
          );
        }),

        const Spacer(),

        // ONLY DOWNLOAD BUTTON — NO PROGRESS BAR HERE
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isDownloading
                ? null // Disable if already downloading
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
              backgroundColor: provider.isDownloading ? Colors.grey : Colors.blueAccent,
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              provider.isDownloading ? "Downloading..." : "Download",
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );
}

// ───────────────────────────────────────────── FULL SCREEN PROGRESS DIALOG
void _showDownloadProgressDialog(BuildContext context) {
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 5, color: Colors.blueAccent),
                SizedBox(height: 2.h),
                Text("Downloading Video...", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                LinearProgressIndicator(
                  value: provider.downloadProgress > 0 && provider.downloadProgress < 1
                      ? provider.downloadProgress
                      : null,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                SizedBox(height: 1.h),
                Text(
                  provider.downloadProgress >= 1
                      ? "Download Complete!"
                      : "${(provider.downloadProgress * 100).toStringAsFixed(1)}%",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}