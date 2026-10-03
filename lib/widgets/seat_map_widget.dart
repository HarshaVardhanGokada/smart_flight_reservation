import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SeatInfo {
  final String id; // e.g. "12A"
  final int row;
  final String col;
  final bool isOccupied;
  final int price; // 0 = standard/free, 250 = standard paid, 650 = extra legroom
  final String type; // 'window', 'aisle', 'middle', 'extra_legroom'

  const SeatInfo({
    required this.id,
    required this.row,
    required this.col,
    required this.isOccupied,
    required this.price,
    required this.type,
  });
}

class SeatMapWidget extends StatelessWidget {
  final List<String> selectedSeatIds;
  final int maxSeatsAllowed;
  final ValueChanged<String> onSeatToggled;

  const SeatMapWidget({
    super.key,
    required this.selectedSeatIds,
    required this.maxSeatsAllowed,
    required this.onSeatToggled,
  });

  // Generates 20 rows of seats (A, B, C | aisle | D, E, F)
  List<List<SeatInfo>> get _rows {
    final List<List<SeatInfo>> generated = [];
    final cols = ['A', 'B', 'C', 'D', 'E', 'F'];

    // Deterministic occupied seats based on seat hash
    for (int r = 1; r <= 20; r++) {
      final List<SeatInfo> rowSeats = [];
      final bool isExtraLegroom = r == 1 || r == 11;

      for (var col in cols) {
        final id = '$r$col';
        final isOccupied = (id.hashCode % 5 == 0); // ~20% occupied
        final isWindow = col == 'A' || col == 'F';
        final isAisle = col == 'C' || col == 'D';
        final type = isExtraLegroom
            ? 'extra_legroom'
            : (isWindow ? 'window' : (isAisle ? 'aisle' : 'middle'));
        final price = isExtraLegroom ? 650 : (isWindow || isAisle ? 250 : 0);

        rowSeats.add(
          SeatInfo(
            id: id,
            row: r,
            col: col,
            isOccupied: isOccupied,
            price: price,
            type: type,
          ),
        );
      }
      generated.add(rowSeats);
    }
    return generated;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Fuselage Nose Graphic
          Container(
            width: 140,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.airline_seat_recline_extra_rounded,
                  size: 16,
                  color: AppTheme.primaryNavy,
                ),
                SizedBox(width: 6),
                Text(
                  'COCKPIT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Column Headers (A B C   D E F)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColHeader('A'),
                _buildColHeader('B'),
                _buildColHeader('C'),
                const SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ),
                ),
                _buildColHeader('D'),
                _buildColHeader('E'),
                _buildColHeader('F'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, index) {
              if (index == 0 || index == 10) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          index == 0
                              ? 'EXTRA LEGROOM ROW (+₹650)'
                              : 'EMERGENCY EXIT ROW (+₹650)',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox(height: 8);
            },
            itemBuilder: (context, rowIndex) {
              final row = rows[rowIndex];
              final rowNum = row.first.row;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSeat(row[0]),
                  _buildSeat(row[1]),
                  _buildSeat(row[2]),
                  // Aisle indicator with Row Number
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '$rowNum',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  _buildSeat(row[3]),
                  _buildSeat(row[4]),
                  _buildSeat(row[5]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColHeader(String col) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          col,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryNavy,
          ),
        ),
      ),
    );
  }

  Widget _buildSeat(SeatInfo seat) {
    final isSelected = selectedSeatIds.contains(seat.id);

    Color bgColor;
    Color borderColor;
    Color iconColor;

    if (seat.isOccupied) {
      bgColor = const Color(0xFFE2E8F0);
      borderColor = const Color(0xFFCBD5E1);
      iconColor = const Color(0xFF94A3B8);
    } else if (isSelected) {
      bgColor = AppTheme.primaryNavy;
      borderColor = AppTheme.primaryNavy;
      iconColor = Colors.white;
    } else if (seat.type == 'extra_legroom') {
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBFDBFE);
      iconColor = AppTheme.primaryBlue;
    } else {
      bgColor = Colors.white;
      borderColor = AppTheme.borderColor;
      iconColor = AppTheme.primaryNavy;
    }

    return InkWell(
      onTap: seat.isOccupied ? null : () => onSeatToggled(seat.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 42,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airline_seat_recline_normal_rounded,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(height: 2),
            Text(
              seat.col,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white
                    : (seat.isOccupied ? const Color(0xFF94A3B8) : AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeatLegendWidget extends StatelessWidget {
  const SeatLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(
            color: Colors.white,
            borderColor: AppTheme.borderColor,
            label: 'Free/Std',
          ),
          _legendItem(
            color: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            label: 'Legroom (₹650)',
          ),
          _legendItem(
            color: AppTheme.primaryNavy,
            borderColor: AppTheme.primaryNavy,
            label: 'Selected',
            isTextWhite: true,
          ),
          _legendItem(
            color: const Color(0xFFE2E8F0),
            borderColor: const Color(0xFFCBD5E1),
            label: 'Occupied',
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required Color borderColor,
    required String label,
    bool isTextWhite = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
