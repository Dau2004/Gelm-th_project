import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import { getStateTrends } from '../services/api';
import 'leaflet/dist/leaflet.css';
import './MoHDashboard.css';

const STATE_COORDINATES = {
  'Central Equatoria': [4.85, 31.58],
  'Eastern Equatoria': [4.72, 33.44],
  'Western Equatoria': [4.62, 28.30],
  'Jonglei': [7.73, 32.90],
  'Unity': [9.38, 30.22],
  'Upper Nile': [9.90, 32.72],
  'Warrap': [8.10, 28.63],
  'Northern Bahr el Ghazal': [8.83, 27.97],
  'Western Bahr el Ghazal': [8.70, 25.88],
  'Lakes': [6.80, 30.50]
};

const GeoHeatmap = () => {
  const [stateData, setStateData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    const style = document.createElement('style');
    style.textContent = `
      @keyframes pulse {
        0% {
          r: attr(r);
          opacity: 0.8;
        }
        50% {
          opacity: 0.4;
        }
        100% {
          r: calc(attr(r) * 1.5);
          opacity: 0;
        }
      }
      .leaflet-interactive {
        filter: drop-shadow(0 0 8px currentColor);
        animation: pulse 2s ease-out infinite;
      }
    `;
    document.head.appendChild(style);
    return () => document.head.removeChild(style);
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const response = await getStateTrends();
      const apiData = response.data;
      
      // Create a map of all 10 states with their data
      const allStates = Object.keys(STATE_COORDINATES).map(stateName => {
        const stateInfo = apiData.find(s => s.state === stateName);
        const sam = stateInfo?.sam_count || 0;
        const mam = stateInfo?.mam_count || 0;
        const healthy = stateInfo?.healthy_count || 0;
        const total = sam + mam + healthy;
        
        return {
          state: stateName,
          sam_count: sam,
          mam_count: mam,
          healthy_count: healthy,
          total: total,
          sam_rate: total > 0 ? (sam / total * 100) : 0,
          mam_rate: total > 0 ? (mam / total * 100) : 0,
          coords: STATE_COORDINATES[stateName]
        };
      });
      
      setStateData(allStates);
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  const getColor = (samRate) => {
    if (samRate >= 50) return '#E74C3C'; // Red for SAM rate >= 50%
    return '#2ECC71'; // Green for SAM rate < 50%
  };

  const getRadius = (total) => {
    return Math.max(15, Math.min(40, total / 2));
  };

  if (loading) return <div className="loading-screen"><div className="spinner"></div></div>;

  return (
    <div className="content-area">
      <div className="chart-container full-width">
        <h3>Geographic Heatmap - South Sudan</h3>
        <MapContainer
          center={[7.5, 30]}
          zoom={6.5}
          style={{ height: '600px', width: '100%', borderRadius: '12px' }}
          scrollWheelZoom={false}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; OpenStreetMap'
          />
          {stateData.map((state, idx) => (
            <CircleMarker
              key={idx}
              center={state.coords}
              radius={getRadius(state.total)}
              fillColor={getColor(state.sam_rate)}
              color="#fff"
              weight={2}
              opacity={1}
              fillOpacity={0.7}
              className="pulsing-marker"
              pathOptions={{
                className: 'radar-pulse'
              }}
            >
              <Popup>
                <div style={{minWidth: '220px', fontFamily: 'system-ui'}}>
                  <h4 style={{margin: '0 0 12px 0', color: '#0E4D34', fontSize: '16px', borderBottom: '2px solid #0E4D34', paddingBottom: '8px'}}>{state.state}</h4>
                  
                  <div style={{marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center'}}>
                    <span style={{color: '#E74C3C', fontWeight: '600'}}>● SAM Cases:</span>
                    <strong style={{fontSize: '16px', color: '#E74C3C'}}>{state.sam_count}</strong>
                  </div>
                  <div style={{marginBottom: '8px', fontSize: '13px', color: '#666', paddingLeft: '20px'}}>
                    Rate: {state.sam_rate.toFixed(1)}%
                  </div>
                  
                  <div style={{marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center'}}>
                    <span style={{color: '#F1C40F', fontWeight: '600'}}>● MAM Cases:</span>
                    <strong style={{fontSize: '16px', color: '#F1C40F'}}>{state.mam_count}</strong>
                  </div>
                  <div style={{marginBottom: '8px', fontSize: '13px', color: '#666', paddingLeft: '20px'}}>
                    Rate: {state.mam_rate.toFixed(1)}%
                  </div>
                  
                  <div style={{marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center'}}>
                    <span style={{color: '#2ECC71', fontWeight: '600'}}>● Healthy:</span>
                    <strong style={{fontSize: '16px', color: '#2ECC71'}}>{state.healthy_count}</strong>
                  </div>
                  
                  <hr style={{margin: '10px 0', border: 'none', borderTop: '1px solid #ddd'}} />
                  <div style={{display: 'flex', justifyContent: 'space-between', fontSize: '15px'}}>
                    <strong>Total Assessments:</strong>
                    <strong style={{color: '#0E4D34'}}>{state.total}</strong>
                  </div>
                </div>
              </Popup>
            </CircleMarker>
          ))}
        </MapContainer>
      </div>

      <div className="chart-container full-width">
        <h3>Legend</h3>
        <div style={{display: 'flex', gap: '20px', flexWrap: 'wrap', padding: '10px'}}>
          <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
            <div style={{width: '20px', height: '20px', borderRadius: '50%', backgroundColor: '#E74C3C'}}></div>
            <span>Critical (SAM Rate ≥ 50%)</span>
          </div>
          <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
            <div style={{width: '20px', height: '20px', borderRadius: '50%', backgroundColor: '#2ECC71'}}></div>
            <span>Normal (SAM Rate &lt; 50%)</span>
          </div>
        </div>
        <p style={{marginTop: '15px', color: '#666', fontSize: '0.9rem'}}>Circle size represents total assessments in each state</p>
      </div>

      <div className="data-table-container">
        <h3>State Statistics</h3>
        <table className="data-table">
          <thead>
            <tr>
              <th>State</th>
              <th>SAM</th>
              <th>MAM</th>
              <th>Healthy</th>
              <th>Total</th>
              <th>SAM Rate</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {stateData.map((state, idx) => (
              <tr key={idx}>
                <td><strong>{state.state}</strong></td>
                <td><span className="badge" style={{background: 'rgba(231, 76, 60, 0.1)', color: '#E74C3C'}}>{state.sam_count}</span></td>
                <td><span className="badge" style={{background: 'rgba(241, 196, 15, 0.1)', color: '#F1C40F'}}>{state.mam_count}</span></td>
                <td><span className="badge" style={{background: 'rgba(46, 204, 113, 0.1)', color: '#2ECC71'}}>{state.healthy_count}</span></td>
                <td>{state.total}</td>
                <td>{state.sam_rate.toFixed(1)}%</td>
                <td>
                  <span className="status" style={{
                    background: state.sam_rate >= 50 ? 'rgba(231, 76, 60, 0.1)' : 'rgba(46, 204, 113, 0.1)',
                    color: state.sam_rate >= 50 ? '#E74C3C' : '#2ECC71',
                    fontWeight: '600'
                  }}>
                    {state.sam_rate >= 50 ? 'Critical' : 'Normal'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default GeoHeatmap;
