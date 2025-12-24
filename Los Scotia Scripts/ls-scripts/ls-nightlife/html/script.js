let currentTab = 'venues';
let isManagerMode = false;

// Initialize application
window.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadNightlifeData();
    showTab('venues');
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
    document.getElementById('closeBtn').addEventListener('click', closeNightlifePanel);

    // Venue visit buttons
    document.querySelectorAll('.visit-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const venue = this.getAttribute('data-venue');
            visitVenue(venue);
        });
    });

    // Event booking buttons
    document.querySelectorAll('.book-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const event = this.getAttribute('data-event');
            bookEvent(event);
        });
    });

    // VIP service request buttons
    document.querySelectorAll('.request-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const service = this.getAttribute('data-service');
            requestVIPService(service);
        });
    });

    // Booking cancellation buttons
    document.querySelectorAll('.cancel-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const booking = this.getAttribute('data-booking');
            cancelBooking(booking);
        });
    });

    // Filter application
    document.getElementById('applyFilters')?.addEventListener('click', applyVenueFilters);

    // Form submissions
    document.getElementById('createEventBtn')?.addEventListener('click', createEvent);
    document.getElementById('makeReservationBtn')?.addEventListener('click', makeReservation);
    document.getElementById('contactConciergeBtn')?.addEventListener('click', contactConcierge);

    // Escape key listener
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeNightlifePanel();
        }
    });

    // Message listener for FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openNightlife':
                openNightlifePanel(data.mode || 'customer');
                break;
            case 'closeNightlife':
                closeNightlifePanel();
                break;
            case 'updateVenues':
                updateVenuesList(data.venues);
                break;
            case 'updateEvents':
                updateEventsList(data.events);
                break;
            case 'updateBookings':
                updateBookingsList(data.bookings);
                break;
            case 'updateVIPServices':
                updateVIPServices(data.services);
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
        case 'venues':
            loadVenuesData();
            break;
        case 'events':
            loadEventsData();
            break;
        case 'bookings':
            loadBookingsData();
            break;
        case 'vip':
            loadVIPData();
            break;
    }
}

// Open nightlife panel
function openNightlifePanel(mode = 'customer') {
    isManagerMode = mode === 'manager';
    document.getElementById('container').classList.remove('hidden');
    
    // Adjust interface based on mode
    adjustInterfaceForMode();
    
    // Notify FiveM
    sendCallback('nightlifePanel:opened', { mode: mode });
}

// Close nightlife panel
function closeNightlifePanel() {
    document.getElementById('container').classList.add('hidden');
    sendCallback('nightlifePanel:closed', {});
}

// Adjust interface based on user mode
function adjustInterfaceForMode() {
    const isManager = isManagerMode;
    
    // Show/hide manager-specific elements
    document.querySelectorAll('.manager-only').forEach(element => {
        element.style.display = isManager ? 'block' : 'none';
    });
}

// Load nightlife data
function loadNightlifeData() {
    sendCallback('nightlifePanel:requestData', { type: 'general' });
}

// Load venues data
function loadVenuesData() {
    sendCallback('nightlifePanel:requestData', { type: 'venues' });
}

// Update venues list
function updateVenuesList(venues) {
    // Venues are already in HTML, but could be dynamically updated here
    sendCallback('nightlifePanel:venuesLoaded', { count: venues?.length || 4 });
}

// Apply venue filters
function applyVenueFilters() {
    const venueType = document.getElementById('venueType').value;
    const priceRange = document.getElementById('priceRange').value;
    
    const filterData = {
        type: venueType,
        priceRange: priceRange
    };
    
    sendCallback('nightlifePanel:applyFilters', filterData);
    showNotification('Filters applied successfully', 'success');
}

// Visit venue
function visitVenue(venue) {
    const venueData = {
        venue: venue,
        timestamp: Date.now()
    };
    
    sendCallback('nightlifePanel:visitVenue', venueData);
    showNotification(`Visiting ${venue}...`, 'info');
}

// Load events data
function loadEventsData() {
    sendCallback('nightlifePanel:requestData', { type: 'events' });
}

// Update events list
function updateEventsList(events) {
    const eventsList = document.getElementById('eventsList');
    if (!eventsList) return;
    
    if (!events || events.length === 0) {
        eventsList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No upcoming events</p>';
        return;
    }
    
    let html = '';
    events.forEach(event => {
        const eventDate = new Date(event.date);
        const day = eventDate.getDate();
        const month = eventDate.toLocaleDateString('en-US', { month: 'short' });
        
        html += `
            <div class="event-item">
                <div class="event-date">
                    <span class="day">${day}</span>
                    <span class="month">${month}</span>
                </div>
                <div class="event-details">
                    <h4>${event.name}</h4>
                    <p class="event-venue">${event.venue}</p>
                    <p class="event-time">${event.time}</p>
                    <p class="event-price">Entry: $${event.price}</p>
                </div>
                <button class="book-btn" data-event="${event.id}">Book Tickets</button>
            </div>
        `;
    });
    
    eventsList.innerHTML = html;
    
    // Re-attach event listeners for new buttons
    document.querySelectorAll('.book-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const event = this.getAttribute('data-event');
            bookEvent(event);
        });
    });
}

// Book event
function bookEvent(eventId) {
    const eventData = {
        eventId: eventId,
        timestamp: Date.now()
    };
    
    sendCallback('nightlifePanel:bookEvent', eventData);
    showNotification('Event booking submitted!', 'success');
}

