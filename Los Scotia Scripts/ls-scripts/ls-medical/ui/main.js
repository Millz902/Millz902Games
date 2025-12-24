window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openMedical') {
        document.getElementById('medical-container').classList.remove('hidden');
        if (data.patientData) {
            updatePatientData(data.patientData);
        }
        if (data.supplies) {
            updateSupplies(data.supplies);
        }
    }
});

function updatePatientData(data) {
    if (data.name) {
        document.getElementById('patient-name').textContent = data.name;
    }
    if (data.health !== undefined) {
        const healthBar = document.getElementById('health-bar');
        healthBar.style.width = data.health + '%';
        
        // Change color based on health level
        if (data.health < 25) {
            healthBar.style.background = 'linear-gradient(90deg, #e74c3c 0%, #e74c3c 100%)';
        } else if (data.health < 50) {
            healthBar.style.background = 'linear-gradient(90deg, #e74c3c 0%, #f39c12 100%)';
        } else if (data.health < 75) {
            healthBar.style.background = 'linear-gradient(90deg, #f39c12 0%, #f1c40f 100%)';
        } else {
            healthBar.style.background = 'linear-gradient(90deg, #f1c40f 0%, #2ecc71 100%)';
        }
    }
    if (data.injuries) {
        document.getElementById('injury-list').textContent = data.injuries.join(', ') || 'None';
    }
    if (data.bloodType) {
        document.getElementById('blood-type').textContent = data.bloodType;
    }
}

function updateSupplies(supplies) {
    if (supplies.bandages !== undefined) {
        document.getElementById('bandages-count').textContent = supplies.bandages;
    }
    if (supplies.painkillers !== undefined) {
        document.getElementById('painkillers-count').textContent = supplies.painkillers;
    }
    if (supplies.morphine !== undefined) {
        document.getElementById('morphine-count').textContent = supplies.morphine;
    }
    if (supplies.adrenaline !== undefined) {
        document.getElementById('adrenaline-count').textContent = supplies.adrenaline;
    }
}

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeMedical`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('medical-container').classList.add('hidden');
});

document.getElementById('bandage-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/useBandage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('painkiller-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/givePainkillers`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('surgery-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/performSurgery`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('revive-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/revivePatient`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('checkup-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/generalCheckup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('xray-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/performXRay`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('bloodtest-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/bloodTest`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('mri-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/performMRI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeMedical`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('medical-container').classList.add('hidden');
    }
});