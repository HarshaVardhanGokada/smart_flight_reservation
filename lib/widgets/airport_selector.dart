import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class AirportSelectorWidget extends StatelessWidget {
  final String label;
  final String airportCode;
  final String cityName;
  final IconData icon;
  final VoidCallback onTap;

  const AirportSelectorWidget({
    super.key,
    required this.label,
    required this.airportCode,
    required this.cityName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        airportCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cityName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.unfold_more_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Displays bottom sheet to search and pick an airport
  static Future<Map<String, String>?> showAirportPicker({
    required BuildContext context,
    required String title,
    String? currentCode,
  }) async {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AirportPickerSheet(
        title: title,
        currentCode: currentCode,
      ),
    );
  }
}

class _AirportPickerSheet extends StatefulWidget {
  final String title;
  final String? currentCode;

  const _AirportPickerSheet({
    required this.title,
    this.currentCode,
  });

  @override
  State<_AirportPickerSheet> createState() => _AirportPickerSheetState();
}

class _AirportPickerSheetState extends State<_AirportPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAirports = AppConstants.airports.where((airport) {
      final code = airport['code']!.toLowerCase();
      final city = airport['city']!.toLowerCase();
      final name = airport['name']!.toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      return code.contains(query) || city.contains(query) || name.contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by city, code or airport name...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Airport List
          Expanded(
            child: filteredAirports.isEmpty
                ? const Center(
                    child: Text(
                      'No matching airports found',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredAirports.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 68),
                    itemBuilder: (context, index) {
                      final airport = filteredAirports[index];
                      final isSelected = airport['code'] == widget.currentCode;

                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryNavy
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            airport['code']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryNavy,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          airport['city']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${airport['name']} • ${airport['country']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryNavy,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, airport),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
