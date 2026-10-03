✈️ Smart Flight Reservation
<p align="center">
  <b>A modern, end-to-end flight reservation platform built with Flutter and Firebase.</b>
</p>

<p align="center">
  Search • Compare • Customize • Book • Pay • Confirm • Manage
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart" />
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase" />
  <img src="https://img.shields.io/badge/Firestore-Database-FFCA28?style=for-the-badge&logo=firebase" />
  <img src="https://img.shields.io/badge/Firebase%20Auth-Authentication-FFCA28?style=for-the-badge&logo=firebase" />
</p>

🌍 About The Project
Smart Flight Reservation is a Flutter-based flight reservation application designed to provide users with a smooth, simple, and professional flight-booking experience.
The application brings the major stages of flight booking into one platform:
Discover → Compare → Select → Customize → Pay → Confirm → Manage

Users can create an account, search for flights, compare available options, view flight details, enter passenger information, select seats and meals, review the fare, complete payment, receive a digital ticket, and manage their bookings.
The project is focused specifically on flight reservations, providing a guided booking experience inspired by modern travel-booking platforms.
🎯 Project Objective
The main objective of Smart Flight Reservation is to develop a reliable and user-friendly flight reservation system that simplifies the complete booking process.
The application aims to provide:
- ✈️ Easy flight discovery
- 🔎 Fast flight search
- 💰 Transparent fare comparison
- 👤 Passenger management
- 💺 Seat selection
- 🍱 Meal selection
- 💳 Secure payment integration
- 🎫 Digital ticket generation
- 📋 Booking management
- 👤 User profile management
- 🔥 Cloud-based data storage
🚀 Core Features
🔐 1. User Authentication
The application uses Firebase Authentication for user account management.
Features
- User registration
- Email/password login
- Logout
- Password reset
- Authentication state management
- Firebase user identity
- User profile management
🏠 2. Home Dashboard
The home screen acts as the main entry point for the application.
Includes
- Personalized user experience
- Flight search
- Quick navigation
- My Bookings
- Profile
- Offers
- Settings
✈️ 3. Flight Search
Users can search for flights according to their travel requirements.
Search Options
- One-way
- Round-trip
- Multi-city
- Departure location
- Destination
- Departure date
- Return date
- Number of passengers
- Cabin class
Search Flow
Origin
   ↓
Destination
   ↓
Travel Date
   ↓
Passengers
   ↓
Cabin Class
   ↓
Search Flights
🔎 4. Flight Results & Comparison
The flight results screen allows users to compare different flight options.
Flight Information
- Airline
- Flight number
- Departure time
- Arrival time
- Flight duration
- Number of stops
- Cabin class
- Base fare
- Taxes
- Service charges
- Total fare
Filtering & Sorting
Flights can be organized according to:
- Price
- Duration
- Stops
- Airline
- Departure time
- Arrival time
🛫 5. Flight Details
Users can view detailed information before proceeding with their booking.
Includes
- Airline details
- Flight number
- Origin
- Destination
- Departure time
- Arrival time
- Flight duration
- Stops
- Cabin class
- Fare information
- Taxes and fees
- Total amount
👤 6. Passenger Management
The application collects passenger information required for the reservation.
Passenger Details
- Full name
- Date of birth
- Gender
- Nationality
- Frequent flyer information
- Multiple passengers
💺 7. Seat Selection
Users can select their preferred seats through an interactive seat-selection interface.
Seat Status
🟢 Available
🔵 Selected
🔴 Booked
Features
- Seat layout
- Seat availability
- Selected seat indication
- Passenger-specific seat selection
- Seat confirmation
- Additional seat charges where applicable
🍱 8. Meal Selection
Passengers can customize their meal preferences during the booking process.
Meal Options
- 🥗 Vegetarian
- 🍗 Non-Vegetarian
- 🌱 Jain
- 🚫 No Meal
🧾 9. Transparent Fare Breakdown
Before payment, users receive a clear summary of the total booking amount.
Base Fare
+ Taxes
+ Service Charges
+ Seat Charges
+ Meal Charges
-------------------------
Total Amount
💳 10. Payment
The application is designed to support multiple payment methods.
Planned Payment Methods
- UPI
- Credit Card
- Debit Card
- Net Banking
- Wallets
Payment Gateway Integration
The project architecture is designed to support payment gateways such as:
- Razorpay
- Stripe
🎫 11. Booking Confirmation
After successful booking, users receive a booking confirmation containing:
- Booking ID
- PNR
- Passenger details
- Flight details
- Seat
- Meal
- Total amount
- Payment status
- Booking date
🎟️ 12. Digital E-Ticket
The application provides a digital representation of the confirmed flight ticket.
E-Ticket Information
- Passenger name
- Airline
- Flight number
- Origin
- Destination
- Travel date
- Departure time
- Arrival time
- Seat
- Cabin
- Meal
- PNR
- Booking ID
- Total amount
The application also supports QR-code based digital ticket information.
📚 13. My Bookings
Users can view their reservations from the My Bookings section.
Booking Categories
- 🟢 Upcoming bookings
- 🔵 Past bookings
Booking Information
- Flight details
- Passenger details
- PNR
- Booking ID
- Booking status
- Payment status
- Booking date
👤 14. Profile Management
Users can manage their personal information through the profile section.
Profile Features
- Name
- Email
- Phone number
- Account information
- Saved passenger information
- Payment information
- Settings
- Logout
⚙️ 15. Settings
The application includes a settings section for managing user preferences.
Planned Settings
- Notification preferences
- Language preferences
- Theme preferences
- Account settings
🔥 Firebase Integration
Firebase is an important part of the Smart Flight Reservation backend architecture.
Firebase Authentication
Firebase Authentication handles:
- User registration
- User login
- Password reset
- Authentication state
- User identity
Cloud Firestore
Cloud Firestore is used for storing application data.
Users
users/
   └── userId/
        ├── uid
        ├── name
        ├── email
        ├── phone
        ├── createdAt
        └── updatedAt
