window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openFarming') {
        document.getElementById('farming-container').classList.remove('hidden');
        if (data.farmData) {
            updateFarmData(data.farmData);
        }
    }
});

function updateFarmData(data) {
    if (data.cropType) {
        document.getElementById('crop-type').textContent = data.cropType.charAt(0).toUpperCase() + data.cropType.slice(1);
    }
    if (data.growthProgress !== undefined) {
        document.getElementById('growth-progress').style.width = data.growthProgress + '%';
    }
    if (data.harvestReady !== undefined) {
        document.getElementById('harvest-ready').textContent = data.harvestReady;
    }
}

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeFarming`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('farming-container').classList.add('hidden');
});

document.getElementById('plant-btn').addEventListener('click', function() {
    const cropType = document.getElementById('crop-select').value;
    if (cropType) {
        fetch(`https://${GetParentResourceName()}/plantCrop`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cropType: cropType })
        });
    }
});

document.getElementById('water-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/waterCrops`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('fertilize-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/fertilizeCrops`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('harvest-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/harvestCrops`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeFarming`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('farming-container').classList.add('hidden');
    }
});