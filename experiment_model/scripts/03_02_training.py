#!/usr/bin/env python
"""
03_02_training.py — Automated hyperparameter sweep for Thai Sign Language models.

Runs all 256 configurations (4 × 2 × 2 × 2 × 2 × 2 × 2) sequentially.
Saves every artifact to models_02/{exp_name}/ exactly as the notebook does.
Fault-tolerant: rerunning this script resumes from where training stopped.

Usage:
    python 03_02_training.py
"""

import os
import json
import time
import random
import warnings
import datetime
import platform
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from sklearn.metrics import (
    classification_report, confusion_matrix,
    precision_recall_fscore_support, top_k_accuracy_score,
)

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, regularizers

warnings.filterwarnings('ignore')

# ─── Paths ────────────────────────────────────────────────────────────────────

ROOT          = Path(__file__).parent.parent.resolve()
DATA_DIR      = ROOT / 'datasets'
DEMO_DATA_DIR = ROOT.parent / 'demo_data'
MODELS_DIR    = ROOT / 'models_02'
LOGS_DIR      = ROOT / 'logs'
STATE_FILE    = ROOT / 'experiment_state.json'

MODELS_DIR.mkdir(parents=True, exist_ok=True)
(LOGS_DIR / 'training').mkdir(parents=True, exist_ok=True)

# ─── Fixed hyperparameters ────────────────────────────────────────────────────

EPOCHS          = 200
SEED            = 42
LABEL_SMOOTHING = 0.05
MIXUP_ALPHA     = 0.1

# ─── Hyperparameter sweep (variation order defines experiment ordering) ────────

l2_reg_values       = [1e-3, 1e-4, 1e-5, 1e-6]
dropout_values      = [0.1, 0.2]
lstm_units_values   = [[128, 64, 32], [128, 64]]
learning_rate_values = [1e-3, 1e-4]
batch_size_values   = [8, 16]
model_type_values   = ['lstm', 'gru']
input_type_values   = ['oldprocessed', 'processed']


# ─── Helpers ──────────────────────────────────────────────────────────────────

def format_float(v: float) -> str:
    """Decimal representation without scientific notation or trailing zeros."""
    return f'{v:.10f}'.rstrip('0').rstrip('.')


def make_exp_name(lr, batch, input_type, model_type, dropout, l2, label_smoothing, units) -> str:
    lr_exp    = int(round(np.log10(lr)))
    units_str = '-'.join(str(u) for u in units)
    return (
        f'{lr_exp}_{batch}_{input_type}_{model_type}_'
        f'{format_float(dropout)}_{format_float(l2)}_'
        f'{format_float(label_smoothing)}_{units_str}'
    )


# ─── Experiment config generation ─────────────────────────────────────────────

def generate_experiment_configs():
    """Return the full ordered list of 256 experiment dicts."""
    configs = []
    for l2 in l2_reg_values:
        for dropout in dropout_values:
            for units in lstm_units_values:
                for lr in learning_rate_values:
                    for batch in batch_size_values:
                        for model_type in model_type_values:
                            for input_type in input_type_values:
                                name = make_exp_name(
                                    lr, batch, input_type, model_type,
                                    dropout, l2, LABEL_SMOOTHING, units,
                                )
                                configs.append({
                                    'name':           name,
                                    'learning_rate':  lr,
                                    'batch_size':     batch,
                                    'input_type':     input_type,
                                    'model_type':     model_type,
                                    'dropout_rate':   dropout,
                                    'l2_reg':         l2,
                                    'label_smoothing': LABEL_SMOOTHING,
                                    'lstm_units':     units,
                                })
    return configs


# ─── Experiment state management ──────────────────────────────────────────────

def load_training_state(total: int) -> dict:
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            state = json.load(f)
        print(f'Loaded state: {len(state["completed"])} completed, {len(state["failed"])} failed')
        return state
    return {
        'current_experiment': 0,
        'running':   None,
        'completed': [],
        'failed':    [],
        'status':    'idle',
        'total':     total,
        'started_at': datetime.datetime.now().isoformat(),
    }


