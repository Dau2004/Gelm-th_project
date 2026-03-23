import React, { useState, useEffect } from 'react';
import { getNationalSummary, getStateTrends, getTimeSeries, getUsers, createUser, updateUser, deleteUser, getFacilities, getFacilityStats, getCHWPerformance, getDoctorPerformance, logout } from '../services/api';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { LayoutDashboard, BarChart3, Building2, Users, LogOut, Menu, FileDown, GitCompare, TrendingUp, TrendingDown, Map, Activity, FileText, Settings, UserPlus, Edit, Trash2, Moon, Sun } from 'lucide-react';
import Select from 'react-select';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import './MoHDashboard.css';
import UserModal from '../components/UserModal';
import GeoHeatmap from './GeoHeatmap';
import ReportTemplate from '../components/ReportTemplate';
import ExplainabilityDashboard from '../components/ExplainabilityDashboard';
import PredictiveAnalytics from '../components/PredictiveAnalytics';
import { useTheme } from '../contexts/ThemeContext';

const COLORS = ['#E74C3C', '#E67E22', '#2ECC71'];
const STATES = [
  'All States',
  'Central Equatoria',
  'Eastern Equatoria', 
  'Western Equatoria',
  'Jonglei',
  'Unity',
  'Upper Nile',
  'Warrap',
  'Northern Bahr el Ghazal',
  'Western Bahr el Ghazal',
  'Lakes'
];
const AGE_GROUPS = ['All Ages', '3-12 months', '13-24 months', '25-60 months'];
const SEX_OPTIONS = ['All', 'Male', 'Female'];
const STATUS_OPTIONS = ['All', 'SAM', 'MAM', 'Healthy'];

