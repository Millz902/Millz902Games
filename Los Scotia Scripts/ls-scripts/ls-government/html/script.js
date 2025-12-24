/**
 * Los Scotia Government Management System - JavaScript
 * Created by Millz902Games
 * © 2025 All Rights Reserved
 * Comprehensive city government administration interface
 */

// Global variables and state
let currentSection = 'dashboard';
let governmentData = {
    cityStats: {
        population: 45328,
        budget: 12400000,
        pendingPermits: 23,
        activeIssues: 7
    },
    departments: {},
    permits: [],
    elections: [],
    budget: {},
    projects: []
};
let currentUser = {
    name: 'System Administrator',
    role: 'admin',
    permissions: ['all']
};

// Initialize the government system
$(document).ready(function() {
    console.log('Los Scotia Government System Initialized');
    initializeGovernmentSystem();
    updateCurrentDateTime();
    setInterval(updateCurrentDateTime, 1000);
    loadDashboardData();
});

// Initialize government system
function initializeGovernmentSystem() {
    // Listen for messages from Lua
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.type) {
            case 'showGovernment':
                showGovernmentInterface();
                break;
            case 'hideGovernment':
                hideGovernmentInterface();
                break;
            case 'updateGovernmentData':
                updateGovernmentData(data.data);
                break;
            case 'userLogin':
                handleUserLogin(data.user);
                break;
            case 'notification':
                showNotification(data.title, data.message, data.type);
                break;
        }
    });
    
    // Set up event listeners
    setupEventListeners();
}

// Setup event listeners
function setupEventListeners() {
    // Keyboard shortcuts
    $(document).keydown(function(e) {
        if (e.ctrlKey) {
            switch(e.key) {
                case 'h':
                    e.preventDefault();
                    showSection('dashboard');
                    break;
                case 'r':
                    e.preventDefault();
                    refreshCurrentSection();
                    break;
                case 's':
                    e.preventDefault();
                    saveCurrentData();
                    break;
            }
        }
        
        if (e.key === 'Escape') {
            closeModal();
        }
    });
    
    // Click outside modal to close
    $(document).on('click', '.modal-overlay', function(e) {
        if (e.target === this) {
            closeModal();
        }
    });
    
    // Auto-save functionality
    setInterval(autoSave, 300000); // Auto-save every 5 minutes
}

// Date and time updates
function updateCurrentDateTime() {
    const now = new Date();
    const dateString = now.toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
    const timeString = now.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
    
    $('#current-date').text(dateString);
    $('#current-time').text(timeString);
}

// Navigation functions
function showSection(sectionName) {
    // Update navigation
    $('.nav-btn').removeClass('active');
    $(`.nav-btn[data-section="${sectionName}"]`).addClass('active');
    
    // Update content
    $('.content-section').removeClass('active');
    $(`#${sectionName}-section`).addClass('active');
    
    currentSection = sectionName;
    
    // Load section-specific data
    loadSectionData(sectionName);
    
    // Send section change to Lua
    $.post('http://ls-government/sectionChanged', JSON.stringify({
        section: sectionName
    }));
}

function loadSectionData(section) {
    switch(section) {
        case 'dashboard':
            loadDashboardData();
            break;
        case 'mayor':
            loadMayorData();
            break;
        case 'council':
            loadCouncilData();
            break;
        case 'departments':
            loadDepartmentsData();
            break;
        case 'services':
            loadServicesData();
            break;
        case 'permits':
            loadPermitsData();
            break;
        case 'budget':
            loadBudgetData();
            break;
        case 'elections':
            loadElectionsData();
            break;
        case 'planning':
            loadPlanningData();
            break;
    }
}

// Dashboard functions
function loadDashboardData() {
    updateCityStats();
    updateRecentActivity();
    updateUpcomingEvents();
}

function updateCityStats() {
    $('#city-population').text(governmentData.cityStats.population.toLocaleString());
    $('#city-budget').text(`$${(governmentData.cityStats.budget / 1000000).toFixed(1)}M`);
    $('#pending-permits').text(governmentData.cityStats.pendingPermits);
    $('#active-issues').text(governmentData.cityStats.activeIssues);
}

function updateRecentActivity() {
    // Update recent activity list with latest data
    const activities = [
        {
            icon: 'fas fa-file-plus',
            title: 'New Business License Application',
            desc: 'Los Scotia Auto Repair submitted application',
            time: '2 hours ago'
        },
        {
            icon: 'fas fa-gavel',
            title: 'City Council Meeting Scheduled',
            desc: 'Weekly meeting scheduled for Thursday 7 PM',
            time: '4 hours ago'
        },
        {
            icon: 'fas fa-money-bill',
            title: 'Budget Amendment Approved',
            desc: 'Public Works budget increased by $250K',
            time: '1 day ago'
        }
    ];
    
    updateActivityList('#recent-activity', activities);
}

