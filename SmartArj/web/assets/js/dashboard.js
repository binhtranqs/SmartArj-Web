// Dashboard.js - Quản lý biểu đồ, thông báo và chatbot

// Khởi tạo biểu đồ khi trang load
document.addEventListener('DOMContentLoaded', function () {
    initChart();
    initNotifications();
    initChatbot();
    loadForecast(); // Load forecast if VIP
});

// Khởi tạo biểu đồ Chart.js
function initChart() {
    const ctx = document.getElementById('lineChart');
    if (!ctx) return;

    // Lấy dữ liệu từ JSP (sẽ được inject từ backend)
    const historyData = window.historyData || [25, 26, 27, 28, 29, 30, 31];
    const forecastData = window.forecastData || [31, 32, 33, 34, 35, 36, 37];

    const labels = ['Ngày 1', 'Ngày 2', 'Ngày 3', 'Ngày 4', 'Ngày 5', 'Ngày 6', 'Ngày 7'];

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Dữ liệu lịch sử',
                    data: historyData,
                    borderColor: '#4F46E5',
                    backgroundColor: 'rgba(79, 70, 229, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Dự báo',
                    data: forecastData,
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderDash: [5, 5],
                    tension: 0.4,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                },
                title: {
                    display: true,
                    text: 'Biểu đồ Dữ liệu & Dự báo'
                }
            },
            scales: {
                y: {
                    beginAtZero: false
                }
            }
        }
    });
}

// Khởi tạo chức năng thông báo
function initNotifications() {
    const bellIcon = document.getElementById('notificationBell');
    const dropdown = document.getElementById('notificationDropdown');

    if (!bellIcon || !dropdown) return;

    bellIcon.addEventListener('click', function (e) {
        e.stopPropagation();
        dropdown.classList.toggle('show');
    });

    // Đóng dropdown khi click bên ngoài
    document.addEventListener('click', function (e) {
        if (!bellIcon.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.classList.remove('show');
        }
    });

    // Load alerts
    loadAlerts();
}

async function loadAlerts() {
    const list = document.querySelector('.notification-list');
    const badge = document.querySelector('.notification-badge');
    if (!list) return;

    try {
        const res = await fetch('api/alerts');
        const json = await res.json();

        if (json.status === 'success') {
            const alerts = json.data;

            // Update badge
            if (alerts.length > 0) {
                badge.textContent = alerts.length;
                badge.style.display = 'block';
            } else {
                badge.style.display = 'none';
            }

            // Render items
            list.innerHTML = '';
            if (alerts.length === 0) {
                list.innerHTML = '<div class="notification-item">Không có thông báo mới</div>';
                return;
            }


            alerts.forEach(a => {
                const item = document.createElement('div');
                item.className = 'notification-item';

                // Determine icon and color based on alert type
                let icon = '🔔';
                let iconColor = '#6366f1';

                if (a.message.includes('nhiệt độ cao') || a.message.includes('nóng')) {
                    icon = '🌡️';
                    iconColor = '#ef4444';
                } else if (a.message.includes('mưa') || a.message.includes('Mưa')) {
                    icon = '🌧️';
                    iconColor = '#3b82f6';
                } else if (a.message.includes('dữ liệu') || a.message.includes('đồng bộ')) {
                    icon = '📊';
                    iconColor = '#10b981';
                }

                item.innerHTML = `
                    <div style="display: flex; gap: 0.75rem; align-items: start;">
                        <div style="font-size: 1.5rem; flex-shrink: 0; margin-top: 0.125rem;">${icon}</div>
                        <div style="flex: 1; min-width: 0;">
                            <div style="font-weight: 600; font-size: 0.9375rem; color: var(--text-primary); margin-bottom: 0.25rem;">
                                ${a.title || a.zone}
                            </div>
                            <div style="font-size: 0.875rem; color: var(--text-secondary); line-height: 1.4; margin-bottom: 0.375rem;">
                                ${a.message}
                            </div>
                            <div style="font-size: 0.75rem; color: var(--text-tertiary); display: flex; align-items: center; gap: 0.25rem;">
                                <span>⏰</span>
                                <span>${a.time}</span>
                            </div>
                        </div>
                    </div>
                `;
                list.appendChild(item);
            });
        }
    } catch (e) {
        console.error("Failed to load alerts", e);
    }
}

