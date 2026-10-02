#!/bin/bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$APP_DIR"

echo "UVR Catalina Intel installer"
echo "============================"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: este instalador es solo para macOS."
  exit 1
fi

ARCH="$(uname -m)"
if [ "$ARCH" != "x86_64" ]; then
  echo "ERROR: se esperaba Mac Intel x86_64 y se detectó: $ARCH"
  exit 1
fi

MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || true)"
echo "macOS detectado: $MACOS_VERSION"
echo "Arquitectura: $ARCH"

PYTHON=""
for candidate in python3.10 python3.9 python3; do
  if command -v "$candidate" >/dev/null 2>&1; then
    ver="$($candidate -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    case "$ver" in
      3.9|3.10)
        PYTHON="$candidate"
        break
        ;;
    esac
  fi
done

if [ -z "$PYTHON" ]; then
  echo
  echo "ERROR: UVR necesita Python 3.9 o 3.10 para esta instalación."
  echo "Instalá Python 3.9/3.10 para macOS Intel desde python.org y volvé a ejecutar:"
  echo "  ./install_macos_catalina_intel.sh"
  exit 2
fi

echo "Python: $($PYTHON --version)"

# Mantener temporales y caché junto al proyecto. En Macs con poco espacio
# interno, /var/folders puede llenarse aunque UVR esté en un disco externo.
WORK_ROOT="$APP_DIR/.install-work"
export TMPDIR="$WORK_ROOT/tmp"
export PIP_CACHE_DIR="$WORK_ROOT/pip-cache"
mkdir -p "$TMPDIR" "$PIP_CACHE_DIR"
echo "Temporales: $TMPDIR"
echo "Cache pip:  $PIP_CACHE_DIR"

VENV_DIR=".venv-catalina"
if [ ! -d "$VENV_DIR" ]; then
  "$PYTHON" -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
python -m pip install --upgrade "pip<24.1" setuptools wheel

TMP_REQ="$WORK_ROOT/requirements-catalina.txt"

# onnxruntime-gpu no corresponde en un Mac Intel sin CUDA.
# Usamos onnxruntime CPU para evitar una dependencia que no puede funcionar aquí.
grep -v '^onnxruntime-gpu' requirements.txt > "$TMP_REQ"

echo
echo "Instalando dependencias de UVR para CPU..."
python -m pip install --no-cache-dir -r "$TMP_REQ"

echo
if command -v ffmpeg >/dev/null 2>&1; then
  echo "FFmpeg OK: $(command -v ffmpeg)"
else
  echo "AVISO: FFmpeg no está instalado."
  echo "UVR podrá fallar con MP3/M4A hasta que instales ffmpeg."
fi

cat > run_uvr_catalina.command <<'EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")"
source .venv-catalina/bin/activate
exec python UVR.py
EOF
chmod +x run_uvr_catalina.command

echo
echo "Instalación terminada."
echo "Para abrir UVR:"
echo "  ./run_uvr_catalina.command"
echo
echo "La primera ejecución puede tardar mientras UVR prepara/descarga modelos."
