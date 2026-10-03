import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  /// Store booking directly in Firestore under `bookings/{bookingId}`
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _bookingsCollection.doc(booking.bookingId).set(booking.toMap());

      // Create booking confirmation notification in Firestore 'notifications'
      await NotificationService().sendNotification(
        userId: booking.userId,
        title: 'Booking Confirmed - PNR ${booking.pnr}',
        message:
            'Your flight ${booking.airline} ${booking.flightNumber} from ${booking.departure} to ${booking.arrival} is confirmed.',
        type: 'booking',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Live stream of bookings filtered by current authenticated user
  Stream<List<BookingModel>> streamUserBookings([String? userId]) {
    final uid = userId ?? AuthService().currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    return _bookingsCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data());
      }).toList();
      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return list;
    });
  }

  /// Admin: Live stream of all bookings in the system
  Stream<List<BookingModel>> streamAllBookings() {
    return _bookingsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data());
      }).toList();
      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return list;
    });
  }

  /// Admin: Stream of all registered user profiles
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// One-time fetch of user bookings
  Future<List<BookingModel>> getUserBookings([String? userId]) async {
    final uid = userId ?? AuthService().currentUser?.uid;
    if (uid == null) {
      return [];
    }

    try {
      final snapshot =
          await _bookingsCollection.where('userId', isEqualTo: uid).get();
      final list = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();
      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Cancel a booking: Updates status to 'Cancelled' and updates refund details.
  /// Does NOT delete the document completely from Firestore.
  Future<void> cancelBooking({
    required String bookingId,
    required int cancellationFee,
    required int refundAmount,
  }) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      final data = doc.data();

      await _bookingsCollection.doc(bookingId).update({
        'bookingStatus': 'Cancelled',
        'paymentStatus': 'Refunded (₹$refundAmount)',
        'cancellationFee': cancellationFee,
        'refundAmount': refundAmount,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (data != null) {
        final userId = data['userId'] as String? ?? '';
        final pnr = data['pnr'] as String? ?? '';
        if (userId.isNotEmpty) {
          await NotificationService().sendNotification(
            userId: userId,
            title: 'Booking Cancelled - PNR $pnr',
            message:
                'Your flight booking has been cancelled. Refund of ₹$refundAmount will be processed to your payment method.',
            type: 'cancellation',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return BookingModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}
