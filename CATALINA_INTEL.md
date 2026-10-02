# UVR en macOS Catalina Intel

Esta variante está pensada para **macOS Catalina 10.15 + Mac Intel x86_64**.

El bundle oficial de UVR 5.6 no garantiza Catalina. Por eso esta ruta usa una instalación Python aislada y evita la dependencia `onnxruntime-gpu`, que no corresponde en macOS Intel sin CUDA.

## Requisitos

- Mac Intel (`x86_64`)
- macOS Catalina 10.15
- Python 3.9 o 3.10 de 64 bits
- Espacio libre para modelos
- FFmpeg recomendado para MP3/M4A

Python 3.9 y 3.10 tuvieron instaladores oficiales para macOS 10.9 o posterior, por lo que son una base más apropiada para Catalina que depender del bundle de UVR.

## Instalación

Desde Terminal:

```bash
git clone https://github.com/sebastisnzoth/ultimatevocalremovergui.git
cd ultimatevocalremovergui
git checkout fix/macos-catalina-intel-install
chmod +x install_macos_catalina_intel.sh
./install_macos_catalina_intel.sh
```

El script crea un entorno separado llamado:

```
.venv-catalina
```

y no modifica el Python del sistema.

## Abrir UVR

```bash
./run_uvr_catalina.command
```

También se puede abrir `run_uvr_catalina.command` desde Finder después de darle permiso de ejecución.

## Para separar voz e instrumental con máxima calidad

Dentro de UVR, priorizá modelos de separación **Vocals / Instrumental**. Los modelos más pesados suelen producir mejor aislamiento, pero en este Mac Intel funcionarán por CPU y pueden tardar bastante.

Para conservar calidad:

- Entrada: WAV/FLAC si está disponible.
- Salida: WAV.
- Evitar recomprimir a MP3 durante la separación.
- Si aparece error de memoria, reducir Segment/Window.

## FFmpeg

Comprobá:

```bash
ffmpeg -version
```

Si no existe, instalalo antes de procesar MP3/M4A.

## Diagnóstico

```bash
source .venv-catalina/bin/activate
python --version
python -c "import torch; print(torch.__version__)"
python -c "import onnxruntime; print(onnxruntime.__version__)"
python UVR.py
```

## Alcance

Este ajuste no altera la lógica de separación de UVR ni los modelos. Solo añade una ruta de instalación aislada y compatible con el escenario Catalina + Intel.
