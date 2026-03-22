# 1. Use the official Deno image as a temporary builder
FROM denoland/deno:bin AS deno_binary

# 2. Switch to a Debian-based Python slim image
FROM python:3.12-slim

# 3. Install system dependencies
# ffmpeg: For video/audio merging
# atomicparsley: For metadata/thumbnails
# ca-certificates: For secure downloads
RUN apt-get update && apt-get install -y \
    ffmpeg \
    atomicparsley \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy the Deno binary from the official image
COPY --from=deno_binary /deno /usr/local/bin/deno

# 5. Install the yt-dlp nightly build
# No need for --break-system-packages on Debian slim with pip
RUN pip install --no-cache-dir --pre "yt-dlp[default,deno]"

#6. Set up the non-root user and make it the active user
RUN addgroup --gid 1000 ytgroup && \
    adduser --disabled-password --uid 1000 -gid 1000 ytuser 

#7. create directories to be used by ytdlp and give it ownership
RUN mkdir -p /downloads && \
    chmod 777 /downloads && \
    chown -R ytuser:ytgroup /downloads && \
    mkdir -p /ytdlp_cache && \
    chmod 777 /ytdlp_cache && \
    chown -R ytuser:ytgroup /ytdlp_cache

USER ytuser

# 8. Setup workspace
WORKDIR /downloads

# 9. Define the execution point
ENTRYPOINT ["yt-dlp"]

