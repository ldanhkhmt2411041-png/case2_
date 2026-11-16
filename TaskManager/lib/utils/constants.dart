// Cau hinh URL API:
// - Khi chay tren Web / Windows Desktop: dung 'http://localhost:5000/api'
// - Khi chay tren Android Emulator: doi thanh 'http://10.0.2.2:5000/api'
// - Khi may khac/dien thoai that ket noi qua mang Wi-Fi/LAN: doi thanh 'http://<IP_MAY_TINH>:5000/api'
const String baseUrl = 'http://localhost:5000/api';

const priorityLabels = {
  'low': 'Thấp',
  'medium': 'Trung bình',
  'high': 'Cao',
};

const statusLabels = {
  'todo': 'Chưa thực hiện',
  'in_progress': 'Đang thực hiện',
  'completed': 'Đã hoàn thành',
};
