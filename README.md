# Comparative Study on Convolutional and Vision Transformer Architectures for Subject-Independent Motor Imagery Decoding

[![Python 3.10](https://img.shields.io/badge/Python-3.10-blue.svg)](https://www.python.org/downloads/release/python-3100/)
[![TensorFlow 2.10.1](https://img.shields.io/badge/TensorFlow-2.10.1-orange.svg)](https://www.tensorflow.org/versions/r2.10)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: Under Review](https://img.shields.io/badge/Journal-JNEUMETH--D--26--00712-green.svg)](https://www.sciencedirect.com/journal/journal-of-neuroscience-methods)

This repository hosts the official implementation and reproducible experimental pipeline for the manuscript:
> **"A Comparative Study on Convolutional and Transformer Architectures for Subject-Independent Motor Imagery Decoding"**  
> Under revision at *Journal of Neuroscience Methods* (Manuscript Ref: `JNEUMETH-D-26-00712`).

---

## 📌 Overview & Key Scientific Contributions

Subject-independent Motor Imagery Brain-Computer Interfaces (MI-BCIs) face severe domain-shift challenges due to high inter-subject anatomical and electrophysiological variability. This study systematically compares three prominent neural architectures under a strict **subject-independent cross-validation protocol**:

1. **EEGNet**: Compact Depthwise & Separable Convolutional Neural Network.
2. **CvT (Convolutional Vision Transformer)**: Hybrid model leveraging multi-head self-attention with convolutional token projections.
3. **ViT-PE (Vision Transformer with Positional Embeddings)**: Pure self-attention sequence model with learnable spatial-temporal patch encoders.

### Key Highlights
- **Rigorous Evaluation**: Evaluated across 3 signal representations (**Raw**, **Filtered 8–30 Hz**, and **Filtered 8–13 Hz**) using a 27-channel standard sensorimotor montage.
- **Statistical Significance**: Validated via paired $t$-tests, Wilcoxon signed-rank tests, and Cohen’s $d$ effect sizes across folds.
- **Computational Benchmark**: Detailed profile of trainable parameters, memory footprint, and single-trial CPU inference latency for real-time BCI feasibility.
- **Explainable AI (XAI)**: Model interpretability confirmed through systematic **27-Channel Occlusion Sensitivity Analysis**, demonstrating clear neurophysiological convergence on primary sensorimotor and parietal cortex regions ($C3$, $C4$, $CP3$, $P4$).

---

## 📁 Repository Structure

```
MotorImagery-BCI/
│
├── PreProcessing/                  # MATLAB / EEGLAB signal conditioning scripts
│   ├── Raw_Signal_Processing.m         # 0.5 Hz high-pass, artifact cleaning, channel selection
│   ├── PreProcessed_FilteredData_8_30Hz.m  # Bandpass 8–30 Hz (Mu + Beta rhythms)
│   └── PreProcessed_FilteredData_8_13Hz.m  # Bandpass 8–13 Hz (Mu rhythm isolation)
│
├── Bridge/                         # Array conversion from MATLAB to NumPy
│   └── Convert Mat Files to NPY Files.ipynb
│
├── Metadata/                       # Cohort trial-to-subject metadata mappings
│   ├── dataset_metadata_raw.csv
│   ├── dataset_metadata_filtered.csv
│   └── dataset_metadata_8_13Hz.csv
│
├── Models/                         # Deep Learning model definitions and training loops
│   ├── EEGNet.ipynb                    # Compact spatial-temporal CNN
│   ├── CvT.ipynb                       # Convolutional Vision Transformer
│   └── ViT-PE.ipynb                    # Vision Transformer with Patch Embeddings
│
├── Analysis/                       # Post-hoc evaluation, statistics, benchmarks & XAI
│   ├── 01_statistical_analysis.ipynb   # Paired statistical hypothesis tests & Cohen's d
│   ├── 02_computational_complexity.ipynb # Inference latency & parameter benchmarks
│   ├── 03_channel_occlusion_xai.ipynb  # Systematic 27-channel occlusion sensitivity
│   ├── Hyperparameter Tuning.ipynb     # Optuna study for Bayesian hyperparameter search
│   ├── Generate_Plots.ipynb            # ROC-AUC curves & Confusion Matrices
│   ├── XAI.ipynb                       # Gradient-based saliency maps
│   ├── computational_complexity_summary.csv
│   ├── statistical_significance_results.csv
│   ├── summary_fold_performance.csv
│   └── xai_outputs/                    # High-resolution vector & raster figures
│       ├── channel_occlusion_comparison.pdf
│       ├── channel_occlusion_comparison.png
│       └── channel_occlusion_importance_summary.csv
│
├── results/                        # Raw fold-by-fold metric outputs (CSV)
│   ├── eegnet_results_*.csv
│   ├── cvt_results_*.csv
│   └── vit_pe_results_*.csv
│
├── requirements.txt                # Pinned Python package dependencies
├── LICENSE                         # Open-source MIT License
└── README.md                       # Repository documentation
```

---

## 🔬 Experimental Pipeline

```
 ┌────────────────────────────────────────────────────────┐
 │ 1. MATLAB / EEGLAB Preprocessing                       │
 │    - 27 Sensorimotor Channels                          │
 │    - Bandpass Filtering (Raw, 8-30 Hz, 8-13 Hz)        │
 │    - Channel-wise Z-score Normalization (2560 samples) │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 2. NumPy Serialization & Metadata Generation           │
 │    - Convert .mat trials to .npy arrays                │
 │    - Group trials by Subject ID and Class Label        │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 3. Subject-Independent 5-Fold Cross-Validation         │
 │    - GroupKFold partitioning by subject                │
 │    - Train & Evaluate: EEGNet, CvT, ViT-PE             │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 4. Statistical, Complexity, and Interpretability Post-Hoc │
 │    - Paired hypothesis testing (t-test, Wilcoxon, d)   │
 │    - Single-trial latency & parameter profiling        │
 │    - Systematic 27-channel occlusion sensitivity (XAI) │
 └────────────────────────────────────────────────────────┘
```

---

## 🛠️ Installation & Environment Setup

### 1. Prerequisites
- **Python**: `3.10` (Python $\le 3.10$ is required for TensorFlow 2.10.x compatibility).
- **MATLAB** (Optional, only needed if re-running raw preprocessing from `.cnt`/`.mat` recordings): EEGLAB `v2024.2` or later.

### 2. Clone the Repository
```bash
git clone https://github.com/YourUsername/MotorImagery-BCI.git
cd MotorImagery-BCI
```

### 3. Setup Virtual Environment
It is strongly recommended to use a dedicated virtual environment or Conda environment:

```bash
# Using conda
conda create -n mi-bci python=3.10 -y
conda activate mi-bci

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 🚀 Execution & Reproducibility Guide

### Step 1: Preprocessing & Data Serialization (Optional)
If you are starting from raw EEG data:
1. Run the MATLAB scripts in `PreProcessing/` to generate baseline and filtered `.mat` trial structures.
2. Execute `Bridge/Convert Mat Files to NPY Files.ipynb` to structure the `.npy` files and create the cohort manifest under `Metadata/`.

> **Data Availability**: Preprocessed sample arrays can be organized into `Raw/`, `Filtered_8_30Hz/`, and `Filtered_8_13Hz/` at the root directory.

### Step 2: Model Training (Subject-Independent GroupKFold)
Train each model architecture across datasets:
```bash
# Launch Jupyter Lab
jupyter lab
```
Run `Models/EEGNet.ipynb`, `Models/CvT.ipynb`, or `Models/ViT-PE.ipynb`.  
Each notebook uses `GroupKFold(n_splits=5)` grouped strictly by `subject`, saving model weights to `models/{architecture}_{dataset}_fold{k}.h5` and recording fold scores to `results/`.

### Step 3: Statistical Rigor & Hypothesis Testing
Run `Analysis/01_statistical_analysis.ipynb`.  
This notebook aggregates all 9 fold result sets and computes:
- Metric summaries ($\text{Mean} \pm \text{SD}$) for Accuracy, Precision, Recall, F1-Score, and AUC.
- Paired Student's $t$-tests and Wilcoxon signed-rank tests across models.
- Cohen’s $d$ effect sizes ($<0.2$ negligible, $\ge 0.2$ small, $\ge 0.5$ medium, $\ge 0.8$ large).
- Outputs saved to `Analysis/statistical_significance_results.csv`.

### Step 4: Computational Complexity & Real-Time Feasibility
Run `Analysis/02_computational_complexity.ipynb`.  
This evaluates:
- Number of trainable parameters and memory footprint (MB).
- Warm-up and benchmarked single-trial inference latency on CPU (`tf.device('/CPU:0')`).
- Outputs: `Analysis/computational_complexity_summary.csv` and publication figures (`.pdf` / `.png`).

### Step 5: Explainable AI (Channel Occlusion Sensitivity)
Run `Analysis/03_channel_occlusion_xai.ipynb`.  
- **Methodology**: Systematically zeros out each of the 27 sensorimotor channels individually across a balanced validation trial set (100 Left, 100 Right).
- **Metric**: Quantifies accuracy drop ($\Delta \text{Acc} = \text{Acc}_{\text{Baseline}} - \text{Acc}_{\text{Occluded}}$).
- **Custom Deserialization**: Automatically handles custom Keras layers (`Patches`, `PatchEncoder`, `SinusoidalPositionEmbedding`) across CvT and ViT-PE.
- Outputs saved to `Analysis/xai_outputs/`.

---

## 📊 Summary of Benchmark Findings

| Model | Dataset | Trainable Params | Model Size (MB) | CPU Latency (ms) | Real-Time Capable (<100 ms) |
|---|---|:---:|:---:|:---:|:---:|
| **EEGNet** | Raw / Filtered | 45,570 | ~0.59 | 14.5 ± 1.2 | ✅ Yes |
| **CvT** | Filtered 8–30 Hz | ~1.31 M | ~5.32 | 48.7 ± 3.4 | ✅ Yes |
| **ViT-PE** | Filtered 8–30 Hz | ~3.84 M | ~15.20 | 82.1 ± 5.6 | ✅ Yes |

*All evaluated architectures execute well within typical BCI epoch sliding windows (e.g., 250–500 ms).*

---

## 🧠 Sensor Montage (27 Channels)

The following motor and pre-motor standard 10–20 electrode montage is utilized:
```
F3,  Fz,  F4,
FC5, FC3, FC1, FCz, FC2, FC4, FC6,
C5,  C3,  C1,  Cz,  C2,  C4,  C6,
CP5, CP3, CP1, CPz, CP2, CP4, CP6,
P3,  Pz,  P4
```

---

## 📜 Citation

If you use this code, data structures, or benchmark results in your research, please cite our manuscript:

```bibtex
@article{abdollahi2026comparative,
  title={A Comparative Study on Convolutional and Transformer Architectures for Subject-Independent Motor Imagery Decoding},
  author={Abdollahi, Armin and Kasaeian, Sarina and Keyhanmehr, [Co-author Name]},
  journal={Journal of Neuroscience Methods},
  volume={Under Revision},
  pages={JNEUMETH-D-26-00712},
  year={2026}
}
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