def save_training_state(state: dict):
    tmp = STATE_FILE.with_suffix('.tmp')
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2))
    tmp.replace(STATE_FILE)


# ─── Data loading (cached per input_type) ─────────────────────────────────────

_data_cache: dict = {}


def load_data(input_type: str):
    """Load train/val/test splits for the given input_type. Results are cached."""
    if input_type in _data_cache:
        return _data_cache[input_type]

    print(f'  Loading data: {input_type}')

    if input_type == 'processed':
        proc       = DATA_DIR / 'processed'
        with open(proc / 'class_labels.json') as f:
            label_info = json.load(f)
        CLASSES      = label_info['classes']
        label_to_idx = label_info['class_to_label']
        idx_to_label = {int(k): v for k, v in label_info['label_to_class'].items()}
        X_train = np.load(proc / 'X_train.npy').astype(np.float32)
        X_val   = np.load(proc / 'X_val.npy').astype(np.float32)
        X_test  = np.load(proc / 'X_test.npy').astype(np.float32)
        y_train = np.load(proc / 'y_train.npy')
        y_val   = np.load(proc / 'y_val.npy')
        y_test  = np.load(proc / 'y_test.npy')
    else:  # oldprocessed
        proc       = DEMO_DATA_DIR / 'processed'
        with open(proc / 'labels.json') as f:
            label_info = json.load(f)
        CLASSES      = label_info['classes']
        label_to_idx = label_info['class_to_idx']
        idx_to_label = {int(v): k for k, v in label_info['class_to_idx'].items()}
        X_train = np.load(proc / 'X_train.npy').astype(np.float32)
        X_val   = np.load(proc / 'X_val.npy').astype(np.float32)
        X_test  = np.load(proc / 'X_test.npy').astype(np.float32)
        y_train = np.load(proc / 'y_train.npy')
        y_val   = np.load(proc / 'y_val.npy')
        y_test  = np.load(proc / 'y_test.npy')

    print(f'  X_train {X_train.shape}  X_val {X_val.shape}  X_test {X_test.shape}')

    result = (X_train, X_val, X_test, y_train, y_val, y_test,
              CLASSES, idx_to_label, label_info, label_to_idx)
    _data_cache[input_type] = result
    return result


# ─── MixUp ────────────────────────────────────────────────────────────────────

def mixup_batch(X, y, alpha=MIXUP_ALPHA):
    if alpha <= 0:
        return X, y
    lam_shape = (len(X),) + (1,) * (X.ndim - 1)
    lam       = np.random.beta(alpha, alpha, size=lam_shape)
    idx       = np.random.permutation(len(X))
    X_mix     = lam * X + (1 - lam) * X[idx]
    lam2      = lam.reshape(len(X), 1)
    y_mix     = lam2 * y + (1 - lam2) * y[idx]
    return X_mix.astype(np.float32), y_mix.astype(np.float32)


# ─── Model builder ────────────────────────────────────────────────────────────

def build_recurrent_model(input_shape, num_classes, model_type, units, dropout_rate, l2):
    cell_map = {'lstm': layers.LSTM, 'gru': layers.GRU}
    assert model_type in cell_map, f'Unknown model_type {model_type!r}'
    Cell = cell_map[model_type]
    reg  = regularizers.l2(l2)

    inp = keras.Input(shape=input_shape, name='input')
    x   = inp

    if len(input_shape) == 4:
        x = layers.TimeDistributed(
            keras.Sequential([
                layers.Conv2D(32, 3, activation='relu', padding='same'),
                layers.MaxPooling2D(2),
                layers.Conv2D(64, 3, activation='relu', padding='same'),
                layers.GlobalAveragePooling2D(),
            ]), name='cnn_stem'
        )(x)

    x = layers.BatchNormalization()(x)

    for i, u in enumerate(units):
        is_last = (i == len(units) - 1)
        x = Cell(
            u,
            return_sequences=not is_last,
            dropout=dropout_rate * 0.5,
            recurrent_dropout=dropout_rate * 0.3,
            kernel_regularizer=reg,
            name=f'{model_type}_{i}',
        )(x)
        x = layers.BatchNormalization()(x)
        x = layers.Dropout(dropout_rate)(x)

    x   = layers.Dense(64, activation='relu', kernel_regularizer=reg)(x)
    x   = layers.Dropout(dropout_rate * 0.5)(x)
    out = layers.Dense(num_classes, activation='softmax', name='output')(x)

    return keras.Model(inp, out, name=f'{model_type}_classifier')


