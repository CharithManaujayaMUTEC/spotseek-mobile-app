// Sample mock data for partners/manager finance rows
// Used in debug mode to avoid calling the real /api/partners/finance endpoint.

const List<Map<String, dynamic>> partnersFinanceMock = [
  {
    'event_id': 101,
    'event_name': 'Mock Concert A',
    'total_sales': 12500.50,
    'currency': 'LKR',
    'date_range': '2025-10-01 to 2025-10-31',
    'tickets_sold': 250,
  },
  {
    'event_id': 102,
    'event_name': 'Mock Festival B',
    'total_sales': 9800.00,
    'currency': 'LKR',
    'date_range': '2025-10-01 to 2025-10-31',
    'tickets_sold': 160,
  },
  {
    'event_id': 103,
    'event_name': 'Mock Workshop C',
    'total_sales': 4500.75,
    'currency': 'LKR',
    'date_range': '2025-10-15 to 2025-10-20',
    'tickets_sold': 45,
  },
];
