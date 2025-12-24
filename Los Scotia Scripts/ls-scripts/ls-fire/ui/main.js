window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openFire') {
        document.getElementById('fire-container').classList.remove('hidden');
        if (data.fireData) {
            updateFireData(data.fireData);
        }
    }
    
    if (data.action === 'updateIncidents') {
        updateIncidents(data.incidents);
    }
});

function updateFireData(data) {
    if (data.onDutyCount !== undefined) {
        document.getElementById('on-duty-count').textContent = data.onDutyCount;
    }
    if (data.availableUnits !== undefined) {
        document.getElementById('available-units').textContent = data.availableUnits;
    }
    if (data.responseTime !== undefined) {
        document.getElementById('response-time').textContent = data.responseTime + ' min';
    }
}

function updateIncidents(incidents) {
    const incidentsList = document.getElementById('incidents-list');
    incidentsList.innerHTML = '';
    
    if (incidents && incidents.length > 0) {
        incidents.forEach(incident => {
            const incidentItem = document.createElement('div');
            incidentItem.className = 'incident-item';
            incidentItem.innerHTML = `
                <span class="incident-type">${incident.type}</span>
                <span class="incident-status">${incident.status}</span>
            `;
            incidentsList.appendChild(incidentItem);
        });
    } else {
        const noIncidents = document.createElement('div');
        noIncidents.className = 'incident-item';
        noIncidents.innerHTML = `
            <span class="incident-type">No Active Incidents</span>
            <span class="incident-status">All Clear</span>
        `;
        incidentsList.appendChild(noIncidents);
    }
}

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeFire`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('fire-container').classList.add('hidden');
});

document.getElementById('fire-call-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/respondFire`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'fire' })
    });
});

document.getElementById('medical-call-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/respondMedical`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'medical' })
    });
});

document.getElementById('rescue-call-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/respondRescue`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'rescue' })
    });
});

document.getElementById('equipment-check-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/equipmentCheck`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('maintenance-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/vehicleMaintenance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('inventory-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/checkInventory`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeFire`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('fire-container').classList.add('hidden');
    }
});