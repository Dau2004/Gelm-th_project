import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Polygon
import numpy as np

# ── COLOR PALETTE ─────────────────────────────────────────────────────────────
BG          = '#0d1117'
PANEL_BG    = '#161b22'
BORDER      = '#30363d'

B1_EC = '#388bfd'   # Block 1 – blue   (preprocessing)
B2_EC = '#3fb950'   # Block 2 – green  (tree ensemble)
B3_EC = '#d29922'   # Block 3 – orange (prediction)

TEXT  = '#e6edf3'
GREY  = '#8b949e'
ARR   = '#6e7681'

# ── HELPERS ───────────────────────────────────────────────────────────────────
def rbox(ax, x, y, w, h, fc, ec, lw=2, ls='-', z=3, alpha=1.0):
    p = FancyBboxPatch((x, y), w, h,
                       boxstyle="round,pad=0.07",
                       facecolor=fc, edgecolor=ec,
                       linewidth=lw, zorder=z,
                       linestyle=ls, alpha=alpha)
    ax.add_patch(p)

def oval(ax, cx, cy, rx, ry, fc, ec, lw=2, z=3):
    e = mpatches.Ellipse((cx, cy), 2*rx, 2*ry,
                          facecolor=fc, edgecolor=ec,
                          linewidth=lw, zorder=z)
    ax.add_patch(e)

def diamond(ax, cx, cy, hw, hh, fc, ec, lw=2, z=3):
    pts = [[cx, cy+hh], [cx+hw, cy], [cx, cy-hh], [cx-hw, cy]]
    ax.add_patch(Polygon(pts, closed=True, facecolor=fc, edgecolor=ec,
                         linewidth=lw, zorder=z))

def t(ax, x, y, s, fs=8.5, c=TEXT, bold=False, ha='center', va='center', z=6):
    ax.text(x, y, s, ha=ha, va=va, fontsize=fs,
            fontweight='bold' if bold else 'normal', color=c, zorder=z)

def arr(ax, x1, y1, x2, y2, c=ARR, lw=1.8):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=c, lw=lw,
                               mutation_scale=14), zorder=5)

def line(ax, x1, y1, x2, y2, c=ARR, lw=1.8):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='-', color=c, lw=lw), zorder=5)

def block_border(ax, x, y, w, h, ec, label):
    rbox(ax, x, y, w, h, 'none', ec, lw=1.8, ls='--', z=2, alpha=0.65)
    rbox(ax, x+0.12, y+h-0.5, 2.6, 0.42, PANEL_BG, ec, lw=1.2, z=4)
    ax.text(x+0.35, y+h-0.29, '▣', fontsize=6.5, color=ec, zorder=5, va='center')
    ax.text(x+0.62, y+h-0.29, label, fontsize=7.5, color=ec,
            fontweight='bold', zorder=5, va='center')

