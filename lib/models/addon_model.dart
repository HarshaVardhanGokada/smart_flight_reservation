class AddonItem {
  final String id;
  final String title;
  final String description;
  final int price;
  final String category; // 'meal', 'baggage', 'insurance', 'priority'
  final String? dietaryType; // 'veg', 'non-veg', 'jain'

  const AddonItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.dietaryType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      if (dietaryType != null) 'dietaryType': dietaryType,
    };
  }

  factory AddonItem.fromMap(Map<String, dynamic> map) {
    return AddonItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      category: map['category'] ?? '',
      dietaryType: map['dietaryType'],
    );
  }
}

class AvailableAddons {
  static const List<AddonItem> meals = [
    AddonItem(
      id: 'meal_veg_thali',
      title: 'Paneer Butter Masala Meal',
      description: 'Cottage cheese curry with Jeera rice, paratha, & gulab jamun',
      price: 399,
      category: 'meal',
      dietaryType: 'veg',
    ),
    AddonItem(
      id: 'meal_chicken_biryani',
      title: 'Awadhi Chicken Biryani',
      description: 'Slow-cooked fragrant basmati rice with spiced tender chicken & raita',
      price: 499,
      category: 'meal',
      dietaryType: 'non-veg',
    ),
    AddonItem(
      id: 'meal_jain_platter',
      title: 'Jain Special Dal Khichdi & Aloo',
      description: 'Pure satvik meal prepared without onion, garlic, or root vegetables',
      price: 379,
      category: 'meal',
      dietaryType: 'jain',
    ),
    AddonItem(
      id: 'meal_fruit_bowl',
      title: 'Seasonal Fresh Fruit Bowl & Yogurt',
      description: 'Cut dragon fruit, kiwi, berries, and flavored Greek yogurt',
      price: 299,
      category: 'meal',
      dietaryType: 'veg',
    ),
  ];

  static const List<AddonItem> baggage = [
    AddonItem(
      id: 'baggage_5kg',
      title: 'Extra 5 kg Check-in Baggage',
      description: 'Pre-book additional 5 kg at discounted rates vs airport counter',
      price: 1350,
      category: 'baggage',
    ),
    AddonItem(
      id: 'baggage_10kg',
      title: 'Extra 10 kg Check-in Baggage',
      description: 'Pre-book additional 10 kg check-in allowance',
      price: 2600,
      category: 'baggage',
    ),
    AddonItem(
      id: 'baggage_15kg',
      title: 'Extra 15 kg Check-in Baggage',
      description: 'Pre-book additional 15 kg for bulky or extended trip bags',
      price: 3750,
      category: 'baggage',
    ),
  ];

  static const AddonItem travelInsurance = AddonItem(
    id: 'insurance_comprehensive',
    title: 'Comprehensive Travel Shield',
    description: 'Covers trip cancellation, baggage loss up to ₹25,000, and medical emergencies up to ₹5,00,000',
    price: 249,
    category: 'insurance',
  );

  static const AddonItem priorityBoarding = AddonItem(
    id: 'priority_express',
    title: 'Priority Boarding & Fast-Track Baggage',
    description: 'Skip long boarding queues and receive your baggage first upon landing',
    price: 399,
    category: 'priority',
  );
}
