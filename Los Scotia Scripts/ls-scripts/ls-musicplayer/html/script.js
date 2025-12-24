document.addEventListener('DOMContentLoaded', function() {
    // Track playlist - this will be populated from the server
    let playlist = [
        {
            title: "Los Scotia Theme",
            artist: "Millz902Games",
            file: "theme.mp3",
            art: "img/los-scotia-logo.png"
        },
        {
            title: "Night Drive",
            artist: "Millz902Games",
            file: "night_drive.mp3",
            art: "img/los-scotia-night.png"
        },
        {
            title: "City Lights",
            artist: "Millz902Games",
            file: "city_lights.mp3",
            art: "img/los-scotia-city.png"
        }
    ];

    // DOM Elements
    const playButton = document.getElementById('play-button');
    const playIcon = document.getElementById('play-icon');
    const prevButton = document.getElementById('prev-button');
    const nextButton = document.getElementById('next-button');
    const progress = document.getElementById('progress');
    const progressBar = document.querySelector('.progress-bar');
    const currentTimeEl = document.getElementById('current-time');
    const totalTimeEl = document.getElementById('total-time');
    const volumeSlider = document.getElementById('volume-slider');
    const volumeIcon = document.getElementById('volume-icon');
    const minimizeButton = document.getElementById('minimize-button');
    const playerContent = document.getElementById('player-content');
    const albumArt = document.getElementById('album-art');
    const trackTitle = document.getElementById('track-title');
    const trackArtist = document.getElementById('track-artist');

    // Audio object
    const audio = new Audio();
    let isPlaying = false;
    let currentTrack = 0;
    let isMinimized = false;

    // Initialize volume
    audio.volume = volumeSlider.value / 100;

    // Load the first track
    loadTrack(currentTrack);

    // Initialize the player
    function loadTrack(trackIndex) {
        if (trackIndex >= playlist.length) trackIndex = 0;
        if (trackIndex < 0) trackIndex = playlist.length - 1;
        
        currentTrack = trackIndex;
        audio.src = `../sounds/${playlist[currentTrack].file}`;
        trackTitle.textContent = playlist[currentTrack].title;
        trackArtist.textContent = playlist[currentTrack].artist;
        albumArt.src = playlist[currentTrack].art;
        
        audio.load();
        updateTotalTime();
    }

    // Format time in MM:SS
    function formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
    }

    // Update total time display
    function updateTotalTime() {
        audio.addEventListener('loadedmetadata', function() {
            totalTimeEl.textContent = formatTime(audio.duration);
        });
    }

    // Play/Pause toggle
    function togglePlay() {
        if (isPlaying) {
            audio.pause();
            playIcon.className = 'fas fa-play';
            document.querySelector('.album-art').classList.remove('playing');
        } else {
            audio.play();
            playIcon.className = 'fas fa-pause';
            document.querySelector('.album-art').classList.add('playing');
        }
        isPlaying = !isPlaying;
    }

    // Update progress bar
    function updateProgress() {
        const progressPercent = (audio.currentTime / audio.duration) * 100;
        progress.style.width = `${progressPercent}%`;
        currentTimeEl.textContent = formatTime(audio.currentTime);
    }

    // Set progress when clicked
    function setProgress(e) {
        const width = this.clientWidth;
        const clickX = e.offsetX;
        const duration = audio.duration;
        audio.currentTime = (clickX / width) * duration;
    }

    // Next track
    function nextTrack() {
        currentTrack = (currentTrack + 1) % playlist.length;
        loadTrack(currentTrack);
        if (isPlaying) {
            audio.play();
            document.querySelector('.album-art').classList.add('playing');
        }
    }

    // Previous track
    function prevTrack() {
        currentTrack = (currentTrack - 1 + playlist.length) % playlist.length;
        loadTrack(currentTrack);
        if (isPlaying) {
            audio.play();
            document.querySelector('.album-art').classList.add('playing');
        }
    }

    // Update volume
    function updateVolume() {
        audio.volume = volumeSlider.value / 100;
        
        // Update volume icon based on level
        if (audio.volume === 0) {
            volumeIcon.className = 'fas fa-volume-mute';
        } else if (audio.volume < 0.5) {
            volumeIcon.className = 'fas fa-volume-down';
        } else {
            volumeIcon.className = 'fas fa-volume-up';
        }
    }

    // Toggle minimize player
    function toggleMinimize() {
        isMinimized = !isMinimized;
        if (isMinimized) {
            playerContent.classList.add('collapsed');
            minimizeButton.innerHTML = '<i class="fas fa-plus"></i>';
        } else {
            playerContent.classList.remove('collapsed');
            minimizeButton.innerHTML = '<i class="fas fa-minus"></i>';
        }
    }

    // Event Listeners
    playButton.addEventListener('click', togglePlay);
    audio.addEventListener('timeupdate', updateProgress);
    progressBar.addEventListener('click', setProgress);
    prevButton.addEventListener('click', prevTrack);
    nextButton.addEventListener('click', nextTrack);
    volumeSlider.addEventListener('input', updateVolume);
    minimizeButton.addEventListener('click', toggleMinimize);
    
    // Auto play next track when current one ends
    audio.addEventListener('ended', nextTrack);

    // Mute/unmute when clicking volume icon
    volumeIcon.addEventListener('click', function() {
        if (audio.volume > 0) {
            // Store previous volume for unmuting
            volumeIcon.dataset.prevVolume = audio.volume;
            audio.volume = 0;
            volumeSlider.value = 0;
            volumeIcon.className = 'fas fa-volume-mute';
        } else {
            // Restore previous volume
            const prevVol = parseFloat(volumeIcon.dataset.prevVolume) || 0.7;
            audio.volume = prevVol;
            volumeSlider.value = prevVol * 100;
            volumeIcon.className = prevVol < 0.5 ? 'fas fa-volume-down' : 'fas fa-volume-up';
        }
    });

    // FiveM NUI Message Event Listener
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.type === 'showMusicPlayer') {
            document.querySelector('.music-player-container').style.display = 'block';
            
            // If a playlist was provided, use it
            if (data.playlist && Array.isArray(data.playlist)) {
                playlist = data.playlist;
                currentTrack = 0;
                loadTrack(currentTrack);
            }
            
            // Auto-play if specified
            if (data.autoplay && !isPlaying) {
                togglePlay();
            }
        }
        else if (data.type === 'hideMusicPlayer') {
            document.querySelector('.music-player-container').style.display = 'none';
            if (isPlaying) {
                togglePlay(); // pause the music
            }
        }
        else if (data.type === 'setPlaylist') {
            if (data.playlist && Array.isArray(data.playlist)) {
                playlist = data.playlist;
                currentTrack = 0;
                loadTrack(currentTrack);
            }
        }
        else if (data.type === 'playPause') {
            togglePlay();
        }
        else if (data.type === 'nextTrack') {
            nextTrack();
        }
        else if (data.type === 'prevTrack') {
            prevTrack();
        }
        else if (data.type === 'setVolume') {
            if (typeof data.volume === 'number') {
                volumeSlider.value = data.volume * 100;
                updateVolume();
            }
        }
    });

    // Initialize player as hidden
    document.querySelector('.music-player-container').style.display = 'none';
});