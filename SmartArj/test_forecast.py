import requests
import json

s = requests.Session()

# Login
login_url = "http://localhost:9999/login"
login_payload = {
    "username": "admin",
    "password": "123"
}
res = s.post(login_url, data=login_payload)
print("Login status:", res.status_code)

# Get zones
zones_url = "http://localhost:9999/api/zones"
res = s.get(zones_url)
print("Zones status:", res.status_code)
zones = res.json()
print("Available zones:", json.dumps(zones, indent=2))

if not zones:
    print("No zones available for this user.")
else:
    # Use the first zone found
    zone_id = zones[0]['zoneId']
    print(f"Testing forecast for zoneId={zone_id}")
    
    forecast_url = f"http://localhost:9999/api/forecast?zoneId={zone_id}"
    res = s.get(forecast_url)
    print("Forecast status:", res.status_code)
    print("Forecast response:", res.text)
