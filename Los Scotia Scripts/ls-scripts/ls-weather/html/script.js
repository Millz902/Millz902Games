let currentTab = 'current';
let currentWeather = {};
let forecastData = {};
let weatherAlerts = [];
let isControlMode = false;

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    initializeWeatherData();
    updateCurrentWeather();
});

// Set up event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeWeather);

    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });

    // Forecast controls
    document.querySelectorAll('.forecast-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            switchForecastPeriod(this.dataset.period);
        });
    });

    // Weather control
    document.getElementById('applyWeatherBtn').addEventListener('click', applyWeather);
    document.getElementById('resetWeatherBtn').addEventListener('click', resetWeather);
    document.getElementById('savePresetBtn').addEventListener('click', savePreset);
    document.getElementById('windSpeedControl').addEventListener('input', updateWindSpeedDisplay);

    // Weather presets
    document.querySelectorAll('.preset-item').forEach(item => {
        item.querySelector('.preset-btn').addEventListener('click', function() {
            applyPreset(item.dataset.preset);
        });
    });

    // Schedule weather
    document.getElementById('addScheduleBtn').addEventListener('click', addScheduledWeather);

    // Alerts
    document.getElementById('createAlertBtn').addEventListener('click', createWeatherAlert);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeWeather();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openWeather':
                openWeather();
                break;
            case 'closeWeather':
                closeWeather();
                break;
            case 'updateCurrentWeather':
                updateCurrentWeather(data.weather);
                break;
            case 'updateForecast':
                updateForecast(data.forecast);
                break;
            case 'updateAlerts':
                updateWeatherAlerts(data.alerts);
                break;
            case 'weatherChanged':
                handleWeatherChange(data.weather);
                break;
        }
    });
}

// Tab switching
function switchTab(tabName) {
    currentTab = tabName;
    
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.tab === tabName) {
            btn.classList.add('active');
        }
    });
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');
    
    // Tab-specific initialization
    if (tabName === 'forecast') {
        loadForecastData();
    } else if (tabName === 'control') {
        loadWeatherControls();
    } else if (tabName === 'alerts') {
        loadWeatherAlerts();
    }
}

// Forecast period switching
function switchForecastPeriod(period) {
    // Update forecast buttons
    document.querySelectorAll('.forecast-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.period === period) {
            btn.classList.add('active');
        }
    });
    
    // Update forecast content
    document.querySelectorAll('.forecast-content').forEach(content => {
        content.classList.remove('active');
    });
    
    if (period === 'hourly') {
        document.getElementById('hourlyForecast').classList.add('active');
    } else if (period === 'daily') {
        document.getElementById('dailyForecast').classList.add('active');
    }
}

// Open weather interface
function openWeather() {
    document.getElementById('container').classList.remove('hidden');
    sendCallback('weather:opened', {});
}

// Close weather interface
function closeWeather() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('weather:closed', {});
}

// Initialize weather data
function initializeWeatherData() {
    currentWeather = {
        temperature: 22,
        condition: 'Sunny',
        description: 'Clear skies with plenty of sunshine',
        icon: '☀️',
        windSpeed: 12,
        windDirection: 'NE',
        humidity: 65,
        visibility: 10,
        pressure: 1013,
        feelsLike: 24,
        sunrise: '06:24 AM',
        sunset: '19:47 PM',
        location: 'Los Scotia'
    };
    
    forecastData = {
        hourly: [
            { time: 'Now', icon: '☀️', temp: 22, rain: 0 },
            { time: '15:00', icon: '☀️', temp: 24, rain: 5 },
            { time: '16:00', icon: '⛅', temp: 23, rain: 10 },
            { time: '17:00', icon: '⛅', temp: 21, rain: 15 },
            { time: '18:00', icon: '🌧️', temp: 19, rain: 80 }
        ],
        daily: [
            { day: 'Today', icon: '☀️', high: 24, low: 16, condition: 'Sunny' },
            { day: 'Tomorrow', icon: '🌧️', high: 18, low: 12, condition: 'Rainy' },
            { day: 'Wednesday', icon: '⛅', high: 20, low: 14, condition: 'Cloudy' }
        ]
    };
    
    weatherAlerts = [
        {
            id: 1,
            type: 'severe',
            title: 'Thunderstorm Warning',
            description: 'Severe thunderstorms expected from 6:00 PM to 9:00 PM',
            time: 'Active until 21:00',
            icon: '⚠️'
        }
    ];
}

// Update current weather display
function updateCurrentWeather(weather = null) {
    if (weather) {
        currentWeather = { ...currentWeather, ...weather };
    }
    
    document.getElementById('currentTemp').textContent = `${currentWeather.temperature}°C`;
    document.getElementById('weatherIcon').textContent = currentWeather.icon;
    document.getElementById('weatherCondition').textContent = currentWeather.condition;
    document.getElementById('weatherDescription').textContent = currentWeather.description;
    document.getElementById('currentLocation').textContent = currentWeather.location;
    document.getElementById('windSpeed').textContent = `${currentWeather.windSpeed} km/h`;
    document.getElementById('windDirection').textContent = currentWeather.windDirection;
    document.getElementById('humidity').textContent = `${currentWeather.humidity}%`;
    document.getElementById('visibility').textContent = `${currentWeather.visibility} km`;
    document.getElementById('pressure').textContent = `${currentWeather.pressure} hPa`;
    document.getElementById('feelsLike').textContent = `${currentWeather.feelsLike}°C`;
    document.getElementById('sunrise').textContent = currentWeather.sunrise;
    document.getElementById('sunset').textContent = currentWeather.sunset;
}