# ─── Callbacks ────────────────────────────────────────────────────────────────

class SweepProgressCallback(keras.callbacks.Callback):
    """Prints clean per-epoch progress for the sweep runner."""

    def __init__(self, exp_idx: int, total_exps: int):
        super().__init__()
        self.exp_idx    = exp_idx
        self.total_exps = total_exps
        self.best_val_acc = 0.0

    def on_epoch_end(self, epoch, logs=None):
        logs     = logs or {}
        val_acc  = logs.get('val_accuracy', 0.0)
        if val_acc > self.best_val_acc:
            self.best_val_acc = val_acc
        total_epochs = self.params.get('epochs', EPOCHS)

        print(
            f'\nEpoch {epoch + 1}/{total_epochs}\n'
            f'loss: {logs.get("loss", 0):.4f}  '
            f'acc: {logs.get("accuracy", 0):.4f}  '
            f'val_loss: {logs.get("val_loss", 0):.4f}  '
            f'val_acc: {val_acc:.4f}\n'
            f'Best val_acc so far: {self.best_val_acc:.4f}',
            flush=True,
        )


class LearningRateLogger(keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs=None):
        if logs is not None:
            logs['lr'] = float(keras.backend.get_value(self.model.optimizer.learning_rate))


    def make_callbacks(exp_dir: Path, exp_idx: int, total_exps: int, monitor='val_loss'):
        ckpt_path = str(exp_dir / 'best_weights.weights.h5')
        return [
            keras.callbacks.EarlyStopping(
                monitor=monitor, patience=10, restore_best_weights=True, verbose=0,
            ),
            keras.callbacks.ReduceLROnPlateau(
                monitor=monitor, factor=0.5, patience=10, min_lr=1e-8, verbose=0,
            ),
            keras.callbacks.ModelCheckpoint(
                filepath=ckpt_path, monitor=monitor,
                save_best_only=True, save_weights_only=True, verbose=0,
            ),
            LearningRateLogger(),
            SweepProgressCallback(exp_idx, total_exps),
        ]


# ─── Save experiment results ──────────────────────────────────────────────────

