"""
Model 2: Quality Check Service
Detects suspicious measurements before pathway classification
"""

import joblib
import numpy as np
import os

class QualityCheckService:
    def __init__(self):
        model_path = os.path.join(os.path.dirname(__file__), '..', '..', 'model2_quality_classifier.pkl')
        try:
            self.model = joblib.load(model_path)
            self.model_loaded = True
        except:
            self.model = None
            self.model_loaded = False
    
    def check_quality(self, muac_mm, age_months, sex, edema, appetite, danger_signs):
        """
        Check if measurement is OK or SUSPICIOUS.
        
        Returns:
            dict: {
                'status': 'OK' or 'SUSPICIOUS',
                'confidence': float,
                'flags': list of issues,
                'recommendation': str
            }
        """
        flags = []
        
        # Rule-based checks (always run)
        if muac_mm < 50 or muac_mm > 200:
            flags.append('unit_error')
        
        if age_months < 6 or age_months > 59:
            flags.append('age_out_of_range')
        
        if appetite not in ['good', 'poor', 'failed']:
            flags.append('invalid_appetite')
        
        if edema not in [0, 1, 2, 3]:
            flags.append('invalid_edema')
        
        # Impossible combinations
        if muac_mm > 130 and edema >= 2:
            flags.append('impossible_combo')
        
        # If model is loaded, use ML prediction
        if self.model_loaded and self.model:
            try:
                # Compute derived features
                near_threshold = 1 if 113 <= muac_mm <= 117 else 0
                unit_suspect = 1 if muac_mm < 50 or muac_mm > 200 else 0
                age_suspect = 1 if age_months < 6 or age_months > 59 else 0
                
                # Encode features
                sex_encoded = 1 if sex == 'M' else 0
                appetite_map = {'good': 0, 'poor': 1, 'failed': 2}
                appetite_encoded = appetite_map.get(appetite, 2)
                
                # Create feature vector
                X = np.array([[
                    muac_mm, age_months, sex_encoded, edema,
                    appetite_encoded, danger_signs,
                    near_threshold, unit_suspect, age_suspect
                ]])
                
                # Predict
                pred = self.model.predict(X)[0]
                proba = self.model.predict_proba(X)[0]
                
                ml_status = 'SUSPICIOUS' if pred == 1 else 'OK'
                ml_confidence = proba[pred]
                
            except Exception as e:
                ml_status = 'OK'
                ml_confidence = 0.5
        else:
            # Fallback to rule-based only
            ml_status = 'SUSPICIOUS' if len(flags) > 0 else 'OK'
            ml_confidence = 0.7 if len(flags) == 0 else 0.3
        
        # Final decision
        if len(flags) > 0 or ml_status == 'SUSPICIOUS':
            status = 'SUSPICIOUS'
            recommendation = self._get_recommendation(flags)
        else:
            status = 'OK'
            recommendation = 'Measurement appears valid'
        
        return {
            'status': status,
            'confidence': float(ml_confidence),
            'flags': flags,
            'recommendation': recommendation,
            'model_used': self.model_loaded
        }
    
    def _get_recommendation(self, flags):
        """Generate recommendation based on flags."""
        if 'unit_error' in flags:
            return 'Please verify MUAC unit (mm vs cm)'
        elif 'age_out_of_range' in flags:
            return 'Please verify child age (6-59 months)'
        elif 'invalid_appetite' in flags:
            return 'Please verify appetite assessment'
        elif 'impossible_combo' in flags:
            return 'High MUAC with severe edema is unusual - please re-check'
        else:
            return 'Please re-measure MUAC carefully'

# Singleton instance
_quality_service = None

def get_quality_service():
    global _quality_service
    if _quality_service is None:
        _quality_service = QualityCheckService()
    return _quality_service
