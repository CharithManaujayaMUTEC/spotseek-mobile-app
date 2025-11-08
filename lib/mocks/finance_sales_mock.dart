// Mock finance sales data used as a fallback when the backend API is unavailable.

const Map<String, dynamic> financeSalesMock = {
  'totalSales': 125000.00,
  'totalCommissions': 5000.00,
  'netRevenue': 120000.00,
  'salesByPackage': [
    {
      'packageName': 'General Admission',
      'ticketsSold': 800,
      'revenue': 80000.00,
    },
    {
      'packageName': 'VIP',
      'ticketsSold': 150,
      'revenue': 37500.00,
    },
    {
      'packageName': 'Early Bird',
      'ticketsSold': 50,
      'revenue': 7500.00,
    },
  ],
};
