import React, { useRef } from 'react';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import html2canvas from 'html2canvas';
import './ReportTemplate.css';

const COLORS = ['#E74C3C', '#E67E22', '#2ECC71'];

const ReportTemplate = ({ type, data, onClose }) => {
  const reportRef = useRef(null);
  
  const generatePDF = async () => {
    const doc = new jsPDF();
    const { summary, stateTrends, chwPerformance, doctorPerformance, facilities, timeSeries } = data;

    // Header
    doc.setFillColor(14, 77, 52);
    doc.rect(0, 0, 210, 40, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(28);
    doc.text('Gelmäth', 105, 20, { align: 'center' });
    doc.setFontSize(14);
    doc.text('Community-based Management of Acute Malnutrition', 105, 30, { align: 'center' });
    
    doc.setTextColor(0, 0, 0);
    doc.setFontSize(10);
    const now = new Date();
    const dateStr = now.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
    const timeStr = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    doc.text(`Generated: ${dateStr} at ${timeStr}`, 20, 50);
    doc.text('South Sudan Ministry of Health', 20, 55);

    if (type === 'national') {
      doc.setFontSize(18);
      doc.setTextColor(14, 77, 52);
      doc.text('National Malnutrition Summary Report', 20, 70);
      
      doc.setFontSize(11);
      doc.setTextColor(0, 0, 0);
      doc.text('Executive Summary', 20, 85);
      doc.setFontSize(10);
      
      const metrics = [
        ['Total Assessments', summary.total_assessments],
        ['SAM Cases', `${summary.sam_count} (${summary.sam_prevalence}%)`],
        ['MAM Cases', `${summary.mam_count} (${summary.mam_prevalence}%)`],
        ['Healthy Children', summary.healthy_count],
        ['Active CHWs', summary.active_chws || 0],
        ['Healthcare Facilities', facilities?.length || 0]
      ];
      
      autoTable(doc, {
        startY: 90,
        head: [['Indicator', 'Value']],
        body: metrics,
        theme: 'grid',
        headStyles: { fillColor: [14, 77, 52], textColor: [255, 255, 255] },
        margin: { left: 20, right: 20 }
      });

      doc.addPage();
      doc.setFontSize(14);
      doc.setTextColor(14, 77, 52);
      doc.text('State-Level Breakdown', 20, 20);
      
      autoTable(doc, {
        startY: 30,
        head: [['State', 'Total', 'SAM', 'SAM %', 'MAM', 'MAM %', 'Healthy']],
        body: stateTrends.map(s => {
          const total = s.sam_count + s.mam_count + s.healthy_count;
          return [
            s.state,
            total,
            s.sam_count,
            total > 0 ? ((s.sam_count / total) * 100).toFixed(1) + '%' : '0%',
            s.mam_count,
            total > 0 ? ((s.mam_count / total) * 100).toFixed(1) + '%' : '0%',
            s.healthy_count
          ];
        }),
        theme: 'striped',
        headStyles: { fillColor: [14, 77, 52] }
      });

    } else if (type === 'state') {
      doc.setFontSize(18);
      doc.setTextColor(14, 77, 52);
      doc.text('State-Level Analysis Report', 20, 70);
      
      autoTable(doc, {
        startY: 85,
        head: [['State', 'Total Cases', 'SAM', 'MAM', 'Healthy', 'SAM Prevalence']],
        body: stateTrends.map(s => {
          const total = s.sam_count + s.mam_count + s.healthy_count;
          const samPrev = total > 0 ? ((s.sam_count / total) * 100).toFixed(1) : 0;
          return [s.state, total, s.sam_count, s.mam_count, s.healthy_count, samPrev + '%'];
        }),
        theme: 'grid',
        headStyles: { fillColor: [14, 77, 52] }
      });

    } else if (type === 'chw') {
      doc.setFontSize(18);
      doc.setTextColor(14, 77, 52);
      doc.text('CHW Performance Report', 20, 70);
      
      autoTable(doc, {
        startY: 85,
        head: [['CHW Name', 'Total', 'SAM', 'MAM', 'Healthy', 'SAM Rate']],
        body: chwPerformance.map(c => {
          const samRate = c.total_assessments > 0 ? ((c.sam_cases / c.total_assessments) * 100).toFixed(1) : 0;
          return [c.chw_name, c.total_assessments, c.sam_cases, c.mam_cases, c.healthy_cases, samRate + '%'];
        }),
        theme: 'striped',
        headStyles: { fillColor: [14, 77, 52] }
      });

    } else if (type === 'facility') {
      doc.setFontSize(18);
      doc.setTextColor(14, 77, 52);
      doc.text('Facility Capacity Report', 20, 70);
      
      autoTable(doc, {
        startY: 85,
        head: [['Facility', 'Type', 'State', 'County', 'Status']],
        body: facilities.map(f => [f.name, f.facility_type, f.state, f.county, 'Active']),
        theme: 'grid',
        headStyles: { fillColor: [14, 77, 52] }
      });
    }

    // Capture charts as images
    if (reportRef.current) {
      const sections = reportRef.current.querySelectorAll('.report-section');
      let yPosition = 65;
      
      for (let i = 0; i < sections.length; i++) {
        const section = sections[i];
        const canvas = await html2canvas(section, { scale: 2, backgroundColor: '#ffffff' });
        const imgData = canvas.toDataURL('image/png');
        const imgWidth = 170;
        const imgHeight = (canvas.height * imgWidth) / canvas.width;
        
        if (yPosition + imgHeight > 280) {
          doc.addPage();
          yPosition = 20;
        }
        
        doc.addImage(imgData, 'PNG', 20, yPosition, imgWidth, imgHeight);
        yPosition += imgHeight + 10;
      }
    }
    
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
    doc.save(`gelmath-${type}-report-${timestamp}.pdf`);
  };

  const renderNationalReport = () => {
    const { summary, stateTrends, timeSeries } = data;
    const pieData = [
      { name: 'SAM', value: summary.sam_count },
      { name: 'MAM', value: summary.mam_count },
      { name: 'Healthy', value: summary.healthy_count }
    ];

    return (
      <div className="report-preview" ref={reportRef}>
        <div className="report-header">
          <div className="report-logo">Gelmäth</div>
          <div className="report-title">
            <h1>National Malnutrition Summary Report</h1>
            <p>South Sudan Ministry of Health</p>
            <p className="report-date">Generated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} at {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}</p>
          </div>
        </div>

        <div className="report-section">
          <h2>Executive Summary</h2>
          <div className="metrics-grid-report">
            <div className="metric-box">
              <div className="metric-label">Total Assessments</div>
              <div className="metric-value-large">{summary.total_assessments}</div>
            </div>
            <div className="metric-box danger">
              <div className="metric-label">SAM Cases</div>
              <div className="metric-value-large">{summary.sam_count}</div>
              <div className="metric-sub">{summary.sam_prevalence}% prevalence</div>
            </div>
            <div className="metric-box warning">
              <div className="metric-label">MAM Cases</div>
              <div className="metric-value-large">{summary.mam_count}</div>
              <div className="metric-sub">{summary.mam_prevalence}% prevalence</div>
            </div>
            <div className="metric-box success">
              <div className="metric-label">Healthy Children</div>
              <div className="metric-value-large">{summary.healthy_count}</div>
              <div className="metric-sub">{summary.total_assessments > 0 ? ((summary.healthy_count / summary.total_assessments) * 100).toFixed(1) : 0}% of total</div>
            </div>
            <div className="metric-box">
              <div className="metric-label">Active CHWs</div>
              <div className="metric-value-large">{data.users?.filter(u => u.role === 'CHW' && u.is_active).length || 0}</div>
              <div className="metric-sub">{data.users?.filter(u => u.role === 'CHW').length || 0} total</div>
            </div>
            <div className="metric-box">
              <div className="metric-label">Active Doctors</div>
              <div className="metric-value-large">{data.users?.filter(u => u.role === 'DOCTOR' && u.is_active).length || 0}</div>
              <div className="metric-sub">{data.users?.filter(u => u.role === 'DOCTOR').length || 0} total</div>
            </div>
          </div>
        </div>

        <div className="report-section">
          <h2>Clinical Status Distribution</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie data={pieData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label>
                {pieData.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index]} />)}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>State-Level Breakdown</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={stateTrends}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="state" angle={-45} textAnchor="end" height={100} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="sam_count" fill="#E74C3C" name="SAM" />
              <Bar dataKey="mam_count" fill="#E67E22" name="MAM" />
              <Bar dataKey="healthy_count" fill="#2ECC71" name="Healthy" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {timeSeries && timeSeries.length > 0 && (
          <div className="report-section">
            <h2>Trend Analysis</h2>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={timeSeries}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="sam_count" stroke="#E74C3C" strokeWidth={2} name="SAM" />
                <Line type="monotone" dataKey="mam_count" stroke="#E67E22" strokeWidth={2} name="MAM" />
                <Line type="monotone" dataKey="healthy_count" stroke="#2ECC71" strokeWidth={2} name="Healthy" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}

        <div className="report-section">
          <h2>State Statistics Table</h2>
          <table className="report-table">
            <thead>
              <tr>
                <th>State</th>
                <th>Total</th>
                <th>SAM</th>
                <th>SAM %</th>
                <th>MAM</th>
                <th>MAM %</th>
                <th>Healthy</th>
              </tr>
            </thead>
            <tbody>
              {stateTrends.map((state, idx) => {
                const total = state.sam_count + state.mam_count + state.healthy_count;
                return (
                  <tr key={idx}>
                    <td><strong>{state.state}</strong></td>
                    <td>{total}</td>
                    <td className="danger-text">{state.sam_count}</td>
                    <td>{total > 0 ? ((state.sam_count / total) * 100).toFixed(1) : 0}%</td>
                    <td className="warning-text">{state.mam_count}</td>
                    <td>{total > 0 ? ((state.mam_count / total) * 100).toFixed(1) : 0}%</td>
                    <td className="success-text">{state.healthy_count}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    );
  };

  const renderStateReport = () => {
    const { stateTrends } = data;
    const chartData = stateTrends.map(s => ({
      ...s,
      total: s.sam_count + s.mam_count + s.healthy_count,
      samRate: s.sam_count + s.mam_count + s.healthy_count > 0 
        ? ((s.sam_count / (s.sam_count + s.mam_count + s.healthy_count)) * 100).toFixed(1) 
        : 0
    }));

    return (
      <div className="report-preview" ref={reportRef}>
        <div className="report-header">
          <div className="report-logo">Gelmäth</div>
          <div className="report-title">
            <h1>State-Level Analysis Report</h1>
            <p>Detailed Breakdown by State and County</p>
            <p className="report-date">Generated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} at {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}</p>
          </div>
        </div>

        <div className="report-section">
          <h2>Cases by State</h2>
          <ResponsiveContainer width="100%" height={350}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="state" angle={-45} textAnchor="end" height={100} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="sam_count" fill="#E74C3C" name="SAM" />
              <Bar dataKey="mam_count" fill="#E67E22" name="MAM" />
              <Bar dataKey="healthy_count" fill="#2ECC71" name="Healthy" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>SAM Prevalence by State</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="state" angle={-45} textAnchor="end" height={100} />
              <YAxis label={{ value: 'SAM Rate (%)', angle: -90, position: 'insideLeft' }} />
              <Tooltip />
              <Bar dataKey="samRate" fill="#E74C3C" name="SAM Prevalence %" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>Detailed State Statistics</h2>
          <table className="report-table">
            <thead>
              <tr>
                <th>State</th>
                <th>Total Cases</th>
                <th>SAM</th>
                <th>MAM</th>
                <th>Healthy</th>
                <th>SAM Prevalence</th>
              </tr>
            </thead>
            <tbody>
              {chartData.map((state, idx) => (
                <tr key={idx}>
                  <td><strong>{state.state}</strong></td>
                  <td>{state.total}</td>
                  <td className="danger-text">{state.sam_count}</td>
                  <td className="warning-text">{state.mam_count}</td>
                  <td className="success-text">{state.healthy_count}</td>
                  <td><strong>{state.samRate}%</strong></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  };

  const renderCHWReport = () => {
    const { chwPerformance } = data;
    const topPerformers = [...chwPerformance].sort((a, b) => b.total_assessments - a.total_assessments).slice(0, 10);

    return (
      <div className="report-preview" ref={reportRef}>
        <div className="report-header">
          <div className="report-logo">Gelmäth</div>
          <div className="report-title">
            <h1>CHW Performance Report</h1>
            <p>Individual CHW Activity and Outcomes</p>
            <p className="report-date">Generated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} at {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}</p>
          </div>
        </div>

        <div className="report-section">
          <h2>Top 10 CHWs by Total Assessments</h2>
          <ResponsiveContainer width="100%" height={350}>
            <BarChart data={topPerformers}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="chw_name" angle={-45} textAnchor="end" height={120} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="total_assessments" fill="#0E4D34" name="Total Assessments" />
              <Bar dataKey="sam_cases" fill="#E74C3C" name="SAM Cases" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>CHW Case Distribution</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={topPerformers}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="chw_name" angle={-45} textAnchor="end" height={120} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="sam_cases" fill="#E74C3C" name="SAM" stackId="a" />
              <Bar dataKey="mam_cases" fill="#E67E22" name="MAM" stackId="a" />
              <Bar dataKey="healthy_cases" fill="#2ECC71" name="Healthy" stackId="a" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>CHW Performance Summary</h2>
          <table className="report-table">
            <thead>
              <tr>
                <th>CHW Name</th>
                <th>Total</th>
                <th>SAM</th>
                <th>MAM</th>
                <th>Healthy</th>
                <th>SAM Rate</th>
              </tr>
            </thead>
            <tbody>
              {chwPerformance.map((chw, idx) => {
                const samRate = chw.total_assessments > 0 ? ((chw.sam_cases / chw.total_assessments) * 100).toFixed(1) : 0;
                return (
                  <tr key={idx}>
                    <td><strong>{chw.chw_name}</strong></td>
                    <td>{chw.total_assessments}</td>
                    <td className="danger-text">{chw.sam_cases}</td>
                    <td className="warning-text">{chw.mam_cases}</td>
                    <td className="success-text">{chw.healthy_cases}</td>
                    <td>{samRate}%</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    );
  };

  const renderFacilityReport = () => {
    const { facilities, stateTrends } = data;
    const facilityByState = stateTrends.map(state => ({
      state: state.state,
      facilities: facilities.filter(f => f.state === state.state).length
    }));

    return (
      <div className="report-preview" ref={reportRef}>
        <div className="report-header">
          <div className="report-logo">Gelmäth</div>
          <div className="report-title">
            <h1>Facility Capacity Report</h1>
            <p>Resource Utilization and Capacity Analysis</p>
            <p className="report-date">Generated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })} at {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}</p>
          </div>
        </div>

        <div className="report-section">
          <h2>Facilities by State</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={facilityByState}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="state" angle={-45} textAnchor="end" height={100} />
              <YAxis />
              <Tooltip />
              <Bar dataKey="facilities" fill="#0E4D34" name="Number of Facilities" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>Facility Type Distribution</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie 
                data={[
                  { name: 'Hospital', value: facilities.filter(f => f.facility_type === 'Hospital').length },
                  { name: 'Health Center', value: facilities.filter(f => f.facility_type === 'Health Center').length },
                  { name: 'Clinic', value: facilities.filter(f => f.facility_type === 'Clinic').length }
                ]} 
                dataKey="value" 
                nameKey="name" 
                cx="50%" 
                cy="50%" 
                outerRadius={100} 
                label
              >
                <Cell fill="#0E4D34" />
                <Cell fill="#2ECC71" />
                <Cell fill="#E67E22" />
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="report-section">
          <h2>Facility Directory</h2>
          <table className="report-table">
            <thead>
              <tr>
                <th>Facility Name</th>
                <th>Type</th>
                <th>State</th>
                <th>County</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {facilities.map((f, idx) => (
                <tr key={idx}>
                  <td><strong>{f.name}</strong></td>
                  <td>{f.facility_type}</td>
                  <td>{f.state}</td>
                  <td>{f.county}</td>
                  <td><span className="status-badge active">Active</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  };

  return (
    <div className="report-modal-overlay" onClick={onClose}>
      <div className="report-modal" onClick={(e) => e.stopPropagation()}>
        <div className="report-modal-header">
          <h2>Report Preview</h2>
          <div>
            <button className="btn-primary" onClick={generatePDF}>Download PDF</button>
            <button className="btn-secondary" onClick={onClose}>Close</button>
          </div>
        </div>
        <div className="report-modal-content">
          {type === 'national' && renderNationalReport()}
          {type === 'state' && renderStateReport()}
          {type === 'chw' && renderCHWReport()}
          {type === 'facility' && renderFacilityReport()}
        </div>
      </div>
    </div>
  );
};

export default ReportTemplate;
