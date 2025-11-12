import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'sendhive.dart';

String searchQuery = '';
final FocusNode _searchFocus = FocusNode();
TextEditingController _controller = TextEditingController();
bool _isSearch = false;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyAppState();
}

class _MyAppState extends State<Home> {
  static const platform = MethodChannel('apk_share_channel');
  List<AppInfo> apps = [];

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void loadApps() async {
    try {
      List<AppInfo> fetchedApps = await InstalledApps.getInstalledApps(
        true,
        true,
      );
      if (!mounted) return;
      setState(() {
        apps = fetchedApps;
      });
    } catch (e) {
      print("Error loading apps: $e");
      setState(() {});
    }
  }

  Future<void> shareApk(AppInfo app) async {
    try {
      final apkPath = await platform.invokeMethod<String>('getApkPath', {
        'packageName': app.packageName,
      });

      if (apkPath == null) {
        throw 'APK path not found';
      }

      await Share.shareXFiles([
        XFile(apkPath),
      ], text: 'نصب برنامه ${app.name} از طریق SendApp');
    } catch (e) {
      print("Error sharing APK: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('خطا در ارسال فایل'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Future<void> saveApkToPublic(AppInfo app) async {
    try {
      final apkPath = await platform.invokeMethod<String>('getApkPath', {
        'packageName': app.packageName,
      });
      if (apkPath == null) throw 'فایل APK پیدا نشد';
      final apkFile = File(apkPath);

      final downloadDir = Directory('/storage/emulated/0/SendApp');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final fileName = '${app.name}.apk';
      final savedFile = File('${downloadDir.path}/$fileName');
      await apkFile.copy(savedFile.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فایل با موفقیت ذخیره شد:\n${savedFile.path}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
    } catch (e) {
      print('Error saving file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('خطا در ذخیره فایل'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Settings>('SettingsBox');
    final settings = box.getAt(0);

    void toggleTheme() {
      settings!.darkmood = !settings.darkmood;
      settings.save();
    }

    List<AppInfo> filteredApps = apps.where((app) {
      return app.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final theme = Theme.of(context);
    final isDark = settings?.darkmood ?? theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // بکگراند
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/whall.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // لایه بلور
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0)),
          ),

          // محتوای اصلی
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: _isSearch
                    ? (isDark ? Colors.black54 : Colors.white70)
                    : (isDark ? Colors.black54 : Colors.white70),
                pinned: false,
                floating: true,
                elevation: 0,
                toolbarHeight: 70,
                title: _isSearch
                    ? TextField(
                        autofocus: true,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        controller: _controller,
                        focusNode: _searchFocus,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'جستجو...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          border: InputBorder.none,
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: List.generate('SeNdApP'.length, (index) {
                            final colorList = [
                              Colors.orangeAccent,
                              Colors.lightGreenAccent,
                              Colors.lightBlueAccent,
                              Colors.lightBlueAccent,
                              Colors.purpleAccent,
                            ];
                            return TextSpan(
                              text: 'ApKet'[index],
                              style: TextStyle(
                                color: colorList[index % colorList.length],
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                      ),

                centerTitle: true,
                leading: _isSearch
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearch = false;
                            searchQuery = '';
                            _controller.clear();
                          });
                        },
                      )
                    : null,
                actions: [
                  if (_isSearch && searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          _controller.clear();
                        });
                      },
                    )
                  else if (!_isSearch) ...[
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearch = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          toggleTheme();
                        });
                      },
                    ),
                  ],
                ],
              ),

              // اینجا لیستت
              filteredApps.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.android_rounded,
                              size: 60,
                              color: isDark ? Colors.green : Colors.green,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'در حال  بارگذاری...'
                                  : 'نتیجه‌ای برای "$searchQuery" یافت نشد',
                              style: TextStyle(
                                fontFamily: 'Lateef',
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final app = filteredApps[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 1,
                          ),
                          elevation: 0,
                          color: isDark ? Colors.black54 : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: ListTile(
                            leading: app.icon != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      app.icon as Uint8List,
                                      width: 50,
                                      height: 50,
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.android_rounded,
                                      color: isDark
                                          ? Colors.green
                                          : Colors.green,
                                    ),
                                  ),
                            title: Text(
                              app.name,
                              style: TextStyle(
                                fontFamily: 'eng',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              app.packageName,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            onTap: () => showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) =>
                                  appInfoBottomSheet(app, isDark),
                            ),
                          ),
                        );
                      }, childCount: filteredApps.length),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget appInfoBottomSheet(AppInfo app, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.5,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.black87 : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      app.icon != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                app.icon as Uint8List,
                                width: 64,
                                height: 64,
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.android_rounded,
                                color: isDark ? Colors.green : Colors.green,
                              ),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: TextStyle(
                                fontFamily: 'Lateef',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اطلاعات برنامه',
                            style: TextStyle(
                              fontFamily: 'Lateef',
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            icon: Icons.info_outline,
                            label: 'نام بسته',
                            value: app.packageName,
                            isDark: isDark,
                          ),
                          InfoRow(
                            icon: Icons.calendar_today,
                            label: 'تاریخ نصب',
                            value: '${app.versionName} (${app.versionCode})',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ActionButton(
                                icon: Icons.share,
                                label: 'اشتراک گذاری',
                                color: Colors.blue,
                                onPressed: () => shareApk(app),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }
}