function updateUpcomingEvents() {
    // Update upcoming events with latest data
    const events = [
        {
            day: '24',
            month: 'SEP',
            title: 'City Council Meeting',
            time: '7:00 PM - City Hall'
        },
        {
            day: '28',
            month: 'SEP',
            title: 'Public Hearing - Zoning Changes',
            time: '6:00 PM - Community Center'
        }
    ];
    
    updateEventsList('#upcoming-events', events);
}

function updateActivityList(containerId, activities) {
    const container = $(containerId);
    container.empty();
    
    activities.forEach(activity => {
        const activityHtml = `
            <div class="activity-item">
                <div class="activity-icon"><i class="${activity.icon}"></i></div>
                <div class="activity-content">
                    <div class="activity-title">${activity.title}</div>
                    <div class="activity-desc">${activity.desc}</div>
                    <div class="activity-time">${activity.time}</div>
                </div>
            </div>
        `;
        container.append(activityHtml);
    });
}

function updateEventsList(containerId, events) {
    const container = $(containerId);
    container.empty();
    
    events.forEach(event => {
        const eventHtml = `
            <div class="event-item">
                <div class="event-date">
                    <div class="event-day">${event.day}</div>
                    <div class="event-month">${event.month}</div>
                </div>
                <div class="event-content">
                    <div class="event-title">${event.title}</div>
                    <div class="event-time">${event.time}</div>
                </div>
            </div>
        `;
        container.append(eventHtml);
    });
}

function refreshDashboard() {
    showLoading('Refreshing dashboard data...');
    
    // Simulate API call
    setTimeout(() => {
        loadDashboardData();
        hideLoading();
        showNotification('Success', 'Dashboard data refreshed successfully', 'success');
    }, 1000);
}

// Mayor's Office functions
function loadMayorData() {
    updateMayorSchedule();
    updateMayorInitiatives();
}

function updateMayorSchedule() {
    const schedule = [
        { time: '9:00 AM', event: 'Budget Meeting with City Manager' },
        { time: '11:30 AM', event: 'Press Conference - New Park Opening' },
        { time: '2:00 PM', event: 'Meeting with Business Leaders' },
        { time: '4:30 PM', event: 'Community Forum Planning' }
    ];
    
    const container = $('#mayor-schedule');
    container.empty();
    
    schedule.forEach(item => {
        const scheduleHtml = `
            <div class="schedule-item">
                <div class="schedule-time">${item.time}</div>
                <div class="schedule-event">${item.event}</div>
            </div>
        `;
        container.append(scheduleHtml);
    });
}

function updateMayorInitiatives() {
    // Update initiative progress bars
    $('.initiative-progress .progress-fill').each(function() {
        const width = $(this).css('width');
        $(this).css('width', '0%');
        setTimeout(() => {
            $(this).css('width', width);
        }, 500);
    });
}

function scheduleAppointment() {
    const modalContent = `
        <h4>Schedule Mayor Appointment</h4>
        <form id="appointment-form">
            <div class="form-group">
                <label for="appointment-name">Full Name:</label>
                <input type="text" id="appointment-name" required>
            </div>
            <div class="form-group">
                <label for="appointment-organization">Organization:</label>
                <input type="text" id="appointment-organization">
            </div>
            <div class="form-group">
                <label for="appointment-purpose">Purpose:</label>
                <textarea id="appointment-purpose" required></textarea>
            </div>
            <div class="form-group">
                <label for="appointment-date">Preferred Date:</label>
                <input type="date" id="appointment-date" required>
            </div>
            <div class="form-group">
                <label for="appointment-time">Preferred Time:</label>
                <input type="time" id="appointment-time" required>
            </div>
        </form>
    `;
    
    showModal('Schedule Mayor Appointment', modalContent, 'Submit Request', function() {
        const formData = getFormData('#appointment-form');
        submitAppointmentRequest(formData);
    });
}

// City Council functions
function loadCouncilData() {
    updateCouncilMembers();
    updateCouncilMeetings();
    updateRecentVotes();
}

function updateCouncilMembers() {
    // Council members data is static in HTML, could be dynamic
}

function updateCouncilMeetings() {
    // Meeting data is static in HTML, could be dynamic
}

function updateRecentVotes() {
    // Voting history is static in HTML, could be dynamic
}

function scheduleMeeting() {
    const modalContent = `
        <h4>Schedule Council Meeting</h4>
        <form id="meeting-form">
            <div class="form-group">
                <label for="meeting-title">Meeting Title:</label>
                <input type="text" id="meeting-title" required>
            </div>
            <div class="form-group">
                <label for="meeting-type">Meeting Type:</label>
                <select id="meeting-type" required>
                    <option value="">Select Type</option>
                    <option value="regular">Regular Meeting</option>
                    <option value="special">Special Meeting</option>
                    <option value="emergency">Emergency Meeting</option>
                    <option value="work-session">Work Session</option>
                </select>
            </div>
            <div class="form-group">
                <label for="meeting-date">Date:</label>
                <input type="date" id="meeting-date" required>
            </div>
            <div class="form-group">
                <label for="meeting-time">Time:</label>
                <input type="time" id="meeting-time" required>
            </div>
            <div class="form-group">
                <label for="meeting-location">Location:</label>
                <input type="text" id="meeting-location" value="City Hall Council Chambers" required>
            </div>
            <div class="form-group">
                <label for="meeting-agenda">Agenda Items:</label>
                <textarea id="meeting-agenda" rows="4" required></textarea>
            </div>
        </form>
    `;
    
    showModal('Schedule Council Meeting', modalContent, 'Schedule Meeting', function() {
        const formData = getFormData('#meeting-form');
        scheduleCouncilMeeting(formData);
    });
}

