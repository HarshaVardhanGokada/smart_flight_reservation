import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/booking_model.dart';

class TicketPdfService {
  TicketPdfService._();

  /// Generates a PDF Document for a confirmed booking
  static Future<Uint8List> generateTicketPdf(BookingModel booking) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0B1F3A),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SMART FLIGHT',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.Text(
                          'ELECTRONIC BOARDING PASS & ITINERARY',
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF10B981),
                        borderRadius:
                            pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        booking.bookingStatus.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // PNR and Booking Ref Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BOOKING REFERENCE (PNR)',
                          style: const pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          booking.pnr,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF0B1F3A),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BOOKING ID',
                          style: const pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          booking.bookingId,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF0B1F3A),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'BOOKING DATE',
                          style: const pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          booking.bookingDate,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Flight Route & Times Box
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8FAFC),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${booking.airline} • Flight ${booking.flightNumber}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1A73E8),
                          ),
                        ),
                        pw.Text(
                          'Cabin: ${booking.flight.cabinClass}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(color: const PdfColor.fromInt(0xFFCBD5E1)),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              booking.departure,
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              booking.flight.originCity,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              booking.departureTime,
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF0B1F3A),
                              ),
                            ),
                            pw.Text(
                              'Terminal: ${booking.flight.departureTerminal}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text(
                              booking.flight.duration,
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              '----------------->',
                              style: pw.TextStyle(
                                color: const PdfColor.fromInt(0xFF1A73E8),
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              booking.flight.stopsLabel,
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              booking.arrival,
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              booking.flight.destinationCity,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              booking.arrivalTime,
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF0B1F3A),
                              ),
                            ),
                            pw.Text(
                              'Terminal: ${booking.flight.arrivalTerminal}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Passengers & Seat Table
              pw.Text(
                'PASSENGERS & SEAT ASSIGNMENTS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.5,
                  color: const PdfColor.fromInt(0xFF0B1F3A),
                ),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                headers: ['#', 'Passenger Name', 'Type', 'Seat', 'Baggage'],
                data: List.generate(booking.passengerDetails.length, (i) {
                  final p = booking.passengerDetails[i];
                  final seat = i < booking.selectedSeats.length
                      ? booking.selectedSeats[i]
                      : '-';
                  return [
                    '${i + 1}',
                    p.fullName,
                    p.passengerType,
                    seat,
                    booking.flight.includedBaggage,
                  ];
                }),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0B1F3A),
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0)),
                  ),
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8,
                ),
              ),

              pw.SizedBox(height: 20),

              // Fare Summary & Verification Barcode
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 280,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PAYMENT SUMMARY',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _fareRow('Base Fare', 'Rs. ${booking.fare}'),
                        _fareRow('Taxes & Airport Fees', 'Rs. ${booking.taxes}'),
                        if (booking.seatCharges > 0)
                          _fareRow('Seat Selection Charges', 'Rs. ${booking.seatCharges}'),
                        if (booking.addonCharges > 0)
                          _fareRow('Add-ons (Meals/Baggage)', 'Rs. ${booking.addonCharges}'),
                        if (booking.discount > 0)
                          _fareRow('Promo Discount', '-Rs. ${booking.discount}'),
                        pw.Divider(color: const PdfColor.fromInt(0xFFE2E8F0)),
                        _fareRow('Total Amount Paid', 'Rs. ${booking.totalAmount}', isBold: true),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Paid via ${booking.paymentMethod} • Status: ${booking.paymentStatus}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromInt(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Verification QR Code
                  pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data:
                            'SMART_FLIGHT|PNR:${booking.pnr}|ID:${booking.bookingId}|FL:${booking.flightNumber}|PASSENGERS:${booking.passengers}',
                        width: 90,
                        height: 90,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Scan to verify at gate',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer Notice
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF1F5F9),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Important Notice: Please present this e-ticket along with a valid government photo ID at the airport check-in counter. Boarding gates close 25 minutes prior to scheduled departure.',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _fareRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Directly displays system print/share dialog for the generated PDF
  static Future<void> printOrShareTicket(BookingModel booking) async {
    final pdfBytes = await generateTicketPdf(booking);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'SmartFlight_${booking.pnr}_Ticket.pdf',
    );
  }
}
