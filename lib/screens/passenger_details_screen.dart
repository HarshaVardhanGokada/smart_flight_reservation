import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import '../models/passenger_model.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'seat_selection_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final FlightOffer flight;
  final FlightSearchCriteria criteria;

  const PassengerDetailsScreen({
    super.key,
    required this.flight,
    required this.criteria,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDataHolder {
  String title;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController dob;
  String gender;
  String nationality;
  String idType = 'Aadhaar / Govt ID';
  final TextEditingController idNumber;
  final String passengerType;

  _PassengerDataHolder({
    this.title = 'Mr',
    required this.firstName,
    required this.lastName,
    required this.dob,
    this.gender = 'Male',
    this.nationality = 'Indian',
    required this.idNumber,
    required this.passengerType,
  });

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    dob.dispose();
    idNumber.dispose();
  }
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  late final List<_PassengerDataHolder> _passengers;

  @override
  void initState() {
    super.initState();
    _initPassengerHolders();
    _prefillFromAuth();
  }

  void _initPassengerHolders() {
    _passengers = [];

    // Adults
    for (int i = 0; i < widget.criteria.adults; i++) {
      _passengers.add(
        _PassengerDataHolder(
          title: 'Mr',
          firstName: TextEditingController(),
          lastName: TextEditingController(),
          dob: TextEditingController(),
          gender: 'Male',
          nationality: 'Indian',
          idNumber: TextEditingController(),
          passengerType: 'Adult',
        ),
      );
    }

    // Children
    for (int i = 0; i < widget.criteria.children; i++) {
      _passengers.add(
        _PassengerDataHolder(
          title: 'Master',
          firstName: TextEditingController(),
          lastName: TextEditingController(),
          dob: TextEditingController(),
          gender: 'Male',
          nationality: 'Indian',
          idNumber: TextEditingController(),
          passengerType: 'Child',
        ),
      );
    }

    // Infants
    for (int i = 0; i < widget.criteria.infants; i++) {
      _passengers.add(
        _PassengerDataHolder(
          title: 'Master',
          firstName: TextEditingController(),
          lastName: TextEditingController(),
          dob: TextEditingController(),
          gender: 'Male',
          nationality: 'Indian',
          idNumber: TextEditingController(),
          passengerType: 'Infant',
        ),
      );
    }
  }

  Future<void> _prefillFromAuth() async {
    final user = AuthService().currentUser;
    if (user != null) {
      if (user.email != null) {
        _contactEmailController.text = user.email!;
      }
      final profile = await AuthService().getUserProfile(user.uid);
      if (profile != null) {
        if (profile.phone.isNotEmpty) {
          _contactPhoneController.text = profile.phone;
        }
        if (profile.fullName.isNotEmpty && _passengers.isNotEmpty) {
          final parts = profile.fullName.trim().split(' ');
          _passengers[0].firstName.text = parts.first;
          if (parts.length > 1) {
            _passengers[0].lastName.text = parts.sublist(1).join(' ');
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    for (var p in _passengers) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDob(int index) async {
    final holder = _passengers[index];
    final now = DateTime.now();

    DateTime firstDate;
    DateTime lastDate;
    DateTime initialDate;

    if (holder.passengerType == 'Adult') {
      firstDate = DateTime(1920);
      lastDate = now.subtract(const Duration(days: 365 * 12));
      initialDate = DateTime(1995);
    } else if (holder.passengerType == 'Child') {
      firstDate = now.subtract(const Duration(days: 365 * 12));
      lastDate = now.subtract(const Duration(days: 365 * 2));
      initialDate = now.subtract(const Duration(days: 365 * 6));
    } else {
      // Infant
      firstDate = now.subtract(const Duration(days: 365 * 2));
      lastDate = now;
      initialDate = now.subtract(const Duration(days: 180));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        holder.dob.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _proceedToSeatSelection() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required passenger details.'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final List<PassengerModel> passengerModels = [];
    for (int i = 0; i < _passengers.length; i++) {
      final p = _passengers[i];
      passengerModels.add(
        PassengerModel(
          title: p.title,
          firstName: p.firstName.text.trim(),
          lastName: p.lastName.text.trim(),
          dateOfBirth: p.dob.text.trim(),
          gender: p.gender,
          nationality: p.nationality,
          idType: p.idType,
          idNumber: p.idNumber.text.trim(),
          email: _contactEmailController.text.trim(),
          phone: _contactPhoneController.text.trim(),
          passengerType: p.passengerType,
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreen(
          flight: widget.flight,
          criteria: widget.criteria,
          passengers: passengerModels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Passenger Details'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Contact Information Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.contact_mail_outlined,
                          size: 18, color: AppTheme.primaryNavy),
                      SizedBox(width: 8),
                      Text(
                        'Booking Contact Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your ticket and flight updates will be sent to this email & phone number.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Contact email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Mobile Number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Contact phone number is required';
                      }
                      if (val.trim().replaceAll(RegExp(r'[^\d]'), '').length < 10) {
                        return 'Enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Dynamic Passenger Forms
            ...List.generate(_passengers.length, (index) {
              final holder = _passengers[index];
              return _buildPassengerCard(index, holder);
            }),

            const SizedBox(height: 16),

            // Proceed Action
            AppButton(
              label: 'Proceed to Seat Selection',
              icon: Icons.airline_seat_recline_extra_rounded,
              onPressed: _proceedToSeatSelection,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard(int index, _PassengerDataHolder holder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Passenger ${index + 1} (${holder.passengerType})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  holder.passengerType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title & First Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 105,
                child: DropdownButtonFormField<String>(
                  initialValue: holder.title,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                  items: ['Mr', 'Mrs', 'Ms', 'Master']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => holder.title = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: holder.firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Last Name
          TextFormField(
            controller: holder.lastName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Last / Surname'),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
          ),

          const SizedBox(height: 14),

          // DOB & Gender
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDob(index),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: holder.dob,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'DD/MM/YYYY',
                        suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: holder.gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => holder.gender = val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ID Type & ID Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  initialValue: holder.idType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'ID Document',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  ),
                  items: ['Aadhaar / Govt ID', 'Passport', 'Voter ID']
                      .map((id) => DropdownMenuItem(
                            value: id,
                            child: Text(
                              id,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => holder.idType = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: holder.idNumber,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'ID / Passport Number',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