function viewMinutes() {
    const modalContent = `
        <h4>Meeting Minutes Archive</h4>
        <div class="minutes-list">
            <div class="minute-item">
                <div class="minute-date">September 17, 2025</div>
                <div class="minute-title">Regular City Council Meeting</div>
                <button class="btn small" onclick="viewMinuteDetails('2025-09-17')">View</button>
            </div>
            <div class="minute-item">
                <div class="minute-date">September 10, 2025</div>
                <div class="minute-title">Special Budget Session</div>
                <button class="btn small" onclick="viewMinuteDetails('2025-09-10')">View</button>
            </div>
            <div class="minute-item">
                <div class="minute-date">September 3, 2025</div>
                <div class="minute-title">Regular City Council Meeting</div>
                <button class="btn small" onclick="viewMinuteDetails('2025-09-03')">View</button>
            </div>
        </div>
    `;
    
    showModal('Meeting Minutes', modalContent, 'Close', function() {
        closeModal();
    });
}

// Departments functions
function loadDepartmentsData() {
    updateDepartmentStats();
}

function updateDepartmentStats() {
    // Department statistics are static in HTML, could be dynamic
    animateDepartmentCards();
}

function animateDepartmentCards() {
    $('.department-card').each(function(index) {
        $(this).css('animation-delay', `${index * 0.1}s`);
        $(this).addClass('fade-in');
    });
}

function viewDepartment(departmentId) {
    const departmentData = {
        'police': {
            name: 'Police Department',
            chief: 'Chief Robert Martinez',
            officers: 45,
            vehicles: 23,
            budget: '$4,350,000',
            description: 'Provides law enforcement and public safety services to the citizens of Los Scotia.'
        },
        'fire': {
            name: 'Fire Department',
            chief: 'Fire Chief Lisa Thompson',
            personnel: 38,
            stations: 3,
            budget: '$2,980,000',
            description: 'Provides fire suppression, emergency medical services, and rescue operations.'
        },
        'medical': {
            name: 'EMS Department',
            director: 'Dr. Michael Chen',
            paramedics: 24,
            ambulances: 8,
            budget: '$1,800,000',
            description: 'Provides emergency medical services and ambulance transport.'
        },
        'public-works': {
            name: 'Public Works Department',
            director: 'Maria Rodriguez',
            workers: 32,
            projects: 5,
            budget: '$2,450,000',
            description: 'Maintains city infrastructure including roads, water, and sewer systems.'
        },
        'parks': {
            name: 'Parks & Recreation',
            director: 'James Wilson',
            facilities: 12,
            programs: 8,
            budget: '$1,200,000',
            description: 'Manages city parks, recreational facilities, and community programs.'
        },
        'planning': {
            name: 'Planning & Zoning',
            director: 'Sarah Johnson',
            applications: 15,
            projects: 8,
            budget: '$800,000',
            description: 'Oversees city planning, zoning, and development projects.'
        }
    };
    
    const dept = departmentData[departmentId];
    if (!dept) return;
    
    const modalContent = `
        <h4>${dept.name}</h4>
        <div class="department-details">
            <p><strong>Director/Chief:</strong> ${dept.chief || dept.director}</p>
            <p><strong>Budget:</strong> ${dept.budget}</p>
            <p>${dept.description}</p>
            
            <div class="department-stats-grid">
                ${Object.keys(dept).filter(key => !['name', 'chief', 'director', 'budget', 'description'].includes(key))
                    .map(key => `<div class="stat-item"><span class="stat-label">${key.charAt(0).toUpperCase() + key.slice(1)}:</span><span class="stat-value">${dept[key]}</span></div>`).join('')}
            </div>
            
            <div class="department-actions">
                <button class="btn primary" onclick="manageDepartment('${departmentId}')">Manage Department</button>
                <button class="btn secondary" onclick="viewDepartmentReports('${departmentId}')">View Reports</button>
            </div>
        </div>
    `;
    
    showModal(dept.name, modalContent, 'Close', function() {
        closeModal();
    });
}