// Load forecast data
function loadForecastData() {
    // This would typically fetch from server
    // For now, using initialized data
}

// Load weather controls
function loadWeatherControls() {
    updateWindSpeedDisplay();
}

// Apply weather changes
function applyWeather() {
    const weatherType = document.getElementById('weatherType').value;
    const transitionTime = document.getElementById('transitionTime').value;
    const windSpeed = document.getElementById('windSpeedControl').value;
    const windDirection = document.getElementById('windDirectionControl').value;
    
    const weatherData = {
        type: weatherType,
        transition: transitionTime,
        windSpeed: windSpeed,
        windDirection: windDirection
    };
    
    sendCallback('weather:applyWeather', weatherData);
    showNotification(`Weather changed to: ${weatherType}`, 'success');
}

// Reset weather to natural
function resetWeather() {
    sendCallback('weather:resetWeather', {});
    showNotification('Weather reset to natural state', 'info');
}

// Save weather preset
function savePreset() {
    const weatherType = document.getElementById('weatherType').value;
    const windSpeed = document.getElementById('windSpeedControl').value;
    const windDirection = document.getElementById('windDirectionControl').value;
    
    const preset = {
        type: weatherType,
        windSpeed: windSpeed,
        windDirection: windDirection
    };
    
    sendCallback('weather:savePreset', preset);
    showNotification('Weather preset saved!', 'success');
}

// Apply weather preset
function applyPreset(presetType) {
    const presets = {
        sunny: { type: 'clear', windSpeed: 10, windDirection: 'SW' },
        storm: { type: 'thunder', windSpeed: 45, windDirection: 'W' },
        winter: { type: 'blizzard', windSpeed: 35, windDirection: 'N' },
        fog: { type: 'foggy', windSpeed: 5, windDirection: 'E' }
    };
    
    const preset = presets[presetType];
    if (preset) {
        document.getElementById('weatherType').value = preset.type;
        document.getElementById('windSpeedControl').value = preset.windSpeed;
        document.getElementById('windDirectionControl').value = preset.windDirection;
        updateWindSpeedDisplay();
        
        sendCallback('weather:applyPreset', { preset: presetType, data: preset });
        showNotification(`Applied ${presetType} preset`, 'success');
    }
}

// Update wind speed display
function updateWindSpeedDisplay() {
    const value = document.getElementById('windSpeedControl').value;
    document.getElementById('windSpeedDisplay').textContent = `${value} km/h`;
}

// Add scheduled weather event
function addScheduledWeather() {
    sendCallback('weather:addSchedule', {});
    showNotification('Schedule weather dialog opened', 'info');
}

// Load weather alerts
function loadWeatherAlerts() {
    renderActiveAlerts();
}

// Render active alerts
function renderActiveAlerts() {
    const alertsList = document.getElementById('activeAlerts');
    
    if (weatherAlerts.length === 0) {
        alertsList.innerHTML = '<p style="color: #bdc3c7; text-align: center; padding: 20px;">No active alerts</p>';
        return;
    }
    
    let html = '';
    weatherAlerts.forEach(alert => {
        html += `
            <div class="alert-item ${alert.type}">
                <div class="alert-icon">${alert.icon}</div>
                <div class="alert-info">
                    <div class="alert-title">${alert.title}</div>
                    <div class="alert-description">${alert.description}</div>
                    <div class="alert-time">${alert.time}</div>
                </div>
                <div class="alert-actions">
                    <button class="alert-btn" onclick="editAlert('${alert.id}')">Edit</button>
                    <button class="alert-btn" onclick="cancelAlert('${alert.id}')">Cancel</button>
                </div>
            </div>
        `;
    });
    
    alertsList.innerHTML = html;
}

// Create weather alert
function createWeatherAlert() {
    sendCallback('weather:createAlert', {});
    showNotification('Create alert dialog opened', 'info');
}

// Edit weather alert
function editAlert(alertId) {
    sendCallback('weather:editAlert', { alertId: alertId });
    showNotification('Edit alert dialog opened', 'info');
}

// Cancel weather alert
function cancelAlert(alertId) {
    weatherAlerts = weatherAlerts.filter(alert => alert.id != alertId);
    renderActiveAlerts();
    sendCallback('weather:cancelAlert', { alertId: alertId });
    showNotification('Weather alert cancelled', 'info');
}

// Update functions from FiveM
function updateForecast(forecast) {
    forecastData = forecast;
    if (currentTab === 'forecast') {
        loadForecastData();
    }
}

function updateWeatherAlerts(alerts) {
    weatherAlerts = alerts;
    if (currentTab === 'alerts') {
        renderActiveAlerts();
    }
}

function handleWeatherChange(weather) {
    updateCurrentWeather(weather);
    showNotification(`Weather updated: ${weather.condition}`, 'info');
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#74b9ff'};
        color: white;
        padding: 15px 25px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 500;
        z-index: 10001;
        animation: slideInRight 0.3s ease-out;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Send callback to FiveM
function sendCallback(event, data) {
    if (window.invokeNative) {
        fetch(`https://${GetParentResourceName()}/${event}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).catch(err => console.error('Callback error:', err));
    }
}

// Add slide animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);