const heistData = {
    bank: { difficulty: 'Hard', payout: '$100,000', players: '3-4', cooldown: '60 min' },
    jewelry: { difficulty: 'Easy', payout: '$25,000', players: '2-3', cooldown: '20 min' },
    casino: { difficulty: 'Very Hard', payout: '$250,000', players: '4-6', cooldown: '120 min' },
    warehouse: { difficulty: 'Medium', payout: '$50,000', players: '2-4', cooldown: '30 min' },
    armored: { difficulty: 'Medium', payout: '$75,000', players: '2-3', cooldown: '45 min' }
};

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openHeists') {
        document.getElementById('heists-container').classList.remove('hidden');
        if (data.heistData) {
            updateHeistData(data.heistData);
        }
    }
    
    if (data.action === 'updateCrew') {
        updateCrewList(data.crew);
    }
});

function updateHeistData(data) {
    if (data.selectedHeist) {
        document.getElementById('heist-type').value = data.selectedHeist;
        updateHeistInfo(data.selectedHeist);
    }
}

function updateHeistInfo(heistType) {
    const info = heistData[heistType];
    if (info) {
        document.getElementById('heist-difficulty').textContent = info.difficulty;
        document.getElementById('heist-payout').textContent = info.payout;
        document.getElementById('required-players').textContent = info.players;
        document.getElementById('heist-cooldown').textContent = info.cooldown;
    }
}

function updateCrewList(crew) {
    const crewList = document.getElementById('crew-list');
    crewList.innerHTML = '';
    
    if (crew && crew.length > 0) {
        crew.forEach(member => {
            const memberDiv = document.createElement('div');
            memberDiv.className = 'crew-member';
            memberDiv.innerHTML = `
                <span class="member-name">${member.name}</span>
                <span class="member-role">${member.role}</span>
            `;
            crewList.appendChild(memberDiv);
        });
    } else {
        const defaultMember = document.createElement('div');
        defaultMember.className = 'crew-member';
        defaultMember.innerHTML = `
            <span class="member-name">You (Leader)</span>
            <span class="member-role">Mastermind</span>
        `;
        crewList.appendChild(defaultMember);
    }
}

document.getElementById('heist-type').addEventListener('change', function() {
    const selectedHeist = this.value;
    updateHeistInfo(selectedHeist);
    
    fetch(`https://${GetParentResourceName()}/selectHeist`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ heistType: selectedHeist })
    });
});

document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeHeists`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    document.getElementById('heists-container').classList.add('hidden');
});

document.getElementById('invite-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/invitePlayer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('ready-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/readyUp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('start-heist-btn').addEventListener('click', function() {
    const heistType = document.getElementById('heist-type').value;
    fetch(`https://${GetParentResourceName()}/startHeist`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ heistType: heistType })
    });
});

document.getElementById('cancel-heist-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/cancelHeist`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeHeists`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        document.getElementById('heists-container').classList.add('hidden');
    }
});

// Initialize with default heist info
updateHeistInfo('bank');