function addDepartment() {
    const modalContent = `
        <h4>Add New Department</h4>
        <form id="department-form">
            <div class="form-group">
                <label for="dept-name">Department Name:</label>
                <input type="text" id="dept-name" required>
            </div>
            <div class="form-group">
                <label for="dept-director">Director/Chief:</label>
                <input type="text" id="dept-director" required>
            </div>
            <div class="form-group">
                <label for="dept-budget">Annual Budget:</label>
                <input type="number" id="dept-budget" required>
            </div>
            <div class="form-group">
                <label for="dept-description">Description:</label>
                <textarea id="dept-description" required></textarea>
            </div>
            <div class="form-group">
                <label for="dept-icon">Icon Class:</label>
                <input type="text" id="dept-icon" placeholder="fas fa-building" required>
            </div>
        </form>
    `;
    
    showModal('Add New Department', modalContent, 'Add Department', function() {
        const formData = getFormData('#department-form');
        createNewDepartment(formData);
    });
}

// Services functions
function loadServicesData() {
    updateServiceCategories();
}

function updateServiceCategories() {
    // Service categories are static in HTML, could be dynamic
}

function manageService(serviceId) {
    const modalContent = `
        <h4>Manage Service: ${serviceId.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</h4>
        <div class="service-management">
            <div class="service-stats">
                <div class="stat-card">
                    <div class="stat-label">Active Cases</div>
                    <div class="stat-value">23</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Monthly Budget</div>
                    <div class="stat-value">$45,000</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Staff Assigned</div>
                    <div class="stat-value">8</div>
                </div>
            </div>
            <div class="service-actions">
                <button class="btn primary" onclick="editService('${serviceId}')">Edit Service</button>
                <button class="btn secondary" onclick="viewServiceReports('${serviceId}')">View Reports</button>
                <button class="btn secondary" onclick="assignStaff('${serviceId}')">Assign Staff</button>
            </div>
        </div>
    `;
    
    showModal('Service Management', modalContent, 'Close', function() {
        closeModal();
    });
}

function addService() {
    const modalContent = `
        <h4>Add New Service</h4>
        <form id="service-form">
            <div class="form-group">
                <label for="service-name">Service Name:</label>
                <input type="text" id="service-name" required>
            </div>
            <div class="form-group">
                <label for="service-category">Category:</label>
                <select id="service-category" required>
                    <option value="">Select Category</option>
                    <option value="housing">Housing Services</option>
                    <option value="transportation">Transportation</option>
                    <option value="environmental">Environmental</option>
                    <option value="community">Community</option>
                </select>
            </div>
            <div class="form-group">
                <label for="service-description">Description:</label>
                <textarea id="service-description" required></textarea>
            </div>
            <div class="form-group">
                <label for="service-budget">Monthly Budget:</label>
                <input type="number" id="service-budget" required>
            </div>
        </form>
    `;
    
    showModal('Add New Service', modalContent, 'Add Service', function() {
        const formData = getFormData('#service-form');
        createNewService(formData);
    });
}

// Permits functions
function loadPermitsData() {
    updatePermitsTable();
}

function updatePermitsTable() {
    // Permits table is populated with static data, could be dynamic
}

function showPermitTab(tabName) {
    $('.tab-btn').removeClass('active');
    $(`.tab-btn:contains('${tabName.charAt(0).toUpperCase() + tabName.slice(1)}')`).addClass('active');
    
    // Filter permits table based on tab
    filterPermitsByStatus(tabName);
}

function filterPermitsByStatus(status) {
    // Implementation for filtering permits table
    $('#permits-tbody tr').each(function() {
        const rowStatus = $(this).find('.status-badge').text().toLowerCase();
        if (status === 'pending' && rowStatus.includes('pending')) {
            $(this).show();
        } else if (status === 'approved' && rowStatus.includes('approved')) {
            $(this).show();
        } else if (status === 'denied' && rowStatus.includes('denied')) {
            $(this).show();
        } else if (status === 'expired' && rowStatus.includes('expired')) {
            $(this).show();
        } else if (status === 'pending') {
            $(this).hide();
        }
    });
}

function newPermitApplication() {
    const modalContent = `
        <h4>New Permit Application</h4>
        <form id="permit-form">
            <div class="form-group">
                <label for="permit-type">Permit Type:</label>
                <select id="permit-type" required>
                    <option value="">Select Type</option>
                    <option value="building">Building Permit</option>
                    <option value="business">Business License</option>
                    <option value="event">Event Permit</option>
                    <option value="sign">Sign Permit</option>
                </select>
            </div>
            <div class="form-group">
                <label for="applicant-name">Applicant Name:</label>
                <input type="text" id="applicant-name" required>
            </div>
            <div class="form-group">
                <label for="property-address">Property Address:</label>
                <input type="text" id="property-address" required>
            </div>
            <div class="form-group">
                <label for="permit-description">Project Description:</label>
                <textarea id="permit-description" required></textarea>
            </div>
            <div class="form-group">
                <label for="estimated-cost">Estimated Cost:</label>
                <input type="number" id="estimated-cost" required>
            </div>
        </form>
    `;
    
    showModal('New Permit Application', modalContent, 'Submit Application', function() {
        const formData = getFormData('#permit-form');
        submitPermitApplication(formData);
    });
}

