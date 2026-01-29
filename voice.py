import subprocess
import tempfile
import os
import re
import sounddevice as sd
import soundfile as sf

MODEL = "tts/models/en_US-hfc_female-medium.onnx"
PIPER_EXE = os.environ.get("PIPER_EXE", r"C:\Program Files\piper\piper.exe")

def clean_text(text):
    # Piper hates emojis / unicode
    text = re.sub(r"[^\x00-\x7F]+", "", text)
    return text.strip()

def speak(text):
    text = clean_text(text)
    if not text:
        return

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        wav = f.name

    try:
        subprocess.run(
            [PIPER_EXE, "--model", MODEL, "--output_file", wav],
            input=text,
            text=True,
            encoding="utf-8",
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True
        )

        data, fs = sf.read(wav, dtype="float32")
        sd.play(data, fs)
        sd.wait()

    except Exception as e:
        print("🔇 TTS error:", e)

    finally:
        if os.path.exists(wav):
            os.remove(wav)
