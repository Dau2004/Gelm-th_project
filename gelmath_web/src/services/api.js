import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://100.54.11.150:8000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  console.log('API Request:', config.url, 'Token:', token ? 'Present' : 'Missing');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => {
    console.log('API Response:', response.config.url, 'Status:', response.status);
    return response;
  },
  (error) => {
    console.error('API Error:', error.config?.url, 'Status:', error.response?.status, 'Data:', error.response?.data);
    return Promise.reject(error);
  }
);

export const login = async (username, password) => {
  const response = await axios.post(`${API_URL}/auth/login/`, { username, password });
  const { access, refresh, user } = response.data;
  localStorage.setItem('access_token', access);
  localStorage.setItem('refresh_token', refresh);
  if (user) {
    localStorage.setItem('user_role', user.role);
    localStorage.setItem('user_info', JSON.stringify(user));
  }
  console.log('Tokens saved:', { access: access.substring(0, 20) + '...', refresh: refresh.substring(0, 20) + '...', role: user?.role });
  return response.data;
};

export const logout = () => {
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
};

export const getNationalSummary = () => api.get('/analytics/national-summary/');
export const getStateTrends = () => api.get('/analytics/state-trends/');
export const getTimeSeries = (params) => api.get('/analytics/time-series/', { params });
export const getFacilityStats = (facilityId) => {
  if (facilityId) {
    return api.get(`/analytics/facility/${facilityId}/`);
  }
  // Return all facilities data from facilities endpoint
  return api.get('/facilities/');
};
export const getAssessments = (params) => api.get('/assessments/', { params });
export const getTreatments = (params) => api.get('/treatments/', { params });
export const getUsers = () => api.get('/users/');
export const createUser = (userData) => api.post('/users/', userData);
export const updateUser = (userId, userData) => api.put(`/users/${userId}/`, userData);
export const deleteUser = (userId) => api.delete(`/users/${userId}/`);
export const getCHWAssessmentCounts = () => api.get('/assessments/chw-counts/');
export const resetPassword = (userId, password) => api.post(`/users/${userId}/reset_password/`, { password });
export const getFacilities = () => api.get('/facilities/');
export const getCHWPerformance = () => api.get('/analytics/chw-performance/');
export const getDoctorPerformance = () => api.get('/analytics/doctor-performance/');
export const getReferrals = () => api.get('/referrals/');
export const updateReferralStatus = (referralId, data) => api.patch(`/referrals/${referralId}/`, data);
export const explainPrediction = (assessmentData) => api.post('/assessments/explain/', assessmentData);
export const getForecast = () => api.get('/analytics/forecast/');

export default api;