function reviewPermit(permitId) {
    const modalContent = `
        <h4>Review Permit: ${permitId}</h4>
        <div class="permit-review">
            <div class="permit-details">
                <p><strong>Application #:</strong> ${permitId}</p>
                <p><strong>Type:</strong> Building Permit</p>
                <p><strong>Applicant:</strong> John Smith</p>
                <p><strong>Property:</strong> 123 Main St</p>
                <p><strong>Description:</strong> Residential addition - 500 sq ft</p>
                <p><strong>Estimated Cost:</strong> $25,000</p>
            </div>
            <div class="review-actions">
                <label for="review-notes">Review Notes:</label>
                <textarea id="review-notes" placeholder="Enter review comments..."></textarea>
                
                <div class="decision-buttons">
                    <button class="btn success" onclick="approvePermit('${permitId}')">Approve</button>
                    <button class="btn warning" onclick="requestMoreInfo('${permitId}')">Request More Info</button>
                    <button class="btn danger" onclick="denyPermit('${permitId}')">Deny</button>
                </div>
            </div>
        </div>
    `;
    
    showModal('Permit Review', modalContent, 'Close', function() {
        closeModal();
    });
}

function searchPermits() {
    const modalContent = `
        <h4>Search Permits</h4>
        <form id="search-form">
            <div class="form-group">
                <label for="search-permit-id">Permit ID:</label>
                <input type="text" id="search-permit-id" placeholder="PER-2025-001">
            </div>
            <div class="form-group">
                <label for="search-applicant">Applicant Name:</label>
                <input type="text" id="search-applicant">
            </div>
            <div class="form-group">
                <label for="search-address">Property Address:</label>
                <input type="text" id="search-address">
            </div>
            <div class="form-group">
                <label for="search-type">Permit Type:</label>
                <select id="search-type">
                    <option value="">All Types</option>
                    <option value="building">Building Permit</option>
                    <option value="business">Business License</option>
                    <option value="event">Event Permit</option>
                    <option value="sign">Sign Permit</option>
                </select>
            </div>
            <div class="form-group">
                <label for="search-status">Status:</label>
                <select id="search-status">
                    <option value="">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="denied">Denied</option>
                    <option value="expired">Expired</option>
                </select>
            </div>
        </form>
    `;
    
    showModal('Search Permits', modalContent, 'Search', function() {
        const searchData = getFormData('#search-form');
        performPermitSearch(searchData);
    });
}

// Budget functions
function loadBudgetData() {
    updateBudgetOverview();
    updateDepartmentBudgets();
    animateBudgetCharts();
}

function updateBudgetOverview() {
    // Budget overview is static in HTML, could be dynamic
}

function updateDepartmentBudgets() {
    // Department budget table is static in HTML, could be dynamic
}

function animateBudgetCharts() {
    $('.chart-bar').each(function() {
        const height = $(this).css('height');
        $(this).css('height', '0%');
        setTimeout(() => {
            $(this).css('height', height);
        }, 500);
    });
}

function generateBudgetReport() {
    showLoading('Generating budget report...');
    
    setTimeout(() => {
        hideLoading();
        showNotification('Success', 'Budget report generated successfully', 'success');
        
        // Simulate opening a PDF report
        const modalContent = `
            <h4>Budget Report Generated</h4>
            <div class="report-info">
                <p>Your budget report has been generated successfully.</p>
                <p><strong>Report Name:</strong> FY2025_Budget_Report_${new Date().toISOString().slice(0, 10)}.pdf</p>
                <p><strong>File Size:</strong> 2.4 MB</p>
                <p><strong>Generated:</strong> ${new Date().toLocaleString()}</p>
                
                <div class="report-actions">
                    <button class="btn primary" onclick="downloadReport()">Download PDF</button>
                    <button class="btn secondary" onclick="emailReport()">Email Report</button>
                    <button class="btn secondary" onclick="printReport()">Print Report</button>
                </div>
            </div>
        `;
        
        showModal('Budget Report', modalContent, 'Close', function() {
            closeModal();
        });
    }, 2000);
}

function budgetProposal() {
    const modalContent = `
        <h4>New Budget Proposal</h4>
        <form id="budget-proposal-form">
            <div class="form-group">
                <label for="proposal-title">Proposal Title:</label>
                <input type="text" id="proposal-title" required>
            </div>
            <div class="form-group">
                <label for="proposal-department">Department:</label>
                <select id="proposal-department" required>
                    <option value="">Select Department</option>
                    <option value="police">Police Department</option>
                    <option value="fire">Fire Department</option>
                    <option value="public-works">Public Works</option>
                    <option value="parks">Parks & Recreation</option>
                </select>
            </div>
            <div class="form-group">
                <label for="proposal-amount">Proposed Amount:</label>
                <input type="number" id="proposal-amount" required>
            </div>
            <div class="form-group">
                <label for="proposal-justification">Justification:</label>
                <textarea id="proposal-justification" required></textarea>
            </div>
            <div class="form-group">
                <label for="proposal-timeline">Implementation Timeline:</label>
                <input type="text" id="proposal-timeline" required>
            </div>
        </form>
    `;
    
    showModal('New Budget Proposal', modalContent, 'Submit Proposal', function() {
        const formData = getFormData('#budget-proposal-form');
        submitBudgetProposal(formData);
    });
}

