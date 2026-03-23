import React, { useState } from 'react';
import { login } from '../services/api';
import { Shield, Heart, Users, TrendingUp, Lock, User } from 'lucide-react';
import './Login.css';

function Login({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('MOH_ADMIN');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await login(username, password);
      const userRole = response.user?.role || role;
      onLogin(userRole);
    } catch (err) {
      setError('Invalid credentials. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-left">
        <div className="login-hero">
          <img src="/logo_white.png" alt="Gelmëth Logo" className="hero-logo" />
          <h1>Gelmëth</h1>
          <p className="tagline">Protecting Every Child</p>
          <p className="description">
            Advanced malnutrition surveillance and care pathway management system for South Sudan
          </p>

          <div className="features-grid">
            <div className="feature-item">
              <Heart size={24} />
              <div>
                <h4>Real-time Monitoring</h4>
                <p>Track malnutrition cases instantly</p>
              </div>
            </div>
            <div className="feature-item">
              <Users size={24} />
              <div>
                <h4>Community Care</h4>
                <p>Empowering CHWs and doctors</p>
              </div>
            </div>
            <div className="feature-item">
              <TrendingUp size={24} />
              <div>
                <h4>Data-Driven Insights</h4>
                <p>Analytics for better outcomes</p>
              </div>
            </div>
          </div>

          <div className="stats-row">
            <div className="stat-item">
              <div className="stat-value">10+</div>
              <div className="stat-label">States Covered</div>
            </div>
            <div className="stat-item">
              <div className="stat-value">50+</div>
              <div className="stat-label">Health Facilities</div>
            </div>
            <div className="stat-item">
              <div className="stat-value">1000+</div>
              <div className="stat-label">Children Protected</div>
            </div>
          </div>
        </div>
      </div>

      <div className="login-right">
        <div className="login-box">
          <h2>Welcome Back</h2>
          <p className="login-subtitle">Sign in to access your dashboard</p>

          <form onSubmit={handleSubmit}>
            <div className="input-group">
              <User size={20} className="input-icon" />
              <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>

            <div className="input-group">
              <Lock size={20} className="input-icon" />
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <div className="role-selector">
              <label>Login as:</label>
              <div className="role-options">
                <button
                  type="button"
                  className={`role-option ${role === 'MOH_ADMIN' ? 'active' : ''}`}
                  onClick={() => setRole('MOH_ADMIN')}
                >
                  MoH Admin
                </button>
                <button
                  type="button"
                  className={`role-option ${role === 'DOCTOR' ? 'active' : ''}`}
                  onClick={() => setRole('DOCTOR')}
                >
                  Doctor
                </button>
              </div>
            </div>

            {error && <div className="error-message">{error}</div>}

            <button type="submit" disabled={loading} className="login-button">
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>

          <div className="login-footer">
            <p>Ministry of Health - South Sudan</p>
            <p>Powered by WHO CMAM Guidelines</p>
          </div>

          <div className="copyright-footer">
            <p>© 2026 Gelmëth. All rights reserved.</p>
            <p className="footer-links">
              <a href="/privacy-policy" target="_blank" rel="noopener noreferrer">Privacy Policy & Terms</a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;