# ── DRAW ONE MODEL ────────────────────────────────────────────────────────────
def draw_model(ax, title,
               features, feat_label,
               params,
               accuracy, split_info,
               blocks,          # list of 3 block dicts
               outputs):        # list of (label, fc, ec) tuples

    ax.set_facecolor(BG)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 9.5)
    ax.axis('off')

    # ── info panel ────────────────────────────────────────────────────────────
    rbox(ax, 0.15, 0.2, 3.85, 9.1, PANEL_BG, BORDER, lw=1.5, z=1)

    yp = 9.0
    t(ax, 2.1, yp, 'Random Forest', fs=10, bold=True, c='#58a6ff')
    yp -= 0.45
    t(ax, 2.1, yp, 'Classifier', fs=8.5, c='#58a6ff')

    yp -= 0.55
    t(ax, 0.38, yp, 'PARAMETERS', fs=7.5, bold=True, c=GREY, ha='left')
    for p in params:
        yp -= 0.36
        t(ax, 0.48, yp, f'• {p}', fs=7.5, c=TEXT, ha='left')

    yp -= 0.48
    t(ax, 0.38, yp, feat_label, fs=7.5, bold=True, c=GREY, ha='left')
    for f in features:
        yp -= 0.33
        t(ax, 0.48, yp, f'• {f}', fs=7.2, c=TEXT, ha='left')

    yp -= 0.5
    t(ax, 0.38, yp, 'SPLIT', fs=7.5, bold=True, c=GREY, ha='left')
    for s in split_info:
        yp -= 0.33
        t(ax, 0.48, yp, f'• {s}', fs=7.2, c=TEXT, ha='left')

    yp -= 0.52
    t(ax, 0.38, yp, 'TEST ACCURACY', fs=7.5, bold=True, c=GREY, ha='left')
    yp -= 0.44
    t(ax, 2.1, yp, accuracy, fs=16, bold=True, c='#f1c232')

    yp -= 0.48
    t(ax, 0.38, yp, 'FRAMEWORK', fs=7.5, bold=True, c=GREY, ha='left')
    yp -= 0.34
    t(ax, 0.48, yp, 'scikit-learn', fs=8, c='#3fb950', ha='left')

    # ── diagram area ──────────────────────────────────────────────────────────
    rbox(ax, 4.25, 0.2, 15.6, 9.1, '#010409', BORDER, lw=1.5, z=1)

    # title
    t(ax, 12.05, 9.1, title, fs=11, bold=True, c=TEXT)

    # ── BLOCK 1 ───────────────────────────────────────────────────────────────
    b1 = blocks[0]
    block_border(ax, 4.5, 6.2, 15.2, 2.55, B1_EC, 'FEATURE PROCESSING BLOCK')

    # Input oval
    oval(ax, 5.35, 7.47, 0.57, 0.37, '#0d1d35', B1_EC, lw=2)
    t(ax, 5.35, 7.47, 'Input\nLayer', fs=7, bold=True)

    arr(ax, 5.92, 7.47, 6.45, 7.47)

    # Box 1
    rbox(ax, 6.45, 7.07, 2.05, 0.8, '#0d1d35', B1_EC, lw=2)
    t(ax, 7.48, 7.47, b1['box1'], fs=8, bold=True)

    arr(ax, 8.5, 7.47, 9.05, 7.47)

    # Diamond
    diamond(ax, 9.95, 7.47, 0.88, 0.47, '#1a1208', B1_EC, lw=2)
    t(ax, 9.95, 7.47, b1['diamond'], fs=7)

    # Yes branch
    arr(ax, 10.83, 7.47, 11.4, 7.47)
    t(ax, 11.12, 7.62, 'Yes', fs=7, c='#3fb950', bold=True)
    rbox(ax, 11.4, 7.07, 2.0, 0.8, '#0d2010', '#3fb950', lw=2)
    t(ax, 12.4, 7.47, b1['yes_box'], fs=8, bold=True)

    # No bypass (below)
    line(ax, 9.95, 7.0,  9.95, 6.72)
    t(ax, 9.78, 6.86, 'No', fs=7, c='#f85149', bold=True, ha='right')
    line(ax, 9.95, 6.72, 13.48, 6.72)
    arr(ax, 13.48, 6.72, 13.48, 7.07)

    arr(ax, 13.4, 7.47, 14.0, 7.47)

    # Box 2
    rbox(ax, 14.0, 7.07, 2.3, 0.8, '#0d1d35', B1_EC, lw=2)
    t(ax, 15.15, 7.47, b1['box2'], fs=8, bold=True)

    # Connect down
    arr(ax, 15.15, 7.07, 15.15, 6.18)

    # ── BLOCK 2 ───────────────────────────────────────────────────────────────
    b2 = blocks[1]
    block_border(ax, 4.5, 3.65, 15.2, 2.35, B2_EC, 'TREE ENSEMBLE BLOCK  (×100 trees)')

    rbox(ax, 4.72, 4.2, 2.05, 0.8, '#0d2010', B2_EC, lw=2)
    t(ax, 5.75, 4.6, b2['box1'], fs=8, bold=True)
    arr(ax, 6.77, 4.6, 7.3, 4.6)

    diamond(ax, 8.2, 4.6, 0.88, 0.47, '#0d1a08', B2_EC, lw=2)
    t(ax, 8.2, 4.6, b2['diamond'], fs=7)

    arr(ax, 9.08, 4.6, 9.65, 4.6)
    t(ax, 9.37, 4.75, 'Yes', fs=7, c='#3fb950', bold=True)
    rbox(ax, 9.65, 4.2, 2.2, 0.8, '#0d2010', B2_EC, lw=2)
    t(ax, 10.75, 4.6, b2['yes_box'], fs=8, bold=True)

    line(ax, 8.2, 4.13, 8.2, 3.88)
    t(ax, 8.03, 4.0, 'No', fs=7, c='#f85149', bold=True, ha='right')
    line(ax, 8.2, 3.88, 11.93, 3.88)
    arr(ax, 11.93, 3.88, 11.93, 4.2)

    arr(ax, 11.85, 4.6, 12.45, 4.6)

    rbox(ax, 12.45, 4.2, 2.2, 0.8, '#1a1208', '#d29922', lw=2)
    t(ax, 13.55, 4.6, b2['box2'], fs=8, bold=True)

    arr(ax, 13.55, 4.2, 13.55, 3.63)

    # ── BLOCK 3 ───────────────────────────────────────────────────────────────
    b3 = blocks[2]
    block_border(ax, 4.5, 1.05, 15.2, 2.42, B3_EC, 'PREDICTION BLOCK')

    rbox(ax, 4.72, 1.6, 2.05, 0.8, '#1a1208', B3_EC, lw=2)
    t(ax, 5.75, 2.0, b3['box1'], fs=8, bold=True)
    arr(ax, 6.77, 2.0, 7.3, 2.0)

    diamond(ax, 8.2, 2.0, 0.88, 0.47, '#1a1208', B3_EC, lw=2)
    t(ax, 8.2, 2.0, b3['diamond'], fs=7)

    arr(ax, 9.08, 2.0, 9.65, 2.0)
    t(ax, 9.37, 2.15, 'Yes', fs=7, c='#3fb950', bold=True)
    rbox(ax, 9.65, 1.6, 2.2, 0.8, '#1a1208', B3_EC, lw=2)
    t(ax, 10.75, 2.0, b3['yes_box'], fs=8, bold=True)

    line(ax, 8.2, 1.53, 8.2, 1.28)
    t(ax, 8.03, 1.40, 'No', fs=7, c='#f85149', bold=True, ha='right')
    line(ax, 8.2, 1.28, 11.93, 1.28)
    arr(ax, 11.93, 1.28, 11.93, 1.6)

    arr(ax, 11.85, 2.0, 12.45, 2.0)

    # Output oval
    oval(ax, 13.35, 2.0, 0.62, 0.38, '#0d1d35', B1_EC, lw=2)
    t(ax, 13.35, 2.0, 'Output\nLayer', fs=7, bold=True)

    # Output class boxes
    n = len(outputs)
    y_centers = [2.0 + (n-1)*0.45 - i*0.9 for i in range(n)]
    for i, ((lbl, fc, ec), yc) in enumerate(zip(outputs, y_centers)):
        arr(ax, 13.97, 2.0, 14.55, yc)
        rbox(ax, 14.55, yc-0.3, 2.7, 0.6, fc, ec, lw=2)
        t(ax, 15.9, yc, lbl, fs=9, bold=True)


