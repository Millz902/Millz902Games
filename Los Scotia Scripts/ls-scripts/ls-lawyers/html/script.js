let currentTab = 'overview';
let isLawyerMode = false;

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadLawyerData();
    showTab('overview');
});

// Set up event listeners
function setupEventListeners() {
    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showTab(tabName);
        });
    });

    // Close button
    document.getElementById('closeBtn').addEventListener('click', closeLawPanel);

    // Service request buttons
    document.querySelectorAll('.request-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const service = this.getAttribute('data-service');
            requestLegalService(service);
        });
    });

    // Legal forms
    document.querySelectorAll('.form-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const form = this.getAttribute('data-form');
            downloadLegalForm(form);
        });
    });

    // Create invoice button
    document.getElementById('createInvoiceBtn')?.addEventListener('click', createInvoice);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeLawPanel();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openLawyers':
                openLawPanel(data.mode || 'client');
                break;
            case 'closeLawyers':
                closeLawPanel();
                break;
            case 'updateLawyerData':
                updateLawyerData(data.data);
                break;
            case 'updateCases':
                updateCasesList(data.cases);
                break;
            case 'updateBilling':
                updateBillingData(data.billing);
                break;
        }
    });
}

// Show specific tab
function showTab(tabName) {
    // Update active tab button
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    // Update active tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}Tab`).classList.add('active');

    currentTab = tabName;

    // Load tab-specific data
    switch(tabName) {
        case 'overview':
            loadOverviewData();
            break;
        case 'cases':
            loadCasesData();
            break;
        case 'services':
            loadServicesData();
            break;
        case 'billing':
            loadBillingData();
            break;
    }
}

// Open law panel
function openLawPanel(mode = 'client') {
    isLawyerMode = mode === 'lawyer';
    document.getElementById('container').classList.remove('hidden');
    
    // Adjust interface based on mode
    adjustInterfaceForMode();
    
    // Notify FiveM
    sendCallback('lawPanel:opened', { mode: mode });
}

// Close law panel
function closeLawPanel() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('lawPanel:closed', {});
}

// Adjust interface based on user mode
function adjustInterfaceForMode() {
    const isLawyer = isLawyerMode;
    
    // Show/hide lawyer-specific elements
    document.querySelectorAll('.lawyer-only').forEach(element => {
        element.style.display = isLawyer ? 'block' : 'none';
    });
    
    // Adjust tab visibility
    const billingTab = document.querySelector('[data-tab="billing"]');
    if (billingTab) {
        billingTab.style.display = isLawyer ? 'block' : 'none';
    }
}

// Load lawyer data
function loadLawyerData() {
    sendCallback('lawPanel:requestData', { type: 'lawyer' });
}

// Load overview data
function loadOverviewData() {
    const stats = {
        activeCases: 12,
        clientMeetings: 3,
        courtHearings: 2,
        pendingPayments: 5
    };
    
    updateOverviewStats(stats);
    sendCallback('lawPanel:requestData', { type: 'overview' });
}

// Update overview statistics
function updateOverviewStats(stats) {
    document.getElementById('activeCases').textContent = stats.activeCases || 0;
    document.getElementById('clientMeetings').textContent = stats.clientMeetings || 0;
    document.getElementById('courtHearings').textContent = stats.courtHearings || 0;
    document.getElementById('pendingPayments').textContent = stats.pendingPayments || 0;
}

// Load cases data
function loadCasesData() {
    sendCallback('lawPanel:requestData', { type: 'cases' });
}

