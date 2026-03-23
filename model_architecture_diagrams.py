import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

# Set up the figure with subplots
fig = plt.figure(figsize=(20, 12))

# Model 1: Care Pathway Classifier
ax1 = plt.subplot(2, 1, 1)
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 8)
ax1.set_title('Model 1: Care Pathway Classifier Architecture', fontsize=16, fontweight='bold', pad=20)

# Input features
features = [
    'sex_encoded\n(0=F, 1=M)',
    'age_months_filled\n(6-59)',
    'muac_mm\n(95-145)',
    'edema\n(0-3)',
    'appetite_encoded\n(0=good, 1=poor)',
    'danger_signs\n(0/1)'
]

# Draw input layer
for i, feature in enumerate(features):
    y_pos = 6.5 - i * 1.1
    box = FancyBboxPatch((0.5, y_pos), 1.5, 0.8, 
                         boxstyle="round,pad=0.1", 
                         facecolor='lightblue', 
                         edgecolor='navy', 
                         linewidth=2)
    ax1.add_patch(box)
    ax1.text(1.25, y_pos + 0.4, feature, ha='center', va='center', fontsize=9, fontweight='bold')

# Random Forest
rf_box = FancyBboxPatch((3, 2), 3, 4, 
                        boxstyle="round,pad=0.2", 
                        facecolor='lightgreen', 
                        edgecolor='darkgreen', 
                        linewidth=3)
ax1.add_patch(rf_box)
ax1.text(4.5, 4, 'Random Forest\nClassifier\n\nn_estimators=100\nmax_depth=10\nclass_weight=balanced', 
         ha='center', va='center', fontsize=12, fontweight='bold')

# Output classes
outputs = ['SC-ITP\n(Stabilization Center)', 'OTP\n(Outpatient)', 'TSFP\n(Supplementary)']
colors = ['#ff6b6b', '#4ecdc4', '#45b7d1']

for i, (output, color) in enumerate(zip(outputs, colors)):
    y_pos = 5.5 - i * 1.5
    box = FancyBboxPatch((7.5, y_pos), 2, 1, 
                         boxstyle="round,pad=0.1", 
                         facecolor=color, 
                         edgecolor='black', 
                         linewidth=2)
    ax1.add_patch(box)
    ax1.text(8.5, y_pos + 0.5, output, ha='center', va='center', fontsize=10, fontweight='bold')

# Draw arrows
for i in range(6):
    y_start = 6.9 - i * 1.1
    arrow = ConnectionPatch((2, y_start), (3, 4), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5, 
                           mutation_scale=20, fc="black", lw=2)
    ax1.add_patch(arrow)

for i in range(3):
    y_end = 6 - i * 1.5
    arrow = ConnectionPatch((6, 4), (7.5, y_end), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5, 
                           mutation_scale=20, fc="black", lw=2)
    ax1.add_patch(arrow)

# Add accuracy text
ax1.text(4.5, 1, 'Accuracy: 94.05%', ha='center', va='center', 
         fontsize=14, fontweight='bold', 
         bbox=dict(boxstyle="round,pad=0.3", facecolor='yellow', alpha=0.7))

ax1.set_xticks([])
ax1.set_yticks([])
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax1.spines['bottom'].set_visible(False)
ax1.spines['left'].set_visible(False)

# Model 2: Quality Classifier
ax2 = plt.subplot(2, 1, 2)
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 10)
ax2.set_title('Model 2: Quality Classifier Architecture', fontsize=16, fontweight='bold', pad=20)

# Input features for Model 2
features2 = [
    'muac_mm',
    'age_months',
    'sex_encoded',
    'edema',
    'appetite_encoded',
    'danger_signs',
    'near_threshold\n(derived)',
    'unit_suspect\n(derived)',
    'age_suspect\n(derived)'
]

# Draw input layer
for i, feature in enumerate(features2):
    y_pos = 8.5 - i * 0.9
    box = FancyBboxPatch((0.5, y_pos), 1.5, 0.7, 
                         boxstyle="round,pad=0.1", 
                         facecolor='lightcoral', 
                         edgecolor='darkred', 
                         linewidth=2)
    ax2.add_patch(box)
    ax2.text(1.25, y_pos + 0.35, feature, ha='center', va='center', fontsize=9, fontweight='bold')

# Random Forest for Quality
rf_box2 = FancyBboxPatch((3, 3), 3, 4, 
                         boxstyle="round,pad=0.2", 
                         facecolor='lightyellow', 
                         edgecolor='orange', 
                         linewidth=3)
ax2.add_patch(rf_box2)
ax2.text(4.5, 5, 'Random Forest\nClassifier\n\nn_estimators=100\nmax_depth=10\nmin_samples_split=10', 
         ha='center', va='center', fontsize=12, fontweight='bold')

# Output classes for Model 2
outputs2 = ['OK\n(Valid measurement)', 'SUSPICIOUS\n(Potential error)']
colors2 = ['#2ecc71', '#e74c3c']

for i, (output, color) in enumerate(zip(outputs2, colors2)):
    y_pos = 5.5 - i * 2
    box = FancyBboxPatch((7.5, y_pos), 2, 1.2, 
                         boxstyle="round,pad=0.1", 
                         facecolor=color, 
                         edgecolor='black', 
                         linewidth=2)
    ax2.add_patch(box)
    ax2.text(8.5, y_pos + 0.6, output, ha='center', va='center', fontsize=10, fontweight='bold', color='white')

