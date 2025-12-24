// LS Towing & Recovery System - JavaScript Functionality

// Global state management
const TowingSystem = {
    state: {
        currentTab: 'dispatch',
        isOnDuty: false,
        dispatcherId: null,
        trucks: [],
        drivers: [],
        jobs: [],
        impoundedVehicles: [],
        bills: [],
        settings: {},
        map: {
            trucks: [],
            incidents: [],
            impounds: []
        }
    },
    
    // Initialize the system
    init() {
        this.setupEventListeners();
        this.setupTabs();
        this.loadData();
        this.startUpdates();
        this.updateTime();
        this.setupMap();
    },
    
    // Setup event listeners for UI interactions
    setupEventListeners() {
        // Tab navigation
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                const tabName = e.currentTarget.dataset.tab;
                this.switchTab(tabName);
            });
        });
        
        // Modal handling
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal-overlay')) {
                this.closeModal();
            }
            
            if (e.target.classList.contains('modal-close')) {
                this.closeModal();
            }
        });
        
        // Action buttons
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('assign-btn')) {
                const jobId = e.target.dataset.jobId;
                this.showAssignJobModal(jobId);
            }
            
            if (e.target.classList.contains('release-btn')) {
                const vehicleId = e.target.dataset.vehicleId;
                this.releaseVehicle(vehicleId);
            }
            
            if (e.target.classList.contains('dispatch-btn')) {
                const truckId = e.target.dataset.truckId;
                this.dispatchTruck(truckId);
            }
            
            if (e.target.classList.contains('view-bill-btn')) {
                const billId = e.target.dataset.billId;
                this.viewBill(billId);
            }
        });
        
        // Settings form
        const settingsForm = document.getElementById('settings-form');
        if (settingsForm) {
            settingsForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.saveSettings();
            });
        }
        
        // Filter handling
        document.querySelectorAll('.filter-input').forEach(input => {
            input.addEventListener('input', (e) => {
                this.handleFilter(e.target);
            });
        });
        
        // Duty toggle
        const dutyToggle = document.getElementById('duty-toggle');
        if (dutyToggle) {
            dutyToggle.addEventListener('click', () => {
                this.toggleDuty();
            });
        }
        
        // Job creation
        const newJobBtn = document.getElementById('new-job-btn');
        if (newJobBtn) {
            newJobBtn.addEventListener('click', () => {
                this.showNewJobModal();
            });
        }
        
        // Map controls
        document.querySelectorAll('.map-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.target.dataset.action;
                this.handleMapAction(action);
            });
        });
    },
    
    // Setup tab switching
    setupTabs() {
        this.switchTab('dispatch');
    },
    
    // Switch between tabs
    switchTab(tabName) {
        // Update state
        this.state.currentTab = tabName;
        
        // Update navigation
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        
        // Update content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(`${tabName}-tab`).classList.add('active');
        
        // Load tab-specific data
        switch (tabName) {
            case 'dispatch':
                this.updateDispatchView();
                break;
            case 'trucks':
                this.updateTrucksView();
                break;
            case 'drivers':
                this.updateDriversView();
                break;
            case 'impound':
                this.updateImpoundView();
                break;
            case 'jobs':
                this.updateJobsView();
                break;
            case 'billing':
                this.updateBillingView();
                break;
            case 'settings':
                this.updateSettingsView();
                break;
        }
    },
    
    // Load initial data
    loadData() {
        // Send NUI message to load data from server
        this.sendNUIMessage('loadTowingData', {});
        
        // Mock data for testing
        this.state.trucks = [
            {
                id: 'TOW-001',
                callsign: 'Tow 1',
                type: 'Heavy Duty',
                driver: 'John Smith',
                status: 'available',
                location: { x: 150, y: 200 },
                fuel: 85,
                odometer: 45230,
                lastMaintenance: '2024-01-15'
            },
            {
                id: 'TOW-002',
                callsign: 'Tow 2',
                type: 'Light Duty',
                driver: 'Mike Johnson',
                status: 'busy',
                location: { x: 300, y: 150 },
                fuel: 62,
                odometer: 32100,
                lastMaintenance: '2024-01-10'
            }
        ];
        
        this.state.jobs = [
            {
                id: 'JOB-001',
                type: 'Vehicle Breakdown',
                priority: 'urgent',
                location: 'Highway 1, Mile 15',
                customer: 'Sarah Wilson',
                vehicle: '2020 Honda Civic',
                timeCreated: new Date().toISOString(),
                status: 'pending',
                description: 'Engine overheating, needs roadside assistance'
            },
            {
                id: 'JOB-002',
                type: 'Accident Recovery',
                priority: 'emergency',
                location: 'Main St & 5th Ave',
                customer: 'Emergency Services',
                vehicle: '2019 Ford F-150',
                timeCreated: new Date(Date.now() - 300000).toISOString(),
                status: 'assigned',
                assignedTruck: 'TOW-002',
                description: 'Multi-vehicle accident, requires immediate towing'
            }
        ];
        
        this.state.drivers = [
            {
                id: 'DRV-001',
                name: 'John Smith',
                phone: '555-0101',
                status: 'online',
                currentTruck: 'TOW-001',
                rating: 4.8,
                totalJobs: 245,
                hireDate: '2023-03-15'
            },
            {
                id: 'DRV-002',
                name: 'Mike Johnson',
                phone: '555-0102',
                status: 'busy',
                currentTruck: 'TOW-002',
                rating: 4.6,
                totalJobs: 189,
                hireDate: '2023-07-22'
            }
        ];
        
        this.state.impoundedVehicles = [
            {
                id: 'IMP-001',
                plate: 'ABC123',
                make: 'Toyota',
                model: 'Camry',
                year: 2018,
                color: 'Blue',
                ownerName: 'Alex Thompson',
                ownerPhone: '555-0201',
                reason: 'Illegal Parking',
                impoundDate: '2024-01-18',
                location: 'Lot A-12',
                fees: 250,
                status: 'impounded'
            }
        ];
    },
    
    // Update dispatch view
    updateDispatchView() {
        this.updateJobQueue();
        this.updateDispatchStats();
        this.updateMap();
    },
    
    // Update job queue
    updateJobQueue() {
        const jobQueue = document.getElementById('job-queue');
        if (!jobQueue) return;
        
        jobQueue.innerHTML = '';
        
        this.state.jobs.forEach(job => {
            const jobElement = this.createJobElement(job);
            jobQueue.appendChild(jobElement);
        });
    },
    
    // Create job element
    createJobElement(job) {
        const div = document.createElement('div');
        div.className = `job-item ${job.priority}`;
        
        const timeAgo = this.formatTimeAgo(new Date(job.timeCreated));
        const priorityIcon = this.getPriorityIcon(job.priority);
        
        div.innerHTML = `
            <div class="job-priority ${job.priority}">
                <i class="${priorityIcon}"></i>
                ${job.priority.toUpperCase()}
            </div>
            <div class="job-details">
                <div class="job-type">${job.type}</div>
                <div class="job-location"><i class="fas fa-map-marker-alt"></i> ${job.location}</div>
                <div class="job-customer"><i class="fas fa-user"></i> ${job.customer}</div>
                <div class="job-vehicle"><i class="fas fa-car"></i> ${job.vehicle}</div>
                <div class="job-time"><i class="fas fa-clock"></i> ${timeAgo}</div>
            </div>
            <div class="job-actions">
                <button class="assign-btn ${job.priority}" data-job-id="${job.id}">
                    <i class="fas fa-truck"></i>
                    ${job.status === 'assigned' ? 'Reassign' : 'Assign'}
                </button>
            </div>
        `;
        
        return div;
    },
    
    // Update dispatch statistics
    updateDispatchStats() {
        const pendingJobs = this.state.jobs.filter(job => job.status === 'pending').length;
        const activeJobs = this.state.jobs.filter(job => job.status === 'assigned' || job.status === 'in-progress').length;
        const availableTrucks = this.state.trucks.filter(truck => truck.status === 'available').length;
        const onlineDrivers = this.state.drivers.filter(driver => driver.status === 'online' || driver.status === 'busy').length;
        
        document.getElementById('pending-jobs').textContent = pendingJobs;
        document.getElementById('active-jobs').textContent = activeJobs;
        document.getElementById('available-trucks').textContent = availableTrucks;
        document.getElementById('online-drivers').textContent = onlineDrivers;
    },
    
    // Update map view
    updateMap() {
        const mapOverlay = document.querySelector('.map-overlay');
        if (!mapOverlay) return;
        
        mapOverlay.innerHTML = '';
        
        // Add truck markers
        this.state.trucks.forEach(truck => {
            const marker = this.createTruckMarker(truck);
            mapOverlay.appendChild(marker);
        });
        
        // Add incident markers
        this.state.jobs.filter(job => job.status === 'pending').forEach(job => {
            const marker = this.createIncidentMarker(job);
            mapOverlay.appendChild(marker);
        });
        
        // Add impound markers
        const impoundLots = [
            { id: 'lot-a', name: 'Lot A', x: 100, y: 300 },
            { id: 'lot-b', name: 'Lot B', x: 350, y: 250 }
        ];
        
        impoundLots.forEach(lot => {
            const marker = this.createImpoundMarker(lot);
            mapOverlay.appendChild(marker);
        });
    },
    
    // Create truck marker
    createTruckMarker(truck) {
        const marker = document.createElement('div');
        marker.className = `truck-marker ${truck.status}`;
        marker.style.left = `${truck.location.x}px`;
        marker.style.top = `${truck.location.y}px`;
        marker.innerHTML = `
            <i class="fas fa-truck"></i>
            <div class="truck-info">
                ${truck.callsign}<br>
                Driver: ${truck.driver}<br>
                Status: ${truck.status.charAt(0).toUpperCase() + truck.status.slice(1)}
            </div>
        `;
        
        return marker;
    },
    
    // Create incident marker
    createIncidentMarker(job) {
        const marker = document.createElement('div');
        marker.className = 'incident-marker';
        // Random position for demo
        marker.style.left = `${Math.random() * 400}px`;
        marker.style.top = `${Math.random() * 300}px`;
        marker.innerHTML = `
            <i class="fas fa-exclamation-triangle"></i>
            <div class="incident-info">
                ${job.type}<br>
                Priority: ${job.priority}<br>
                Customer: ${job.customer}
            </div>
        `;
        
        return marker;
    },
    
    // Create impound marker
    createImpoundMarker(lot) {
        const marker = document.createElement('div');
        marker.className = 'impound-marker';
        marker.style.left = `${lot.x}px`;
        marker.style.top = `${lot.y}px`;
        marker.innerHTML = `
            <i class="fas fa-parking"></i>
            <div class="impound-info">
                ${lot.name}<br>
                Impound Lot
            </div>
        `;
        
        return marker;
    },
    
    // Update trucks view
    updateTrucksView() {
        const trucksGrid = document.getElementById('trucks-grid');
        if (!trucksGrid) return;
        
        trucksGrid.innerHTML = '';
        
        this.state.trucks.forEach(truck => {
            const truckCard = this.createTruckCard(truck);
            trucksGrid.appendChild(truckCard);
        });
        
        this.updateTruckStats();
    },
    
    // Create truck card
    createTruckCard(truck) {
        const div = document.createElement('div');
        div.className = `truck-card ${truck.status}`;
        
        div.innerHTML = `
            <div class="truck-header">
                <div class="truck-image">
                    <i class="fas fa-truck"></i>
                </div>
                <div class="truck-info">
                    <h4>${truck.callsign}</h4>
                    <span class="truck-id">ID: ${truck.id}</span>
                    <span class="truck-type">${truck.type}</span>
                </div>
                <div class="truck-status ${truck.status}">
                    <div class="status-indicator ${truck.status}"></div>
                    ${truck.status.charAt(0).toUpperCase() + truck.status.slice(1)}
                </div>
            </div>
            <div class="truck-details">
                <div class="detail-item">
                    <span class="detail-label">Driver:</span>
                    <span class="detail-value">${truck.driver}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Fuel:</span>
                    <span class="detail-value">${truck.fuel}%</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Odometer:</span>
                    <span class="detail-value">${truck.odometer.toLocaleString()} mi</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Last Service:</span>
                    <span class="detail-value">${truck.lastMaintenance}</span>
                </div>
            </div>
            <div class="truck-actions">
                <button class="action-btn primary small dispatch-btn" data-truck-id="${truck.id}">
                    <i class="fas fa-paper-plane"></i>
                    Dispatch
                </button>
                <button class="action-btn secondary small" onclick="TowingSystem.viewTruckDetails('${truck.id}')">
                    <i class="fas fa-eye"></i>
                    Details
                </button>
                <button class="action-btn warning small" onclick="TowingSystem.scheduleMaintenance('${truck.id}')">
                    <i class="fas fa-wrench"></i>
                    Service
                </button>
            </div>
        `;
        
        return div;
    },
    
    // Update truck statistics
    updateTruckStats() {
        const availableTrucks = this.state.trucks.filter(truck => truck.status === 'available').length;
        const busyTrucks = this.state.trucks.filter(truck => truck.status === 'busy').length;
        const maintenanceTrucks = this.state.trucks.filter(truck => truck.status === 'maintenance').length;
        const totalTrucks = this.state.trucks.length;
        
        document.getElementById('available-trucks-stat').textContent = availableTrucks;
        document.getElementById('busy-trucks-stat').textContent = busyTrucks;
        document.getElementById('maintenance-trucks-stat').textContent = maintenanceTrucks;
        document.getElementById('total-trucks-stat').textContent = totalTrucks;
    },
    
    // Update drivers view
    updateDriversView() {
        const driversTable = document.getElementById('drivers-table-body');
        if (!driversTable) return;
        
        driversTable.innerHTML = '';
        
        this.state.drivers.forEach(driver => {
            const row = this.createDriverRow(driver);
            driversTable.appendChild(row);
        });
    },
    
    // Create driver row
    createDriverRow(driver) {
        const tr = document.createElement('tr');
        
        tr.innerHTML = `
            <td>
                <div class="driver-info">
                    <i class="fas fa-user-circle driver-avatar"></i>
                    <div>
                        <strong>${driver.name}</strong>
                        <small>ID: ${driver.id}</small>
                    </div>
                </div>
            </td>
            <td>${driver.phone}</td>
            <td><span class="status-badge ${driver.status}">${driver.status.charAt(0).toUpperCase() + driver.status.slice(1)}</span></td>
            <td>${driver.currentTruck || 'None'}</td>
            <td>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <span>${driver.rating}</span>
                    <div style="color: #ff6b35;">
                        ${'★'.repeat(Math.floor(driver.rating))}${'☆'.repeat(5 - Math.floor(driver.rating))}
                    </div>
                </div>
            </td>
            <td>${driver.totalJobs}</td>
            <td>${driver.hireDate}</td>
            <td>
                <div style="display: flex; gap: 0.5rem;">
                    <button class="action-btn primary small" onclick="TowingSystem.viewDriverDetails('${driver.id}')">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="action-btn secondary small" onclick="TowingSystem.editDriver('${driver.id}')">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
        `;
        
        return tr;
    },
    
    // Update impound view
    updateImpoundView() {
        const impoundTable = document.getElementById('impound-table-body');
        if (!impoundTable) return;
        
        impoundTable.innerHTML = '';
        
        this.state.impoundedVehicles.forEach(vehicle => {
            const row = this.createImpoundRow(vehicle);
            impoundTable.appendChild(row);
        });
        
        this.updateImpoundStats();
    },
    
    // Create impound row
    createImpoundRow(vehicle) {
        const tr = document.createElement('tr');
        
        const daysSinceImpound = Math.floor((new Date() - new Date(vehicle.impoundDate)) / (1000 * 60 * 60 * 24));
        
        tr.innerHTML = `
            <td>
                <div class="vehicle-info">
                    <strong>${vehicle.plate}</strong>
                    <small>${vehicle.year} ${vehicle.make} ${vehicle.model}</small>
                </div>
            </td>
            <td>${vehicle.color}</td>
            <td>
                <div>
                    <strong>${vehicle.ownerName}</strong>
                    <small>${vehicle.ownerPhone}</small>
                </div>
            </td>
            <td>${vehicle.reason}</td>
            <td>${vehicle.impoundDate}</td>
            <td>${vehicle.location}</td>
            <td>$${vehicle.fees.toFixed(2)}</td>
            <td><span class="status-badge ${vehicle.status}">${vehicle.status.charAt(0).toUpperCase() + vehicle.status.slice(1)}</span></td>
            <td>
                <div style="display: flex; gap: 0.5rem;">
                    <button class="action-btn success small release-btn" data-vehicle-id="${vehicle.id}">
                        <i class="fas fa-unlock"></i>
                        Release
                    </button>
                    <button class="action-btn secondary small" onclick="TowingSystem.viewVehicleDetails('${vehicle.id}')">
                        <i class="fas fa-eye"></i>
                        Details
                    </button>
                </div>
            </td>
        `;
        
        return tr;
    },
    
    // Update impound statistics
    updateImpoundStats() {
        const totalImpounded = this.state.impoundedVehicles.length;
        const pendingRelease = this.state.impoundedVehicles.filter(v => v.status === 'pending_release').length;
        const totalFees = this.state.impoundedVehicles.reduce((sum, v) => sum + v.fees, 0);
        const availableSpaces = 50 - totalImpounded; // Assuming 50 total spaces
        
        document.getElementById('total-impounded-stat').textContent = totalImpounded;
        document.getElementById('pending-release-stat').textContent = pendingRelease;
        document.getElementById('total-fees-stat').textContent = `$${totalFees.toFixed(2)}`;
        document.getElementById('available-spaces-stat').textContent = availableSpaces;
    },
    
    // Update jobs view
    updateJobsView() {
        const jobsTable = document.getElementById('jobs-table-body');
        if (!jobsTable) return;
        
        jobsTable.innerHTML = '';
        
        this.state.jobs.forEach(job => {
            const row = this.createJobRow(job);
            jobsTable.appendChild(row);
        });
        
        this.updateJobStats();
    },
    
    // Create job row
    createJobRow(job) {
        const tr = document.createElement('tr');
        
        tr.innerHTML = `
            <td>${job.id}</td>
            <td>${job.type}</td>
            <td><span class="status-badge ${job.priority}">${job.priority.charAt(0).toUpperCase() + job.priority.slice(1)}</span></td>
            <td>${job.location}</td>
            <td>${job.customer}</td>
            <td>${job.vehicle}</td>
            <td>${job.assignedTruck || 'Not Assigned'}</td>
            <td><span class="status-badge ${job.status}">${job.status.replace('_', ' ').charAt(0).toUpperCase() + job.status.replace('_', ' ').slice(1)}</span></td>
            <td>${new Date(job.timeCreated).toLocaleDateString()}</td>
            <td>
                <div style="display: flex; gap: 0.5rem;">
                    <button class="action-btn primary small" onclick="TowingSystem.viewJobDetails('${job.id}')">
                        <i class="fas fa-eye"></i>
                        Details
                    </button>
                    <button class="action-btn secondary small" onclick="TowingSystem.editJob('${job.id}')">
                        <i class="fas fa-edit"></i>
                        Edit
                    </button>
                </div>
            </td>
        `;
        
        return tr;
    },
    
    // Update job statistics
    updateJobStats() {
        const completedJobs = this.state.jobs.filter(job => job.status === 'completed').length;
        const pendingJobs = this.state.jobs.filter(job => job.status === 'pending').length;
        const inProgressJobs = this.state.jobs.filter(job => job.status === 'in-progress').length;
        const totalJobs = this.state.jobs.length;
        
        document.getElementById('completed-jobs-stat').textContent = completedJobs;
        document.getElementById('pending-jobs-stat').textContent = pendingJobs;
        document.getElementById('in-progress-jobs-stat').textContent = inProgressJobs;
        document.getElementById('total-jobs-stat').textContent = totalJobs;
    },
    
    // Update billing view
    updateBillingView() {
        this.updateFinancialSummary();
        this.updateRevenueChart();
        this.updateOutstandingInvoices();
    },
    
    // Update financial summary
    updateFinancialSummary() {
        // Mock financial data
        const revenue = 15420.50;
        const expenses = 8230.25;
        const profit = revenue - expenses;
        
        document.getElementById('revenue-amount').textContent = `$${revenue.toLocaleString()}`;
        document.getElementById('expenses-amount').textContent = `$${expenses.toLocaleString()}`;
        document.getElementById('profit-amount').textContent = `$${profit.toLocaleString()}`;
        
        // Update change indicators
        document.getElementById('revenue-change').textContent = '+12.5%';
        document.getElementById('expenses-change').textContent = '+5.2%';
        document.getElementById('profit-change').textContent = '+18.3%';
    },
    
    // Update revenue chart
    updateRevenueChart() {
        const chartBars = document.querySelector('.chart-bars');
        if (!chartBars) return;
        
        const monthlyData = [
            { month: 'Jan', amount: 12500 },
            { month: 'Feb', amount: 13200 },
            { month: 'Mar', amount: 11800 },
            { month: 'Apr', amount: 14500 },
            { month: 'May', amount: 15420 }
        ];
        
        chartBars.innerHTML = '';
        const maxAmount = Math.max(...monthlyData.map(d => d.amount));
        
        monthlyData.forEach(data => {
            const bar = document.createElement('div');
            bar.className = 'chart-bar';
            const height = (data.amount / maxAmount) * 250;
            bar.style.height = `${height}px`;
            
            bar.innerHTML = `
                <div class="bar-value">$${data.amount.toLocaleString()}</div>
                <div class="bar-label">${data.month}</div>
            `;
            
            chartBars.appendChild(bar);
        });
    },
    
    // Update outstanding invoices
    updateOutstandingInvoices() {
        const invoicesTable = document.getElementById('invoices-table-body');
        if (!invoicesTable) return;
        
        // Mock invoice data
        const invoices = [
            {
                id: 'INV-001',
                customer: 'Sarah Wilson',
                amount: 150.00,
                service: 'Roadside Assistance',
                dueDate: '2024-01-25',
                status: 'overdue'
            },
            {
                id: 'INV-002',
                customer: 'Mike Thompson',
                amount: 320.00,
                service: 'Vehicle Recovery',
                dueDate: '2024-01-30',
                status: 'pending'
            }
        ];
        
        invoicesTable.innerHTML = '';
        
        invoices.forEach(invoice => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${invoice.id}</td>
                <td>${invoice.customer}</td>
                <td>$${invoice.amount.toFixed(2)}</td>
                <td>${invoice.service}</td>
                <td>${invoice.dueDate}</td>
                <td><span class="status-badge ${invoice.status}">${invoice.status.charAt(0).toUpperCase() + invoice.status.slice(1)}</span></td>
                <td>
                    <button class="action-btn primary small view-bill-btn" data-bill-id="${invoice.id}">
                        <i class="fas fa-eye"></i>
                        View
                    </button>
                </td>
            `;
            invoicesTable.appendChild(tr);
        });
    },
    
    // Update settings view
    updateSettingsView() {
        // Load current settings
        const settings = this.state.settings;
        
        // Populate form fields
        Object.keys(settings).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                if (element.type === 'checkbox') {
                    element.checked = settings[key];
                } else {
                    element.value = settings[key] || '';
                }
            }
        });
    },
    
    // Modal functions
    showAssignJobModal(jobId) {
        const job = this.state.jobs.find(j => j.id === jobId);
        if (!job) return;
        
        const availableTrucks = this.state.trucks.filter(truck => truck.status === 'available');
        
        const modalContent = `
            <div class="modal-header">
                <h3>Assign Job: ${job.type}</h3>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <p><strong>Location:</strong> ${job.location}</p>
                <p><strong>Customer:</strong> ${job.customer}</p>
                <p><strong>Vehicle:</strong> ${job.vehicle}</p>
                <p><strong>Priority:</strong> ${job.priority}</p>
                <br>
                <label for="truck-select">Select Truck:</label>
                <select id="truck-select" style="width: 100%; padding: 0.5rem; margin-top: 0.5rem;">
                    <option value="">Choose a truck...</option>
                    ${availableTrucks.map(truck => 
                        `<option value="${truck.id}">${truck.callsign} - ${truck.driver}</option>`
                    ).join('')}
                </select>
            </div>
            <div class="modal-footer">
                <button class="btn secondary" onclick="TowingSystem.closeModal()">Cancel</button>
                <button class="btn primary" onclick="TowingSystem.assignJob('${jobId}')">Assign Job</button>
            </div>
        `;
        
        this.showModal(modalContent);
    },
    
    showModal(content) {
        const modal = document.getElementById('modal-overlay');
        const modalContent = document.querySelector('.modal-content');
        modalContent.innerHTML = content;
        modal.classList.remove('hidden');
    },
    
    closeModal() {
        const modal = document.getElementById('modal-overlay');
        modal.classList.add('hidden');
    },
    
    // Action functions
    assignJob(jobId) {
        const truckSelect = document.getElementById('truck-select');
        const selectedTruck = truckSelect.value;
        
        if (!selectedTruck) {
            alert('Please select a truck');
            return;
        }
        
        // Update job
        const job = this.state.jobs.find(j => j.id === jobId);
        if (job) {
            job.status = 'assigned';
            job.assignedTruck = selectedTruck;
        }
        
        // Update truck status
        const truck = this.state.trucks.find(t => t.id === selectedTruck);
        if (truck) {
            truck.status = 'busy';
        }
        
        // Send to server
        this.sendNUIMessage('assignJob', { jobId, truckId: selectedTruck });
        
        this.closeModal();
        this.updateDispatchView();
        this.showNotification('Job assigned successfully', 'success');
    },
    
    releaseVehicle(vehicleId) {
        const vehicle = this.state.impoundedVehicles.find(v => v.id === vehicleId);
        if (!vehicle) return;
        
        if (confirm(`Release vehicle ${vehicle.plate}? Total fees: $${vehicle.fees.toFixed(2)}`)) {
            // Remove from impounded vehicles
            this.state.impoundedVehicles = this.state.impoundedVehicles.filter(v => v.id !== vehicleId);
            
            // Send to server
            this.sendNUIMessage('releaseVehicle', { vehicleId });
            
            this.updateImpoundView();
            this.showNotification('Vehicle released successfully', 'success');
        }
    },
    
    toggleDuty() {
        this.state.isOnDuty = !this.state.isOnDuty;
        
        const dutyButton = document.getElementById('duty-toggle');
        const statusIndicator = document.querySelector('.status-indicator');
        
        if (this.state.isOnDuty) {
            dutyButton.textContent = 'Go Off Duty';
            dutyButton.classList.add('danger');
            statusIndicator.classList.remove('offline');
        } else {
            dutyButton.textContent = 'Go On Duty';
            dutyButton.classList.remove('danger');
            statusIndicator.classList.add('offline');
        }
        
        this.sendNUIMessage('toggleDuty', { onDuty: this.state.isOnDuty });
    },
    
    // Utility functions
    updateTime() {
        const timeElement = document.querySelector('.current-time');
        if (timeElement) {
            timeElement.textContent = new Date().toLocaleTimeString();
        }
    },
    
    formatTimeAgo(date) {
        const now = new Date();
        const diffInMinutes = Math.floor((now - date) / (1000 * 60));
        
        if (diffInMinutes < 1) return 'Just now';
        if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
        
        const diffInHours = Math.floor(diffInMinutes / 60);
        if (diffInHours < 24) return `${diffInHours}h ago`;
        
        const diffInDays = Math.floor(diffInHours / 24);
        return `${diffInDays}d ago`;
    },
    
    getPriorityIcon(priority) {
        const icons = {
            'emergency': 'fas fa-exclamation-triangle',
            'urgent': 'fas fa-exclamation-circle',
            'normal': 'fas fa-info-circle',
            'scheduled': 'fas fa-calendar-alt'
        };
        return icons[priority] || 'fas fa-info-circle';
    },
    
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        // Add notification styles
        notification.style.position = 'fixed';
        notification.style.top = '20px';
        notification.style.right = '20px';
        notification.style.background = type === 'success' ? '#00ff00' : type === 'error' ? '#ff4444' : '#ff6b35';
        notification.style.color = '#000';
        notification.style.padding = '1rem';
        notification.style.borderRadius = '5px';
        notification.style.zIndex = '10000';
        notification.style.transition = 'opacity 0.3s ease';
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    },
    
    sendNUIMessage(action, data) {
        // Send message to FiveM client
        if (typeof GetParentResourceName !== 'undefined') {
            fetch(`https://${GetParentResourceName()}/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
        }
    },
    
    // Setup map functionality
    setupMap() {
        // Initialize map interactions
        this.updateMap();
    },
    
    handleMapAction(action) {
        switch (action) {
            case 'refresh':
                this.updateMap();
                break;
            case 'center':
                // Center map view
                break;
            case 'toggle-trucks':
                // Toggle truck visibility
                break;
            case 'toggle-incidents':
                // Toggle incident visibility
                break;
        }
    },
    
    // Filter handling
    handleFilter(input) {
        const filterType = input.dataset.filter;
        const filterValue = input.value.toLowerCase();
        
        // Implement filtering logic based on current tab
        switch (this.state.currentTab) {
            case 'drivers':
                this.filterDrivers(filterValue);
                break;
            case 'impound':
                this.filterImpound(filterValue);
                break;
            case 'jobs':
                this.filterJobs(filterValue);
                break;
        }
    },
    
    filterDrivers(filterValue) {
        const rows = document.querySelectorAll('#drivers-table-body tr');
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(filterValue) ? '' : 'none';
        });
    },
    
    filterImpound(filterValue) {
        const rows = document.querySelectorAll('#impound-table-body tr');
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(filterValue) ? '' : 'none';
        });
    },
    
    filterJobs(filterValue) {
        const rows = document.querySelectorAll('#jobs-table-body tr');
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(filterValue) ? '' : 'none';
        });
    },
    
    // Save settings
    saveSettings() {
        const form = document.getElementById('settings-form');
        const formData = new FormData(form);
        const settings = {};
        
        for (let [key, value] of formData.entries()) {
            settings[key] = value;
        }
        
        this.state.settings = settings;
        this.sendNUIMessage('saveSettings', settings);
        this.showNotification('Settings saved successfully', 'success');
    },
    
    // Start periodic updates
    startUpdates() {
        // Update time every second
        setInterval(() => {
            this.updateTime();
        }, 1000);
        
        // Update data every 30 seconds
        setInterval(() => {
            this.loadData();
            if (this.state.currentTab === 'dispatch') {
                this.updateDispatchView();
            }
        }, 30000);
    }
};

// Initialize the system when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    TowingSystem.init();
});

// Close NUI when ESC is pressed
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        TowingSystem.sendNUIMessage('closeNUI', {});
    }
});

// Expose system for debugging
window.TowingSystem = TowingSystem;