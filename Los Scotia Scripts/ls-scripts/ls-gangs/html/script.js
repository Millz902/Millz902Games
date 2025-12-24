document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('container');
    const closeBtn = document.getElementById('close-btn');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    // Tab switching functionality
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all tabs and contents
            tabBtns.forEach(tb => tb.classList.remove('active'));
            tabContents.forEach(tc => tc.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding content
            this.classList.add('active');
            document.getElementById(targetTab).classList.add('active');
        });
    });

    // Close button functionality
    closeBtn.addEventListener('click', function() {
        container.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Gang action button handlers
    document.getElementById('invite-btn').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/inviteMember`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('promote-btn').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/promoteMember`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('expand-territory').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/expandTerritory`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Activity button handlers
    document.querySelectorAll('.activity-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const activity = this.textContent.toLowerCase();
            fetch(`https://${GetParentResourceName()}/startActivity`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    activity: activity
                })
            });
        });
    });

    // Listen for messages from the client
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'show':
                container.classList.remove('hidden');
                if(data.gangData) {
                    updateGangInfo(data.gangData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateGang':
                if(data.gangData) {
                    updateGangInfo(data.gangData);
                }
                break;
                
            case 'updateMembers':
                if(data.members) {
                    updateMemberList(data.members);
                }
                break;
                
            case 'updateTerritory':
                if(data.territory) {
                    updateTerritoryInfo(data.territory);
                }
                break;
        }
    });

    // Update gang information
    function updateGangInfo(gangData) {
        document.getElementById('gang-name').textContent = gangData.name || 'Unknown';
        document.getElementById('gang-leader').textContent = gangData.leader || 'Unknown';
        document.getElementById('member-count').textContent = gangData.memberCount || 0;
        document.getElementById('territory-control').textContent = `${gangData.territoryControl || 0}%`;
        document.getElementById('gang-funds').textContent = `$${gangData.funds || 0}`;
        
        const repElement = document.getElementById('gang-reputation');
        repElement.textContent = gangData.reputation || 'Low';
        repElement.className = `rep-${(gangData.reputation || 'low').toLowerCase()}`;
    }

    // Update member list
    function updateMemberList(members) {
        const memberList = document.querySelector('.member-list');
        memberList.innerHTML = '';
        
        if(members && members.length > 0) {
            members.forEach(member => {
                const memberDiv = document.createElement('div');
                memberDiv.className = 'member-item';
                memberDiv.innerHTML = `
                    <div class="member-info">
                        <span class="member-name">${member.name}</span>
                        <span class="member-rank">${member.rank}</span>
                    </div>
                    <div class="member-actions">
                        <button onclick="kickMember(${member.id})">Kick</button>
                    </div>
                `;
                memberList.appendChild(memberDiv);
            });
        } else {
            memberList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No gang members</p>';
        }
    }

    // Update territory information
    function updateTerritoryInfo(territory) {
        document.getElementById('controlled-areas').textContent = territory.controlledAreas || 0;
        document.getElementById('territory-income').textContent = `$${territory.income || 0}`;
        document.getElementById('wars-won').textContent = territory.warsWon || 0;
    }

    // Global function for kicking members
    window.kickMember = function(memberId) {
        fetch(`https://${GetParentResourceName()}/kickMember`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                memberId: memberId
            })
        });
    };

    // Escape key handler
    document.addEventListener('keydown', function(event) {
        if(event.key === 'Escape') {
            container.classList.add('hidden');
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
});