Bookings
bookings/
   └── bookingId/
        ├── userId
        ├── flight
        ├── passenger
        ├── seat
        ├── meal
        ├── amount
        ├── paymentStatus
        └── bookingDate
Payments
payments/
   └── paymentId/
        ├── userId
        ├── bookingId
        ├── amount
        ├── transactionId
        ├── paymentStatus
        └── paymentDate
🏗️ Application Architecture
Smart Flight Reservation
│
├── Authentication
│   ├── Login
│   ├── Signup
│   └── Password Reset
│
├── Home
│   ├── Flight Search
│   ├── Offers
│   ├── My Bookings
│   └── Profile
│
├── Flight Search
│   ├── Search Criteria
│   ├── Flight Results
│   ├── Filters
│   └── Sorting
│
├── Booking
│   ├── Flight Details
│   ├── Passenger Details
│   ├── Seat Selection
│   ├── Meal Selection
│   └── Checkout
│
├── Payment
│   ├── Payment Methods
│   ├── Fare Summary
│   └── Payment Status
│
├── Ticketing
│   ├── Booking Confirmation
│   ├── PNR
│   ├── E-Ticket
│   └── QR Code
│
└── Profile
    ├── Personal Information
    ├── Saved Passengers
    ├── Payment Methods
    └── Settings
🔄 Complete Booking Journey
Splash Screen
      ↓
Login / Signup
      ↓
Home
      ↓
Search Flights
      ↓
Flight Results
      ↓
Flight Details
      ↓
Passenger Details
      ↓
Seat Selection
      ↓
Meal Selection
      ↓
Checkout
      ↓
Payment
      ↓
Booking Confirmation
      ↓
Digital E-Ticket
      ↓
My Bookings
      ↓
Manage Booking
      ↓
Profile
📱 Application Screens
#	Screen	Description
1	Splash Screen	Application introduction and branding
2	Login	Existing user authentication
3	Signup	New user registration
4	Home	Main flight-booking dashboard
5	Menu	Application navigation
6	Settings	User preferences
7	Search Flights	Flight search configuration
8	Flight Results	Available flight options
9	Flight Details	Detailed flight information
10	Passenger Details	Traveller information
11	Seat Selection	Interactive seat selection
12	Food Selection	Meal customization
13	Checkout	Booking review and fare summary
14	Payment	Payment process
15	Booking Confirmation	Reservation confirmation
16	E-Ticket	Digital flight ticket
17	My Bookings	Booking history and upcoming trips
18	Profile	User account management


🛠️ Technology Stack
Frontend
- Flutter
- Dart
- Material Design
- Responsive UI
Backend
- Firebase
- Firebase Authentication
- Cloud Firestore
Flight Data
The architecture is designed to support third-party flight APIs such as:
- Amadeus
- Skyscanner
Payment
The architecture is designed to support:
- Razorpay
- Stripe
Design
- Figma
📂 Project Structure
smart_flight_reservation/
│
├── android/
├── ios/
├── macos/
├── web/
│
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   ├── firebase_options.dart
│   └── main.dart
│
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
🔐 Security & Data Management
Firebase Authentication provides identity management for users.
Cloud Firestore stores application information associated with authenticated users.
The application architecture uses Firebase User IDs to associate:
User
 ↓
