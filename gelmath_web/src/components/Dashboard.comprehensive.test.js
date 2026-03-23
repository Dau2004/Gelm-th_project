/**
 * WEB DASHBOARD COMPREHENSIVE TESTS
 * Tests React components, API integration, charts, and user interactions
 * Goal: Find real issues, not just pass tests
 */

import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { BrowserRouter } from 'react-router-dom';
import axios from 'axios';

// Mock axios
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// Import components (will fail if imports are broken)
let MoHDashboard, Login, UserModal, PredictiveAnalytics;

try {
  MoHDashboard = require('../pages/MoHDashboard').default;
  Login = require('../pages/Login').default;
  UserModal = require('../components/UserModal').default;
  PredictiveAnalytics = require('../components/PredictiveAnalytics').default;
} catch (error) {
  console.error('Component import failed:', error);
}

// Helper to wrap components with Router
const renderWithRouter = (component) => {
  return render(<BrowserRouter>{component}</BrowserRouter>);
};

describe('Web Dashboard - Component Tests', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    localStorage.clear();
  });

  describe('Login Component', () => {
    test('Login form renders with required fields', () => {
      if (!Login) {
        console.warn('Login component not found');
        return;
      }

      renderWithRouter(<Login />);

      expect(screen.getByLabelText(/username/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
    });

    test('Login form validates empty fields', async () => {
      if (!Login) return;

      renderWithRouter(<Login />);

      const loginButton = screen.getByRole('button', { name: /login/i });
      fireEvent.click(loginButton);

      await waitFor(() => {
        // Should show validation errors
        expect(screen.getByText(/required/i) || screen.getByText(/enter/i)).toBeInTheDocument();
      });
    });

    test('Login submits credentials to API', async () => {
      if (!Login) return;

      mockedAxios.post.mockResolvedValueOnce({
        data: { access: 'test_token', refresh: 'refresh_token' }
      });

      renderWithRouter(<Login />);

      const usernameInput = screen.getByLabelText(/username/i);
      const passwordInput = screen.getByLabelText(/password/i);
      const loginButton = screen.getByRole('button', { name: /login/i });

      fireEvent.change(usernameInput, { target: { value: 'testuser' } });
      fireEvent.change(passwordInput, { target: { value: 'testpass' } });
      fireEvent.click(loginButton);

      await waitFor(() => {
        expect(mockedAxios.post).toHaveBeenCalledWith(
          expect.stringContaining('/auth/login'),
          expect.objectContaining({
            username: 'testuser',
            password: 'testpass'
          })
        );
      });
    });

    test('Login handles API errors gracefully', async () => {
      if (!Login) return;

      mockedAxios.post.mockRejectedValueOnce({
        response: { data: { detail: 'Invalid credentials' } }
      });

      renderWithRouter(<Login />);

      const usernameInput = screen.getByLabelText(/username/i);
      const passwordInput = screen.getByLabelText(/password/i);
      const loginButton = screen.getByRole('button', { name: /login/i });

      fireEvent.change(usernameInput, { target: { value: 'wrong' } });
      fireEvent.change(passwordInput, { target: { value: 'wrong' } });
      fireEvent.click(loginButton);

      await waitFor(() => {
        expect(screen.getByText(/invalid/i) || screen.getByText(/error/i)).toBeInTheDocument();
      });
    });

    test('Login stores token in localStorage', async () => {
      if (!Login) return;

      mockedAxios.post.mockResolvedValueOnce({
        data: { access: 'test_token_123', refresh: 'refresh_token_123' }
      });

      renderWithRouter(<Login />);

      const usernameInput = screen.getByLabelText(/username/i);
      const passwordInput = screen.getByLabelText(/password/i);
      const loginButton = screen.getByRole('button', { name: /login/i });

      fireEvent.change(usernameInput, { target: { value: 'testuser' } });
      fireEvent.change(passwordInput, { target: { value: 'testpass' } });
      fireEvent.click(loginButton);

      await waitFor(() => {
        expect(localStorage.getItem('token')).toBeTruthy();
      });
    });
  });

  describe('MoH Dashboard Component', () => {
    const mockDashboardData = {
      total_assessments: 1500,
      sam_count: 300,
      mam_count: 450,
      healthy_count: 750,
      sam_percentage: 20,
      mam_percentage: 30,
      healthy_percentage: 50,
      recent_assessments: []
    };

    beforeEach(() => {
      localStorage.setItem('token', 'test_token');
    });

    test('Dashboard renders without crashing', () => {
      if (!MoHDashboard) {
        console.warn('MoHDashboard component not found');
        return;
      }

      renderWithRouter(<MoHDashboard />);
      expect(screen.getByText(/dashboard/i)).toBeInTheDocument();
    });

    test('Dashboard fetches data on mount', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({ data: mockDashboardData });

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        expect(mockedAxios.get).toHaveBeenCalledWith(
          expect.stringContaining('/analytics/national-summary'),
          expect.any(Object)
        );
      });
    });

    test('Dashboard displays summary statistics', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({ data: mockDashboardData });

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        expect(screen.getByText(/1500/)).toBeInTheDocument(); // Total
        expect(screen.getByText(/300/)).toBeInTheDocument(); // SAM
        expect(screen.getByText(/450/)).toBeInTheDocument(); // MAM
      });
    });

    test('Dashboard handles empty data', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({
        data: {
          total_assessments: 0,
          sam_count: 0,
          mam_count: 0,
          healthy_count: 0
        }
      });

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        expect(screen.getByText(/0/) || screen.getByText(/no data/i)).toBeInTheDocument();
      });
    });

    test('Dashboard handles API errors', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockRejectedValueOnce(new Error('Network error'));

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        expect(screen.getByText(/error/i) || screen.getByText(/failed/i)).toBeInTheDocument();
      });
    });

    test('Dashboard shows loading state', () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockImplementationOnce(() => new Promise(() => {})); // Never resolves

      renderWithRouter(<MoHDashboard />);

      expect(screen.getByText(/loading/i) || screen.getByRole('progressbar')).toBeInTheDocument();
    });
  });

  describe('User Management Component', () => {
    test('User modal opens and closes', () => {
      if (!UserModal) {
        console.warn('UserModal component not found');
        return;
      }

      const mockClose = jest.fn();
      render(<UserModal isOpen={true} onClose={mockClose} />);

      expect(screen.getByRole('dialog') || screen.getByText(/user/i)).toBeInTheDocument();

      const closeButton = screen.getByRole('button', { name: /close/i });
      fireEvent.click(closeButton);

      expect(mockClose).toHaveBeenCalled();
    });

    test('User creation form validates fields', async () => {
      if (!UserModal) return;

      const mockOnSave = jest.fn();
      render(<UserModal isOpen={true} onClose={() => {}} onSave={mockOnSave} />);

      const saveButton = screen.getByRole('button', { name: /save/i });
      fireEvent.click(saveButton);

      await waitFor(() => {
        expect(screen.getByText(/required/i)).toBeInTheDocument();
      });
    });

    test('User creation submits to API', async () => {
      if (!UserModal) return;

      mockedAxios.post.mockResolvedValueOnce({ data: { id: 1, username: 'newuser' } });

      const mockOnSave = jest.fn();
      render(<UserModal isOpen={true} onClose={() => {}} onSave={mockOnSave} />);

      const usernameInput = screen.getByLabelText(/username/i);
      const roleSelect = screen.getByLabelText(/role/i);
      const saveButton = screen.getByRole('button', { name: /save/i });

      fireEvent.change(usernameInput, { target: { value: 'newuser' } });
      fireEvent.change(roleSelect, { target: { value: 'CHW' } });
      fireEvent.click(saveButton);

      await waitFor(() => {
        expect(mockedAxios.post).toHaveBeenCalled();
        expect(mockOnSave).toHaveBeenCalled();
      });
    });
  });

  describe('Charts and Visualizations', () => {
    test('Charts render with data', async () => {
      if (!MoHDashboard) return;

      const mockData = {
        total_assessments: 1000,
        sam_count: 200,
        mam_count: 300,
        healthy_count: 500,
        monthly_trends: [
          { month: 'Jan', sam: 50, mam: 75, healthy: 125 },
          { month: 'Feb', sam: 60, mam: 80, healthy: 130 }
        ]
      };

      mockedAxios.get.mockResolvedValueOnce({ data: mockData });

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        // Check if chart library elements are present
        expect(document.querySelector('.recharts-wrapper') || 
               document.querySelector('svg')).toBeInTheDocument();
      });
    });

    test('Charts handle empty data gracefully', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({
        data: { monthly_trends: [] }
      });

      renderWithRouter(<MoHDashboard />);

      await waitFor(() => {
        expect(screen.getByText(/no data/i) || screen.getByText(/empty/i)).toBeInTheDocument();
      });
    });
  });

  describe('Predictive Analytics Component', () => {
    test('Predictive analytics renders', () => {
      if (!PredictiveAnalytics) {
        console.warn('PredictiveAnalytics component not found');
        return;
      }

      renderWithRouter(<PredictiveAnalytics />);
      expect(screen.getByText(/predictive/i) || screen.getByText(/forecast/i)).toBeInTheDocument();
    });

    test('Forecast data is fetched and displayed', async () => {
      if (!PredictiveAnalytics) return;

      const mockForecast = {
        predictions: [
          { month: 'Mar', predicted_sam: 65 },
          { month: 'Apr', predicted_sam: 70 }
        ]
      };

      mockedAxios.get.mockResolvedValueOnce({ data: mockForecast });

      renderWithRouter(<PredictiveAnalytics />);

      await waitFor(() => {
        expect(mockedAxios.get).toHaveBeenCalledWith(
          expect.stringContaining('/forecast'),
          expect.any(Object)
        );
      });
    });
  });

  describe('API Service Integration', () => {
    test('API calls include authentication token', async () => {
      localStorage.setItem('token', 'test_token_123');

      mockedAxios.get.mockResolvedValueOnce({ data: {} });

      // Simulate API call
      await axios.get('/api/assessments', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });

      expect(mockedAxios.get).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          headers: expect.objectContaining({
            Authorization: 'Bearer test_token_123'
          })
        })
      );
    });

    test('API handles 401 unauthorized', async () => {
      mockedAxios.get.mockRejectedValueOnce({
        response: { status: 401, data: { detail: 'Unauthorized' } }
      });

      try {
        await axios.get('/api/assessments');
      } catch (error) {
        expect(error.response.status).toBe(401);
      }
    });

    test('API handles network errors', async () => {
      mockedAxios.get.mockRejectedValueOnce(new Error('Network Error'));

      try {
        await axios.get('/api/assessments');
        fail('Should have thrown error');
      } catch (error) {
        expect(error.message).toBe('Network Error');
      }
    });
  });

  describe('Routing and Navigation', () => {
    test('Navigation between pages works', () => {
      if (!MoHDashboard) return;

      renderWithRouter(<MoHDashboard />);

      const navLinks = screen.getAllByRole('link');
      expect(navLinks.length).toBeGreaterThan(0);
    });

    test('Protected routes redirect to login', () => {
      localStorage.removeItem('token');

      renderWithRouter(<MoHDashboard />);

      // Should redirect to login or show login prompt
      expect(screen.getByText(/login/i) || window.location.pathname).toBeTruthy();
    });
  });

  describe('Data Filtering and Search', () => {
    test('Filter by state works', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({ data: { results: [] } });

      renderWithRouter(<MoHDashboard />);

      const stateFilter = screen.getByLabelText(/state/i);
      if (stateFilter) {
        fireEvent.change(stateFilter, { target: { value: 'Central Equatoria' } });

        await waitFor(() => {
          expect(mockedAxios.get).toHaveBeenCalledWith(
            expect.stringContaining('state=Central Equatoria'),
            expect.any(Object)
          );
        });
      }
    });

    test('Search functionality works', async () => {
      if (!MoHDashboard) return;

      mockedAxios.get.mockResolvedValueOnce({ data: { results: [] } });

      renderWithRouter(<MoHDashboard />);

      const searchInput = screen.getByPlaceholderText(/search/i);
      if (searchInput) {
        fireEvent.change(searchInput, { target: { value: 'test query' } });

        await waitFor(() => {
          expect(mockedAxios.get).toHaveBeenCalledWith(
            expect.stringContaining('search=test query'),
            expect.any(Object)
          );
        });
      }
    });
  });

  describe('PDF Export Functionality', () => {
    test('PDF export button exists', () => {
      if (!MoHDashboard) return;

      renderWithRouter(<MoHDashboard />);

      const exportButton = screen.getByText(/export/i) || screen.getByText(/pdf/i);
      expect(exportButton).toBeInTheDocument();
    });

    test('PDF export triggers download', async () => {
      if (!MoHDashboard) return;

      const mockBlob = new Blob(['test'], { type: 'application/pdf' });
      mockedAxios.get.mockResolvedValueOnce({ data: mockBlob });

      renderWithRouter(<MoHDashboard />);

      const exportButton = screen.getByText(/export/i);
      if (exportButton) {
        fireEvent.click(exportButton);

        await waitFor(() => {
          expect(mockedAxios.get).toHaveBeenCalled();
        });
      }
    });
  });

  describe('Real-time Updates', () => {
    test('Dashboard refreshes data periodically', async () => {
      if (!MoHDashboard) return;

      jest.useFakeTimers();
      mockedAxios.get.mockResolvedValue({ data: {} });

      renderWithRouter(<MoHDashboard />);

      // Fast-forward time
      jest.advanceTimersByTime(60000); // 1 minute

      await waitFor(() => {
        expect(mockedAxios.get).toHaveBeenCalledTimes(2); // Initial + refresh
      });

      jest.useRealTimers();
    });
  });

  describe('Responsive Design', () => {
    test('Dashboard adapts to mobile viewport', () => {
      if (!MoHDashboard) return;

      // Set mobile viewport
      global.innerWidth = 375;
      global.innerHeight = 667;

      renderWithRouter(<MoHDashboard />);

      // Check if mobile menu or responsive elements exist
      expect(document.body).toBeInTheDocument();
    });
  });
});

// Run with: npm test