# ═════════════════════════════════════════════════════════════════════════════
# FIGURE
# ═════════════════════════════════════════════════════════════════════════════
fig = plt.figure(figsize=(20, 14), facecolor=BG)
fig.patch.set_facecolor(BG)

# ─── Shared page title ───────────────────────────────────────────────────────
fig.text(0.5, 0.975,
         'MODEL ARCHITECTURE  ·  MODEL DESIGN & TOOLS',
         ha='center', va='top',
         fontsize=17, fontweight='bold', color=TEXT,
         fontfamily='monospace')

# thin horizontal rule
ax_rule = fig.add_axes([0.05, 0.963, 0.90, 0.002])
ax_rule.set_facecolor('#30363d'); ax_rule.axis('off')

# ─── MODEL 1 ─────────────────────────────────────────────────────────────────
ax1 = fig.add_axes([0.03, 0.50, 0.94, 0.455])

draw_model(
    ax=ax1,
    title='Model 1 :  Care Pathway Classifier',
    features=['sex_encoded', 'age_months_filled', 'muac_mm',
              'edema', 'appetite_encoded', 'danger_signs'],
    feat_label='INPUT FEATURES  (6)',
    params=['n_estimators = 100', 'max_depth = 10',
            'class_weight = balanced', 'random_state = 42'],
    accuracy='94.05 %',
    split_info=['Train  70 %  (2794 rows)',
                'Val    15 %  (601 rows)',
                'Test   15 %  (605 rows)'],
    blocks=[
        # Block 1
        dict(box1='Feature\nEncoding',
             diamond='Missing\nValues?',
             yes_box='Median\nImputation',
             box2='Feature\nVector (6-D)'),
        # Block 2
        dict(box1='Bootstrap\nSample',
             diamond='Max\nDepth?',
             yes_box='Gini Split\nNode',
             box2='Leaf Node\nPrediction'),
        # Block 3
        dict(box1='Collect\nVotes',
             diamond='Majority\nVote?',
             yes_box='Class\nProbabilities',
             box2=''),
    ],
    outputs=[
        ('SC - ITP  (Stabilization Center)', '#2d0d0d', '#f85149'),
        ('OTP  (Outpatient Treatment)',       '#0d2d0d', '#3fb950'),
        ('TSFP  (Supplementary Feeding)',     '#0d1a2d', '#388bfd'),
    ]
)