Booking
 ↓
Payment
 ↓
E-Ticket
For production deployment, the project should use:
- Firestore Security Rules
- Authentication-based access control
- Secure API key management
- Server-side validation
- Secure payment verification
- Transaction verification
- Proper environment configuration
🌱 Future Scope
🤖 AI Fare Prediction
An AI-based system could analyze historical fare trends and help users identify suitable booking times.
👥 Group Booking
Support for group reservations and shared/split payments.
🛰️ Real-Time Flight Updates
Integration with flight-status services could provide:
- Flight delays
- Gate changes
- Cancellation alerts
- Departure updates
- Arrival updates
⭐ Loyalty & Rewards
Future versions can include:
- Frequent flyer programs
- Reward points
- Travel benefits
- Loyalty membership integration
🔔 Push Notifications
Users could receive notifications for:
- Booking confirmation
- Payment status
- Flight reminders
- Flight delays
- Gate changes
- Cancellation updates
📊 Development Roadmap
Phase 1 — Application Foundation
- [x] Flutter project setup
- [x] Basic application structure
- [x] Splash screen
- [x] Login screen
- [x] Signup screen
- [x] Home interface
Phase 2 — Firebase
- [x] Firebase project creation
- [x] Firebase Core integration
- [x] Firebase Authentication
- [x] Email/password authentication
- [x] Cloud Firestore setup
- [x] User profile storage
Phase 3 — Flight Booking
- [x] Flight search interface
- [x] Flight results interface
- [x] Flight details
- [x] Passenger details
- [x] Seat selection
- [x] Meal selection
- [x] Checkout flow
Phase 4 — Booking & Ticketing
- [x] Booking confirmation interface
- [x] Booking ID
- [x] PNR
- [x] E-ticket interface
- [x] QR code generation
- [x] My Bookings interface
Phase 5 — External Integrations
- [ ] Live flight API integration
- [ ] Real-time flight availability
- [ ] Production payment gateway
- [ ] Real payment verification
- [ ] Real-time seat locking
- [ ] Flight status API
- [ ] Push notifications
Phase 6 — Advanced Features
- [ ] AI fare prediction
- [ ] Group booking
- [ ] Loyalty & rewards
- [ ] Advanced travel recommendations
🚀 Getting Started
Prerequisites
Install:
- Flutter SDK
- Dart SDK
- VS Code or Android Studio
- Android Studio / Xcode for mobile development
- Firebase account
Check Flutter:
flutter doctor
Installation
Clone the repository:
git clone https://github.com/YOUR_USERNAME/smart-flight-reservation.git
Navigate into the project:
cd smart-flight-reservation
Install dependencies:
flutter pub get
Run the application:
flutter run
For Chrome:
flutter run -d chrome
🔥 Firebase Setup
Create a Firebase project and connect the Flutter application using FlutterFire.
Enable:
Firebase Authentication
        ↓
Email / Password
Create:
Cloud Firestore
Configure Firebase for the required Flutter platforms.
Then run:
flutter pub get
and launch the application.
🧪 Testing
Test the complete flow:
Create Account
      ↓
Login
      ↓
Search Flight
      ↓
Select Flight
      ↓
Enter Passenger Details
      ↓
Select Seat
      ↓
Select Meal
      ↓
Review Fare
      ↓
Payment
      ↓
Booking Confirmation
      ↓
E-Ticket
      ↓
My Bookings
📌 Development Status
🚧 Smart Flight Reservation is currently under active development.

The core Flutter interface, Firebase integration, authentication flow, user profile storage, booking workflow, ticket interface, and QR-based ticket functionality are being developed as part of the project.
Advanced integrations such as live airline inventory, production payment processing, real-time flight information, and external API integrations are planned as the project progresses.
🎓 Academic Project
Project: Smart Flight Reservation
Course: Mobile Application Development
Project ID: 23CSE465
Team
Name	Student ID
G. Harsha	CB.SC.U4CSE24719
R. Jason	CB.SC.U4CSE24721
S. Rahul	CB.SC.U4CSE24766


🎯 Project Vision
Smart Flight Reservation aims to evolve into a complete digital flight-booking platform where users can manage their entire journey from one application.
Search smarter. Compare better. Book faster. Travel easier.

<p align="center">

✈️ Smart Flight Reservation
Search. Compare. Book. Fly.
Built with Flutter & Firebase
</p>