// Elections functions
function loadElectionsData() {
    updateElectionInfo();
    updateVoterRegistration();
}

function updateElectionInfo() {
    // Election information is static in HTML, could be dynamic
}

function updateVoterRegistration() {
    // Voter registration stats are static in HTML, could be dynamic
}

function createElection() {
    const modalContent = `
        <h4>Create New Election</h4>
        <form id="election-form">
            <div class="form-group">
                <label for="election-title">Election Title:</label>
                <input type="text" id="election-title" required>
            </div>
            <div class="form-group">
                <label for="election-type">Election Type:</label>
                <select id="election-type" required>
                    <option value="">Select Type</option>
                    <option value="mayor">Mayoral Election</option>
                    <option value="council">City Council Election</option>
                    <option value="referendum">Referendum</option>
                    <option value="special">Special Election</option>
                </select>
            </div>
            <div class="form-group">
                <label for="election-date">Election Date:</label>
                <input type="date" id="election-date" required>
            </div>
            <div class="form-group">
                <label for="registration-deadline">Registration Deadline:</label>
                <input type="date" id="registration-deadline" required>
            </div>
            <div class="form-group">
                <label for="early-voting-start">Early Voting Start:</label>
                <input type="date" id="early-voting-start">
            </div>
            <div class="form-group">
                <label for="early-voting-end">Early Voting End:</label>
                <input type="date" id="early-voting-end">
            </div>
        </form>
    `;
    
    showModal('Create New Election', modalContent, 'Create Election', function() {
        const formData = getFormData('#election-form');
        createNewElection(formData);
    });
}

function manageElection(electionId) {
    const modalContent = `
        <h4>Manage Election: ${electionId}</h4>
        <div class="election-management">
            <div class="election-tabs">
                <button class="tab-btn active" onclick="showElectionTab('candidates')">Candidates</button>
                <button class="tab-btn" onclick="showElectionTab('voters')">Voters</button>
                <button class="tab-btn" onclick="showElectionTab('results')">Results</button>
                <button class="tab-btn" onclick="showElectionTab('settings')">Settings</button>
            </div>
            <div class="election-content">
                <div id="candidates-tab" class="election-tab-content active">
                    <h5>Registered Candidates</h5>
                    <div class="candidates-list">
                        <div class="candidate-item">
                            <span>Maria Gonzalez - District 2</span>
                            <button class="btn small">Edit</button>
                        </div>
                        <div class="candidate-item">
                            <span>Robert Chen - District 4</span>
                            <button class="btn small">Edit</button>
                        </div>
                    </div>
                    <button class="btn primary" onclick="addCandidate('${electionId}')">Add Candidate</button>
                </div>
            </div>
        </div>
    `;
    
    showModal('Election Management', modalContent, 'Close', function() {
        closeModal();
    });
}

// Planning functions
function loadPlanningData() {
    updatePlanningProjects();
    updateZoningInfo();
}

function updatePlanningProjects() {
    // Planning projects are static in HTML, could be dynamic
    animateProgressBars();
}

function updateZoningInfo() {
    // Zoning information is static in HTML, could be dynamic
}

function animateProgressBars() {
    $('.progress-fill').each(function() {
        const width = $(this).css('width');
        $(this).css('width', '0%');
        setTimeout(() => {
            $(this).css('width', width);
        }, 500);
    });
}

function newPlanningProject() {
    const modalContent = `
        <h4>New Planning Project</h4>
        <form id="planning-form">
            <div class="form-group">
                <label for="project-name">Project Name:</label>
                <input type="text" id="project-name" required>
            </div>
            <div class="form-group">
                <label for="project-type">Project Type:</label>
                <select id="project-type" required>
                    <option value="">Select Type</option>
                    <option value="development">Development</option>
                    <option value="infrastructure">Infrastructure</option>
                    <option value="park">Park/Recreation</option>
                    <option value="zoning">Zoning Change</option>
                </select>
            </div>
            <div class="form-group">
                <label for="project-location">Location:</label>
                <input type="text" id="project-location" required>
            </div>
            <div class="form-group">
                <label for="project-budget">Estimated Budget:</label>
                <input type="number" id="project-budget" required>
            </div>
            <div class="form-group">
                <label for="project-description">Description:</label>
                <textarea id="project-description" required></textarea>
            </div>
            <div class="form-group">
                <label for="project-timeline">Expected Timeline:</label>
                <input type="text" id="project-timeline" required>
            </div>
        </form>
    `;
    
    showModal('New Planning Project', modalContent, 'Create Project', function() {
        const formData = getFormData('#planning-form');
        createPlanningProject(formData);
    });
}

