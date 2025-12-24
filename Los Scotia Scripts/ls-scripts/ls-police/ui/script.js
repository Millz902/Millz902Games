// Los Scotia Police MDT JavaScript

class PoliceMDT {
    constructor() {
        this.currentSection = 'dashboard';
        this.playerData = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupNUIListeners();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const section = e.currentTarget.dataset.section;
                this.switchSection(section);
            });
        });

        // Close MDT
        document.getElementById('close-mdt').addEventListener('click', () => {
            this.closeMDT();
        });

        // Modal close buttons
        document.querySelectorAll('.modal-close').forEach(btn => {
            btn.addEventListener('click', () => {
                this.closeModal();
            });
        });

        // Modal backdrop
        document.getElementById('modal-backdrop').addEventListener('click', () => {
            this.closeModal();
        });

        // Search buttons
        document.getElementById('search-citizen-btn').addEventListener('click', () => {
            this.searchCitizen();
        });

        document.getElementById('search-vehicle-btn').addEventListener('click', () => {
            this.searchVehicle();
        });

        // Search on Enter
        document.getElementById('citizen-search').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.searchCitizen();
        });

        document.getElementById('vehicle-search').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.searchVehicle();
        });

        // Create buttons
        document.getElementById('create-report-btn').addEventListener('click', () => {
            this.openModal('report-modal');
        });

        document.getElementById('create-bolo-btn').addEventListener('click', () => {
            this.openModal('bolo-modal');
        });

        // Form submissions
        document.getElementById('report-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.createReport();
        });

        document.getElementById('bolo-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.createBOLO();
        });

        // BOLO type change
        document.getElementById('bolo-type').addEventListener('change', (e) => {
            const type = e.target.value;
            const plateGroup = document.getElementById('bolo-plate-group');
            const personGroup = document.getElementById('bolo-person-group');
            
            if (type === 'vehicle') {
                plateGroup.style.display = 'block';
                personGroup.style.display = 'none';
            } else if (type === 'person') {
                plateGroup.style.display = 'none';
                personGroup.style.display = 'block';
            } else {
                plateGroup.style.display = 'none';
                personGroup.style.display = 'none';
            }
        });

        // Filter reports
        document.getElementById('filter-reports-btn').addEventListener('click', () => {
            this.filterReports();
        });
    }

    setupNUIListeners() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            switch (data.action) {
                case 'openMDT':
                    this.openMDT(data.playerData);
                    break;
                case 'closeMDT':
                    this.closeMDT();
                    break;
                case 'updateDutyList':
                    this.updateDutyList(data.officers);
                    break;
                case 'updateAlerts':
                    this.updateAlerts(data.alerts);
                    break;
            }
        });
    }

    openMDT(playerData) {
        this.playerData = playerData;
        document.getElementById('mdt-container').classList.remove('hidden');
        
        // Update officer info
        const charinfo = playerData.charinfo;
        document.getElementById('officer-name').textContent = 
            `${charinfo.firstname} ${charinfo.lastname}`;
        document.getElementById('officer-badge').textContent = 
            `Badge #${playerData.job.grade.level}${Math.floor(Math.random() * 1000)}`;
        
        // Load dashboard data
        this.loadDashboard();
    }

    closeMDT() {
        document.getElementById('mdt-container').classList.add('hidden');
        this.postData('closeMDT');
    }

    switchSection(section) {
        // Update navigation
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-section="${section}"]`).classList.add('active');

        // Update content
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(`${section}-section`).classList.add('active');

        this.currentSection = section;

        // Load section data
        switch (section) {
            case 'dashboard':
                this.loadDashboard();
                break;
            case 'reports':
                this.loadReports();
                break;
            case 'bolos':
                this.loadBOLOs();
                break;
            case 'evidence':
                this.loadEvidence();
                break;
            case 'warrants':
                this.loadWarrants();
                break;
        }
    }

    loadDashboard() {
        // Load duty officers, alerts, and statistics
        this.postData('getDashboardData').then(data => {
            if (data) {
                this.updateDutyList(data.officers || {});
                this.updateAlerts(data.alerts || []);
                this.updateStatistics(data.stats || {});
            }
        });
    }

    updateDutyList(officers) {
        const container = document.getElementById('duty-officers-list');
        container.innerHTML = '';

        Object.values(officers).forEach(officer => {
            const officerDiv = document.createElement('div');
            officerDiv.className = 'list-item officer-item';
            officerDiv.innerHTML = `
                <div class="list-item-header">
                    <span class="list-item-title">${officer.name}</span>
                    <span class="officer-callsign">${officer.callsign}</span>
                </div>
                <div class="list-item-content">
                    Rank: ${officer.rank}
                </div>
            `;
            container.appendChild(officerDiv);
        });

        if (Object.keys(officers).length === 0) {
            container.innerHTML = '<div class="loading">No officers on duty</div>';
        }
    }

    updateAlerts(alerts) {
        const container = document.getElementById('active-alerts-list');
        container.innerHTML = '';

        alerts.forEach(alert => {
            const alertDiv = document.createElement('div');
            alertDiv.className = `list-item alert-item priority-${alert.priority?.toLowerCase() || 'medium'}`;
            alertDiv.innerHTML = `
                <div class="list-item-header">
                    <span class="list-item-title">${alert.type.toUpperCase()}</span>
                    <span class="list-item-meta">${this.formatTime(alert.timestamp)}</span>
                </div>
                <div class="list-item-content">
                    ${alert.description}
                </div>
            `;
            container.appendChild(alertDiv);
        });

        if (alerts.length === 0) {
            container.innerHTML = '<div class="loading">No active alerts</div>';
        }
    }

    updateStatistics(stats) {
        document.getElementById('total-arrests').textContent = stats.arrests || 0;
        document.getElementById('total-reports').textContent = stats.reports || 0;
        document.getElementById('active-bolos').textContent = stats.bolos || 0;
        document.getElementById('evidence-count').textContent = stats.evidence || 0;
    }

    searchCitizen() {
        const searchTerm = document.getElementById('citizen-search').value.trim();
        if (!searchTerm) return;

        const container = document.getElementById('citizen-results');
        container.innerHTML = '<div class="loading">Searching...</div>';

        this.postData('searchCitizen', { search: searchTerm }).then(results => {
            container.innerHTML = '';
            
            if (results && results.length > 0) {
                results.forEach(citizen => {
                    const citizenDiv = document.createElement('div');
                    citizenDiv.className = 'list-item';
                    citizenDiv.innerHTML = `
                        <div class="list-item-header">
                            <span class="list-item-title">${citizen.firstname} ${citizen.lastname}</span>
                            <span class="list-item-meta">ID: ${citizen.citizenid}</span>
                        </div>
                        <div class="list-item-content">
                            <strong>DOB:</strong> ${citizen.birthdate}<br>
                            <strong>Phone:</strong> ${citizen.phone}<br>
                            <strong>Nationality:</strong> ${citizen.nationality}
                        </div>
                    `;
                    container.appendChild(citizenDiv);
                });
            } else {
                container.innerHTML = '<div class="loading">No citizens found</div>';
            }
        });
    }

    searchVehicle() {
        const plate = document.getElementById('vehicle-search').value.trim().toUpperCase();
        if (!plate) return;

        const container = document.getElementById('vehicle-results');
        container.innerHTML = '<div class="loading">Searching...</div>';

        this.postData('searchVehicle', { plate: plate }).then(result => {
            container.innerHTML = '';
            
            if (result) {
                const vehicleDiv = document.createElement('div');
                vehicleDiv.className = 'list-item';
                vehicleDiv.innerHTML = `
                    <div class="list-item-header">
                        <span class="list-item-title">${result.vehicle} - ${result.plate}</span>
                        <span class="list-item-meta">Status: ${result.state}</span>
                    </div>
                    <div class="list-item-content">
                        <strong>Owner:</strong> ${result.owner}<br>
                        <strong>Garage:</strong> ${result.garage}
                        ${result.bolo ? `<br><strong style="color: #e74c3c;">BOLO:</strong> ${result.bolo.title}` : ''}
                    </div>
                `;
                container.appendChild(vehicleDiv);
            } else {
                container.innerHTML = '<div class="loading">Vehicle not found</div>';
            }
        });
    }

    createReport() {
        const formData = {
            title: document.getElementById('report-title').value,
            type: document.getElementById('report-type').value,
            description: document.getElementById('report-description').value,
            suspects: this.parseJSON(document.getElementById('report-suspects').value) || [],
            evidence: this.parseJSON(document.getElementById('report-evidence').value) || [],
            vehicle_plate: document.getElementById('report-vehicle').value
        };

        this.postData('createReport', formData).then(success => {
            if (success) {
                this.closeModal();
                this.loadReports();
                document.getElementById('report-form').reset();
            }
        });
    }

    createBOLO() {
        const formData = {
            type: document.getElementById('bolo-type').value,
            title: document.getElementById('bolo-title').value,
            description: document.getElementById('bolo-description').value,
            plate: document.getElementById('bolo-plate').value,
            person_id: document.getElementById('bolo-person').value
        };

        this.postData('createBOLO', formData).then(success => {
            if (success) {
                this.closeModal();
                this.loadBOLOs();
                document.getElementById('bolo-form').reset();
            }
        });
    }

    loadReports() {
        const container = document.getElementById('reports-list');
        container.innerHTML = '<div class="loading">Loading reports...</div>';

        this.postData('getReports').then(reports => {
            container.innerHTML = '';
            
            if (reports && reports.length > 0) {
                reports.forEach(report => {
                    const reportDiv = document.createElement('div');
                    reportDiv.className = 'list-item';
                    reportDiv.innerHTML = `
                        <div class="list-item-header">
                            <span class="list-item-title">${report.title}</span>
                            <span class="list-item-meta">${report.type.toUpperCase()} - ${this.formatTime(report.created_at)}</span>
                        </div>
                        <div class="list-item-content">
                            ${report.description.substring(0, 100)}...
                        </div>
                    `;
                    container.appendChild(reportDiv);
                });
            } else {
                container.innerHTML = '<div class="loading">No reports found</div>';
            }
        });
    }

    loadBOLOs() {
        const container = document.getElementById('bolos-list');
        container.innerHTML = '<div class="loading">Loading BOLOs...</div>';

        this.postData('getBOLOs').then(bolos => {
            container.innerHTML = '';
            
            if (bolos && bolos.length > 0) {
                bolos.forEach(bolo => {
                    const boloDiv = document.createElement('div');
                    boloDiv.className = 'list-item alert-item';
                    boloDiv.innerHTML = `
                        <div class="list-item-header">
                            <span class="list-item-title">${bolo.title}</span>
                            <span class="list-item-meta">${bolo.type.toUpperCase()} - ${this.formatTime(bolo.created_at)}</span>
                        </div>
                        <div class="list-item-content">
                            ${bolo.description}<br>
                            ${bolo.plate ? `<strong>Plate:</strong> ${bolo.plate}` : ''}
                            ${bolo.person_id ? `<strong>Person ID:</strong> ${bolo.person_id}` : ''}
                        </div>
                    `;
                    container.appendChild(boloDiv);
                });
            } else {
                container.innerHTML = '<div class="loading">No active BOLOs</div>';
            }
        });
    }

    loadEvidence() {
        const container = document.getElementById('evidence-list');
        container.innerHTML = '<div class="loading">Loading evidence...</div>';

        this.postData('getEvidence').then(evidence => {
            container.innerHTML = '';
            
            if (evidence && evidence.length > 0) {
                evidence.forEach(item => {
                    const evidenceDiv = document.createElement('div');
                    evidenceDiv.className = 'list-item';
                    evidenceDiv.innerHTML = `
                        <div class="list-item-header">
                            <span class="list-item-title">${item.id}</span>
                            <span class="list-item-meta">${item.type.toUpperCase()} - ${this.formatTime(item.created_at)}</span>
                        </div>
                        <div class="list-item-content">
                            Collected by: ${item.collector}<br>
                            ${item.data.description || 'No description'}
                        </div>
                    `;
                    container.appendChild(evidenceDiv);
                });
            } else {
                container.innerHTML = '<div class="loading">No evidence found</div>';
            }
        });
    }

    loadWarrants() {
        const container = document.getElementById('warrants-list');
        container.innerHTML = '<div class="loading">Loading warrants...</div>';

        this.postData('getWarrants').then(warrants => {
            container.innerHTML = '';
            
            if (warrants && warrants.length > 0) {
                warrants.forEach(warrant => {
                    const warrantDiv = document.createElement('div');
                    warrantDiv.className = 'list-item alert-item';
                    warrantDiv.innerHTML = `
                        <div class="list-item-header">
                            <span class="list-item-title">Warrant #${warrant.id}</span>
                            <span class="list-item-meta">${this.formatTime(warrant.created_at)}</span>
                        </div>
                        <div class="list-item-content">
                            <strong>Subject:</strong> ${warrant.person_id}<br>
                            <strong>Bail:</strong> $${warrant.bail_amount.toLocaleString()}
                        </div>
                    `;
                    container.appendChild(warrantDiv);
                });
            } else {
                container.innerHTML = '<div class="loading">No active warrants</div>';
            }
        });
    }

    openModal(modalId) {
        document.getElementById('modal-backdrop').classList.remove('hidden');
        document.getElementById(modalId).classList.remove('hidden');
    }

    closeModal() {
        document.getElementById('modal-backdrop').classList.add('hidden');
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.add('hidden');
        });
    }

    parseJSON(str) {
        try {
            return JSON.parse(str);
        } catch (e) {
            return null;
        }
    }

    formatTime(timestamp) {
        return new Date(timestamp * 1000).toLocaleString();
    }

    postData(action, data = {}) {
        return fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        }).then(response => {
            if (response.ok) {
                return response.json();
            }
            return null;
        }).catch(error => {
            console.error('Error:', error);
            return null;
        });
    }
}

// Initialize MDT when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new PoliceMDT();
});

// Handle escape key to close MDT
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const mdt = document.getElementById('mdt-container');
        if (!mdt.classList.contains('hidden')) {
            new PoliceMDT().closeMDT();
        }
    }
});

// Utility function for FiveM
function GetParentResourceName() {
    return 'ls-police';
}