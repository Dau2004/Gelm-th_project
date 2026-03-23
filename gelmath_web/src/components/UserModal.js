import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import './UserModal.css';

const STATE_FACILITIES = {
  'Central Equatoria': ['Juba Teaching Hospital', 'Juba Military Hospital', 'Kator Primary Health Care Centre', 'Munuki Primary Health Care Centre', 'Gudele Primary Health Care Centre'],
  'Eastern Equatoria': ['Torit State Hospital', 'Kapoeta State Hospital', 'Magwi Primary Health Care Centre'],
  'Western Equatoria': ['Yambio State Hospital', 'Ezo Primary Health Care Centre', 'Nzara Primary Health Care Centre'],
  'Jonglei': ['Bor State Hospital', 'Pibor Primary Health Care Centre', 'Akobo Primary Health Care Centre'],
  'Unity': ['Bentiu State Hospital', 'Rubkona Primary Health Care Centre', 'Leer Primary Health Care Centre'],
  'Upper Nile': ['Malakal Teaching Hospital', 'Renk Primary Health Care Centre', 'Kodok Primary Health Care Centre'],
  'Northern Bahr el Ghazal': ['Aweil State Hospital', 'Aweil East Primary Health Care Centre'],
  'Western Bahr el Ghazal': ['Wau Teaching Hospital', 'Raja Primary Health Care Centre'],
  'Lakes': ['Rumbek State Hospital', 'Yirol Primary Health Care Centre'],
  'Warrap': ['Kuajok State Hospital', 'Tonj Primary Health Care Centre']
};

const STATES = Object.keys(STATE_FACILITIES);

function UserModal({ show, onClose, onSubmit, formData, setFormData, isEditing }) {
  const [facilities, setFacilities] = useState([]);

  useEffect(() => {
    if (formData.state) {
      setFacilities(STATE_FACILITIES[formData.state] || []);
    } else {
      setFacilities([]);
    }
  }, [formData.state]);

  if (!show) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    if (name === 'state') {
      setFormData({ ...formData, state: value, facility: '' });
    } else {
      setFormData({ ...formData, [name]: value });
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>{isEditing ? 'Edit User' : 'Add New User'}</h2>
          <button className="modal-close" onClick={onClose}><X size={24} /></button>
        </div>
        <form onSubmit={onSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>Username *</label>
              <input
                type="text"
                name="username"
                value={formData.username}
                onChange={handleChange}
                required
                disabled={isEditing}
              />
            </div>
            <div className="form-group">
              <label>Password {!isEditing && '*'}</label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                required={!isEditing}
                placeholder={isEditing ? 'Leave blank to keep current' : 'Min 8 characters'}
                minLength="8"
              />
            </div>
            <div className="form-group">
              <label>Confirm Password {!isEditing && '*'}</label>
              <input
                type="password"
                name="password2"
                value={formData.password2 || ''}
                onChange={handleChange}
                required={!isEditing}
                placeholder={isEditing ? 'Leave blank to keep current' : 'Confirm password'}
                minLength="8"
              />
            </div>
            <div className="form-group">
              <label>First Name</label>
              <input
                type="text"
                name="first_name"
                value={formData.first_name}
                onChange={handleChange}
              />
            </div>
            <div className="form-group">
              <label>Last Name</label>
              <input
                type="text"
                name="last_name"
                value={formData.last_name}
                onChange={handleChange}
              />
            </div>
            <div className="form-group">
              <label>Phone</label>
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                placeholder="+211..."
              />
            </div>
            <div className="form-group">
              <label>State *</label>
              <select name="state" value={formData.state} onChange={handleChange} required>
                <option value="">Select State</option>
                {STATES.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label>Facility *</label>
              {facilities.length > 0 ? (
                <select
                  name="facility"
                  value={formData.facility}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select Facility</option>
                  {facilities.map(f => <option key={f} value={f}>{f}</option>)}
                </select>
              ) : (
                <input
                  type="text"
                  name="facility"
                  value={formData.facility}
                  onChange={handleChange}
                  placeholder={formData.state ? 'Enter facility name' : 'Select state first'}
                  required
                  disabled={!formData.state}
                />
              )}
              {!formData.state && <small style={{color: '#6b7280', marginTop: '4px'}}>Select state first</small>}
            </div>
            <div className="form-group">
              <label>Role *</label>
              <select name="role" value={formData.role} onChange={handleChange} required>
                <option value="CHW">Community Health Worker</option>
                <option value="DOCTOR">Doctor</option>
                <option value="MOH_ADMIN">MoH Admin</option>
              </select>
            </div>
            
            {/* Doctor-specific fields */}
            {formData.role === 'DOCTOR' && (
              <>
                <div className="form-group">
                  <label>Doctor Title</label>
                  <select
                    name="doctor_title"
                    value={formData.doctor_title || ''}
                    onChange={handleChange}
                  >
                    <option value="">Select Title</option>
                    <option value="Dr.">Dr.</option>
                    <option value="Prof.">Prof.</option>
                    <option value="Assoc. Prof.">Assoc. Prof.</option>
                    <option value="Consultant">Consultant</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Specialization</label>
                  <select
                    name="doctor_specialization"
                    value={formData.doctor_specialization || ''}
                    onChange={handleChange}
                  >
                    <option value="">Select Specialization</option>
                    <option value="Pediatrician">Pediatrician</option>
                    <option value="General Practitioner">General Practitioner</option>
                    <option value="Nutritionist">Nutritionist</option>
                    <option value="Internal Medicine">Internal Medicine</option>
                    <option value="Family Medicine">Family Medicine</option>
                    <option value="Public Health">Public Health</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Years of Experience</label>
                  <input
                    type="number"
                    name="years_experience"
                    value={formData.years_experience || ''}
                    onChange={handleChange}
                    min="0"
                    max="50"
                    placeholder="Years"
                  />
                </div>
                <div className="form-group full-width">
                  <label>Description</label>
                  <textarea
                    name="doctor_description"
                    value={formData.doctor_description || ''}
                    onChange={handleChange}
                    rows="3"
                    placeholder="Brief description of expertise and background..."
                  />
                </div>
              </>
            )}
          </div>
          <div className="modal-footer">
            <button type="button" className="btn-secondary" onClick={onClose}>Cancel</button>
            <button type="submit" className="btn-primary">{isEditing ? 'Update' : 'Create'} User</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default UserModal;