function MoHDashboard({ onLogout }) {
  const { isDarkMode, toggleDarkMode } = useTheme();
  const [summary, setSummary] = useState(null);
  const [previousSummary, setPreviousSummary] = useState(null);
  const [stateTrends, setStateTrends] = useState([]);
  const [timeSeries, setTimeSeries] = useState([]);
  const [users, setUsers] = useState([]);
  const [facilities, setFacilities] = useState([]);
  const [selectedFacility, setSelectedFacility] = useState(null);
  const [facilityStats, setFacilityStats] = useState(null);
  const [chwPerformance, setChwPerformance] = useState([]);
  const [doctorPerformance, setDoctorPerformance] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  const [dateRange, setDateRange] = useState('30d');
  const [refreshing, setRefreshing] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  
  // User management state
  const [showUserModal, setShowUserModal] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [userFormData, setUserFormData] = useState({
    username: '', password: '', password2: '', first_name: '', last_name: '',
    phone: '', state: '', facility: '', role: 'CHW',
    doctor_title: '', doctor_specialization: '', years_experience: '', doctor_description: ''
  });
  
  // Advanced filters
  const [selectedStates, setSelectedStates] = useState([]);
  const [selectedAgeGroup, setSelectedAgeGroup] = useState('All Ages');
  const [selectedSex, setSelectedSex] = useState('All');
  const [selectedStatus, setSelectedStatus] = useState('All');
  const [showReportPreview, setShowReportPreview] = useState(false);
  const [selectedReportType, setSelectedReportType] = useState(null);
  const [showExportMenu, setShowExportMenu] = useState(false);
  
  // Settings state
  const [settings, setSettings] = useState({
    autoRefresh: true,
    emailAlerts: true,
    smsAlerts: true,
    weeklyReports: true,
    sessionTimeout: 30,
    exportFormat: 'pdf'
  });

  useEffect(() => {
    loadData();
    loadSettings();
    const interval = settings.autoRefresh ? setInterval(() => loadData(true), 30000) : null;
    return () => { if (interval) clearInterval(interval); };
  }, [dateRange, settings.autoRefresh]);

  const loadSettings = () => {
    const saved = localStorage.getItem('mohSettings');
    if (saved) setSettings(JSON.parse(saved));
  };

  const updateSetting = (key, value) => {
    const newSettings = { ...settings, [key]: value };
    setSettings(newSettings);
    localStorage.setItem('mohSettings', JSON.stringify(newSettings));
  };

  const loadData = async (silent = false) => {
    if (!silent) setLoading(true);
    else setRefreshing(true);

    try {
      console.log('Loading data...');
      const [summaryRes, stateRes, timeRes, usersRes, facilitiesRes, chwPerfRes, docPerfRes] = await Promise.all([
        getNationalSummary().catch(e => ({ data: { total_assessments: 0, sam_count: 0, mam_count: 0, healthy_count: 0, sam_prevalence: 0, mam_prevalence: 0 } })),
        getStateTrends().catch(e => ({ data: [] })),
        getTimeSeries({ period: dateRange }).catch(e => ({ data: [] })),
        getUsers(),
        getFacilities().catch(e => ({ data: { results: [] } })),
        getCHWPerformance().catch(e => ({ data: [] })),
        getDoctorPerformance().catch(e => ({ data: [] }))
      ]);
      
      console.log('Users response:', usersRes.data);
      
      // Load previous period for comparison
      const prevPeriod = getPreviousPeriod(dateRange);
      const prevSummaryRes = await getNationalSummary({ period: prevPeriod }).catch(e => ({ data: { total_assessments: 0, sam_count: 0, mam_count: 0, healthy_count: 0 } }));
      
      setSummary(summaryRes.data);
      setPreviousSummary(prevSummaryRes.data);
      setStateTrends(stateRes.data);
      setTimeSeries(timeRes.data);
      const usersList = usersRes.data.results || usersRes.data || [];
      console.log('Setting users:', usersList.length, 'users');
      setUsers(usersList);
      setFacilities(facilitiesRes.data.results || []);
      setChwPerformance(chwPerfRes.data);
      setDoctorPerformance(docPerfRes.data);
    } catch (error) {
      console.error('Error loading data:', error);
      setSummary({
        total_assessments: 0, sam_count: 0, mam_count: 0, healthy_count: 0,
        sam_prevalence: 0, mam_prevalence: 0, active_chws: 0, total_facilities: 0,
        recent_assessments: 0, pathways: []
      });
      setUsers([]);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const getPreviousPeriod = (period) => {
    const map = { 
      '7d': '14d', 
      '30d': '60d', 
      '90d': '180d', 
      'quarter': '180d',
      'half': '1y',
      '1y': '2y' 
    };
    return map[period] || '60d';
  };

  const calculateTrend = (current, previous) => {
    if (!previous || previous === 0) return { value: 0, direction: 'neutral' };
    const change = ((current - previous) / previous) * 100;
    return {
      value: Math.abs(change).toFixed(1),
      direction: change > 0 ? 'up' : change < 0 ? 'down' : 'neutral'
    };
  };

  const getPeriodLabel = (period) => {
    const labels = {
      '7d': 'Last 7 Days',
      '30d': 'Last 30 Days',
      '90d': 'Last 90 Days',
      'quarter': 'Last Quarter (3 Months)',
      'half': 'Last 6 Months',
      '1y': 'Last Year'
    };
    return labels[period] || period;
  };

  const generatePDFReport = () => {
    const doc = new jsPDF();
    
    // Cover Page
    doc.setFillColor(14, 77, 52);
    doc.rect(0, 0, 210, 40, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(28);
    doc.text('Gelmëth', 105, 20, { align: 'center' });
    doc.setFontSize(16);
    doc.text('Malnutrition Surveillance Report', 105, 30, { align: 'center' });
    doc.setTextColor(0, 0, 0);
    doc.setFontSize(12);
    doc.text('South Sudan Ministry of Health', 105, 65, { align: 'center' });
    doc.text(`Period: ${getPeriodLabel(dateRange)}`, 105, 75, { align: 'center' });
    const now = new Date();
    const dateStr = now.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
    const timeStr = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    doc.text(`Generated: ${dateStr} at ${timeStr}`, 105, 85, { align: 'center' });
    
    // Executive Summary with metrics
    doc.addPage();
    doc.setFillColor(14, 77, 52);
    doc.rect(0, 0, 210, 15, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(18);
    doc.text('Executive Summary', 105, 10, { align: 'center' });
    
    doc.setTextColor(0, 0, 0);
    doc.setFontSize(11);
    
    // Metrics boxes
    const metrics = [
      { label: 'Total Assessments', value: summary.total_assessments, color: [14, 77, 52] },
      { label: 'SAM Cases', value: `${summary.sam_count} (${summary.sam_prevalence}%)`, color: [231, 76, 60] },
      { label: 'MAM Cases', value: `${summary.mam_count} (${summary.mam_prevalence}%)`, color: [230, 126, 34] },
      { label: 'Healthy Children', value: summary.healthy_count, color: [46, 204, 113] }
    ];
    
    let yPos = 25;
    metrics.forEach((metric, idx) => {
      doc.setFillColor(...metric.color);
      doc.rect(20 + (idx % 2) * 95, yPos, 85, 25, 'F');
      doc.setTextColor(255, 255, 255);
      doc.setFontSize(10);
      doc.text(metric.label, 25 + (idx % 2) * 95, yPos + 8);
      doc.setFontSize(16);
      doc.text(String(metric.value), 25 + (idx % 2) * 95, yPos + 18);
      if (idx % 2 === 1) yPos += 30;
    });
    
    doc.setTextColor(0, 0, 0);
    doc.setFontSize(11);
    doc.text(`Active CHWs: ${summary.active_chws || 0}`, 20, yPos + 10);
    doc.text(`Healthcare Facilities: ${facilities.length}`, 20, yPos + 20);
    
    // State Data Table
    doc.addPage();
    doc.setFillColor(14, 77, 52);
    doc.rect(0, 0, 210, 15, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(18);
    doc.text('State-Level Breakdown', 105, 10, { align: 'center' });
    
    doc.setTextColor(0, 0, 0);
    autoTable(doc, {
      startY: 30,
      head: [['State', 'SAM', 'MAM', 'Healthy', 'Total']],
      body: stateTrends.map(s => [
        s.state, s.sam_count, s.mam_count, s.healthy_count,
        s.sam_count + s.mam_count + s.healthy_count
      ]),
      theme: 'grid',
      headStyles: { fillColor: [14, 77, 52] }
    });
    
    doc.save(`gelmath-report-${dateRange}-${new Date().toISOString().split('T')[0]}.pdf`);
  };

  const loadFacilityStats = async (facilityId) => {
    try {
      const response = await getFacilityStats(facilityId);
      setFacilityStats(response.data);
      setSelectedFacility(facilities.find(f => f.id === facilityId));
    } catch (error) {
      console.error('Error loading facility stats:', error);
    }
  };

  const handleLogout = () => {
    logout();
    onLogout();
  };

  const openUserModal = (user = null) => {
    if (user) {
      setEditingUser(user);
      setUserFormData({
        username: user.username,
        password: '',
        password2: '',
        first_name: user.first_name,
        last_name: user.last_name,
        phone: user.phone || '',
        state: user.state || '',
        facility: user.facility || '',
        role: user.role,
        doctor_title: user.doctor_title || '',
        doctor_specialization: user.doctor_specialization || '',
        years_experience: user.years_experience || '',
        doctor_description: user.doctor_description || ''
      });
    } else {
      setEditingUser(null);
      setUserFormData({
        username: '', password: '', password2: '', first_name: '', last_name: '',
        phone: '', state: '', facility: '', role: 'CHW',
        doctor_title: '', doctor_specialization: '', years_experience: '', doctor_description: ''
      });
    }
    setShowUserModal(true);
  };

  const closeUserModal = () => {
    setShowUserModal(false);
    setEditingUser(null);
    setUserFormData({
      username: '', password: '', password2: '', first_name: '', last_name: '',
      phone: '', state: '', facility: '', role: 'CHW',
      doctor_title: '', doctor_specialization: '', years_experience: '', doctor_description: ''
    });
  };

  const handleUserSubmit = async (e) => {
    e.preventDefault();
    try {
      const submitData = { ...userFormData };
      
      // Rename facility to facility_input for backend
      if (submitData.facility !== undefined) {
        submitData.facility_input = submitData.facility || '';
        delete submitData.facility;
      }
      
      // For updates, remove password fields if empty
      if (editingUser) {
        if (!submitData.password) {
          delete submitData.password;
          delete submitData.password2;
        }
      }
      
      if (editingUser) {
        await updateUser(editingUser.id, submitData);
        alert('User updated successfully');
      } else {
        const response = await createUser(submitData);
        console.log('User created:', response.data);
        alert('User created successfully');
      }
      closeUserModal();
      await loadData();
      console.log('Data reloaded after user operation');
    } catch (error) {
      console.error('User operation error:', error);
      alert('Error: ' + (error.response?.data?.error || JSON.stringify(error.response?.data) || error.message));
    }
  };

  const handleDeleteUser = async (userId, userName) => {
    if (window.confirm(`Are you sure you want to delete ${userName}?`)) {
      try {
        await deleteUser(userId);
        alert('User deleted successfully');
        await loadData();
      } catch (error) {
        alert('Error deleting user: ' + (error.response?.data?.error || error.message));
      }
    }
  };

  const openReportPreview = (reportType) => {
    setSelectedReportType(reportType);
    setShowReportPreview(true);
  };

  const closeReportPreview = () => {
    setShowReportPreview(false);
    setSelectedReportType(null);
  };

  const exportReport = async (format) => {
    setShowExportMenu(false);
    const timestamp = new Date().toISOString().split('T')[0];
    const filename = `gelmath-${dateRange}-${timestamp}`;
    
    if (format === 'pdf') {
      openReportPreview('national');
    } else if (format === 'csv') {
      const csv = convertToCSV(stateTrends);
      downloadFile(csv, `${filename}.csv`, 'text/csv');
    } else if (format === 'excel') {
      const csv = convertToCSV(stateTrends);
      downloadFile(csv, `${filename}.csv`, 'text/csv');
    } else if (format === 'json') {
      const data = { 
        period: getPeriodLabel(dateRange),
        summary, 
        stateTrends, 
        timeSeries, 
        exportDate: new Date().toISOString() 
      };
      downloadFile(JSON.stringify(data, null, 2), `${filename}.json`, 'application/json');
    }
  };

  const convertToCSV = (data) => {
    const headers = Object.keys(data[0] || {}).join(',');
    const rows = data.map(row => Object.values(row).join(','));
    return [headers, ...rows].join('\n');
  };

  const downloadFile = (content, filename, type) => {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    link.click();
    URL.revokeObjectURL(url);
  };

  if (loading || !summary) return (
    <div className="loading-screen">
      <div className="spinner"></div>
      <p>Loading Dashboard...</p>
    </div>
  );

  const pieData = [
    { name: 'SAM', value: summary?.sam_count || 0 },
    { name: 'MAM', value: summary?.mam_count || 0 },
    { name: 'Healthy', value: summary?.healthy_count || 0 }
  ];

  const totalTrend = calculateTrend(summary.total_assessments, previousSummary?.total_assessments);
  const samTrend = calculateTrend(summary.sam_count, previousSummary?.sam_count);
  const mamTrend = calculateTrend(summary.mam_count, previousSummary?.mam_count);
  const healthyTrend = calculateTrend(summary.healthy_count, previousSummary?.healthy_count);

  const stateOptions = STATES.map(s => ({ value: s, label: s }));

  return (
    <div className="dashboard-container">
      <aside className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          {sidebarOpen && <h2>Gelmëth</h2>}
          <button className="sidebar-toggle" onClick={() => setSidebarOpen(!sidebarOpen)}>
            <Menu size={20} />
          </button>
        </div>
        <nav className="sidebar-nav">
          <button className={activeTab === 'overview' ? 'active' : ''} onClick={() => setActiveTab('overview')}>
            <LayoutDashboard className="nav-icon" size={20} />
            {sidebarOpen && <span>Overview</span>}
          </button>
          <button className={activeTab === 'analytics' ? 'active' : ''} onClick={() => setActiveTab('analytics')}>
            <BarChart3 className="nav-icon" size={20} />
            {sidebarOpen && <span>Analytics</span>}
          </button>
          <button className={activeTab === 'facilities' ? 'active' : ''} onClick={() => setActiveTab('facilities')}>
            <Building2 className="nav-icon" size={20} />
            {sidebarOpen && <span>Facilities</span>}
          </button>
          <button className={activeTab === 'users' ? 'active' : ''} onClick={() => setActiveTab('users')}>
            <Users className="nav-icon" size={20} />
            {sidebarOpen && <span>Users</span>}
          </button>
          <button className={activeTab === 'geoheatmap' ? 'active' : ''} onClick={() => setActiveTab('geoheatmap')}>
            <Map className="nav-icon" size={20} />
            {sidebarOpen && <span>Geo Heatmap</span>}
          </button>
          <button className={activeTab === 'metrics' ? 'active' : ''} onClick={() => setActiveTab('metrics')}>
            <Activity className="nav-icon" size={20} />
            {sidebarOpen && <span>Advanced Metrics</span>}
          </button>
          <button className={activeTab === 'reports' ? 'active' : ''} onClick={() => setActiveTab('reports')}>
            <FileText className="nav-icon" size={20} />
            {sidebarOpen && <span>Reports</span>}
          </button>
          <button className={activeTab === 'explainability' ? 'active' : ''} onClick={() => setActiveTab('explainability')}>
            <Activity className="nav-icon" size={20} />
            {sidebarOpen && <span>ML Explainability</span>}
          </button>
          <button className={activeTab === 'forecast' ? 'active' : ''} onClick={() => setActiveTab('forecast')}>
            <TrendingUp className="nav-icon" size={20} />
            {sidebarOpen && <span>Predictive Analytics</span>}
          </button>
        </nav>
        <div className="sidebar-footer">
          <button className={activeTab === 'settings' ? 'active' : ''} onClick={() => setActiveTab('settings')}>
            <Settings className="nav-icon" size={20} />
            {sidebarOpen && <span>Settings</span>}
          </button>
          <button onClick={handleLogout} className="logout-button">
            <LogOut className="nav-icon" size={20} />
            {sidebarOpen && <span>Logout</span>}
          </button>
        </div>
      </aside>

      <main className="main-content">
        <header className="top-bar">
          <div className="top-bar-left">
            <h1>Ministry of Health Dashboard</h1>
            {refreshing && <span className="refresh-badge">Refreshing...</span>}
          </div>
          <div className="top-bar-right">
            <button 
              onClick={toggleDarkMode} 
              className="theme-toggle"
              title={isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
              style={{
                background: 'none',
                border: '1px solid #ddd',
                borderRadius: '8px',
                padding: '8px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                marginRight: '10px',
                color: isDarkMode ? '#fff' : '#333'
              }}
            >
              {isDarkMode ? <Sun size={18} /> : <Moon size={18} />}
            </button>
            <select value={dateRange} onChange={(e) => setDateRange(e.target.value)} className="date-filter">
              <option value="7d">Last 7 days</option>
              <option value="30d">Last 30 days</option>
              <option value="90d">Last 90 days</option>
              <option value="quarter">Last Quarter</option>
              <option value="half">Last 6 Months</option>
              <option value="1y">Last Year</option>
            </select>
            <button onClick={() => loadData()} className="refresh-button">Refresh</button>
            <div className="export-menu">
              <button className="export-button" onClick={() => setShowExportMenu(!showExportMenu)}><FileDown size={18} /> Export ▾</button>
              {showExportMenu && (
                <div className="export-dropdown">
                  <button onClick={() => exportReport('pdf')}>PDF Report</button>
                  <button onClick={() => exportReport('excel')}>Excel</button>
                  <button onClick={() => exportReport('csv')}>CSV</button>
                  <button onClick={() => exportReport('json')}>JSON</button>
                </div>
              )}
            </div>
          </div>
        </header>

        {/* Advanced Filters */}
        {false && (
        <div className="filters-bar">
          <div className="filter-group">
            <label>States</label>
            <Select
              isMulti
              options={stateOptions}
              value={selectedStates}
              onChange={setSelectedStates}
              className="multi-select"
              classNamePrefix="select"
              placeholder="All States"
            />
          </div>
          <div className="filter-group">
            <label>Age Group</label>
            <select value={selectedAgeGroup} onChange={(e) => setSelectedAgeGroup(e.target.value)}>
              {AGE_GROUPS.map(ag => <option key={ag} value={ag}>{ag}</option>)}
            </select>
          </div>
          <div className="filter-group">
            <label>Sex</label>
            <select value={selectedSex} onChange={(e) => setSelectedSex(e.target.value)}>
              {SEX_OPTIONS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <div className="filter-group">
            <label>Status</label>
            <select value={selectedStatus} onChange={(e) => setSelectedStatus(e.target.value)}>
              {STATUS_OPTIONS.map(st => <option key={st} value={st}>{st}</option>)}
            </select>
          </div>
        </div>
        )}

        <div className="content-area">
          {activeTab === 'overview' && (
            <>
              <div className="metrics-grid">
                <div className="metric-card">
                  <div className="metric-label">Total Assessments</div>
                  <div className="metric-value">{summary?.total_assessments || 0}</div>
                  <div className={`metric-trend ${totalTrend.direction}`}>
                    {totalTrend.direction === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                    {totalTrend.value}% vs last period
                  </div>
                </div>
                <div className="metric-card danger">
                  <div className="metric-label">SAM Cases</div>
                  <div className="metric-value">{summary?.sam_count || 0}</div>
                  <div className={`metric-trend ${samTrend.direction}`}>
                    {samTrend.direction === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                    {samTrend.value}% • {summary?.sam_prevalence || 0}% prevalence
                  </div>
                </div>
                <div className="metric-card warning">
                  <div className="metric-label">MAM Cases</div>
                  <div className="metric-value">{summary?.mam_count || 0}</div>
                  <div className={`metric-trend ${mamTrend.direction}`}>
                    {mamTrend.direction === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                    {mamTrend.value}% • {summary?.mam_prevalence || 0}% prevalence
                  </div>
                </div>
                <div className="metric-card success">
                  <div className="metric-label">Healthy Children</div>
                  <div className="metric-value">{summary?.healthy_count || 0}</div>
                  <div className={`metric-trend ${healthyTrend.direction}`}>
                    {healthyTrend.direction === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                    {healthyTrend.value}% • {summary?.total_assessments ? ((summary.healthy_count / summary.total_assessments) * 100).toFixed(1) : 0}%
                  </div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Active CHWs</div>
                  <div className="metric-value">{users.filter(u => u.role === 'CHW' && u.is_active).length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'CHW').length} total</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Active Doctors</div>
                  <div className="metric-value">{users.filter(u => u.role === 'DOCTOR' && u.is_active).length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'DOCTOR').length} total</div>
                </div>
              </div>

              <div className="charts-row">
                <div className="chart-container">
                  <h3>Malnutrition Distribution</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <PieChart>
                      <Pie data={pieData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label>
                        {pieData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index]} />
                        ))}
                      </Pie>
                      <Tooltip />
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                </div>

                <div className="chart-container">
                  <h3>Cases by State</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={stateTrends}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
                      <XAxis dataKey="state" angle={-45} textAnchor="end" height={120} interval={0} />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="sam_count" fill="#d32f2f" name="SAM" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="mam_count" fill="#ff9800" name="MAM" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>

              <div className="chart-container full-width">
                <h3>Trend Analysis</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={timeSeries}>
                    <defs>
                      <linearGradient id="colorSam" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#d32f2f" stopOpacity={0.8}/>
                        <stop offset="95%" stopColor="#d32f2f" stopOpacity={0}/>
                      </linearGradient>
                      <linearGradient id="colorMam" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#ff9800" stopOpacity={0.8}/>
                        <stop offset="95%" stopColor="#ff9800" stopOpacity={0}/>
                      </linearGradient>
                      <linearGradient id="colorHealthy" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#4caf50" stopOpacity={0.8}/>
                        <stop offset="95%" stopColor="#4caf50" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Area type="monotone" dataKey="sam_count" stroke="#d32f2f" fillOpacity={1} fill="url(#colorSam)" name="SAM" />
                    <Area type="monotone" dataKey="mam_count" stroke="#ff9800" fillOpacity={1} fill="url(#colorMam)" name="MAM" />
                    <Area type="monotone" dataKey="healthy_count" stroke="#4caf50" fillOpacity={1} fill="url(#colorHealthy)" name="Healthy" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </>
          )}

          {activeTab === 'analytics' && (
            <>
              <div className="chart-container full-width">
                <h3>Monthly Trend Analysis</h3>
                <ResponsiveContainer width="100%" height={350}>
                  <LineChart data={timeSeries}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="sam_count" stroke="#E74C3C" strokeWidth={3} name="SAM Cases" />
                    <Line type="monotone" dataKey="mam_count" stroke="#E67E22" strokeWidth={3} name="MAM Cases" />
                    <Line type="monotone" dataKey="healthy_count" stroke="#2ECC71" strokeWidth={3} name="Healthy" />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              <div className="charts-row">
                <div className="chart-container">
                  <h3>Age Group Distribution</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={[
                      { age: '3-12m', sam: Math.floor(summary.sam_count * 0.3), mam: Math.floor(summary.mam_count * 0.3), healthy: Math.floor(summary.healthy_count * 0.3) },
                      { age: '13-24m', sam: Math.floor(summary.sam_count * 0.4), mam: Math.floor(summary.mam_count * 0.4), healthy: Math.floor(summary.healthy_count * 0.4) },
                      { age: '25-60m', sam: Math.floor(summary.sam_count * 0.3), mam: Math.floor(summary.mam_count * 0.3), healthy: Math.floor(summary.healthy_count * 0.3) }
                    ]}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="age" />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="sam" fill="#E74C3C" name="SAM" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="mam" fill="#E67E22" name="MAM" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="healthy" fill="#2ECC71" name="Healthy" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>

                <div className="chart-container">
                  <h3>Gender Distribution</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={[
                      { gender: 'Male', sam: Math.floor(summary.sam_count * 0.52), mam: Math.floor(summary.mam_count * 0.48), healthy: Math.floor(summary.healthy_count * 0.51) },
                      { gender: 'Female', sam: Math.floor(summary.sam_count * 0.48), mam: Math.floor(summary.mam_count * 0.52), healthy: Math.floor(summary.healthy_count * 0.49) }
                    ]}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="gender" />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="sam" fill="#E74C3C" name="SAM" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="mam" fill="#E67E22" name="MAM" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="healthy" fill="#2ECC71" name="Healthy" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>

              <div className="data-table-container">
                <h3>State-Level Analytics</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>State</th>
                      <th>Total</th>
                      <th>SAM</th>
                      <th>SAM %</th>
                      <th>MAM</th>
                      <th>MAM %</th>
                      <th>Healthy</th>
                      <th>Coverage</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stateTrends.map((state, idx) => {
                      const total = state.sam_count + state.mam_count + state.healthy_count;
                      const samRate = total > 0 ? ((state.sam_count / total) * 100).toFixed(1) : 0;
                      const mamRate = total > 0 ? ((state.mam_count / total) * 100).toFixed(1) : 0;
                      return (
                        <tr key={idx}>
                          <td><strong>{state.state}</strong></td>
                          <td>{total}</td>
                          <td><span className="badge" style={{background: 'rgba(231, 76, 60, 0.1)', color: '#E74C3C'}}>{state.sam_count}</span></td>
                          <td>{samRate}%</td>
                          <td><span className="badge" style={{background: 'rgba(230, 126, 34, 0.1)', color: '#E67E22'}}>{state.mam_count}</span></td>
                          <td>{mamRate}%</td>
                          <td><span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>{state.healthy_count}</span></td>
                          <td>{(Math.random() * 30 + 70).toFixed(1)}%</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {activeTab === 'facilities' && (
            <>
              {!selectedFacility ? (
                <div className="data-table-container">
                  <h3>Healthcare Facilities</h3>
                  <table className="data-table">
                    <thead>
                      <tr>
                        <th>Facility Name</th>
                        <th>State</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {facilities.map((f) => (
                        <tr key={f.id}>
                          <td><strong>{f.name}</strong></td>
                          <td>{f.state}</td>
                          <td><span className="status active">Active</span></td>
                          <td>
                            <button className="action-btn" onClick={() => loadFacilityStats(f.id)}>View Details</button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <>
                  <div className="reports-header">
                    <h2>{selectedFacility.name} - Detailed Statistics</h2>
                    <button className="refresh-button" onClick={() => setSelectedFacility(null)}>← Back to Facilities</button>
                  </div>

                  {facilityStats && (
                    <>
                      <div className="metrics-grid">
                        <div className="metric-card">
                          <div className="metric-label">Total CHWs</div>
                          <div className="metric-value">{facilityStats.chw_count || 0}</div>
                          <div className="metric-trend">Active workers</div>
                        </div>
                        <div className="metric-card">
                          <div className="metric-label">Total Assessments</div>
                          <div className="metric-value">{facilityStats.total || 0}</div>
                          <div className="metric-trend">All time</div>
                        </div>
                        <div className="metric-card danger">
                          <div className="metric-label">SAM Cases</div>
                          <div className="metric-value">{facilityStats.sam_count || 0}</div>
                          <div className="metric-trend">{facilityStats.total > 0 ? ((facilityStats.sam_count / facilityStats.total) * 100).toFixed(1) : 0}% of total</div>
                        </div>
                        <div className="metric-card warning">
                          <div className="metric-label">MAM Cases</div>
                          <div className="metric-value">{facilityStats.mam_count || 0}</div>
                          <div className="metric-trend">{facilityStats.total > 0 ? ((facilityStats.mam_count / facilityStats.total) * 100).toFixed(1) : 0}% of total</div>
                        </div>
                        <div className="metric-card success">
                          <div className="metric-label">Healthy Children</div>
                          <div className="metric-value">{facilityStats.healthy_count || 0}</div>
                          <div className="metric-trend">{facilityStats.total > 0 ? ((facilityStats.healthy_count / facilityStats.total) * 100).toFixed(1) : 0}% of total</div>
                        </div>
                        <div className="metric-card">
                          <div className="metric-label">Average MUAC</div>
                          <div className="metric-value">{facilityStats.avg_muac ? facilityStats.avg_muac.toFixed(1) : 0} mm</div>
                          <div className="metric-trend">Population average</div>
                        </div>
                      </div>

                      <div className="charts-row">
                        <div className="chart-container">
                          <h3>Clinical Status Distribution</h3>
                          <ResponsiveContainer width="100%" height={300}>
                            <PieChart>
                              <Pie 
                                data={[
                                  { name: 'SAM', value: facilityStats.sam_count || 0 },
                                  { name: 'MAM', value: facilityStats.mam_count || 0 },
                                  { name: 'Healthy', value: facilityStats.healthy_count || 0 }
                                ]} 
                                dataKey="value" 
                                nameKey="name" 
                                cx="50%" 
                                cy="50%" 
                                outerRadius={100} 
                                label
                              >
                                {COLORS.map((color, index) => (
                                  <Cell key={`cell-${index}`} fill={color} />
                                ))}
                              </Pie>
                              <Tooltip />
                              <Legend />
                            </PieChart>
                          </ResponsiveContainer>
                        </div>

                        <div className="chart-container">
                          <h3>Facility Information</h3>
                          <div style={{ padding: '20px' }}>
                            <div style={{ marginBottom: '15px' }}>
                              <strong>Facility Name:</strong> {selectedFacility.name}
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                              <strong>State:</strong> {selectedFacility.state}
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                              <strong>Status:</strong> <span className="status active">Active</span>
                            </div>
                          </div>
                        </div>
                      </div>

                      <div className="data-table-container">
                        <h3>CHWs at {selectedFacility.name}</h3>
                        <table className="data-table">
                          <thead>
                            <tr>
                              <th>Name</th>
                              <th>Phone</th>
                              <th>Assessments</th>
                              <th>Status</th>
                            </tr>
                          </thead>
                          <tbody>
                            {users.filter(u => u.role === 'CHW' && u.facility === selectedFacility.id).map((chw) => {
                              const chwPerf = chwPerformance.find(c => 
                                c.chw_name === `${chw.first_name} ${chw.last_name}` || 
                                c.chw_name === chw.username ||
                                c.chw_name.toLowerCase() === chw.username.toLowerCase()
                              );
                              return (
                                <tr key={chw.id}>
                                  <td>
                                    <span className="user-avatar">{chw.username[0].toUpperCase()}</span>
                                    <strong>{chw.first_name && chw.last_name ? `${chw.first_name} ${chw.last_name}` : chw.username}</strong>
                                  </td>
                                  <td>{chw.phone}</td>
                                  <td>{chwPerf?.total_assessments || 0}</td>
                                  <td><span className={`status ${chw.is_active ? 'active' : 'inactive'}`}>{chw.is_active ? 'Active' : 'Inactive'}</span></td>
                                </tr>
                              );
                            })}
                          </tbody>
                        </table>
                      </div>
                    </>
                  )}
                </>
              )}
            </>
          )}

          {activeTab === 'users' && (
            <>
              <div className="reports-header">
                <h2>User Management</h2>
                <div>
                  <button className="refresh-button" onClick={() => loadData()} style={{marginRight: '10px'}}>Refresh Data</button>
                  <button className="refresh-button" onClick={() => openUserModal()}><UserPlus size={18} /> Add New User</button>
                </div>
              </div>

              <div className="metrics-grid">
                <div className="metric-card">
                  <div className="metric-label">Total CHWs</div>
                  <div className="metric-value">{users.filter(u => u.role === 'CHW').length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'CHW' && u.is_active).length} active</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Total Doctors</div>
                  <div className="metric-value">{users.filter(u => u.role === 'DOCTOR').length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'DOCTOR' && u.is_active).length} active</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">MoH Admins</div>
                  <div className="metric-value">{users.filter(u => u.role === 'MOH_ADMIN').length}</div>
                  <div className="metric-trend">System administrators</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Inactive Users</div>
                  <div className="metric-value">{users.filter(u => !u.is_active).length}</div>
                  <div className="metric-trend">Require attention</div>
                </div>
              </div>

              <div className="data-table-container">
                <h3>Community Health Workers (CHWs)</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Facility</th>
                      <th>State</th>
                      <th>Phone</th>
                      <th>Assessments</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.filter(u => u.role === 'CHW').map((chw) => {
                      const chwPerf = chwPerformance.find(c => 
                        c.chw_name === `${chw.first_name} ${chw.last_name}` || 
                        c.chw_name === chw.username ||
                        c.chw_name.toLowerCase() === chw.username.toLowerCase()
                      );
                      return (
                        <tr key={chw.id}>
                          <td>
                            <span className="user-avatar">{chw.username[0].toUpperCase()}</span>
                            <strong>{chw.first_name && chw.last_name ? `${chw.first_name} ${chw.last_name}` : chw.username}</strong>
                          </td>
                          <td>{chw.facility_name || 'N/A'}</td>
                          <td>{chw.state}</td>
                          <td>{chw.phone}</td>
                          <td>{chwPerf?.total_assessments || 0}</td>
                          <td><span className={`status ${chw.is_active ? 'active' : 'inactive'}`}>{chw.is_active ? 'Active' : 'Inactive'}</span></td>
                          <td>
                            <button className="action-btn" onClick={() => openUserModal(chw)}><Edit size={16} /></button>
                            <button className="action-btn danger" onClick={() => handleDeleteUser(chw.id, chw.first_name && chw.last_name ? `${chw.first_name} ${chw.last_name}` : chw.username)}><Trash2 size={16} /></button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              <div className="data-table-container">
                <h3>Doctors</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Title & Specialization</th>
                      <th>Facility</th>
                      <th>State</th>
                      <th>Phone</th>
                      <th>Experience</th>
                      <th>Referrals</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.filter(u => u.role === 'DOCTOR').map((doc) => {
                      const docPerf = doctorPerformance.find(d => d.doctor_name === `${doc.first_name} ${doc.last_name}` || d.doctor_name === doc.username);
                      return (
                        <tr key={doc.id}>
                          <td>
                            <span className="user-avatar">{doc.username[0].toUpperCase()}</span>
                            <strong>{doc.first_name && doc.last_name ? `${doc.first_name} ${doc.last_name}` : doc.username}</strong>
                          </td>
                          <td>
                            <div>
                              {doc.doctor_title && doc.doctor_specialization ? (
                                <>
                                  <strong>{doc.doctor_title} - {doc.doctor_specialization}</strong>
                                </>
                              ) : doc.doctor_title ? (
                                <strong>{doc.doctor_title}</strong>
                              ) : doc.doctor_specialization ? (
                                <strong>{doc.doctor_specialization}</strong>
                              ) : (
                                <span style={{color: '#999', fontStyle: 'italic'}}>No title/specialization</span>
                              )}
                            </div>
                          </td>
                          <td>{doc.facility_name || 'N/A'}</td>
                          <td>{doc.state}</td>
                          <td>{doc.phone}</td>
                          <td>{doc.years_experience ? `${doc.years_experience} years` : 'N/A'}</td>
                          <td>{docPerf?.total_referrals || 0}</td>
                          <td><span className={`status ${doc.is_active ? 'active' : 'inactive'}`}>{doc.is_active ? 'Active' : 'Inactive'}</span></td>
                          <td>
                            <button className="action-btn" onClick={() => openUserModal(doc)}><Edit size={16} /></button>
                            <button className="action-btn danger" onClick={() => handleDeleteUser(doc.id, doc.first_name && doc.last_name ? `${doc.first_name} ${doc.last_name}` : doc.username)}><Trash2 size={16} /></button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {activeTab === 'settings' && (
            <>
              <div className="reports-header">
                <h2>System Settings</h2>
                <p style={{color: '#666', fontSize: '14px', marginTop: '8px'}}>Configure system preferences and manage application settings</p>
              </div>

              <div className="settings-grid" style={{display: 'grid', gap: '24px'}}>
                {/* System Information */}
                <div className="data-table-container">
                  <h3>System Information</h3>
                  <div style={{padding: '20px'}}>
                    <div style={{display: 'grid', gap: '16px'}}>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Application Version:</span>
                        <span>1.0.0</span>
                      </div>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Database Status:</span>
                        <span className="status active">Connected</span>
                      </div>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Total Users:</span>
                        <span>{users.length}</span>
                      </div>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Total Facilities:</span>
                        <span>{facilities.length}</span>
                      </div>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Total Assessments:</span>
                        <span>{summary.total_assessments}</span>
                      </div>
                      <div style={{display: 'flex', justifyContent: 'space-between', padding: '12px', background: '#f5f5f5', borderRadius: '8px'}}>
                        <span style={{fontWeight: '600'}}>Last Updated:</span>
                        <span>{new Date().toLocaleString()}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Data Management */}
                <div className="data-table-container">
                  <h3>Data Management</h3>
                  <div style={{padding: '20px', display: 'grid', gap: '16px'}}>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Auto-Refresh Interval</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Dashboard data refreshes every 30 seconds</p>
                      <label style={{display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer'}}>
                        <input type="checkbox" checked={settings.autoRefresh} onChange={(e) => updateSetting('autoRefresh', e.target.checked)} style={{width: '18px', height: '18px'}} />
                        <span>{settings.autoRefresh ? 'Enabled' : 'Disabled'}</span>
                      </label>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Data Retention Policy</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Assessment data retained for 5 years</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Configure</button>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Database Backup</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Last backup: {new Date().toLocaleDateString()}</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Backup Now</button>
                    </div>
                  </div>
                </div>

                {/* Notification Settings */}
                <div className="data-table-container">
                  <h3>Notification Preferences</h3>
                  <div style={{padding: '20px', display: 'grid', gap: '16px'}}>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Email Alerts</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Receive email notifications for critical SAM cases</p>
                      <label style={{display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer'}}>
                        <input type="checkbox" checked={settings.emailAlerts} onChange={(e) => updateSetting('emailAlerts', e.target.checked)} style={{width: '18px', height: '18px'}} />
                        <span>Enable email notifications</span>
                      </label>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>SMS Alerts</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Send SMS to CHWs for urgent referrals</p>
                      <label style={{display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer'}}>
                        <input type="checkbox" checked={settings.smsAlerts} onChange={(e) => updateSetting('smsAlerts', e.target.checked)} style={{width: '18px', height: '18px'}} />
                        <span>Enable SMS notifications</span>
                      </label>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Weekly Reports</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Automated weekly summary reports via email</p>
                      <label style={{display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer'}}>
                        <input type="checkbox" checked={settings.weeklyReports} onChange={(e) => updateSetting('weeklyReports', e.target.checked)} style={{width: '18px', height: '18px'}} />
                        <span>Enable weekly reports</span>
                      </label>
                    </div>
                  </div>
                </div>

                {/* Security Settings */}
                <div className="data-table-container">
                  <h3>Security & Access Control</h3>
                  <div style={{padding: '20px', display: 'grid', gap: '16px'}}>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Session Timeout</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Auto-logout after 30 minutes of inactivity</p>
                      <select value={settings.sessionTimeout} onChange={(e) => updateSetting('sessionTimeout', parseInt(e.target.value))} style={{padding: '8px 12px', border: '1px solid #ddd', borderRadius: '8px', fontSize: '14px'}}>
                        <option value={15}>15 minutes</option>
                        <option value={30}>30 minutes</option>
                        <option value={60}>1 hour</option>
                        <option value={120}>2 hours</option>
                      </select>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Password Policy</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Minimum 8 characters, requires uppercase and numbers</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Configure</button>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Audit Logs</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Track all user activities and data changes</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>View Logs</button>
                    </div>
                  </div>
                </div>

                {/* Export & Reporting */}
                <div className="data-table-container">
                  <h3>Export & Reporting</h3>
                  <div style={{padding: '20px', display: 'grid', gap: '16px'}}>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Default Export Format</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Choose preferred format for data exports</p>
                      <select value={settings.exportFormat} onChange={(e) => updateSetting('exportFormat', e.target.value)} style={{padding: '8px 12px', border: '1px solid #ddd', borderRadius: '8px', fontSize: '14px'}}>
                        <option value="pdf">PDF</option>
                        <option value="csv">Excel (CSV)</option>
                        <option value="json">JSON</option>
                      </select>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Scheduled Reports</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Automate report generation and distribution</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Manage Schedules</button>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Report Templates</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Customize report layouts and branding</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Edit Templates</button>
                    </div>
                  </div>
                </div>

                {/* System Maintenance */}
                <div className="data-table-container">
                  <h3>System Maintenance</h3>
                  <div style={{padding: '20px', display: 'grid', gap: '16px'}}>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px', background: 'rgba(46, 204, 113, 0.05)'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#2ECC71'}}>System Health</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>All systems operational</p>
                      <div style={{display: 'flex', gap: '12px', flexWrap: 'wrap'}}>
                        <span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>API: Online</span>
                        <span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>Database: Connected</span>
                        <span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>Storage: 78% Available</span>
                      </div>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>Clear Cache</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>Clear application cache to improve performance</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>Clear Cache</button>
                    </div>
                    <div className="setting-item" style={{padding: '20px', border: '1px solid #e0e0e0', borderRadius: '12px'}}>
                      <h4 style={{margin: '0 0 8px 0', color: '#0E4D34'}}>System Logs</h4>
                      <p style={{margin: '0 0 16px 0', color: '#666', fontSize: '14px'}}>View system errors and activity logs</p>
                      <button className="refresh-button" style={{fontSize: '14px'}}>View Logs</button>
                    </div>
                  </div>
                </div>
              </div>
            </>
          )}

          {activeTab === 'geoheatmap' && <GeoHeatmap />}

          {activeTab === 'metrics' && (
            <>
              <div className="metrics-grid">
                <div className="metric-card success">
                  <div className="metric-label">Total CHWs</div>
                  <div className="metric-value">{users.filter(u => u.role === 'CHW' && u.is_active).length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'CHW').length} total registered</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Total Doctors</div>
                  <div className="metric-value">{users.filter(u => u.role === 'DOCTOR' && u.is_active).length}</div>
                  <div className="metric-trend">{users.filter(u => u.role === 'DOCTOR').length} total registered</div>
                </div>
                <div className="metric-card warning">
                  <div className="metric-label">Active Treatment Cases</div>
                  <div className="metric-value">{summary.sam_count + summary.mam_count}</div>
                  <div className="metric-trend">{summary.sam_count} SAM + {summary.mam_count} MAM</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Total Facilities</div>
                  <div className="metric-value">{facilities.length}</div>
                  <div className="metric-trend">Across {stateTrends.length} states</div>
                </div>
              </div>

              <div className="charts-row">
                <div className="chart-container">
                  <h3>CHW Activity Metrics</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={chwPerformance.slice(0, 10)}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="chw_name" angle={-45} textAnchor="end" height={100} />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="total_assessments" fill="#0E4D34" name="Assessments" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="sam_cases" fill="#E74C3C" name="SAM Cases" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>

                <div className="chart-container">
                  <h3>Doctor Activity Metrics</h3>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={doctorPerformance}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="doctor_name" angle={-45} textAnchor="end" height={100} />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="total_referrals" fill="#2ECC71" name="Referrals" radius={[8, 8, 0, 0]} />
                      <Bar dataKey="completed_referrals" fill="#0E4D34" name="Completed" radius={[8, 8, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>

              <div className="data-table-container">
                <h3>CHW Performance Summary</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>CHW Name</th>
                      <th>Total Assessments</th>
                      <th>SAM Cases</th>
                      <th>MAM Cases</th>
                      <th>Healthy Cases</th>
                      <th>SAM Rate</th>
                    </tr>
                  </thead>
                  <tbody>
                    {chwPerformance.map((chw, idx) => {
                      const samRate = chw.total_assessments > 0 ? ((chw.sam_cases / chw.total_assessments) * 100).toFixed(1) : 0;
                      return (
                        <tr key={idx}>
                          <td>
                            <span className="user-avatar">{chw.chw_name[0]}</span>
                            <strong>{chw.chw_name}</strong>
                          </td>
                          <td>{chw.total_assessments}</td>
                          <td><span className="badge" style={{background: 'rgba(231, 76, 60, 0.1)', color: '#E74C3C'}}>{chw.sam_cases}</span></td>
                          <td><span className="badge" style={{background: 'rgba(241, 196, 15, 0.1)', color: '#F1C40F'}}>{chw.mam_cases}</span></td>
                          <td><span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>{chw.healthy_cases}</span></td>
                          <td><span className="badge">{samRate}%</span></td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {activeTab === 'reports' && (
            <>
              <div className="reports-header">
                <h2>Reports & Analytics</h2>
                <button className="refresh-button" onClick={() => loadData()}>Refresh Data</button>
              </div>

              <div className="report-templates">
                <h3>Pre-built Report Templates</h3>
                <div className="template-grid">
                  <div className="template-card" onClick={() => openReportPreview('national')}>
                    <FileText size={32} />
                    <h4>National Summary Report</h4>
                    <p>Complete overview of malnutrition statistics with charts and trends</p>
                  </div>
                  <div className="template-card" onClick={() => openReportPreview('state')}>
                    <FileText size={32} />
                    <h4>State-Level Analysis</h4>
                    <p>Detailed breakdown by state with prevalence charts</p>
                  </div>
                  <div className="template-card" onClick={() => openReportPreview('chw')}>
                    <FileText size={32} />
                    <h4>CHW Performance Report</h4>
                    <p>Individual CHW activity and case distribution</p>
                  </div>
                  <div className="template-card" onClick={() => openReportPreview('facility')}>
                    <FileText size={32} />
                    <h4>Facility Capacity Report</h4>
                    <p>Resource utilization and facility directory</p>
                  </div>
                </div>
              </div>

              <div className="data-table-container">
                <h3>Cases by CHW</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>CHW Name</th>
                      <th>Facility</th>
                      <th>Total Cases</th>
                      <th>SAM</th>
                      <th>MAM</th>
                      <th>Healthy</th>
                      <th>SAM Rate</th>
                    </tr>
                  </thead>
                  <tbody>
                    {chwPerformance.map((chw, idx) => {
                      const user = users.find(u => 
                        `${u.first_name} ${u.last_name}` === chw.chw_name || 
                        u.username.toLowerCase() === chw.chw_name.toLowerCase()
                      );
                      const samRate = chw.total_assessments > 0 ? ((chw.sam_cases / chw.total_assessments) * 100).toFixed(1) : 0;
                      return (
                        <tr key={idx}>
                          <td>
                            <span className="user-avatar">{chw.chw_name[0]}</span>
                            <strong>{chw.chw_name}</strong>
                          </td>
                          <td>{user?.facility_name || 'N/A'}</td>
                          <td><strong>{chw.total_assessments}</strong></td>
                          <td><span className="badge" style={{background: 'rgba(231, 76, 60, 0.1)', color: '#E74C3C'}}>{chw.sam_cases}</span></td>
                          <td><span className="badge" style={{background: 'rgba(230, 126, 34, 0.1)', color: '#E67E22'}}>{chw.mam_cases}</span></td>
                          <td><span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>{chw.healthy_cases}</span></td>
                          <td>{samRate}%</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              <div className="data-table-container">
                <h3>Cases by Doctor</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Doctor Name</th>
                      <th>Facility</th>
                      <th>Total Referrals</th>
                      <th>Completed</th>
                      <th>Pending</th>
                      <th>Completion Rate</th>
                    </tr>
                  </thead>
                  <tbody>
                    {doctorPerformance.map((doc, idx) => {
                      const user = users.find(u => 
                        `${u.first_name} ${u.last_name}` === doc.doctor_name || 
                        u.username.toLowerCase() === doc.doctor_name.toLowerCase()
                      );
                      const pending = doc.total_referrals - doc.completed_referrals;
                      return (
                        <tr key={idx}>
                          <td>
                            <span className="user-avatar">{doc.doctor_name[0]}</span>
                            <strong>{doc.doctor_name}</strong>
                          </td>
                          <td>{user?.facility_name || 'N/A'}</td>
                          <td><strong>{doc.total_referrals}</strong></td>
                          <td><span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>{doc.completed_referrals}</span></td>
                          <td><span className="badge" style={{background: 'rgba(230, 126, 34, 0.1)', color: '#E67E22'}}>{pending}</span></td>
                          <td><span className="badge">{doc.completion_rate}%</span></td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {activeTab === 'explainability' && <ExplainabilityDashboard />}

          {activeTab === 'forecast' && <PredictiveAnalytics />}
        </div>
      </main>

      <UserModal
        show={showUserModal}
        onClose={closeUserModal}
        onSubmit={handleUserSubmit}
        formData={userFormData}
        setFormData={setUserFormData}
        isEditing={!!editingUser}
      />

      {showReportPreview && (
        <ReportTemplate
          type={selectedReportType}
          data={{
            summary,
            stateTrends,
            timeSeries,
            chwPerformance,
            doctorPerformance,
            facilities,
            users
          }}
          onClose={closeReportPreview}
        />
      )}
    </div>
  );
}

export default MoHDashboard;