# Draw arrows for Model 2
for i in range(9):
    y_start = 8.85 - i * 0.9
    arrow = ConnectionPatch((2, y_start), (3, 5), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5, 
                           mutation_scale=20, fc="black", lw=2)
    ax2.add_patch(arrow)

for i in range(2):
    y_end = 6.1 - i * 2
    arrow = ConnectionPatch((6, 5), (7.5, y_end), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5, 
                           mutation_scale=20, fc="black", lw=2)
    ax2.add_patch(arrow)

# Add accuracy text for Model 2
ax2.text(4.5, 1.5, 'Accuracy: 89.2%', ha='center', va='center', 
         fontsize=14, fontweight='bold', 
         bbox=dict(boxstyle="round,pad=0.3", facecolor='yellow', alpha=0.7))

ax2.set_xticks([])
ax2.set_yticks([])
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
ax2.spines['bottom'].set_visible(False)
ax2.spines['left'].set_visible(False)

plt.tight_layout()
plt.savefig('/Users/ram/Downloads/MUAC_DEVELOPMENT/model_architectures.png', dpi=300, bbox_inches='tight')
plt.show()

# Create a combined system flow diagram
fig2, ax = plt.subplots(1, 1, figsize=(16, 10))
ax.set_xlim(0, 12)
ax.set_ylim(0, 10)
ax.set_title('Complete CMAM ML System Architecture Flow', fontsize=18, fontweight='bold', pad=30)

# Input data
input_box = FancyBboxPatch((0.5, 4), 2, 2, 
                          boxstyle="round,pad=0.2", 
                          facecolor='lightblue', 
                          edgecolor='navy', 
                          linewidth=3)
ax.add_patch(input_box)
ax.text(1.5, 5, 'Clinical Input\n\n• MUAC (mm)\n• Age (months)\n• Sex\n• Edema\n• Appetite\n• Danger signs', 
        ha='center', va='center', fontsize=10, fontweight='bold')

# Model 2 (Quality Check)
model2_box = FancyBboxPatch((3.5, 7), 2.5, 1.5, 
                           boxstyle="round,pad=0.2", 
                           facecolor='lightyellow', 
                           edgecolor='orange', 
                           linewidth=3)
ax.add_patch(model2_box)
ax.text(4.75, 7.75, 'Model 2\nQuality Check\n89.2% Accuracy', 
        ha='center', va='center', fontsize=11, fontweight='bold')

# Decision diamond
decision_points = np.array([[4.75, 5.5], [5.5, 4.5], [4.75, 3.5], [4, 4.5]])
decision = patches.Polygon(decision_points, closed=True, 
                          facecolor='yellow', edgecolor='black', linewidth=2)
ax.add_patch(decision)
ax.text(4.75, 4.5, 'OK?', ha='center', va='center', fontsize=12, fontweight='bold')

# Model 1 (Pathway Prediction)
model1_box = FancyBboxPatch((7, 4), 2.5, 2, 
                           boxstyle="round,pad=0.2", 
                           facecolor='lightgreen', 
                           edgecolor='darkgreen', 
                           linewidth=3)
ax.add_patch(model1_box)
ax.text(8.25, 5, 'Model 1\nPathway Classifier\n94.05% Accuracy', 
        ha='center', va='center', fontsize=11, fontweight='bold')

# Final outputs
output_box = FancyBboxPatch((10, 3), 1.5, 4, 
                           boxstyle="round,pad=0.2", 
                           facecolor='lightcoral', 
                           edgecolor='darkred', 
                           linewidth=3)
ax.add_patch(output_box)
ax.text(10.75, 5, 'Care Pathway\n\n• SC-ITP\n• OTP\n• TSFP\n\n+ Confidence\n+ Quality Flag', 
        ha='center', va='center', fontsize=10, fontweight='bold')

# Suspicious output
suspicious_box = FancyBboxPatch((3.5, 1), 2.5, 1.5, 
                               boxstyle="round,pad=0.2", 
                               facecolor='#e74c3c', 
                               edgecolor='darkred', 
                               linewidth=3)
ax.add_patch(suspicious_box)
ax.text(4.75, 1.75, 'SUSPICIOUS\nFlag for Review', 
        ha='center', va='center', fontsize=11, fontweight='bold', color='white')

# Draw arrows
arrows = [
    ((2.5, 5), (3.5, 7.75)),  # Input to Model 2
    ((4.75, 7), (4.75, 5.5)),  # Model 2 to Decision
    ((5.5, 4.5), (7, 5)),      # Decision to Model 1 (OK)
    ((4.75, 3.5), (4.75, 2.5)),  # Decision to Suspicious (NOT OK)
    ((9.5, 5), (10, 5))        # Model 1 to Output
]

for start, end in arrows:
    arrow = ConnectionPatch(start, end, "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5, 
                           mutation_scale=25, fc="black", lw=3)
    ax.add_patch(arrow)

# Add labels
ax.text(3, 6.5, 'Quality\nCheck', ha='center', va='center', fontsize=9, 
        bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))
ax.text(6, 4.8, 'OK', ha='center', va='center', fontsize=10, fontweight='bold', color='green')
ax.text(4.2, 3, 'SUSPICIOUS', ha='center', va='center', fontsize=9, fontweight='bold', color='red')

ax.set_xticks([])
ax.set_yticks([])
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['left'].set_visible(False)

plt.tight_layout()
plt.savefig('/Users/ram/Downloads/MUAC_DEVELOPMENT/system_flow_diagram.png', dpi=300, bbox_inches='tight')
plt.show()

print("✅ Model architecture diagrams created successfully!")
print("📁 Files saved:")
print("   - model_architectures.png")
print("   - system_flow_diagram.png")