def save_experiment_results(exp_dir, exp_name, cfg, model, history,
                             X_val, y_val, CLASSES, idx_to_label,
                             label_info, train_time) -> dict:
    hist        = history.history
    epochs_ran  = range(1, len(hist['loss']) + 1)
    NUM_CLASSES = len(CLASSES)
    BATCH_SIZE  = cfg['batch_size']

    # — Training curves —
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle(f'Training curves — {exp_name}', fontsize=14)

    axes[0].plot(epochs_ran, hist['loss'],     label='Train loss')
    axes[0].plot(epochs_ran, hist['val_loss'], label='Val loss')
    axes[0].set_title('Loss')
    axes[0].set_xlabel('Epoch')
    axes[0].legend()
    axes[0].grid(True)

    axes[1].plot(epochs_ran, hist['accuracy'],     label='Train acc')
    axes[1].plot(epochs_ran, hist['val_accuracy'], label='Val acc')
    axes[1].set_title('Accuracy')
    axes[1].set_xlabel('Epoch')
    axes[1].legend()
    axes[1].grid(True)

    if 'lr' in hist:
        axes[2].semilogy(epochs_ran, hist['lr'], color='green')
        axes[2].set_title('Learning Rate')
        axes[2].set_xlabel('Epoch')
        axes[2].grid(True)

    plt.tight_layout()
    plt.savefig(exp_dir / 'training_curves.png', dpi=150, bbox_inches='tight')
    plt.close()

    # — Evaluate on validation set —
    y_val_pred_prob = model.predict(X_val, batch_size=BATCH_SIZE, verbose=0)
    y_val_pred      = np.argmax(y_val_pred_prob, axis=1)
    y_val_true      = y_val.astype(int)

    prec, rec, f1, sup = precision_recall_fscore_support(
        y_val_true, y_val_pred, average=None, labels=list(range(NUM_CLASSES))
    )
    prec_m, rec_m, f1_m, _ = precision_recall_fscore_support(
        y_val_true, y_val_pred, average='macro'
    )
    acc_val  = float(np.mean(y_val_pred == y_val_true))
    top3_val = top_k_accuracy_score(y_val_true, y_val_pred_prob, k=3)

    METRICS = {
        'accuracy':        round(acc_val, 4),
        'top3_accuracy':   round(top3_val, 4),
        'macro_precision': round(prec_m, 4),
        'macro_recall':    round(rec_m,  4),
        'macro_f1':        round(f1_m,   4),
        'per_class': {
            CLASSES[i]: {
                'precision': round(float(prec[i]), 4),
                'recall':    round(float(rec[i]),  4),
                'f1':        round(float(f1[i]),   4),
                'support':   int(sup[i]),
            }
            for i in range(NUM_CLASSES)
        },
    }
    print(f'  Val acc: {acc_val:.4f}  Top-3: {top3_val:.4f}  Macro F1: {f1_m:.4f}')
    print()
    print(classification_report(y_val_true, y_val_pred, target_names=CLASSES))

    # — Confusion matrices —
    cm      = confusion_matrix(y_val_true, y_val_pred)
    cm_norm = cm.astype(float) / cm.sum(axis=1, keepdims=True)

    fig, axes = plt.subplots(1, 2, figsize=(18, 7))
    for ax, data, title, fmt in zip(
        axes,
        [cm, cm_norm],
        ['Confusion Matrix (counts)', 'Confusion Matrix (normalised)'],
        ['d', '.2f'],
    ):
        sns.heatmap(data, ax=ax, annot=True, fmt=fmt, cmap='Blues',
                    xticklabels=CLASSES, yticklabels=CLASSES, linewidths=0.5)
        ax.set_xlabel('Predicted')
        ax.set_ylabel('True')
        ax.set_title(title)
        ax.tick_params(axis='x', rotation=45)
    plt.suptitle(f'Confusion Matrix — {exp_name}', fontsize=14)
    plt.tight_layout()
    plt.savefig(exp_dir / 'confusion_matrix.png', dpi=150, bbox_inches='tight')
    plt.close()

    # — Per-class metrics bar chart —
    x = np.arange(NUM_CLASSES)
    w = 0.25
    fig, ax = plt.subplots(figsize=(14, 5))
    ax.bar(x - w, prec, w, label='Precision')
    ax.bar(x,     rec,  w, label='Recall')
    ax.bar(x + w, f1,   w, label='F1')
    ax.set_xticks(x)
    ax.set_xticklabels(CLASSES, rotation=45, ha='right')
    ax.set_ylim(0, 1.05)
    ax.set_ylabel('Score')
    ax.set_title(f'Per-class Metrics — {exp_name}')
    ax.legend()
    ax.grid(axis='y', alpha=0.4)
    plt.tight_layout()
    plt.savefig(exp_dir / 'per_class_metrics.png', dpi=150, bbox_inches='tight')
    plt.close()

    # — Analysis summary —
    cm_offdiag = cm.copy()
    np.fill_diagonal(cm_offdiag, 0)
    flat_idx       = np.argsort(cm_offdiag.ravel())[::-1][:10]
    confused_pairs = []
    for idx in flat_idx:
        r, c = divmod(int(idx), NUM_CLASSES)
        if cm_offdiag[r, c] > 0:
            confused_pairs.append({'true': CLASSES[r], 'pred': CLASSES[c], 'count': int(cm_offdiag[r, c])})

    sorted_f1 = sorted(enumerate(f1), key=lambda x: x[1])
    weakest   = [CLASSES[i] for i, _ in sorted_f1[:3]]
    strongest = [CLASSES[i] for i, _ in sorted_f1[-3:][::-1]]

    best_val     = max(hist.get('val_accuracy', [0]))
    final_train  = hist.get('accuracy', [0])[-1]
    gap          = final_train - best_val

    ANALYSIS = {
        'most_confused_pairs': confused_pairs,
        'weakest_classes':     weakest,
        'strongest_classes':   strongest,
        'overfitting':  {'detected': gap > 0.15,   'train_val_gap': round(float(gap), 4)},
        'underfitting': {'detected': best_val < 0.60, 'best_val_acc': round(float(best_val), 4)},
    }

    # — Inference validation sample —
    N_SAMPLES = min(8, len(X_val))
    rng_idx   = np.random.choice(len(X_val), N_SAMPLES, replace=False)
    X_sample  = X_val[rng_idx]
    y_sample  = y_val_true[rng_idx]
    probs     = model.predict(X_sample, verbose=0)
    preds     = np.argmax(probs, axis=1)
    confs     = probs[np.arange(N_SAMPLES), preds]

    INFERENCE_RESULTS = []
    for i in range(N_SAMPLES):
        entry = {
            'index':        int(rng_idx[i]),
            'ground_truth': idx_to_label[int(y_sample[i])],
            'predicted':    idx_to_label[int(preds[i])],
            'confidence':   round(float(confs[i]), 4),
            'correct':      bool(y_sample[i] == preds[i]),
        }
        INFERENCE_RESULTS.append(entry)
        status = '✓' if entry['correct'] else '✗'
        print(f"  {status} GT={entry['ground_truth']:12s}  Pred={entry['predicted']:12s}  Conf={entry['confidence']:.3f}")

    # keypoint temporal norm plot (non-video inputs)
    if len(X_val.shape) == 3:
        fig, axes_inf = plt.subplots(N_SAMPLES, 1, figsize=(16, 2 * N_SAMPLES), sharex=True)
        if N_SAMPLES == 1:
            axes_inf = [axes_inf]
        for i, ax in enumerate(axes_inf):
            motion = np.linalg.norm(X_sample[i], axis=1)
            ax.plot(motion, linewidth=0.8)
            c = 'green' if INFERENCE_RESULTS[i]['correct'] else 'red'
            ax.set_ylabel(INFERENCE_RESULTS[i]['ground_truth'], fontsize=7, color=c)
            ax.set_title(
                f"Pred: {INFERENCE_RESULTS[i]['predicted']}  conf={INFERENCE_RESULTS[i]['confidence']:.2f}",
                fontsize=7, color=c,
            )
            ax.tick_params(labelsize=6)
        plt.suptitle('Inference — temporal keypoint norm', fontsize=12)
        plt.tight_layout()
        plt.savefig(exp_dir / 'inference_validation.png', dpi=120, bbox_inches='tight')
        plt.close()

    # — Save model weights & architecture —
    model.save(str(exp_dir / 'saved_model.keras'))
    (exp_dir / 'architecture.json').write_text(model.to_json(indent=2))
    (exp_dir / 'label_encoder.json').write_text(json.dumps(label_info, ensure_ascii=False, indent=2))
    print('  ✓ Model saved successfully')

    # — Save JSON artifacts —
    CONFIG = {
        'exp_name':      exp_name,
        'input_type':    cfg['input_type'],
        'model_type':    cfg['model_type'],
        'batch_size':    cfg['batch_size'],
        'learning_rate': cfg['learning_rate'],
        'num_classes':   NUM_CLASSES,
        'input_shape':   list(X_val.shape[1:]),
        'seed':          SEED,
        'timestamp':     datetime.datetime.now().isoformat(),
    }
    HYPERPARAMS = {
        'lstm_units':      cfg['lstm_units'],
        'dropout_rate':    cfg['dropout_rate'],
        'l2_reg':          cfg['l2_reg'],
        'label_smoothing': cfg['label_smoothing'],
        'mixup_alpha':     MIXUP_ALPHA,
        'epochs_total':    EPOCHS,
        'epochs_ran':      len(hist['loss']),
    }

    (exp_dir / 'config.json').write_text(json.dumps(CONFIG,             ensure_ascii=False, indent=2))
    (exp_dir / 'hyperparams.json').write_text(json.dumps(HYPERPARAMS,   ensure_ascii=False, indent=2))
    (exp_dir / 'metrics.json').write_text(json.dumps(METRICS,           ensure_ascii=False, indent=2))
    (exp_dir / 'inference_results.json').write_text(json.dumps(INFERENCE_RESULTS, ensure_ascii=False, indent=2))
    (exp_dir / 'analysis_summary.json').write_text(json.dumps(ANALYSIS, ensure_ascii=False, indent=2))
    print('  ✓ Metrics saved successfully')

    # — Training log —
    gpu_info = []
    for g in tf.config.list_physical_devices('GPU'):
        try:
            details = tf.config.experimental.get_device_details(g)
            gpu_info.append(details.get('device_name', g.name))
        except Exception:
            gpu_info.append(g.name)

    LOG_ENTRY = {
        'exp_name':            exp_name,
        'timestamp':           CONFIG['timestamp'],
        'tensorflow_version':  tf.__version__,
        'platform':            platform.platform(),
        'gpu':                 gpu_info or ['CPU only'],
        'training_time_min':   round(train_time / 60, 2),
        'epochs_ran':          HYPERPARAMS['epochs_ran'],
        'val_accuracy':        METRICS['accuracy'],
        'top3_accuracy':       METRICS['top3_accuracy'],
        'macro_precision':     METRICS['macro_precision'],
        'macro_recall':        METRICS['macro_recall'],
        'macro_f1':            METRICS['macro_f1'],
        'lr_history':          [round(v, 8) for v in hist.get('lr', [])],
        'train_acc_history':   [round(v, 4) for v in hist.get('accuracy', [])],
        'val_acc_history':     [round(v, 4) for v in hist.get('val_accuracy', [])],
    }
    log_path = LOGS_DIR / 'training' / f'{exp_name}.json'
    log_path.write_text(json.dumps(LOG_ENTRY, ensure_ascii=False, indent=2))
    print('  ✓ Training history saved successfully')

    return METRICS