# feature importance bar strip (inside ax1)
fi_labels = ['muac_mm', 'appetite', 'danger', 'age', 'edema', 'sex']
fi_vals   = [0.450, 0.290, 0.172, 0.047, 0.035, 0.005]
fi_colors = ['#388bfd','#3fb950','#d29922','#bc8cff','#f85149','#6e7681']
ax1.text(17.25, 8.85, 'Feature Importance',
         fontsize=7.5, color=GREY, ha='center', va='center',
         fontweight='bold', zorder=6)
for i, (lbl, val, col) in enumerate(zip(fi_labels, fi_vals, fi_colors)):
    y_fi = 8.5 - i * 0.31
    rbox(ax1, 17.0, y_fi-0.1, val*3.8, 0.22, col, col, lw=1, z=4)
    ax1.text(16.95, y_fi, lbl, fontsize=6.5, color=GREY, ha='right', va='center')
    ax1.text(17.0+val*3.8+0.06, y_fi, f'{val:.0%}', fontsize=6.5,
             color=col, ha='left', va='center')

# ─── MODEL 2 ─────────────────────────────────────────────────────────────────
ax2 = fig.add_axes([0.03, 0.02, 0.94, 0.455])

draw_model(
    ax=ax2,
    title='Model 2 :  Quality / Confidence Classifier',
    features=['muac_mm', 'age_months', 'sex_encoded',
              'edema', 'appetite_encoded', 'danger_signs',
              'near_threshold ★', 'unit_suspect ★', 'age_suspect ★'],
    feat_label='INPUT FEATURES  (9)',
    params=['n_estimators = 100', 'max_depth = 10',
            'min_samples_split = 10', 'random_state = 42'],
    accuracy='89.2 %',
    split_info=['Train  70 %  (5665 rows)',
                'Val    15 %  (1214 rows)',
                'Test   15 %  (1214 rows)'],
    blocks=[
        dict(box1='Feature\nEncoding',
             diamond='Missing\nValues?',
             yes_box='Median\nImputation',
             box2='Feature\nVector (9-D)'),
        dict(box1='Bootstrap\nSample',
             diamond='Max\nDepth?',
             yes_box='Gini Split\nNode',
             box2='Leaf Node\nPrediction'),
        dict(box1='Collect\nVotes',
             diamond='Majority\nVote?',
             yes_box='Class\nProbabilities',
             box2=''),
    ],
    outputs=[
        ('OK  (Valid Measurement)',       '#0d2d0d', '#3fb950'),
        ('SUSPICIOUS  (Flag for Review)', '#2d0d0d', '#f85149'),
    ]
)

# feature importance bar strip (inside ax2)
fi2_labels = ['near_thresh', 'muac_mm', 'age_months', 'appetite', 'edema', 'sex', 'danger', 'unit_susp', 'age_susp']
fi2_vals   = [0.28, 0.21, 0.17, 0.12, 0.08, 0.05, 0.05, 0.03, 0.01]
fi2_colors = ['#d29922','#388bfd','#bc8cff','#3fb950','#f85149','#6e7681','#e3b341','#58a6ff','#8b949e']
ax2.text(17.25, 8.85, 'Feature Importance', fontsize=7.5,
         color=GREY, ha='center', va='center', fontweight='bold', zorder=6)
ax2.text(16.5, 8.55, '★ = derived features', fontsize=6.5,
         color='#d29922', ha='center', va='center', zorder=6)
for i, (lbl, val, col) in enumerate(zip(fi2_labels, fi2_vals, fi2_colors)):
    y_fi = 8.2 - i * 0.28
    rbox(ax2, 17.0, y_fi-0.1, val*5.5, 0.22, col, col, lw=1, z=4)
    ax2.text(16.95, y_fi, lbl, fontsize=6.2, color=GREY, ha='right', va='center')
    ax2.text(17.0+val*5.5+0.06, y_fi, f'{val:.0%}', fontsize=6.2,
             color=col, ha='left', va='center')

plt.savefig('/Users/ram/Downloads/MUAC_DEVELOPMENT/model_architecture_pro.png',
            dpi=200, bbox_inches='tight', facecolor=BG)
print("Saved: model_architecture_pro.png")