// Khởi tạo chatbot
// Lưu ý: Logic mở/đóng và gửi tin nhắn đã được xử lý trong footer.jsp
// (inline onclick trên chatToggle và hàm smartArjChat).
// initChatbot() để trống để tránh conflict double-toggle.
function initChatbot() {
    // footer.jsp đã xử lý toàn bộ chatbox logic
    // không thêm listener ở đây để tránh toggle 2 lần
}

// Thêm tin nhắn vào chat
function addMessage(text, sender) {
    const chatMessages = document.getElementById('chatMessages');
    if (!chatMessages) return;

    const messageDiv = document.createElement('div');
    messageDiv.className = 'chat-message ' + sender;
    messageDiv.textContent = text;
    chatMessages.appendChild(messageDiv);

    // Scroll xuống cuối
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// === Forecast Functionality (VIP) ===
async function loadForecast(zoneId) {
    const forecastSection = document.getElementById('forecastSection');
    if (!forecastSection) return; // Không phải VIP hoặc lỗi

    if (!zoneId) {
        const zoneInput = document.getElementById('zoneId');
        if (zoneInput && zoneInput.value && zoneInput.value !== 'Loading zones...') {
            zoneId = zoneInput.value;
        }
    }

    if (!zoneId) return; // Chưa chọn zone, chưa load xong

    const elLoading = document.getElementById('forecastLoading');
    const elContainer = document.getElementById('forecastContainer');
    const elGrid = document.getElementById('forecastGrid');

    try {
        // Gọi API
        const response = await fetch('api/forecast?days=7&zoneId=' + zoneId);
        if (!response.ok) throw new Error('API Error: ' + response.status);

        const result = await response.json();
        if (result.status !== 'success') throw new Error(result.message);

        const data = result.data; // Array of forecast days

        // 1. Render Chart
        renderForecastChart(data);

        // 2. Render Grid
        elGrid.innerHTML = '';
        data.forEach(day => {
            const div = document.createElement('div');
            div.className = 'card';
            div.style.padding = '1rem';
            div.style.textAlign = 'center';
            div.style.boxShadow = 'none';
            div.style.border = '1px solid var(--border-color)';

            div.innerHTML = `
                <div style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">${day.date}</div>
                <div style="font-size: 2rem; margin-bottom: 0.5rem;">${day.icon}</div>
                <div style="font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">${day.temperature}°C</div>
                <div style="font-size: 0.75rem; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${day.condition}</div>
            `;
            elGrid.appendChild(div);
        });

        // Show container
        elLoading.style.display = 'none';
        elContainer.style.display = 'block';

    } catch (e) {
        console.error('Forecast error:', e);
        elLoading.innerHTML = '<span style="color: var(--danger)">⚠️ Không thể tải dữ liệu dự báo: ' + e.message + '</span>';
    }
}

function renderForecastChart(data) {
    const ctx = document.getElementById('forecastChart');
    if (!ctx) return;

    const labels = data.map(d => d.date);
    const temps = data.map(d => d.temperature);
    const rains = data.map(d => d.rainfall);

    if (window.forecastChartInstance) {
        window.forecastChartInstance.destroy();
    }

    window.forecastChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Nhiệt độ (°C)',
                    data: temps,
                    borderColor: '#F59E0B',
                    backgroundColor: 'rgba(245, 158, 11, 0.1)',
                    tension: 0.4,
                    yAxisID: 'y',
                    fill: true
                },
                {
                    label: 'Lượng mưa (mm)',
                    data: rains,
                    borderColor: '#3B82F6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    tension: 0.4,
                    yAxisID: 'y1',
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' },
                title: { display: false }
            },
            interaction: {
                mode: 'index',
                intersect: false,
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: { display: true, text: 'Nhiệt độ (°C)' }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    title: { display: true, text: 'Lượng mưa (mm)' },
                    grid: { drawOnChartArea: false }
                }
            }
        }
    });
}