# ─── Train a single experiment ────────────────────────────────────────────────

def train_single_experiment(exp_idx: int, cfg: dict, total_exps: int) -> dict:
    exp_name = cfg['name']
    exp_dir  = MODELS_DIR / exp_name
    exp_dir.mkdir(parents=True, exist_ok=True)

    print()
    print('=' * 50)
    print(f'Experiment {exp_idx + 1}/{total_exps}')
    print(f'Model: {cfg["model_type"].upper()}')
    print(f'Input Type: {cfg["input_type"]}')
    print(f'Batch Size: {cfg["batch_size"]}')
    print(f'Learning Rate: {cfg["learning_rate"]}')
    print(f'Dropout: {cfg["dropout_rate"]}')
    print(f'L2: {cfg["l2_reg"]}')
    print(f'Units: {cfg["lstm_units"]}')
    print('=' * 50)

    os.environ['PYTHONHASHSEED'] = str(SEED)
    random.seed(SEED)
    np.random.seed(SEED)
    tf.random.set_seed(SEED)

    (X_train, X_val, X_test, y_train, y_val, y_test,
     CLASSES, idx_to_label, label_info, label_to_idx) = load_data(cfg['input_type'])

    NUM_CLASSES = len(CLASSES)
    INPUT_SHAPE = X_train.shape[1:]

    # MixUp + tf.data pipelines
    y_train_oh          = tf.keras.utils.to_categorical(y_train, NUM_CLASSES)
    y_val_oh            = tf.keras.utils.to_categorical(y_val,   NUM_CLASSES)
    X_train_m, y_train_m = mixup_batch(X_train, y_train_oh)

    train_ds = (
        tf.data.Dataset.from_tensor_slices((X_train_m, y_train_m))
        .shuffle(len(X_train_m), seed=SEED)
        .batch(cfg['batch_size'])
        .prefetch(tf.data.AUTOTUNE)
    )
    val_ds = (
        tf.data.Dataset.from_tensor_slices((X_val, y_val_oh))
        .batch(cfg['batch_size'])
        .prefetch(tf.data.AUTOTUNE)
    )

    # Build & compile
    tf.keras.backend.clear_session()
    model = build_recurrent_model(
        input_shape  = INPUT_SHAPE,
        num_classes  = NUM_CLASSES,
        model_type   = cfg['model_type'],
        units        = cfg['lstm_units'],
        dropout_rate = cfg['dropout_rate'],
        l2           = cfg['l2_reg'],
    )

    model.compile(
        optimizer = keras.optimizers.Adam(learning_rate=cfg['learning_rate']),
        loss      = keras.losses.CategoricalCrossentropy(label_smoothing=cfg['label_smoothing']),
        metrics   = [
            'accuracy',
            keras.metrics.TopKCategoricalAccuracy(k=3, name='top3_acc'),
        ],
    )

    callbacks = make_callbacks(exp_dir, exp_idx, total_exps)

    t0 = time.time()
    history = model.fit(
        train_ds,
        validation_data = val_ds,
        epochs          = EPOCHS,
        callbacks       = callbacks,
        verbose         = 0,
    )
    train_time = time.time() - t0
    print(f'\n  Training time: {train_time / 60:.1f} min')

    metrics = save_experiment_results(
        exp_dir, exp_name, cfg, model, history,
        X_val, y_val, CLASSES, idx_to_label, label_info, train_time,
    )

    del model
    tf.keras.backend.clear_session()

    return metrics


