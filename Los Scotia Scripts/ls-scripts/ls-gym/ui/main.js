// Los Scotia Gym UI JavaScript

let workoutActive = false;
let workoutTimer = null;
let currentEquipment = null;

// DOM Elements
const workoutContainer = document.getElementById('workout-container');
const nutritionPanel = document.getElementById('nutrition-panel');
const statsDisplay = document.getElementById('stats-display');
const achievementNotification = document.getElementById('achievement-notification');
const membershipStatus = document.getElementById('membership-status');

// Message handler
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showWorkout':
            showWorkout(data);
            break;
        case 'hideWorkout':
            hideWorkout();
            break;
        case 'updateProgress':
            updateProgress(data.progress);
            break;
        case 'showNutrition':
            showNutrition(data);
            break;
        case 'hideNutrition':
            hideNutrition();
            break;
        case 'updateNutrition':
            updateNutrition(data);
            break;
        case 'showStats':
            showStats(data);
            break;
        case 'hideStats':
            hideStats();
            break;
        case 'updateStats':
            updateStats(data);
            break;
        case 'showAchievement':
            showAchievement(data);
            break;
        case 'showMembership':
            showMembership(data);
            break;
        case 'hideMembership':
            hideMembership();
            break;
        case 'updateMembership':
            updateMembership(data);
            break;
    }
});

// Workout Functions
function showWorkout(data) {
    workoutActive = true;
    currentEquipment = data.equipment;
    
    // Update workout panel
    document.getElementById('equipment-name').textContent = data.equipment;
    document.getElementById('strength-gain').textContent = `+${data.strengthMin}-${data.strengthMax}`;
    document.getElementById('stamina-gain').textContent = `+${data.staminaMin}-${data.staminaMax}`;
    document.getElementById('energy-cost').textContent = `-${data.energyRequired}`;
    
    // Show container
    workoutContainer.classList.remove('hidden');
    
    // Start timer display
    startWorkoutTimer(data.duration);
    
    // Play start sound
    playSound('workout_start');
}

function hideWorkout() {
    workoutActive = false;
    currentEquipment = null;
    
    workoutContainer.classList.add('hidden');
    
    if (workoutTimer) {
        clearInterval(workoutTimer);
        workoutTimer = null;
    }
}

function updateProgress(progress) {
    const progressFill = document.getElementById('progress-fill');
    const progressPercentage = document.getElementById('progress-percentage');
    
    progressFill.style.width = `${progress}%`;
    progressPercentage.textContent = `${progress}%`;
    
    // Add glow effect when near completion
    if (progress > 80) {
        progressFill.style.boxShadow = '0 0 10px #f39c12';
    }
}

function startWorkoutTimer(duration) {
    let timeLeft = duration;
    
    workoutTimer = setInterval(() => {
        timeLeft--;
        document.getElementById('workout-duration').textContent = timeLeft;
        
        if (timeLeft <= 0) {
            clearInterval(workoutTimer);
            workoutTimer = null;
        }
    }, 1000);
}

// Nutrition Functions
function showNutrition(data) {
    nutritionPanel.classList.remove('hidden');
    updateNutrition(data);
}

function hideNutrition() {
    nutritionPanel.classList.add('hidden');
}

function updateNutrition(data) {
    // Update energy
    const energyFill = document.getElementById('energy-fill');
    const energyValue = document.getElementById('energy-value');
    energyFill.style.width = `${data.energy}%`;
    energyValue.textContent = `${data.energy}%`;
    
    // Update hunger
    const hungerFill = document.getElementById('hunger-fill');
    const hungerValue = document.getElementById('hunger-value');
    hungerFill.style.width = `${data.hunger}%`;
    hungerValue.textContent = `${data.hunger}%`;
    
    // Update thirst
    const thirstFill = document.getElementById('thirst-fill');
    const thirstValue = document.getElementById('thirst-value');
    thirstFill.style.width = `${data.thirst}%`;
    thirstValue.textContent = `${data.thirst}%`;
    
    // Warning colors for low values
    if (data.energy < 20) energyFill.style.background = '#e74c3c';
    if (data.hunger < 20) hungerFill.style.background = '#e74c3c';
    if (data.thirst < 20) thirstFill.style.background = '#e74c3c';
}

// Stats Functions
function showStats(data) {
    statsDisplay.classList.remove('hidden');
    updateStats(data);
}

function hideStats() {
    statsDisplay.classList.add('hidden');
}

function updateStats(data) {
    // Update strength
    document.getElementById('strength-stat').textContent = data.strength;
    document.getElementById('strength-bar').style.width = `${data.strength}%`;
    
    // Update stamina
    document.getElementById('stamina-stat').textContent = data.stamina;
    document.getElementById('stamina-bar').style.width = `${data.stamina}%`;
    
    // Update total workouts
    document.getElementById('total-workouts').textContent = data.totalWorkouts;
    
    // Update favorite equipment
    document.getElementById('favorite-equipment').textContent = data.favoriteEquipment || 'None';
}

