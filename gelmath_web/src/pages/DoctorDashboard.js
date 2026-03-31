import React, { useState, useEffect } from 'react';
import { getReferrals, updateReferralStatus, logout } from '../services/api';
import { LayoutDashboard, FileText, Users, Calendar, LogOut, Menu, Download, Save, CheckCircle, XCircle, AlertTriangle, MapPin, Building2, User, Phone, Clipboard, Moon, Sun } from 'lucide-react';
import './DoctorDashboard.css';
import { useTheme } from '../contexts/ThemeContext';

function DoctorDashboard({ onLogout }) {
  const { isDarkMode, toggleDarkMode } = useTheme();
  const [activeTab, setActiveTab] = useState('referrals');
  const [referrals, setReferrals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedReferral, setSelectedReferral] = useState(null);
  const [filter, setFilter] = useState('pending');
  const [sidebarOpen, setSidebarOpen] = useState(window.innerWidth > 768);
  const [prescription, setPrescription] = useState('');
  const [doctorNotes, setDoctorNotes] = useState('');
  const [doctorSignature, setDoctorSignature] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadReferrals();
  }, []);

  const loadReferrals = async () => {
    try {
      setLoading(true);
      const response = await getReferrals();
      const data = response.data.results || response.data;
      setReferrals(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error('Error loading referrals:', error);
      setReferrals([]);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (referralId, status, notes) => {
    try {
      await updateReferralStatus(referralId, { 
        status: status.toUpperCase(), 
        doctor_notes: notes || doctorNotes,
        prescription: prescription,
        doctor_signature: doctorSignature
      });
      await loadReferrals();
      setSelectedReferral(null);
      setPrescription('');
      setDoctorNotes('');
      setDoctorSignature('');
    } catch (error) {
      console.error('Error updating referral:', error);
      alert('Failed to update referral status');
    }
  };

  const handleLogout = () => {
    logout();
    onLogout();
  };

  const handleDownloadPDF = () => {
    const printWindow = window.open('', '_blank');
    const content = document.getElementById('medical-document-content');
    
    printWindow.document.write(`
      <html>
        <head>
          <title>Medical Document - ${selectedReferral.child_id}</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 48px 64px; max-width: 900px; margin: 0 auto; background: #ffffff; }
            .header { background: linear-gradient(135deg, #2D5F3F 0%, #1A3A28 100%); padding: 40px 32px; text-align: center; color: white; border-radius: 16px; margin-bottom: 40px; box-shadow: 0 8px 16px rgba(0,0,0,0.15); border: 1px solid rgba(255,255,255,0.1); }
            .header h1 { margin: 12px 0 8px 0; letter-spacing: 1.5px; font-size: 20px; }
            .header p { margin: 0; font-size: 12px; opacity: 0.7; }
            .section { margin-bottom: 32px; background: #FEFFFE; padding: 24px; border-radius: 12px; border: 1px solid #F0F9F4; }
            .section-title { color: #2D5F3F; font-size: 14px; font-weight: bold; letter-spacing: 1px; margin-bottom: 12px; border-bottom: 2px solid #2D5F3F; padding-bottom: 4px; }
            .field { display: flex; margin-bottom: 12px; }
            .field-label { width: 140px; font-size: 13px; color: #666; font-weight: 500; }
            .field-value { flex: 1; padding: 8px 12px; background: #f5f5f5; border-radius: 8px; border: 1px solid #ddd; font-size: 13px; }
            .highlight { background: rgba(45, 95, 63, 0.1); border: 2px solid #2D5F3F; font-weight: bold; }
            .alert { padding: 12px; background: #fef3c7; border-radius: 8px; border: 1px solid #fbbf24; font-size: 13px; margin-top: 12px; }
            .notes-box { padding: 12px; background: #fff3cd; border-radius: 8px; border: 1px solid #ffc107; font-size: 13px; line-height: 1.6; white-space: pre-wrap; }
            .signature-box { padding: 28px; background: #F9FAFB; border-radius: 12px; border: 2px solid #D1D5DB; margin-top: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
            .signature-line { border-bottom: 2px solid #000; padding: 8px 0; margin-top: 8px; font-style: italic; min-height: 24px; }
            hr { border: none; border-top: 3px solid #E0F2E7; margin: 40px 0; border-radius: 2px; }
            @media print { 
              body { padding: 40px 60px; margin: 0; }
              .section { break-inside: avoid; }
              .header { break-inside: avoid; }
            }
          </style>
        </head>
        <body>
          ${content.innerHTML}
        </body>
      </html>
    `);
    
    printWindow.document.close();
    setTimeout(() => {
      printWindow.print();
    }, 250);
  };

  const filteredReferrals = referrals.filter(r => 
    filter === 'all' ? true : r.status?.toLowerCase() === filter
  );

  return (
    <div className="doctor-dashboard">
      {sidebarOpen && (
        <div className="sidebar-overlay" onClick={() => setSidebarOpen(false)} />
      )}
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
          <button className={activeTab === 'referrals' ? 'active' : ''} onClick={() => setActiveTab('referrals')}>
            <FileText className="nav-icon" size={20} />
            {sidebarOpen && <span>Referrals</span>}
          </button>
          <button className={activeTab === 'patients' ? 'active' : ''} onClick={() => setActiveTab('patients')}>
            <Users className="nav-icon" size={20} />
            {sidebarOpen && <span>Patients</span>}
          </button>
          <button className={activeTab === 'schedule' ? 'active' : ''} onClick={() => setActiveTab('schedule')}>
            <Calendar className="nav-icon" size={20} />
            {sidebarOpen && <span>Schedule</span>}
          </button>
        </nav>
        <div className="sidebar-footer">
          <button onClick={handleLogout} className="logout-button">
            <LogOut className="nav-icon" size={20} />
            {sidebarOpen && <span>Logout</span>}
          </button>
        </div>
      </aside>

      <main className="main-content">
        <header className="top-bar">
          <div className="top-bar-left">
            <button className="mobile-menu-btn" onClick={() => setSidebarOpen(!sidebarOpen)}>
              <Menu size={20} />
            </button>
            <h1>Doctor Dashboard</h1>
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
            <button onClick={() => loadReferrals()} className="refresh-button">Refresh</button>
          </div>
        </header>

        <div className="content-area">
          {activeTab === 'referrals' && (
            <>
              <div className="filters-bar">
                {['pending', 'accepted', 'in_progress', 'completed', 'all'].map(status => (
                  <button
                    key={status}
                    onClick={() => setFilter(status)}
                    className={`filter-select ${filter === status ? 'active' : ''}`}
                  >
                    {status.replace('_', ' ').toUpperCase()} ({referrals.filter(r => status === 'all' || r.status?.toLowerCase() === status).length})
                  </button>
                ))}
              </div>

              {loading ? (
                <div className="loading-screen">
                  <div className="spinner"></div>
                  <p>Loading referrals...</p>
                </div>
              ) : filteredReferrals.length === 0 ? (
                <div className="empty-state">
                  <p>No referrals found</p>
                </div>
              ) : (
                <div className="referrals-grid">
                  {filteredReferrals.map(referral => (
                    <div key={referral.id} className="referral-card">
                      <div className="referral-header">
                        <span className={`priority-badge priority-${referral.status?.toLowerCase() === 'pending' ? 'high' : referral.status?.toLowerCase() === 'in_progress' ? 'medium' : 'low'}`}>
                          {referral.status?.replace('_', ' ').toUpperCase() || 'UNKNOWN'}
                        </span>
                        <span className="referral-date">
                          {new Date(referral.created_at).toLocaleDateString()}
                        </span>
                      </div>
                      
                      <div className="referral-body">
                        <h4>{referral.child_id}</h4>
                        <span className={`pathway-badge pathway-${referral.pathway?.toLowerCase() || 'sc_itp'}`}>
                          {referral.pathway || 'SC_ITP'}
                        </span>
                        
                        <div className="referral-detail">
                          <strong>CHW:</strong> {referral.chw_name}
                        </div>
                        <div className="referral-detail">
                          <strong>Facility:</strong> {referral.chw_facility}
                        </div>
                        {referral.notes && (
                          <div className="referral-detail" style={{ marginTop: '12px', padding: '12px', background: '#FEF3C7', borderRadius: '8px', fontSize: '12px' }}>
                            <strong>Notes:</strong> {referral.notes}
                          </div>
                        )}
                      </div>

                      <div className="referral-actions">
                        <button 
                          className="btn-review"
                          onClick={() => setSelectedReferral(referral)}
                        >
                          View Details
                        </button>
                        {referral.status?.toLowerCase() === 'pending' && (
                          <button 
                            className="btn-accept"
                            onClick={() => handleStatusUpdate(referral.id, 'accepted', 'Referral accepted for review')}
                          >
                            Accept
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </>
          )}

          {activeTab === 'overview' && (
            <>
              <div className="metrics-grid">
                <div className="metric-card">
                  <div className="metric-label">Total Referrals</div>
                  <div className="metric-value">{referrals.length}</div>
                  <div className="metric-trend">All time</div>
                </div>
                <div className="metric-card" style={{borderLeft: '4px solid #F59E0B'}}>
                  <div className="metric-label">Pending Review</div>
                  <div className="metric-value">{referrals.filter(r => r.status?.toLowerCase() === 'pending').length}</div>
                  <div className="metric-trend">Requires attention</div>
                </div>
                <div className="metric-card" style={{borderLeft: '4px solid #3B82F6'}}>
                  <div className="metric-label">In Progress</div>
                  <div className="metric-value">{referrals.filter(r => r.status?.toLowerCase() === 'accepted' || r.status?.toLowerCase() === 'in_progress').length}</div>
                  <div className="metric-trend">Active cases</div>
                </div>
                <div className="metric-card" style={{borderLeft: '4px solid #10B981'}}>
                  <div className="metric-label">Completed</div>
                  <div className="metric-value">{referrals.filter(r => r.status?.toLowerCase() === 'completed').length}</div>
                  <div className="metric-trend">Successfully treated</div>
                </div>
              </div>

              <div className="data-table-container" style={{marginTop: '24px'}}>
                <h3>Recent Referrals</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Child ID</th>
                      <th>Pathway</th>
                      <th>Status</th>
                      <th>CHW</th>
                      <th>Facility</th>
                      <th>Date</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {referrals.slice(0, 10).map((referral) => (
                      <tr key={referral.id}>
                        <td><strong>{referral.child_id}</strong></td>
                        <td>
                          <span className={`pathway-badge pathway-${referral.pathway?.toLowerCase() || 'sc_itp'}`}>
                            {referral.pathway || 'SC_ITP'}
                          </span>
                        </td>
                        <td>
                          <span className={`status ${referral.status?.toLowerCase() || 'pending'}`}>
                            {referral.status?.replace('_', ' ').toUpperCase() || 'PENDING'}
                          </span>
                        </td>
                        <td>{referral.chw_name}</td>
                        <td>{referral.chw_facility}</td>
                        <td>{new Date(referral.created_at).toLocaleDateString()}</td>
                        <td>
                          <button 
                            className="btn-review"
                            onClick={() => setSelectedReferral(referral)}
                            style={{padding: '6px 12px', fontSize: '12px'}}
                          >
                            View
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {activeTab === 'patients' && (
            <>
              <div className="filters-bar" style={{marginBottom: '24px'}}>
                <input
                  type="text"
                  placeholder="Search by Child ID..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  style={{
                    padding: '12px 16px',
                    fontSize: '14px',
                    border: '2px solid #E5E7EB',
                    borderRadius: '8px',
                    width: '100%',
                    maxWidth: '400px'
                  }}
                />
              </div>

              <div className="data-table-container">
                <h3>Patient Records</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Child ID</th>
                      <th>Age</th>
                      <th>Sex</th>
                      <th>Clinical Status</th>
                      <th>Pathway</th>
                      <th>CHW</th>
                      <th>Facility</th>
                      <th>Last Visit</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {referrals
                      .filter(r => searchQuery === '' || r.child_id.toLowerCase().includes(searchQuery.toLowerCase()))
                      .map((referral) => (
                      <tr key={referral.id}>
                        <td><strong>{referral.child_id}</strong></td>
                        <td>{referral.assessment_details?.age_months} months</td>
                        <td>{referral.assessment_details?.sex === 'M' ? 'Male' : 'Female'}</td>
                        <td>
                          <span className={`badge`} style={{
                            background: referral.assessment_details?.clinical_status === 'SAM' ? 'rgba(220, 38, 38, 0.1)' : 'rgba(251, 146, 60, 0.1)',
                            color: referral.assessment_details?.clinical_status === 'SAM' ? '#dc2626' : '#fb923c',
                            padding: '4px 8px',
                            borderRadius: '4px',
                            fontSize: '12px',
                            fontWeight: '600'
                          }}>
                            {referral.assessment_details?.clinical_status || 'N/A'}
                          </span>
                        </td>
                        <td>
                          <span className={`pathway-badge pathway-${referral.pathway?.toLowerCase() || 'sc_itp'}`}>
                            {referral.pathway || 'SC_ITP'}
                          </span>
                        </td>
                        <td>{referral.chw_name}</td>
                        <td>{referral.chw_facility}</td>
                        <td>{new Date(referral.created_at).toLocaleDateString()}</td>
                        <td>
                          <button 
                            className="btn-review"
                            onClick={() => setSelectedReferral(referral)}
                            style={{padding: '6px 12px', fontSize: '12px'}}
                          >
                            View Details
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {referrals.filter(r => searchQuery === '' || r.child_id.toLowerCase().includes(searchQuery.toLowerCase())).length === 0 && (
                  <div className="empty-state" style={{padding: '40px', textAlign: 'center'}}>
                    <p>No patients found matching "{searchQuery}"</p>
                  </div>
                )}
              </div>
            </>
          )}

          {activeTab === 'schedule' && (
            <>
              <div className="metrics-grid" style={{marginBottom: '24px'}}>
                <div className="metric-card" style={{borderLeft: '4px solid #F59E0B'}}>
                  <div className="metric-label">Today's Appointments</div>
                  <div className="metric-value">{referrals.filter(r => {
                    const today = new Date().toDateString();
                    return new Date(r.created_at).toDateString() === today && r.status?.toLowerCase() === 'accepted';
                  }).length}</div>
                  <div className="metric-trend">Scheduled for today</div>
                </div>
                <div className="metric-card" style={{borderLeft: '4px solid #3B82F6'}}>
                  <div className="metric-label">This Week</div>
                  <div className="metric-value">{referrals.filter(r => {
                    const weekAgo = new Date();
                    weekAgo.setDate(weekAgo.getDate() - 7);
                    return new Date(r.created_at) >= weekAgo && r.status?.toLowerCase() === 'accepted';
                  }).length}</div>
                  <div className="metric-trend">Active this week</div>
                </div>
                <div className="metric-card" style={{borderLeft: '4px solid #10B981'}}>
                  <div className="metric-label">Follow-ups Due</div>
                  <div className="metric-value">{referrals.filter(r => r.status?.toLowerCase() === 'in_progress').length}</div>
                  <div className="metric-trend">Require follow-up</div>
                </div>
                <div className="metric-card">
                  <div className="metric-label">Completed This Month</div>
                  <div className="metric-value">{referrals.filter(r => {
                    const monthAgo = new Date();
                    monthAgo.setMonth(monthAgo.getMonth() - 1);
                    return new Date(r.created_at) >= monthAgo && r.status?.toLowerCase() === 'completed';
                  }).length}</div>
                  <div className="metric-trend">Last 30 days</div>
                </div>
              </div>

              <div className="data-table-container">
                <h3>Upcoming Appointments</h3>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Child ID</th>
                      <th>Status</th>
                      <th>Pathway</th>
                      <th>CHW</th>
                      <th>Facility</th>
                      <th>Notes</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {referrals
                      .filter(r => r.status?.toLowerCase() === 'accepted' || r.status?.toLowerCase() === 'in_progress')
                      .sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
                      .map((referral) => (
                      <tr key={referral.id}>
                        <td>{new Date(referral.created_at).toLocaleDateString('en-US', {weekday: 'short', month: 'short', day: 'numeric'})}</td>
                        <td><strong>{referral.child_id}</strong></td>
                        <td>
                          <span className={`status ${referral.status?.toLowerCase() || 'pending'}`}>
                            {referral.status?.replace('_', ' ').toUpperCase() || 'PENDING'}
                          </span>
                        </td>
                        <td>
                          <span className={`pathway-badge pathway-${referral.pathway?.toLowerCase() || 'sc_itp'}`}>
                            {referral.pathway || 'SC_ITP'}
                          </span>
                        </td>
                        <td>{referral.chw_name}</td>
                        <td>{referral.chw_facility}</td>
                        <td style={{maxWidth: '200px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap'}}>
                          {referral.doctor_notes || referral.notes || '-'}
                        </td>
                        <td>
                          <button 
                            className="btn-review"
                            onClick={() => setSelectedReferral(referral)}
                            style={{padding: '6px 12px', fontSize: '12px'}}
                          >
                            View
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                {referrals.filter(r => r.status?.toLowerCase() === 'accepted' || r.status?.toLowerCase() === 'in_progress').length === 0 && (
                  <div className="empty-state" style={{padding: '40px', textAlign: 'center'}}>
                    <Calendar size={48} color="#9CA3AF" style={{marginBottom: '16px'}} />
                    <p>No upcoming appointments</p>
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      </main>

      {/* Referral Detail Modal */}
      {selectedReferral && (
        <div className="modal-overlay" onClick={() => setSelectedReferral(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{maxWidth: '1000px', width: '95%'}}>
            <div className="modal-header">
              <h2>Referral Details</h2>
              <button onClick={() => setSelectedReferral(null)} className="modal-close">✕</button>
            </div>

            <div className="modal-body" id="medical-document-content" style={{maxHeight: '70vh', overflowY: 'auto', padding: '48px 64px', background: '#ffffff', margin: '0 auto', maxWidth: '900px'}}>
              {/* Medical Document Header */}
              <div className="header" style={{
                background: 'linear-gradient(135deg, #0E4D34 0%, #1A3A28 100%)',
                padding: '40px 32px',
                borderRadius: '16px',
                textAlign: 'center',
                marginBottom: '40px',
                boxShadow: '0 8px 16px rgba(0,0,0,0.15)',
                border: '1px solid rgba(255,255,255,0.1)'
              }}>
                <FileText size={48} color="white" style={{marginBottom: '16px'}} />
                <h1 style={{color: 'white', margin: '0 0 8px 0', letterSpacing: '2px', fontSize: '24px', fontWeight: '700'}}>MEDICAL ASSESSMENT FORM</h1>
                <p style={{color: 'rgba(255,255,255,0.8)', fontSize: '14px', margin: 0, fontWeight: '500'}}>Community Management of Acute Malnutrition</p>
                <p style={{color: 'rgba(255,255,255,0.6)', fontSize: '12px', margin: '4px 0 0 0'}}>South Sudan CMAM Guidelines 2017</p>
              </div>

              {/* Document Information */}
              <div style={{marginBottom: '40px', background: '#F8FFFE', padding: '28px', borderRadius: '16px', border: '1px solid #E0F2E7', boxShadow: '0 2px 8px rgba(0,0,0,0.05)'}}>
                <h4 style={{color: '#0E4D34', fontSize: '15px', fontWeight: '700', letterSpacing: '1.2px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px'}}>
                  <Clipboard size={18} />
                  DOCUMENT INFORMATION
                </h4>
                <div style={{display: 'grid', gap: '14px'}}>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600'}}>Assessment ID</span>
                    <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                      <span style={{fontSize: '13px', fontWeight: '500'}}>#{selectedReferral.assessment_details?.id || 'N/A'}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600'}}>Date & Time</span>
                    <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                      <span style={{fontSize: '13px'}}>{new Date(selectedReferral.created_at).toLocaleString('en-US', {dateStyle: 'medium', timeStyle: 'short'})}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '6px'}}>
                      <Building2 size={14} /> Facility
                    </span>
                    <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                      <span style={{fontSize: '13px', fontWeight: '500'}}>{selectedReferral.chw_facility || selectedReferral.assessment_details?.facility || 'Not specified'}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '6px'}}>
                      <MapPin size={14} /> State
                    </span>
                    <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                      <span style={{fontSize: '13px', fontWeight: '500'}}>{selectedReferral.assessment_details?.state || 'Not specified'}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '6px'}}>
                      <User size={14} /> CHW Name
                    </span>
                    <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                      <span style={{fontSize: '13px', fontWeight: '500'}}>{selectedReferral.referred_by_name}</span>
                    </div>
                  </div>
                  {selectedReferral.assessment_details?.chw_phone && (
                    <div style={{display: 'flex', alignItems: 'center'}}>
                      <span style={{width: '160px', fontSize: '13px', color: '#666', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '6px'}}>
                        <Phone size={14} /> CHW Phone
                      </span>
                      <div style={{flex: 1, padding: '10px 14px', background: 'white', borderRadius: '8px', border: '1px solid #E5E7EB'}}>
                        <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details.chw_phone}</span>
                      </div>
                    </div>
                  )}
                </div>
              </div>

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* Patient Information */}
              <div style={{marginBottom: '32px', background: '#FEFFFE', padding: '24px', borderRadius: '12px', border: '1px solid #F0F9F4'}}>
                <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>PATIENT INFORMATION</h4>
                <div style={{display: 'grid', gap: '12px'}}>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Child ID</span>
                    <div style={{flex: 1, padding: '8px 12px', background: 'rgba(45, 95, 63, 0.1)', borderRadius: '8px', border: '2px solid #2D5F3F'}}>
                      <span style={{fontSize: '13px', fontWeight: 'bold'}}>{selectedReferral.child_id}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Age</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.age_months} months</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Sex</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.sex === 'M' ? 'Male' : 'Female'}</span>
                    </div>
                  </div>
                </div>
              </div>

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* Anthropometric Measurements */}
              <div style={{marginBottom: '32px', background: '#FEFFFE', padding: '24px', borderRadius: '12px', border: '1px solid #F0F9F4'}}>
                <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>ANTHROPOMETRIC MEASUREMENTS</h4>
                <div style={{display: 'grid', gap: '12px'}}>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>MUAC</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.muac_mm} mm ({(selectedReferral.assessment_details?.muac_mm / 10).toFixed(1)} cm)</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>MUAC Z-Score</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.muac_z_score?.toFixed(2) || 'N/A'}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Edema</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.edema ? 'Present' : 'Absent'}</span>
                    </div>
                  </div>
                </div>
              </div>

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* Clinical Assessment */}
              <div style={{marginBottom: '32px', background: '#FEFFFE', padding: '24px', borderRadius: '12px', border: '1px solid #F0F9F4'}}>
                <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>CLINICAL ASSESSMENT</h4>
                <div style={{display: 'grid', gap: '12px'}}>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Appetite Test</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.appetite}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Danger Signs</span>
                    <div style={{flex: 1, padding: '8px 12px', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #ddd'}}>
                      <span style={{fontSize: '13px'}}>{selectedReferral.assessment_details?.danger_signs ? 'Present' : 'Absent'}</span>
                    </div>
                  </div>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Clinical Status</span>
                    <div style={{flex: 1, padding: '8px 12px', background: selectedReferral.assessment_details?.clinical_status === 'SAM' ? 'rgba(220, 38, 38, 0.1)' : 'rgba(251, 146, 60, 0.1)', borderRadius: '8px', border: `1px solid ${selectedReferral.assessment_details?.clinical_status === 'SAM' ? '#dc2626' : '#fb923c'}`}}>
                      <span style={{fontSize: '13px', fontWeight: 'bold', color: selectedReferral.assessment_details?.clinical_status === 'SAM' ? '#dc2626' : '#fb923c'}}>{selectedReferral.assessment_details?.clinical_status}</span>
                    </div>
                  </div>
                </div>
              </div>

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* Final Care Pathway */}
              <div style={{marginBottom: '32px', background: '#FEF7F7', padding: '24px', borderRadius: '12px', border: '1px solid #FECACA'}}>
                <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>FINAL CARE PATHWAY</h4>
                <div style={{display: 'grid', gap: '12px'}}>
                  <div style={{display: 'flex', alignItems: 'center'}}>
                    <span style={{width: '140px', fontSize: '13px', color: '#666', fontWeight: '500'}}>Pathway</span>
                    <div style={{flex: 1, padding: '8px 12px', background: 'rgba(220, 38, 38, 0.1)', borderRadius: '8px', border: '2px solid #dc2626'}}>
                      <span style={{fontSize: '13px', fontWeight: 'bold', color: '#dc2626'}}>{selectedReferral.assessment_details?.recommended_pathway}</span>
                    </div>
                  </div>
                  <div style={{padding: '14px', background: '#FEF3C7', borderRadius: '10px', border: '2px solid #F59E0B', display: 'flex', alignItems: 'center', gap: '12px'}}>
                    <AlertTriangle size={20} color="#F59E0B" />
                    <span style={{fontSize: '13px', fontWeight: '600', color: '#92400E'}}>URGENT: Refer to Stabilization Centre immediately for inpatient care</span>
                  </div>
                </div>
              </div>

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* CHW Notes */}
              {selectedReferral.assessment_details?.chw_notes && (
                <div style={{marginBottom: '32px', background: '#FFFBF0', padding: '24px', borderRadius: '12px', border: '1px solid #FED7AA'}}>
                  <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>COMMUNITY HEALTH WORKER NOTES</h4>
                  <div style={{padding: '12px', background: '#fff3cd', borderRadius: '8px', border: '1px solid #ffc107'}}>
                    <p style={{fontSize: '13px', margin: 0, lineHeight: '1.6'}}>{selectedReferral.assessment_details.chw_notes}</p>
                  </div>
                </div>
              )}

              {selectedReferral.referral_notes && (
                <div style={{marginBottom: '32px', background: '#FFFBF0', padding: '24px', borderRadius: '12px', border: '1px solid #FED7AA'}}>
                  <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>REFERRAL NOTES</h4>
                  <div style={{padding: '12px', background: '#fef3c7', borderRadius: '8px', border: '1px solid #fbbf24'}}>
                    <p style={{fontSize: '13px', margin: 0, lineHeight: '1.6'}}>{selectedReferral.referral_notes}</p>
                  </div>
                </div>
              )}

              <hr style={{border: 'none', borderTop: '3px solid #E0F2E7', margin: '40px 0', borderRadius: '2px'}} />

              {/* Doctor Notes - Editable */}
              <div style={{marginBottom: '32px', background: '#F0F9FF', padding: '24px', borderRadius: '12px', border: '1px solid #BFDBFE'}}>
                <h4 style={{color: '#0E4D34', fontSize: '15px', fontWeight: '700', letterSpacing: '1.2px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px'}}>
                  <FileText size={18} />
                                    DOCTOR NOTES
                </h4>
                <textarea
                  value={doctorNotes || selectedReferral.doctor_notes || ''}
                  onChange={(e) => setDoctorNotes(e.target.value)}
                  placeholder="Enter your clinical observations, diagnosis, and treatment plan..."
                  style={{
                    width: '100%',
                    minHeight: '120px',
                    padding: '12px',
                    border: '2px solid #0E4D34',
                    borderRadius: '8px',
                    fontSize: '13px',
                    fontFamily: 'inherit',
                    lineHeight: '1.6',
                    resize: 'vertical'
                  }}
                />
              </div>

              {/* Prescription - Editable */}
              <div style={{marginBottom: '32px', background: '#F0F9FF', padding: '24px', borderRadius: '12px', border: '1px solid #BFDBFE'}}>
                <h4 style={{color: '#0E4D34', fontSize: '15px', fontWeight: '700', letterSpacing: '1.2px', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px'}}>
                  <Clipboard size={18} />
                                    PRESCRIPTION
                </h4>
                <textarea
                  value={prescription || selectedReferral.prescription || ''}
                  onChange={(e) => setPrescription(e.target.value)}
                  placeholder="Enter medication details, dosage, and instructions..."
                  style={{
                    width: '100%',
                    minHeight: '120px',
                    padding: '12px',
                    border: '2px solid #0E4D34',
                    borderRadius: '8px',
                    fontSize: '13px',
                    fontFamily: 'inherit',
                    lineHeight: '1.6',
                    resize: 'vertical'
                  }}
                />
              </div>

              {/* Doctor Signature */}
              <div style={{marginBottom: '32px', padding: '28px', background: '#F9FAFB', borderRadius: '12px', border: '2px solid #D1D5DB', boxShadow: '0 2px 8px rgba(0,0,0,0.05)'}}>
                <h4 style={{color: '#2D5F3F', fontSize: '14px', fontWeight: 'bold', letterSpacing: '1px', marginBottom: '12px'}}>DOCTOR CERTIFICATION</h4>
                <p style={{fontSize: '11px', lineHeight: '1.6', marginBottom: '16px'}}>I certify that I have reviewed this assessment and the information provided above is accurate to the best of my knowledge.</p>
                <div style={{display: 'flex', gap: '24px'}}>
                  <div style={{flex: 1}}>
                    <label style={{fontSize: '11px', fontWeight: '500', display: 'block', marginBottom: '8px'}}>Doctor Name:</label>
                    <input
                      type="text"
                      value={doctorSignature || selectedReferral.doctor_signature || ''}
                      onChange={(e) => setDoctorSignature(e.target.value)}
                      placeholder="Enter your name"
                      style={{
                        width: '100%',
                        padding: '8px 12px',
                        border: '1px solid #2D5F3F',
                        borderRadius: '8px',
                        fontSize: '13px'
                      }}
                    />
                  </div>
                  <div style={{flex: 1}}>
                    <label style={{fontSize: '11px', fontWeight: '500', display: 'block', marginBottom: '8px'}}>Date:</label>
                    <div style={{padding: '8px 12px', background: '#fff', border: '1px solid #ddd', borderRadius: '8px', fontSize: '13px'}}>
                      {new Date().toLocaleDateString()}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="modal-footer">
              <button 
                className="btn-review"
                onClick={handleDownloadPDF}
                style={{marginRight: '8px', background: '#6366f1', display: 'flex', alignItems: 'center', gap: '8px'}}
              >
                <Download size={16} /> Download PDF
              </button>
              <button 
                className="btn-accept"
                onClick={() => handleStatusUpdate(selectedReferral.id, selectedReferral.status, doctorNotes)}
                style={{marginRight: '8px', display: 'flex', alignItems: 'center', gap: '8px'}}
              >
                <Save size={16} /> Save Changes
              </button>
              {selectedReferral.status === 'PENDING' && (
                <>
                  <button 
                    className="btn-accept"
                    onClick={() => handleStatusUpdate(selectedReferral.id, 'ACCEPTED', 'Referral accepted for review')}
                    style={{display: 'flex', alignItems: 'center', gap: '8px'}}
                  >
                    <CheckCircle size={16} /> Accept Referral
                  </button>
                  <button 
                    className="btn-review"
                    onClick={() => {
                      const notes = prompt('Enter reason for rejection:');
                      if (notes) handleStatusUpdate(selectedReferral.id, 'REJECTED', notes);
                    }}
                    style={{display: 'flex', alignItems: 'center', gap: '8px'}}
                  >
                    <XCircle size={16} /> Reject
                  </button>
                </>
              )}
              {selectedReferral.status === 'ACCEPTED' && (
                <button 
                  className="btn-accept"
                  onClick={() => handleStatusUpdate(selectedReferral.id, 'COMPLETED', 'Treatment completed')}
                  style={{display: 'flex', alignItems: 'center', gap: '8px'}}
                >
                  <CheckCircle size={16} /> Mark as Completed
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default DoctorDashboard;
