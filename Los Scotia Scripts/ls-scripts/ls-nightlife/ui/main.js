window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openNightlife') {
        document.getElementById('nightlife-container').classList.remove('hidden');
        if (data.clubData) {
            updateClubData(data.clubData);
        }
    }
});

function updateClubData(data) {
    if (data.patronCount !== undefined) {
        document.getElementById('patron-count').textContent = data.patronCount;
    }
    if (data.revenue !== undefined) {
        document.getElementById('revenue').textContent = '$' + data.revenue.toLocaleString();
    }
    if (data.volume !== undefined) {
        document.getElementById('volume-slider').value = data.volume;
        document.getElementById('volume-display').textContent = data.volume + '%';
    }
}

document.getElementById('volume-slider').addEventListener('input', function() {
    const volume = this.value;
    document.getElementById('volume-display').textContent = volume + '%';
    
    fetch(`https://${GetParentResourceName()}/setVolume`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ volume: parseInt(volume) })
    });
});

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeNightlife`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('nightlife-container').classList.add('hidden');
});

document.getElementById('dj-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/hireDJ`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('lights-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/toggleLights`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('smoke-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/activateSmoke`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('event-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/specialEvent`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('cocktail-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/serveDrink`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ drinkType: 'cocktail' })
    });
});

document.getElementById('beer-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/serveDrink`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ drinkType: 'beer' })
    });
});

document.getElementById('vip-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/vipService`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('security-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/callSecurity`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeNightlife`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('nightlife-container').classList.add('hidden');
    }
});