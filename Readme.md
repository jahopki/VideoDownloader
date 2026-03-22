# Jim's Video Grabber

This is ultimately a simple wrapper to run the excellent [yt-dlp](https://github.com/yt-dlp/yt-dlp) product in a [Docker container](https://www.docker.com/resources/what-container/) to download videos and name them in a [Plex](https://www.plex.tv/personal-media-server/) (or [Jellyfin](https://jellyfin.org/), [Emby](https://emby.media/), [Infuse](https://firecore.com/infuse), etc) -friendly manner. If nothing else, this assumes that you have Docker installed on your host system.

---

### First
Clone the repository

---

### Second
Setup yt-dlp [configuration](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options). A reasonable configuration file is provided (the `yt-dlp.conf` file) with the repo, but you're encouraged to modify to fit your exact needs. Also be aware that you can append additional yt-dlp configuration properties to the `docker run` command.

---

### Third
Update the `.env` file to reflect your environment and desired configuration / behavior.
- The `LOCAL_STORAGE_DIR` is the path to the directory that you want the downloaded videos to be saved.
  - It's strongly recommended to **not** make this the final destination (ie the file location in your Plex Media Server). Instead, use a temporary location so you can properly organize the files that yt-dlp gets wrong (because it will).
- The `PROCESSOR_CONFIG_FILE` is the name of the file that contains the yt-dlp configuration options. If you don't want to use any of those provided by the repository, just put `/dev/null` as the value here.

---

### Fourth
Build your list of URLs.
- The common use case (for me) is to retrieve a collection of videos. To do this, I put the URLs to the videos in a file named `urls.txt`. NOTE that this file ****must**** be named `urls.txt`.
- If you just want to pull a single video, and don't want to deal with the file, you can comment out this line from docker-compose.yml and just pass the URL as the last parameter to the `docker run` command: `- ./urls.txt:/downloads/urls.txt`
- The URL can reference a playlist and it will get all videos in the playlist. There are parameters to get specific tracks from the playlist, but you'll have to look that up -- I haven't used it (yet).

---

### Fifth
Build the container.
- Ideally, the non-root user of the Docker container should have the same uid and gid of the user on your machine. Use `id -u` to get the user ID and `id -g` to get the group ID, then use these values in the Dockerfile's user creation section.
- The basic / standard build is simply: `docker compose -f docker-compose.yml yt-dlp build`
- An example of a more verbose build to add troubleshooting is: `docker compose -f docker-compose.yml build --progress plain --no-cache yt-dlp`

---

### Sixth
Run the container
- The standard / usual run would be executed with `docker compose run --rm yt-dlp --batch-file /downloads/urls.txt [additional yt-dlp OPTIONS]`
- If you commented out the reference to the `urls.txt` file in the docker-compose file, then you would execute `docker compose run --rm yt-dlp [additional yt-dlp OPTIONS] [URL]`

---

### Seventh
Post processing
- I highly suggest reviewing the metadata of all the videos you download prior to adding them to Plex to ensure that at least the Title and Artist tags are correct. Plex is **extremely** particular about file names (the " - video" suffix is there on purpose to appease Plex) and the corresponding metadata.