// Achievement Functions
function showAchievement(data) {
    document.getElementById('achievement-name').textContent = data.name;
    document.getElementById('achievement-description').textContent = data.description;
    document.getElementById('achievement-reward').textContent = `+$${data.reward}`;
    
    achievementNotification.classList.remove('hidden');
    
    // Play achievement sound
    playSound('achievement');
    
    // Auto hide after 5 seconds
    setTimeout(() => {
        achievementNotification.classList.add('hidden');
    }, 5000);
}

// Membership Functions
function showMembership(data) {
    membershipStatus.classList.remove('hidden');
    updateMembership(data);
}

function hideMembership() {
    membershipStatus.classList.add('hidden');
}

function updateMembership(data) {
    document.getElementById('membership-type-text').textContent = data.type;
    document.getElementById('membership-expires-text').textContent = data.expiresText;
    
    // Update benefits list
    const benefitsList = document.getElementById('membership-benefits-list');
    benefitsList.innerHTML = '';
    
    data.benefits.forEach(benefit => {
        const li = document.createElement('li');
        li.textContent = benefit;
        benefitsList.appendChild(li);
    });
}

// Sound Functions
function playSound(soundName) {
    // Create audio element and play sound
    const audio = new Audio(`sounds/${soundName}.mp3`);
    audio.volume = 0.5;
    audio.play().catch(e => {
        console.log('Could not play sound:', e);
    });
}

// Event Listeners
document.getElementById('close-workout').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeWorkout`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});

// Keyboard Controls
document.addEventListener('keydown', function(event) {
    switch(event.code) {
        case 'Escape':
            if (workoutActive) {
                document.getElementById('close-workout').click();
            }
            break;
        case 'Tab':
            event.preventDefault();
            // Toggle nutrition panel
            if (nutritionPanel.classList.contains('hidden')) {
                showNutrition({energy: 75, hunger: 85, thirst: 90});
            } else {
                hideNutrition();
            }
            break;
        case 'KeyI':
            event.preventDefault();
            // Toggle stats display
            if (statsDisplay.classList.contains('hidden')) {
                showStats({
                    strength: 45,
                    stamina: 35,
                    totalWorkouts: 23,
                    favoriteEquipment: 'Bench Press'
                });
            } else {
                hideStats();
            }
            break;
    }
});

// Utility Functions
function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

function animateNumber(element, start, end, duration) {
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;
    
    const timer = setInterval(() => {
        current += increment;
        element.textContent = Math.round(current);
        
        if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
            element.textContent = end;
            clearInterval(timer);
        }
    }, 16);
}

function createParticleEffect(x, y, color) {
    const particle = document.createElement('div');
    particle.style.position = 'fixed';
    particle.style.left = x + 'px';
    particle.style.top = y + 'px';
    particle.style.width = '4px';
    particle.style.height = '4px';
    particle.style.background = color;
    particle.style.borderRadius = '50%';
    particle.style.pointerEvents = 'none';
    particle.style.zIndex = '9999';
    
    document.body.appendChild(particle);
    
    // Animate particle
    const angle = Math.random() * Math.PI * 2;
    const velocity = Math.random() * 100 + 50;
    const vx = Math.cos(angle) * velocity;
    const vy = Math.sin(angle) * velocity;
    
    let px = x;
    let py = y;
    let opacity = 1;
    
    const animate = () => {
        px += vx * 0.016;
        py += vy * 0.016;
        opacity -= 0.02;
        
        particle.style.left = px + 'px';
        particle.style.top = py + 'px';
        particle.style.opacity = opacity;
        
        if (opacity > 0) {
            requestAnimationFrame(animate);
        } else {
            document.body.removeChild(particle);
        }
    };
    
    requestAnimationFrame(animate);
}

// Progress celebration effect
function celebrateCompletion() {
    const colors = ['#f39c12', '#e67e22', '#d35400'];
    const rect = workoutContainer.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    
    for (let i = 0; i < 20; i++) {
        setTimeout(() => {
            const color = colors[Math.floor(Math.random() * colors.length)];
            createParticleEffect(
                centerX + (Math.random() - 0.5) * 100,
                centerY + (Math.random() - 0.5) * 100,
                color
            );
        }, i * 50);
    }
}

// Initialize UI
document.addEventListener('DOMContentLoaded', function() {
    console.log('Los Scotia Gym UI Loaded');
    
    // Hide all panels initially
    workoutContainer.classList.add('hidden');
    nutritionPanel.classList.add('hidden');
    statsDisplay.classList.add('hidden');
    achievementNotification.classList.add('hidden');
    membershipStatus.classList.add('hidden');
});

// Export functions for external use
window.GymUI = {
    showWorkout,
    hideWorkout,
    updateProgress,
    showNutrition,
    hideNutrition,
    updateNutrition,
    showStats,
    hideStats,
    updateStats,
    showAchievement,
    showMembership,
    hideMembership,
    updateMembership,
    celebrateCompletion
};