# VideoDownloader - Dockerized yt-dlp for High-Quality Video Downloads

> A production-ready Docker container for downloading videos with yt-dlp, optimized for 4K HEVC content with Plex/Apple TV compatibility.

## 🎯 Features

- **4K HEVC Priority** - Automatically selects the best quality (2160p → HEVC → fallback)
- **Plex Optimized** - Organized by artist/uploader with embedded metadata
- **Secure & Isolated** - Runs as non-root user with minimal privileges
- **High Performance** - 4GB RAM disk for fragment merging, concurrent downloads
- **Deno Support** - Handles sites requiring JavaScript execution
- **Batch Processing** - Download multiple videos from a URL list
- **Smart Metadata** - Embeds thumbnails, chapters, and artist information

## 📋 Prerequisites

- Docker
- Docker Compose

## 🚀 Quick Start

### 1. Clone or Download

```bash
git clone <your-repo-url>
cd VideoDownloader
```

### 2. Build the Image

```bash
docker compose build yt-dlp
```

### 3. Download a Video

**Single URL:**
```bash
docker compose run --rm yt-dlp https://youtu.be/YOUR_VIDEO_ID
```

**Batch from `urls.txt`:**
```bash
docker compose run --rm yt-dlp --batch-file urls.txt
```

### 4. Find Your Videos

Downloads appear in the project directory, organized like:
```
VideoDownloader/
├── Artist Name/
│   └── Song Title - video.mp4
└── Another Artist/
    └── Another Song - video.mp4
```

## 📝 Configuration

### URLs File (`urls.txt`)

Add one video URL per line:
```
https://youtu.be/VIDEO_ID_1
https://youtu.be/VIDEO_ID_2
```

### yt-dlp Configuration (`yt-dlp.conf`)

The container uses a pre-configured setup optimized for:
- **Format**: 2160p HEVC with M4A audio, MP4 container
- **Organization**: `Artist/Song Title - video.mp4`
- **Metadata**: Embedded thumbnails, chapters, and artist tags
- **Performance**: 5 concurrent fragment downloads, tmpfs merging
- **Error Handling**: Continues on failures (batch mode)

Key settings:
```conf
--format-sort "res:2160,vcodec:hevc,acodec:m4a"
--merge-output-format mp4
--output "%(artist|uploader)s/%(title)s - video.mp4"
--embed-metadata
--embed-thumbnail
--concurrent-fragments 5
```

### Optional: Download Archive

To prevent re-downloading the same videos, uncomment this line in `yt-dlp.conf`:
```conf
--download-archive /workspace/archive.txt
```

This creates an `archive.txt` file tracking downloaded video IDs.

## 🏗️ Architecture

### Docker Image Stack

- **Base**: Python 3.12-slim (Debian)
- **yt-dlp**: Nightly build with all extras
- **Deno**: JavaScript runtime for advanced extractors
- **ffmpeg**: Video/audio merging and conversion
- **AtomicParsley**: Metadata and thumbnail embedding

### Security Features

- ✅ Non-root user (`ytuser:1000`)
- ✅ No new privileges flag
- ✅ Minimal system dependencies
- ✅ Isolated container environment

### Performance Optimizations

- **4GB tmpfs mount** at `/tmp` for fragment assembly (RAM disk)
- **Concurrent fragment downloads** (5 streams)
- **Dedicated cache directory** for yt-dlp metadata

## 🛠️ Advanced Usage

### Custom yt-dlp Options

You can pass any yt-dlp option directly:
```bash
# Download audio only
docker compose run --rm yt-dlp -x --audio-format mp3 https://youtu.be/VIDEO_ID

# Download playlist
docker compose run --rm yt-dlp https://youtube.com/playlist?list=PLAYLIST_ID

# Limit video quality to 1080p
docker compose run --rm yt-dlp -f "bestvideo[height<=1080]+bestaudio" https://youtu.be/VIDEO_ID
```

### Override Configuration File

The default config is at `/etc/yt-dlp.conf` in the container. To ignore it:
```bash
docker compose run --rm yt-dlp --ignore-config https://youtu.be/VIDEO_ID
```

### Update yt-dlp

Rebuilding the image pulls the latest nightly:
```bash
docker compose build --no-cache yt-dlp
```

## 📂 Project Structure

```
VideoDownloader/
├── .dockerignore       # Optimizes build context
├── .gitignore          # Excludes videos from git
├── Dockerfile          # Multi-stage image definition
├── docker-compose.yml  # Service configuration
├── README.md           # This file
├── urls.txt            # Batch download URLs (gitignored)
├── yt-dlp.conf         # Download preferences
└── [Artist Folders]/   # Downloaded videos (gitignored)
```

## 🐛 Troubleshooting

### "ERROR: unable to download video data"

- Try rebuilding with `--no-cache` to get the latest yt-dlp
- Check if the video is age-restricted or region-locked
- Some sites require authentication (not covered in this setup)

### Videos are low quality

Check if the source has 4K available. The config will download the best available, but if a video maxes out at 1080p, that's what you'll get.

### Permission errors

The container runs as user ID 1000. If your host user has a different UID, you might see permission issues. The `docker-compose.yml` explicitly sets `user: "1000:1000"`.

### Slow downloads

The container uses a 4GB tmpfs RAM disk for merging. If you're on a memory-constrained system, you can reduce this in `docker-compose.yml`:
```yaml
tmpfs:
  - /tmp:rw,size=2G,mode=1777
```

## 📜 License

This project is a wrapper around open-source tools:
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Unlicense
- [ffmpeg](https://ffmpeg.org/) - LGPL/GPL
- [Deno](https://deno.land/) - MIT

Your configuration and Dockerfile are yours to use however you want!

## 🙏 Acknowledgments

- **yt-dlp team** for the incredible video downloader
- **ffmpeg** for multimedia processing
- **Deno** for JavaScript runtime support

---

**Happy downloading! 🎬**
