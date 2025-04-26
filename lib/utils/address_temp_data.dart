// Temporary hardcoded data for address dropdowns
const tempCountries = [
  {'iso2': 'PH', 'name': 'Philippines'},
  {'iso2': 'US', 'name': 'United States'},
  {'iso2': 'IN', 'name': 'India'},
];

const tempStates = {
  'PH': [
    {'iso2': '00', 'name': 'Metro Manila'},
    {'iso2': '01', 'name': 'Laguna'},
    {'iso2': '02', 'name': 'Cebu'},
  ],
  'US': [
    {'iso2': 'CA', 'name': 'California'},
    {'iso2': 'NY', 'name': 'New York'},
    {'iso2': 'TX', 'name': 'Texas'},
  ],
  'IN': [
    {'iso2': 'MH', 'name': 'Maharashtra'},
    {'iso2': 'DL', 'name': 'Delhi'},
    {'iso2': 'KA', 'name': 'Karnataka'},
  ],
};

const tempCities = {
  'PH': {
    '00': ['Quezon City', 'Manila', 'Pasig'],
    '01': ['Santa Cruz', 'San Pablo', 'Calamba'],
    '02': ['Cebu City', 'Mandaue', 'Lapu-Lapu'],
  },
  'US': {
    'CA': ['Los Angeles', 'San Francisco', 'San Diego'],
    'NY': ['New York City', 'Buffalo', 'Albany'],
    'TX': ['Houston', 'Dallas', 'Austin'],
  },
  'IN': {
    'MH': ['Mumbai', 'Pune', 'Nagpur'],
    'DL': ['New Delhi', 'Dwarka', 'Rohini'],
    'KA': ['Bangalore', 'Mysore', 'Mangalore'],
  },
};