// Update cases list
function updateCasesList(cases) {
    const casesList = document.getElementById('casesList');
    if (!casesList) return;
    
    if (!cases || cases.length === 0) {
        casesList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No cases found</p>';
        return;
    }
    
    let html = '';
    cases.forEach(caseItem => {
        html += `
            <div class="case-item" style="background: rgba(255, 255, 255, 0.05); margin: 10px 0; padding: 15px; border-radius: 8px; border-left: 4px solid #8e44ad;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <div>
                        <h5 style="color: #8e44ad; margin-bottom: 8px;">${caseItem.title}</h5>
                        <p style="color: #ffffff; margin-bottom: 5px;">Client: ${caseItem.client}</p>
                        <p style="color: #a0a0a0; font-size: 14px;">Type: ${caseItem.type}</p>
                    </div>
                    <div style="text-align: right;">
                        <span class="case-status" style="background: ${getCaseStatusColor(caseItem.status)}; color: #ffffff; padding: 4px 12px; border-radius: 15px; font-size: 12px; font-weight: 600;">${caseItem.status}</span>
                        <p style="color: #a0a0a0; font-size: 12px; margin-top: 8px;">Due: ${caseItem.dueDate}</p>
                    </div>
                </div>
            </div>
        `;
    });
    
    casesList.innerHTML = html;
}

// Get case status color
function getCaseStatusColor(status) {
    switch(status?.toLowerCase()) {
        case 'active': return '#2ecc71';
        case 'pending': return '#f39c12';
        case 'closed': return '#95a5a6';
        case 'urgent': return '#e74c3c';
        default: return '#8e44ad';
    }
}

// Load services data
function loadServicesData() {
    sendCallback('lawPanel:requestData', { type: 'services' });
}

// Request legal service
function requestLegalService(service) {
    const serviceData = {
        service: service,
        timestamp: Date.now()
    };
    
    sendCallback('lawPanel:requestService', serviceData);
    
    // Show confirmation
    showNotification(`Legal service request submitted: ${service}`, 'success');
}

// Download legal form
function downloadLegalForm(form) {
    sendCallback('lawPanel:downloadForm', { form: form });
    showNotification(`Downloading form: ${form}`, 'info');
}

// Load billing data
function loadBillingData() {
    if (!isLawyerMode) return;
    
    sendCallback('lawPanel:requestData', { type: 'billing' });
}

// Update billing data
function updateBillingData(billing) {
    if (!billing) return;
    
    document.getElementById('totalRevenue').textContent = `$${billing.totalRevenue || 0}`;
    document.getElementById('pendingInvoices').textContent = billing.pendingInvoices || 0;
    document.getElementById('monthlyGoal').textContent = `$${billing.monthlyGoal || 0}`;
}

// Create invoice
function createInvoice() {
    const clientName = document.getElementById('clientName').value;
    const serviceType = document.getElementById('serviceType').value;
    const amount = document.getElementById('amount').value;
    const description = document.getElementById('description').value;
    
    if (!clientName || !serviceType || !amount) {
        showNotification('Please fill in all required fields', 'error');
        return;
    }
    
    const invoiceData = {
        clientName: clientName,
        serviceType: serviceType,
        amount: parseFloat(amount),
        description: description,
        date: new Date().toISOString(),
        id: generateInvoiceId()
    };
    
    sendCallback('lawPanel:createInvoice', invoiceData);
    
    // Clear form
    document.getElementById('clientName').value = '';
    document.getElementById('serviceType').value = '';
    document.getElementById('amount').value = '';
    document.getElementById('description').value = '';
    
    showNotification('Invoice created successfully', 'success');
}

// Generate invoice ID
function generateInvoiceId() {
    return 'INV-' + Date.now().toString().slice(-6);
}

// Update lawyer data
function updateLawyerData(data) {
    if (!data) return;
    
    // Update lawyer info
    document.getElementById('lawyerName').textContent = data.name || 'Unknown Lawyer';
    document.getElementById('specialization').textContent = data.specialization || 'General Practice';
    document.getElementById('experience').textContent = data.experience || '0 years';
    document.getElementById('barNumber').textContent = data.barNumber || 'N/A';
    document.getElementById('practiceAreas').textContent = data.practiceAreas || 'General Law';
    document.getElementById('education').textContent = data.education || 'Law School';
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#2ecc71' : type === 'error' ? '#e74c3c' : '#3498db'};
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 500;
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Send callback to FiveM
function sendCallback(event, data) {
    if (window.invokeNative) {
        fetch(`https://${GetParentResourceName()}/${event}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).catch(err => console.error('Callback error:', err));
    }
}

// Add required CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);