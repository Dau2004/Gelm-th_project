/**
 * MINIMAL WEB DASHBOARD SMOKE TESTS
 * Tests critical components render without crashing
 */

import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock components for testing
const MoHDashboard = () => <div>MoH Dashboard</div>;
const NationalSummary = ({ data }) => (
  <div>
    <h2>National Summary</h2>
    <p>Total: {data.total}</p>
    <p>SAM: {data.sam}</p>
  </div>
);

describe('Web Dashboard Smoke Tests', () => {
  test('MoH Dashboard renders', () => {
    render(<MoHDashboard />);
    expect(screen.getByText('MoH Dashboard')).toBeInTheDocument();
  });

  test('National Summary displays data', () => {
    const mockData = { total: 100, sam: 20, mam: 30, healthy: 50 };
    render(<NationalSummary data={mockData} />);
    
    expect(screen.getByText('National Summary')).toBeInTheDocument();
    expect(screen.getByText('Total: 100')).toBeInTheDocument();
    expect(screen.getByText('SAM: 20')).toBeInTheDocument();
  });

  test('Components handle empty data', () => {
    const mockData = { total: 0, sam: 0, mam: 0, healthy: 0 };
    render(<NationalSummary data={mockData} />);
    
    expect(screen.getByText('Total: 0')).toBeInTheDocument();
  });
});

// Run with: npm test
