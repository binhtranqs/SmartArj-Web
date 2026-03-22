#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Correct CityID → image mapping (from FIX_CITIES_FINAL.sql):
# 1=Đà Nẵng  2=Hà Nội  3=Hồ Chí Minh  4=Cần Thơ  5=Đà Lạt
# 6=Đắk Lắk  7=Hải Phòng  8=Huế  9=Nha Trang  10=Sapa

JSP = r"C:\Users\LENOVO\Documents\NetBeansProjects\SmartArj\web\WEB-INF\views\admin\dashboard.jsp"

with open(JSP, encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
print(f"Line 698: {lines[697].rstrip()}")
print(f"Line 751: {lines[750].rstrip()}")

NEW_BLOCK = r"""                        <% List<Map<String,Object>> zoneData = (List<Map<String,Object>>)
                                request.getAttribute("zoneData");
                                // CityID-based image map (IDs from DB Cities table)
                                // 1=DaNang 2=HaNoi 3=HCM 4=CanTho 5=DaLat
                                // 6=DakLak 7=HaiPhong 8=Hue 9=NhaTrang 10=Sapa
                                String _cp2 = request.getContextPath();
                                java.util.Map<Integer,String> CID_IMG = new java.util.HashMap<>();
                                CID_IMG.put(1,  _cp2 + "/assets/cities/danang.png");
                                CID_IMG.put(2,  _cp2 + "/assets/cities/hanoi.png");
                                CID_IMG.put(3,  _cp2 + "/assets/cities/hcm.png");
                                CID_IMG.put(4,  _cp2 + "/assets/cities/cantho.png");
                                CID_IMG.put(5,  _cp2 + "/assets/cities/dalat.png");
                                CID_IMG.put(6,  _cp2 + "/assets/cities/daklak.png");
                                CID_IMG.put(7,  _cp2 + "/assets/cities/haiphong.png");
                                CID_IMG.put(8,  _cp2 + "/assets/cities/hue.png");
                                CID_IMG.put(9,  _cp2 + "/assets/cities/nhatrang.png");
                                CID_IMG.put(10, _cp2 + "/assets/cities/sapa.png");
                                String FBIMG = "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=360&q=65";
                                if (zoneData != null && !zoneData.isEmpty()) {
                                    java.util.Set<Integer> seenCids = new java.util.HashSet<>();
                                    int ii = 0;
                                    for (Map<String,Object> z : zoneData) {
                                        Object cidObj = z.get("cityId");
                                        int cid = cidObj != null ? ((Number)cidObj).intValue() : -(ii+1);
                                        if (!seenCids.add(cid)) continue;
                                        String img2     = CID_IMG.containsKey(cid) ? CID_IMG.get(cid) : FBIMG;
                                        String dispName = z.get("cityName") != null ? String.valueOf(z.get("cityName")) : "";
                                        String tempStr  = z.get("temp")     != null ? String.valueOf(z.get("temp"))     : "--";
                                        String zoneName = z.get("zoneName") != null ? String.valueOf(z.get("zoneName")) : "";
                                        Object zid      = z.get("zoneId");
                                        String sHumid   = z.get("humid")    != null ? String.valueOf(z.get("humid"))    : "0";
                                        String sRain    = z.get("rain")     != null ? String.valueOf(z.get("rain"))     : "0";
                                        String sWind    = z.get("wind")     != null ? String.valueOf(z.get("wind"))     : "0";
                                        String sUpd     = z.get("updatedAt") != null ? String.valueOf(z.get("updatedAt")) : "--";
                                        String safeDn   = dispName.replace("'", " ");
                                        String safeUpd  = sUpd.replace("'", " ");
                                        ii++;
                                        %>
                                        <div class="city-tile" data-aos="zoom-in" data-aos-delay="<%= (ii-1)*35 %>" data-aos-duration="420"
                                            onclick="showCity('<%= zid %>',this,'<%= safeDn %>','<%= tempStr %>','<%= sHumid %>','<%= sRain %>','<%= sWind %>','<%= safeUpd %>')">
                                            <img class="city-img" src="<%= img2 %>" alt="<%= dispName %>" loading="lazy"
                                                 onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=360&q=65'">
                                            <div class="city-overlay">
                                                <div class="city-tbadge"><%= tempStr %>&#176;C</div>
                                                <div class="city-info">
                                                    <div class="city-name"><%= dispName %></div>
                                                    <div class="city-desc"><i data-lucide="map-pin" width="12" height="12"></i> <%= zoneName %></div>
                                                </div>
                                            </div>
                                        </div>
                                        <% } } else { %>
                                            <div style="grid-column:1/-1;text-align:center;padding:44px 16px;">
                                                <i data-lucide="cloud-off" width="28" height="28" style="color:var(--t3);margin:0 auto 10px;display:block;opacity:.4;"></i>
                                                <p style="font-size:.82rem;color:var(--t3);">Chua co du lieu.</p>
                                            </div>
                                        <% } %>
"""

# Find the start and end lines of the block to replace
start_idx = None
end_idx = None
for i, line in enumerate(lines):
    if '<% List<Map<String,Object>> zoneData' in line and start_idx is None:
        start_idx = i
    if '<% } %>' in line and start_idx is not None and i > start_idx + 30:
        end_idx = i
        break

print(f"Block start (0-indexed): {start_idx} (line {start_idx+1})")
print(f"Block end   (0-indexed): {end_idx}   (line {end_idx+1})")

before = lines[:start_idx]
after  = lines[end_idx+1:]

result = before + [NEW_BLOCK + '\n'] + after
with open(JSP, 'w', encoding='utf-8') as f:
    f.writelines(result)

print(f"Done. New total lines: {len(result)}")
