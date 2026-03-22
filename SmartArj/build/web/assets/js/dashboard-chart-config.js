/** dashboard-chart-config.js — Metric color palette & labels */

const METRIC_CONFIG = {
  temperature: { color: '#EF4444', bg: 'rgba(239,68,68,.12)',  point: '#EF4444' },
  humidity:    { color: '#3B82F6', bg: 'rgba(59,130,246,.12)', point: '#3B82F6' },
  rainfall:    { color: '#0EA5E9', bg: 'rgba(14,165,233,.12)', point: '#0EA5E9' },
  wind:        { color: '#8B5CF6', bg: 'rgba(139,92,246,.12)', point: '#8B5CF6' },
  radiation:   { color: '#F59E0B', bg: 'rgba(245,158,11,.12)', point: '#F59E0B' }
};

const METRIC_LABELS = {
  temperature: 'Nhiệt độ (°C)',
  humidity:    'Độ ẩm (%)',
  rainfall:    'Lượng mưa (mm)',
  wind:        'Gió (km/h)',
  radiation:   'Bức xạ (W/m²)'
};
