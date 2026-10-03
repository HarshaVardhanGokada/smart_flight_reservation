✈️ Smart Flight Reservation
<p align="center">
  <b>A modern Flutter-based flight booking application powered by Firebase.</b>
</p>

<p align="center">
  Search • Compare • Select • Book • Pay • Manage
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

🌍 About
Smart Flight Reservation is a flight-only booking application designed to provide a smooth, modern travel-booking experience.
The application covers the complete journey from flight search to booking confirmation, with Firebase used for authentication and cloud data management.
✨ Key Features
- 🔐 Firebase Authentication — Sign up, login, logout and password reset
- 🔎 Flight Search — Search flights by origin, destination, date, passengers and cabin class
- ✈️ Flight Comparison — Compare airlines, prices, duration and stops
- 📋 Flight Details — View complete flight and fare information
- 👤 Passenger Management — Add and manage traveller details
- 💺 Seat Selection — Interactive seat selection and availability
- 🍱 Meal Selection — Customize passenger meal preferences
- 💰 Fare Breakdown — View base fare, taxes, fees and additional charges
- 💳 Payment — Payment workflow designed for gateway integration
- 🎫 Booking Confirmation — Booking ID, PNR and reservation details
- 🎟️ Digital E-Ticket — Digital ticket with QR-code support
- 📚 My Bookings — View upcoming and previous reservations
- 👤 Profile — Manage user information and preferences
🔥 Firebase
Firebase is used as the cloud backend for the application.
Firebase Authentication
Handles:
- User registration
- Email/password login
- Password reset
- Authentication state
Cloud Firestore
Stores application data such as:
users/
bookings/
payments/
User accounts, booking details, passenger information and payment records can be linked using the authenticated user's Firebase UID and booking IDs.
🔄 Booking Flow
Splash
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
E-Ticket
  ↓
My Bookings
🛠️ Tech Stack
Technology	Purpose
Flutter	Application development
Dart	Programming language
Firebase Authentication	User authentication
Cloud Firestore	Cloud database
Firebase Core	Firebase integration
Figma	UI/UX design
Amadeus / Skyscanner	Planned flight API integration
Razorpay / Stripe	Planned payment integration


📂 Project Structure
smart_flight_reservation/
│
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   ├── firebase_options.dart
│   └── main.dart
│
├── android/
├── ios/
├── macos/
├── web/
├── test/
├── pubspec.yaml
└── README.md
🚀 Future Scope
- 🌐 Live flight API integration
- 💳 Production payment gateway
- 🛰️ Real-time flight status
- 🔔 Push notifications
- 🤖 AI-based fare prediction
- 👥 Group booking
- ⭐ Loyalty and rewards
- 🔒 Advanced booking and payment security
👨‍💻 Team
Member	Student ID
G. Harsha	CB.SC.U4CSE24719
R. Jason	CB.SC.U4CSE24721
S. Rahul	CB.SC.U4CSE24766


<p align="center">
  <b>✈️ Search smarter. Compare better. Book faster. Travel easier.</b>
</p>

<p align="center">
  <i>Built with Flutter & Firebase ❤️</i>
</p>
