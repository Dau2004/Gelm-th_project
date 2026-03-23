import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from './contexts/ThemeContext';
import Login from './pages/Login';
import MoHDashboard from './pages/MoHDashboard';
import DoctorDashboard from './pages/DoctorDashboard';
import PrivacyPolicy from './pages/PrivacyPolicy';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userRole, setUserRole] = useState('MOH_ADMIN'); // Default role

  useEffect(() => {
    const token = localStorage.getItem('access_token');
    const role = localStorage.getItem('user_role') || 'MOH_ADMIN';
    setIsAuthenticated(!!token);
    setUserRole(role);
  }, []);

  const handleLogin = (role = 'MOH_ADMIN') => {
    console.log('Login handler called, checking token...');
    const token = localStorage.getItem('access_token');
    console.log('Token after login:', token ? 'Present' : 'Missing');
    setIsAuthenticated(true);
    setUserRole(role);
    localStorage.setItem('user_role', role);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    localStorage.removeItem('access_token');
    localStorage.removeItem('user_role');
  };

  return (
    <ThemeProvider>
      <Router>
        <div className="App">
          <Routes>
            <Route path="/privacy-policy" element={<PrivacyPolicy />} />
            <Route 
              path="/login" 
              element={
                !isAuthenticated ? (
                  <Login onLogin={handleLogin} />
                ) : (
                  <Navigate to={userRole === 'DOCTOR' ? '/doctor' : '/moh'} replace />
                )
              } 
            />
            <Route 
              path="/moh" 
              element={
                isAuthenticated && userRole === 'MOH_ADMIN' ? (
                  <MoHDashboard onLogout={handleLogout} />
                ) : (
                  <Navigate to="/login" replace />
                )
              } 
            />
            <Route 
              path="/doctor" 
              element={
                isAuthenticated && userRole === 'DOCTOR' ? (
                  <DoctorDashboard onLogout={handleLogout} />
                ) : (
                  <Navigate to="/login" replace />
                )
              } 
            />
            <Route 
              path="/" 
              element={
                <Navigate to={isAuthenticated ? (userRole === 'DOCTOR' ? '/doctor' : '/moh') : '/login'} replace />
              } 
            />
          </Routes>
        </div>
      </Router>
    </ThemeProvider>
  );
}

export default App;
