# Stage 1: Build piper-tts
FROM debian:stable-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y wget tar

# Download and extract piper-tts
RUN wget https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz -O piper.tar.gz && \
    tar -xvf piper.tar.gz

# Stage 2: Final application image
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy piper executable from the builder stage
COPY --from=builder /piper/piper /usr/local/bin/

# Set the PIPER_EXE environment variable
ENV PIPER_EXE=/usr/local/bin/piper

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# --- Notes ---
# This Dockerfile has some limitations:
# 1. Ollama Dependency: This application requires the Ollama service to be running and accessible
#    from this container. You will need to run Ollama separately (e.g., in another Docker container)
#    and ensure the network is configured correctly.
#
# 2. Audio Hardware: This application uses the 'sounddevice' and 'mic' libraries which require access
#    to the host's audio hardware. By default, Docker containers do not have this access.
#    To enable audio, you may need to run the container with additional flags like:
#    --device /dev/snd
#    This is for Linux hosts. Audio on other operating systems might require different configurations.
#    Without audio hardware access, the text-to-speech and microphone functionalities will not work.
#
# Command to run the application
CMD ["python", "main.py"]