function viewZoningMap() {
    const modalContent = `
        <h4>Los Scotia Zoning Map</h4>
        <div class="zoning-map-container">
            <div class="map-placeholder" style="height: 400px; background: #f0f0f0; border: 1px solid #ccc; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                <div style="text-align: center; color: #666;">
                    <i class="fas fa-map" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                    <p>Interactive Zoning Map</p>
                    <p style="font-size: 0.9rem;">Click zones for detailed information</p>
                </div>
            </div>
            <div class="map-legend" style="margin-top: 1rem;">
                <h5>Zone Legend</h5>
                <div class="legend-items" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.5rem;">
                    <div class="legend-item" style="display: flex; align-items: center; gap: 0.5rem;">
                        <div style="width: 20px; height: 20px; background: #10b981; border-radius: 50%;"></div>
                        <span>Residential (R1, R2, R3)</span>
                    </div>
                    <div class="legend-item" style="display: flex; align-items: center; gap: 0.5rem;">
                        <div style="width: 20px; height: 20px; background: #3b82f6; border-radius: 50%;"></div>
                        <span>Commercial (C1, C2)</span>
                    </div>
                    <div class="legend-item" style="display: flex; align-items: center; gap: 0.5rem;">
                        <div style="width: 20px; height: 20px; background: #6b7280; border-radius: 50%;"></div>
                        <span>Industrial (I1, I2)</span>
                    </div>
                    <div class="legend-item" style="display: flex; align-items: center; gap: 0.5rem;">
                        <div style="width: 20px; height: 20px; background: #f59e0b; border-radius: 50%;"></div>
                        <span>Mixed Use (MU)</span>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    showModal('Zoning Map', modalContent, 'Close', function() {
        closeModal();
    });
}

// Utility functions
function showModal(title, content, confirmText, confirmCallback) {
    $('#modal-title').text(title);
    $('#modal-body').html(content);
    $('#modal-confirm').text(confirmText);
    
    // Remove any existing click handlers and add new one
    $('#modal-confirm').off('click').on('click', confirmCallback);
    
    $('#modal-overlay').removeClass('hidden');
}

function closeModal() {
    $('#modal-overlay').addClass('hidden');
    $('#modal-body').empty();
}

function confirmModal() {
    // This will be overridden by the specific confirm callback
}

function getFormData(formSelector) {
    const formData = {};
    $(formSelector + ' input, ' + formSelector + ' select, ' + formSelector + ' textarea').each(function() {
        const field = $(this);
        formData[field.attr('id')] = field.val();
    });
    return formData;
}

function showLoading(message) {
    const loadingHtml = `
        <div class="loading-overlay">
            <div class="loading-content">
                <div class="loading-spinner"></div>
                <p>${message || 'Loading...'}</p>
            </div>
        </div>
    `;
    $('body').append(loadingHtml);
}

function hideLoading() {
    $('.loading-overlay').remove();
}

function showNotification(title, message, type = 'info') {
    const icon = type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-triangle' : 'fa-info-circle';
    const color = type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6';
    
    const notification = $(`
        <div class="notification" style="position: fixed; top: 20px; right: 20px; background: white; padding: 1rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border-left: 4px solid ${color}; z-index: 9999; max-width: 300px;">
            <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                <i class="fas ${icon}" style="color: ${color};"></i>
                <strong>${title}</strong>
            </div>
            <p style="margin: 0; color: #666; font-size: 0.9rem;">${message}</p>
        </div>
    `);
    
    $('body').append(notification);
    
    setTimeout(() => {
        notification.fadeOut(300, function() {
            $(this).remove();
        });
    }, 5000);
}

function refreshCurrentSection() {
    loadSectionData(currentSection);
    showNotification('Refreshed', `${currentSection.charAt(0).toUpperCase() + currentSection.slice(1)} section updated`, 'success');
}

function autoSave() {
    // Auto-save current data
    console.log('Auto-saving government data...');
    
    $.post('http://ls-government/autoSave', JSON.stringify({
        data: governmentData,
        timestamp: new Date().toISOString()
    }));
}

function saveCurrentData() {
    showLoading('Saving data...');
    
    setTimeout(() => {
        hideLoading();
        showNotification('Saved', 'All data saved successfully', 'success');
    }, 1000);
}

// Data update functions
function updateGovernmentData(newData) {
    governmentData = { ...governmentData, ...newData };
    refreshCurrentSection();
}

function handleUserLogin(user) {
    currentUser = user;
    $('#current-user').text(user.name);
    showNotification('Welcome', `Welcome back, ${user.name}`, 'success');
}

// Interface control functions
function showGovernmentInterface() {
    $('#government-app').removeClass('hidden');
}

function hideGovernmentInterface() {
    $('#government-app').addClass('hidden');
}

function logout() {
    if (confirm('Are you sure you want to logout?')) {
        $.post('http://ls-government/logout', JSON.stringify({}));
        hideGovernmentInterface();
    }
}

// Help and support functions
function showHelp() {
    const modalContent = `
        <h4>Government System Help</h4>
        <div class="help-content">
            <h5>Keyboard Shortcuts</h5>
            <ul>
                <li><strong>Ctrl + H:</strong> Go to Dashboard</li>
                <li><strong>Ctrl + R:</strong> Refresh current section</li>
                <li><strong>Ctrl + S:</strong> Save data</li>
                <li><strong>Esc:</strong> Close modal</li>
            </ul>
            
            <h5>Navigation</h5>
            <p>Use the navigation bar at the top to switch between different government sections. Each section contains relevant tools and information for city administration.</p>
            
            <h5>Data Management</h5>
            <p>The system automatically saves data every 5 minutes. You can also manually save using Ctrl+S or the save button in each section.</p>
        </div>
    `;
    
    showModal('Help', modalContent, 'Close', function() {
        closeModal();
    });
}

function showAbout() {
    const modalContent = `
        <h4>About Los Scotia Government System</h4>
        <div class="about-content">
            <p><strong>Version:</strong> 2.1.0</p>
            <p><strong>Build Date:</strong> September 21, 2025</p>
            <p><strong>Developer:</strong> Los Scotia IT Department</p>
            
            <h5>Features</h5>
            <ul>
                <li>Comprehensive city administration</li>
                <li>Department management</li>
                <li>Permit and license processing</li>
                <li>Budget tracking and reporting</li>
                <li>Election management</li>
                <li>City planning tools</li>
            </ul>
            
            <h5>Support</h5>
            <p>For technical support, contact the IT Department at ext. 1234 or email support@losscotia.gov</p>
        </div>
    `;
    
    showModal('About', modalContent, 'Close', function() {
        closeModal();
    });
}

function contactSupport() {
    const modalContent = `
        <h4>Contact Technical Support</h4>
        <form id="support-form">
            <div class="form-group">
                <label for="support-category">Issue Category:</label>
                <select id="support-category" required>
                    <option value="">Select Category</option>
                    <option value="login">Login Issues</option>
                    <option value="data">Data Problems</option>
                    <option value="performance">Performance Issues</option>
                    <option value="bug">Bug Report</option>
                    <option value="feature">Feature Request</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <label for="support-subject">Subject:</label>
                <input type="text" id="support-subject" required>
            </div>
            <div class="form-group">
                <label for="support-description">Description:</label>
                <textarea id="support-description" rows="4" required placeholder="Please describe the issue in detail..."></textarea>
            </div>
            <div class="form-group">
                <label for="support-priority">Priority:</label>
                <select id="support-priority" required>
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="urgent">Urgent</option>
                </select>
            </div>
        </form>
    `;
    
    showModal('Contact Support', modalContent, 'Submit Ticket', function() {
        const formData = getFormData('#support-form');
        submitSupportTicket(formData);
    });
}

// Submit functions (these would integrate with backend systems)
function submitAppointmentRequest(data) {
    showLoading('Submitting appointment request...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Appointment request submitted successfully', 'success');
    }, 1500);
}

function scheduleCouncilMeeting(data) {
    showLoading('Scheduling meeting...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Council meeting scheduled successfully', 'success');
    }, 1500);
}

function createNewDepartment(data) {
    showLoading('Creating department...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'New department created successfully', 'success');
    }, 1500);
}

function createNewService(data) {
    showLoading('Creating service...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'New service created successfully', 'success');
    }, 1500);
}

function submitPermitApplication(data) {
    showLoading('Submitting permit application...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Permit application submitted successfully', 'success');
    }, 1500);
}

function submitBudgetProposal(data) {
    showLoading('Submitting budget proposal...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Budget proposal submitted successfully', 'success');
    }, 1500);
}

function createNewElection(data) {
    showLoading('Creating election...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Election created successfully', 'success');
    }, 1500);
}

function createPlanningProject(data) {
    showLoading('Creating planning project...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Planning project created successfully', 'success');
    }, 1500);
}

function submitSupportTicket(data) {
    showLoading('Submitting support ticket...');
    setTimeout(() => {
        hideLoading();
        closeModal();
        showNotification('Success', 'Support ticket submitted successfully. Ticket #GOV-2025-0123', 'success');
    }, 1500);
}

// Export functions for global access
window.showSection = showSection;
window.refreshDashboard = refreshDashboard;
window.scheduleAppointment = scheduleAppointment;
window.scheduleMeeting = scheduleMeeting;
window.viewMinutes = viewMinutes;
window.viewDepartment = viewDepartment;
window.addDepartment = addDepartment;
window.manageService = manageService;
window.addService = addService;
window.newPermitApplication = newPermitApplication;
window.reviewPermit = reviewPermit;
window.searchPermits = searchPermits;
window.showPermitTab = showPermitTab;
window.generateBudgetReport = generateBudgetReport;
window.budgetProposal = budgetProposal;
window.createElection = createElection;
window.manageElection = manageElection;
window.newPlanningProject = newPlanningProject;
window.viewZoningMap = viewZoningMap;
window.closeModal = closeModal;
window.confirmModal = confirmModal;
window.logout = logout;
window.showHelp = showHelp;
window.showAbout = showAbout;
window.contactSupport = contactSupport;