# ─── Resume / continue logic ──────────────────────────────────────────────────

def is_complete(cfg: dict) -> bool:
    """True if metrics.json already exists (experiment finished successfully)."""
    return (MODELS_DIR / cfg['name'] / 'metrics.json').exists()


def resume_or_continue():
    all_configs = generate_experiment_configs()
    total       = len(all_configs)
    state       = load_training_state(total)

    print(f'\nTotal experiments : {total}')
    print(f'Completed so far  : {len(state["completed"])}')
    print(f'Failed            : {len(state["failed"])}')

    for idx, cfg in enumerate(all_configs):
        exp_name = cfg['name']

        # Already successfully completed
        if exp_name in state['completed']:
            continue

        # Artifacts present but not in state (e.g. from a previous run of an older version)
        if is_complete(cfg):
            print(f'  [skip] {exp_name} — artifacts found, marking complete')
            state['completed'].append(exp_name)
            save_training_state(state)
            continue

        # Was marked running when the process last died
        if state.get('running') == exp_name:
            print(f'\n  [resume] Experiment {idx + 1}/{total} was interrupted — retraining')

        # Mark as in-progress
        state['current_experiment'] = idx
        state['running']            = exp_name
        state['status']             = 'running'
        save_training_state(state)

        try:
            train_single_experiment(idx, cfg, total)

            state['completed'].append(exp_name)
            state['running'] = None
            state['status']  = 'idle'
            save_training_state(state)
            print(f'  ✓ Experiment completed\n')

        except KeyboardInterrupt:
            print(f'\n  Interrupted at experiment {idx + 1}/{total} — '
                  'state saved, rerun to resume.')
            state['status'] = 'interrupted'
            save_training_state(state)
            raise

        except Exception as exc:
            print(f'\n  ERROR in {exp_name}: {exc}')
            state['failed'].append({'name': exp_name, 'error': str(exc), 'idx': idx})
            state['running'] = None
            state['status']  = 'idle'
            save_training_state(state)

    state['status']       = 'done'
    state['finished_at']  = datetime.datetime.now().isoformat()
    save_training_state(state)

    print(f'\nAll {total} experiments finished.')
    print(f'  Completed : {len(state["completed"])}')
    print(f'  Failed    : {len(state["failed"])}')


# ─── Entry point ──────────────────────────────────────────────────────────────

def main():
    print('TensorFlow:', tf.__version__)
    print('GPU devices:', tf.config.list_physical_devices('GPU'))
    for gpu in tf.config.list_physical_devices('GPU'):
        tf.config.experimental.set_memory_growth(gpu, True)
    resume_or_continue()


if __name__ == '__main__':
    main()
