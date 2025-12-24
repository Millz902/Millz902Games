document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('container');
    const closeBtn = document.getElementById('close-btn');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    const actionCards = document.querySelectorAll('.action-card');

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

    // Action card handlers
    actionCards.forEach(card => {
        card.addEventListener('click', function() {
            const action = this.getAttribute('data-action');
            fetch(`https://${GetParentResourceName()}/policeAction`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    action: action
                })
            });
        });
    });

    // Evidence actions
    document.getElementById('collect-evidence').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/collectEvidence`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('analyze-evidence').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/analyzeEvidence`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Dispatch actions
    document.getElementById('respond-call').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/respondToCall`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('backup-request').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/requestBackup`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    document.getElementById('panic-button').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/panicButton`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Report actions
    document.getElementById('create-report').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/createReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    });

    // Listen for messages from the client
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'show':
                container.classList.remove('hidden');
                if(data.policeData) {
                    updatePoliceData(data.policeData);
                }
                break;
                
            case 'hide':
                container.classList.add('hidden');
                break;
                
            case 'updateEvidence':
                if(data.evidence) {
                    updateEvidenceList(data.evidence);
                }
                break;
                
            case 'updateCalls':
                if(data.calls) {
                    updateCallList(data.calls);
                }
                break;
                
            case 'updateReports':
                if(data.reports) {
                    updateReportList(data.reports);
                }
                break;
        }
    });

    // Update police data
    function updatePoliceData(policeData) {
        if(policeData.evidence) {
            updateEvidenceList(policeData.evidence);
        }
        if(policeData.calls) {
            updateCallList(policeData.calls);
        }
        if(policeData.reports) {
            updateReportList(policeData.reports);
        }
    }

    // Update evidence list
    function updateEvidenceList(evidence) {
        const evidenceList = document.querySelector('.evidence-list');
        evidenceList.innerHTML = '';
        
        if(evidence && evidence.length > 0) {
            evidence.forEach(item => {
                const evidenceDiv = document.createElement('div');
                evidenceDiv.className = 'evidence-item';
                evidenceDiv.innerHTML = `
                    <div class="item-info">
                        <span class="item-title">${item.type}</span>
                        <span class="item-description">${item.description}</span>
                        <span class="item-time">${item.collected}</span>
                    </div>
                    <div class="item-actions">
                        <button onclick="viewEvidence(${item.id})">View</button>
                        <button onclick="analyzeEvidence(${item.id})">Analyze</button>
                        <button class="danger" onclick="deleteEvidence(${item.id})">Delete</button>
                    </div>
                `;
                evidenceList.appendChild(evidenceDiv);
            });
        } else {
            evidenceList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No evidence collected</p>';
        }
    }

    // Update call list
    function updateCallList(calls) {
        const callList = document.querySelector('.call-list');
        callList.innerHTML = '';
        
        if(calls && calls.length > 0) {
            calls.forEach(call => {
                const callDiv = document.createElement('div');
                callDiv.className = `call-item priority-${call.priority}`;
                callDiv.innerHTML = `
                    <div class="item-info">
                        <span class="item-title">${call.title}</span>
                        <span class="item-description">${call.location}</span>
                        <span class="item-time status-${call.status}">${call.time}</span>
                    </div>
                    <div class="item-actions">
                        <button onclick="respondToCall(${call.id})">Respond</button>
                        <button onclick="viewCallDetails(${call.id})">Details</button>
                    </div>
                `;
                callList.appendChild(callDiv);
            });
        } else {
            callList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No active calls</p>';
        }
    }

    // Update report list
    function updateReportList(reports) {
        const reportList = document.querySelector('.report-list');
        reportList.innerHTML = '';
        
        if(reports && reports.length > 0) {
            reports.forEach(report => {
                const reportDiv = document.createElement('div');
                reportDiv.className = 'report-item';
                reportDiv.innerHTML = `
                    <div class="item-info">
                        <span class="item-title">${report.title}</span>
                        <span class="item-description">${report.officer}</span>
                        <span class="item-time">${report.date}</span>
                    </div>
                    <div class="item-actions">
                        <button onclick="viewReport(${report.id})">View</button>
                        <button onclick="editReport(${report.id})">Edit</button>
                        <button class="danger" onclick="deleteReport(${report.id})">Delete</button>
                    </div>
                `;
                reportList.appendChild(reportDiv);
            });
        } else {
            reportList.innerHTML = '<p style="color: #a0a0a0; text-align: center;">No reports available</p>';
        }
    }

    // Global functions for various actions
    window.viewEvidence = function(evidenceId) {
        fetch(`https://${GetParentResourceName()}/viewEvidence`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ evidenceId: evidenceId })
        });
    };

    window.analyzeEvidence = function(evidenceId) {
        fetch(`https://${GetParentResourceName()}/analyzeSpecificEvidence`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ evidenceId: evidenceId })
        });
    };

    window.deleteEvidence = function(evidenceId) {
        fetch(`https://${GetParentResourceName()}/deleteEvidence`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ evidenceId: evidenceId })
        });
    };

    window.respondToCall = function(callId) {
        fetch(`https://${GetParentResourceName()}/respondToSpecificCall`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ callId: callId })
        });
    };

    window.viewCallDetails = function(callId) {
        fetch(`https://${GetParentResourceName()}/viewCallDetails`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ callId: callId })
        });
    };

    window.viewReport = function(reportId) {
        fetch(`https://${GetParentResourceName()}/viewReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ reportId: reportId })
        });
    };

    window.editReport = function(reportId) {
        fetch(`https://${GetParentResourceName()}/editReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ reportId: reportId })
        });
    };

    window.deleteReport = function(reportId) {
        fetch(`https://${GetParentResourceName()}/deleteReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ reportId: reportId })
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