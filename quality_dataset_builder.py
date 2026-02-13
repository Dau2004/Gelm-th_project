"""
Model 2: Quality & Confidence Dataset Builder
==============================================
Generates training data for detecting suspicious/unreliable measurements.

Target: confidence_flag ∈ {OK, SUSPICIOUS}

Training data sources:
1. Clean gold records → OK
2. Synthetic corrupted records → SUSPICIOUS
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta

np.random.seed(42)


class QualityDatasetBuilder:
    """Generates quality control training dataset from clean CMAM data."""
    
    def __init__(self, gold_data_path='cmam_gold_final.csv'):
        self.gold_df = pd.read_csv(gold_data_path)
        print(f"Loaded {len(self.gold_df)} clean gold records")
    
    def create_ok_records(self):
        """Label clean records as OK."""
        ok_df = self.gold_df.copy()
        ok_df['confidence_flag'] = 'OK'
        ok_df['error_type'] = 'none'
        return ok_df
    
    def inject_unit_errors(self, df, n_samples):
        """MUAC unit conversion errors (mm ↔ cm)."""
        samples = df.sample(n=n_samples, replace=True).copy().reset_index(drop=True)
        
        for idx in range(len(samples)):
            error_type = np.random.choice(['mm_to_cm', 'cm_to_mm'])
            if error_type == 'mm_to_cm':
                samples.loc[idx, 'muac_mm'] = float(samples.loc[idx, 'muac_mm']) / 10
            else:
                samples.loc[idx, 'muac_mm'] = float(samples.loc[idx, 'muac_mm']) * 10
        
        samples['confidence_flag'] = 'SUSPICIOUS'
        samples['error_type'] = 'unit_error'
        return samples
    
    def inject_noise_errors(self, df, n_samples):
        """Unrealistic MUAC jumps/drops."""
        samples = df.sample(n=n_samples, replace=True).copy().reset_index(drop=True)
        
        for idx in range(len(samples)):
            noise = np.random.randint(-25, 30)
            new_val = int(samples.loc[idx, 'muac_mm']) + noise
            samples.loc[idx, 'muac_mm'] = max(50, min(200, new_val))
        
        samples['confidence_flag'] = 'SUSPICIOUS'
        samples['error_type'] = 'noise'
        return samples
    
    def inject_missing_fields(self, df, n_samples):
        """Missing critical fields."""
        samples = df.sample(n=n_samples, replace=True).copy().reset_index(drop=True)
        
        for idx in range(len(samples)):
            field = np.random.choice(['appetite', 'edema', 'age_months'])
            if field == 'appetite':
                samples.loc[idx, 'appetite'] = 'unknown'
            elif field == 'edema':
                samples.loc[idx, 'edema'] = -1
            else:
                samples.loc[idx, 'age_months'] = np.nan
        
        samples['confidence_flag'] = 'SUSPICIOUS'
        samples['error_type'] = 'missing_field'
        return samples
    
    def inject_age_errors(self, df, n_samples):
        """Age entry errors (wrong units, typos)."""
        samples = df.sample(n=n_samples, replace=True).copy().reset_index(drop=True)
        
        for idx in range(len(samples)):
            error_type = np.random.choice(['multiply_10', 'divide_10', 'typo'])
            if error_type == 'multiply_10':
                samples.loc[idx, 'age_months'] = int(samples.loc[idx, 'age_months']) * 10
            elif error_type == 'divide_10':
                samples.loc[idx, 'age_months'] = max(1, int(samples.loc[idx, 'age_months']) // 10)
            else:
                samples.loc[idx, 'age_months'] = np.random.randint(1, 5)
        
        samples['confidence_flag'] = 'SUSPICIOUS'
        samples['error_type'] = 'age_error'
        return samples
    
    def inject_impossible_combinations(self, df, n_samples):
        """Clinically impossible combinations."""
        samples = df.sample(n=n_samples, replace=True).copy().reset_index(drop=True)
        
        for idx in range(len(samples)):
            samples.loc[idx, 'muac_mm'] = np.random.randint(130, 150)
            samples.loc[idx, 'edema'] = 3
        
        samples['confidence_flag'] = 'SUSPICIOUS'
        samples['error_type'] = 'impossible_combo'
        return samples
    
    def generate_quality_dataset(self, corruption_ratio=2.5):
        """
        Generate full quality dataset.
        
        Args:
            corruption_ratio: Number of corrupted samples per clean sample
        
        Returns:
            DataFrame with OK and SUSPICIOUS records
        """
        print("\n" + "="*70)
        print("GENERATING MODEL 2 QUALITY DATASET")
        print("="*70)
        
        # 1. Clean records → OK
        ok_records = self.create_ok_records()
        n_clean = len(ok_records)
        print(f"\n✓ Clean records (OK): {n_clean}")
        
        # 2. Generate corrupted records → SUSPICIOUS
        n_corrupt_per_type = int(n_clean * corruption_ratio / 5)
        
        unit_errors = self.inject_unit_errors(self.gold_df, n_corrupt_per_type)
        print(f"✓ Unit errors: {len(unit_errors)}")
        
        noise_errors = self.inject_noise_errors(self.gold_df, n_corrupt_per_type)
        print(f"✓ Noise errors: {len(noise_errors)}")
        
        missing_errors = self.inject_missing_fields(self.gold_df, n_corrupt_per_type)
        print(f"✓ Missing field errors: {len(missing_errors)}")
        
        age_errors = self.inject_age_errors(self.gold_df, n_corrupt_per_type)
        print(f"✓ Age errors: {len(age_errors)}")
        
        combo_errors = self.inject_impossible_combinations(self.gold_df, n_corrupt_per_type)
        print(f"✓ Impossible combinations: {len(combo_errors)}")
        
        # 3. Combine all
        quality_df = pd.concat([
            ok_records,
            unit_errors,
            noise_errors,
            missing_errors,
            age_errors,
            combo_errors
        ], ignore_index=True)
        
        # Shuffle
        quality_df = quality_df.sample(frac=1, random_state=42).reset_index(drop=True)
        
        print(f"\n{'='*70}")
        print(f"TOTAL QUALITY DATASET: {len(quality_df)} records")
        print(f"{'='*70}")
        print(f"\nLabel distribution:")
        print(quality_df['confidence_flag'].value_counts())
        print(f"\nError type distribution:")
        print(quality_df['error_type'].value_counts())
        
        return quality_df
    
    def add_derived_features(self, df):
        """Add engineered features for quality detection."""
        df = df.copy()
        
        # Flag if near threshold
        df['near_threshold'] = ((df['muac_mm'] >= 113) & (df['muac_mm'] <= 117)).astype(int)
        
        # Flag if unit suspect (too small or too large)
        df['unit_suspect'] = ((df['muac_mm'] < 50) | (df['muac_mm'] > 200)).astype(int)
        
        # Age plausibility
        df['age_suspect'] = ((df['age_months'] < 6) | (df['age_months'] > 59)).astype(int)
        
        return df
    
    def save_dataset(self, df, output_dir='.'):
        """Save quality dataset with train/val/test splits."""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # Add derived features
        df = self.add_derived_features(df)
        
        # Save full dataset
        full_path = f"{output_dir}/quality_training_data_{timestamp}.csv"
        df.to_csv(full_path, index=False)
        print(f"\n✓ Saved: {full_path}")
        
        # Train/val/test split (70/15/15)
        train_df = df.sample(frac=0.70, random_state=42)
        remaining = df.drop(train_df.index)
        val_df = remaining.sample(frac=0.5, random_state=42)
        test_df = remaining.drop(val_df.index)
        
        train_df.to_csv(f"{output_dir}/quality_train_{timestamp}.csv", index=False)
        val_df.to_csv(f"{output_dir}/quality_val_{timestamp}.csv", index=False)
        test_df.to_csv(f"{output_dir}/quality_test_{timestamp}.csv", index=False)
        
        print(f"✓ Train: {len(train_df)} | Val: {len(val_df)} | Test: {len(test_df)}")
        
        # Metadata
        metadata = {
            'model': 'Model 2 - Quality & Confidence',
            'target': 'confidence_flag (OK / SUSPICIOUS)',
            'timestamp': timestamp,
            'total_records': len(df),
            'train_records': len(train_df),
            'val_records': len(val_df),
            'test_records': len(test_df),
            'label_distribution': df['confidence_flag'].value_counts().to_dict(),
            'error_types': df['error_type'].value_counts().to_dict(),
            'features': list(df.columns)
        }
        
        import json
        meta_path = f"{output_dir}/quality_metadata_{timestamp}.json"
        with open(meta_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        print(f"✓ Metadata: {meta_path}")
        
        return df


if __name__ == '__main__':
    builder = QualityDatasetBuilder('cmam_gold_final.csv')
    quality_df = builder.generate_quality_dataset(corruption_ratio=2.5)
    builder.save_dataset(quality_df)
    
    print("\n" + "="*70)
    print("✓ MODEL 2 QUALITY DATASET READY FOR TRAINING")
    print("="*70)