// Create event (manager only)
function createEvent() {
    if (!isManagerMode) {
        showNotification('Access denied: Manager only', 'error');
        return;
    }
    
    const eventName = document.getElementById('eventName').value;
    const eventVenue = document.getElementById('eventVenue').value;
    const eventDate = document.getElementById('eventDate').value;
    const eventTime = document.getElementById('eventTime').value;
    const eventPrice = document.getElementById('eventPrice').value;
    
    if (!eventName || !eventVenue || !eventDate || !eventTime) {
        showNotification('Please fill in all required fields', 'error');
        return;
    }
    
    const eventData = {
        name: eventName,
        venue: eventVenue,
        date: eventDate,
        time: eventTime,
        price: parseFloat(eventPrice) || 0,
        id: generateEventId()
    };
    
    sendCallback('nightlifePanel:createEvent', eventData);
    
    // Clear form
    document.getElementById('eventName').value = '';
    document.getElementById('eventVenue').value = '';
    document.getElementById('eventDate').value = '';
    document.getElementById('eventTime').value = '';
    document.getElementById('eventPrice').value = '';
    
    showNotification('Event created successfully!', 'success');
}

// Generate event ID
function generateEventId() {
    return 'EVENT-' + Date.now().toString().slice(-6);
}

// Load bookings data
function loadBookingsData() {
    sendCallback('nightlifePanel:requestData', { type: 'bookings' });
}

// Update bookings list
function updateBookingsList(bookings) {
    const bookingsList = document.getElementById('bookingsList');
    if (!bookingsList) return;
    
    if (!bookings || bookings.length === 0) {
        bookingsList.innerHTML = '<p style="color: #a0a0a0; text-align: center; padding: 40px;">No reservations found</p>';
        return;
    }
    
    let html = '';
    bookings.forEach(booking => {
        const statusClass = booking.status?.toLowerCase() || 'pending';
        html += `
            <div class="booking-item">
                <div class="booking-info">
                    <h4>${booking.service} - ${booking.venue}</h4>
                    <p class="booking-date">${booking.date} - ${booking.time}</p>
                    <p class="booking-details">${booking.details}</p>
                    <p class="booking-price">Total: $${booking.total}</p>
                </div>
                <div class="booking-status">
                    <span class="status-badge ${statusClass}">${booking.status}</span>
                    <button class="cancel-btn" data-booking="${booking.id}">Cancel</button>
                </div>
            </div>
        `;
    });
    
    bookingsList.innerHTML = html;
    
    // Re-attach event listeners for new buttons
    document.querySelectorAll('.cancel-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const booking = this.getAttribute('data-booking');
            cancelBooking(booking);
        });
    });
}

// Cancel booking
function cancelBooking(bookingId) {
    const bookingData = {
        bookingId: bookingId,
        timestamp: Date.now()
    };
    
    sendCallback('nightlifePanel:cancelBooking', bookingData);
    showNotification('Booking cancellation requested', 'info');
}

// Make reservation
function makeReservation() {
    const venue = document.getElementById('bookingVenue').value;
    const date = document.getElementById('bookingDate').value;
    const time = document.getElementById('bookingTime').value;
    const partySize = document.getElementById('partySize').value;
    const serviceType = document.getElementById('serviceType').value;
    
    if (!venue || !date || !time || !partySize || !serviceType) {
        showNotification('Please fill in all required fields', 'error');
        return;
    }
    
    const reservationData = {
        venue: venue,
        date: date,
        time: time,
        partySize: parseInt(partySize),
        serviceType: serviceType,
        id: generateBookingId(),
        timestamp: Date.now()
    };
    
    sendCallback('nightlifePanel:makeReservation', reservationData);
    
    // Clear form
    document.getElementById('bookingVenue').value = '';
    document.getElementById('bookingDate').value = '';
    document.getElementById('bookingTime').value = '';
    document.getElementById('partySize').value = '';
    document.getElementById('serviceType').value = 'general';
    
    showNotification('Reservation submitted successfully!', 'success');
}

// Generate booking ID
function generateBookingId() {
    return 'BOOK-' + Date.now().toString().slice(-6);
}

// Load VIP data
function loadVIPData() {
    sendCallback('nightlifePanel:requestData', { type: 'vip' });
}

// Update VIP services
function updateVIPServices(services) {
    // VIP services are static in HTML for now
    sendCallback('nightlifePanel:vipLoaded', { services: services?.length || 4 });
}

// Request VIP service
function requestVIPService(service) {
    const serviceData = {
        service: service,
        timestamp: Date.now()
    };
    
    sendCallback('nightlifePanel:requestVIPService', serviceData);
    showNotification(`VIP service request submitted: ${service}`, 'success');
}

// Contact concierge
function contactConcierge() {
    sendCallback('nightlifePanel:contactConcierge', { timestamp: Date.now() });
    showNotification('Connecting you with VIP concierge...', 'info');
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#4caf50' : type === 'error' ? '#f44336' : '#e91e63'};
        color: white;
        padding: 15px 25px;
        border-radius: 10px;
        font-size: 16px;
        font-weight: 600;
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
        border: 2px solid rgba(255, 255, 255, 0.2);
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove after 4 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 4000);
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
    
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.05);
        }
    }
`;
document.head.appendChild(style);