-- LS Taxi Dispatch System - English Locales

local Translations = {
    -- General System Messages
    ['system_name'] = 'LS Taxi Dispatch System',
    ['version'] = 'v3.2',
    ['loading'] = 'Loading taxi dispatch system...',
    ['system_ready'] = 'Taxi dispatch system is ready',
    ['system_error'] = 'System error occurred',
    ['access_denied'] = 'Access denied: Insufficient permissions',
    ['session_expired'] = 'Session expired, please login again',
    
    -- Authentication & Access
    ['login_required'] = 'You must be logged in to access the dispatch system',
    ['dispatcher_only'] = 'Only dispatchers can access this system',
    ['admin_required'] = 'Administrator privileges required',
    ['login_success'] = 'Successfully logged into dispatch system',
    ['logout_success'] = 'Successfully logged out of dispatch system',
    ['login_failed'] = 'Login failed: Invalid credentials',
    
    -- Dispatch Operations
    ['dispatch_active'] = 'Dispatch system is active',
    ['dispatch_offline'] = 'Dispatch system is offline',
    ['new_call_received'] = 'New taxi call received',
    ['call_assigned'] = 'Call assigned to driver %s',
    ['call_completed'] = 'Call %s completed successfully',
    ['call_cancelled'] = 'Call %s has been cancelled',
    ['no_drivers_available'] = 'No drivers available for assignment',
    ['auto_assign_enabled'] = 'Auto-assignment is enabled',
    ['auto_assign_disabled'] = 'Auto-assignment is disabled',
    ['priority_call'] = 'Priority call: %s',
    ['urgent_call'] = 'URGENT: Emergency taxi request',
    ['scheduled_call'] = 'Scheduled call: %s',
    
    -- Driver Management
    ['driver_online'] = 'Driver %s is now online',
    ['driver_offline'] = 'Driver %s is now offline',
    ['driver_busy'] = 'Driver %s is on a ride',
    ['driver_available'] = 'Driver %s is available',
    ['driver_suspended'] = 'Driver %s has been suspended',
    ['driver_activated'] = 'Driver %s has been activated',
    ['driver_not_found'] = 'Driver not found',
    ['driver_added'] = 'New driver %s added to system',
    ['driver_removed'] = 'Driver %s removed from system',
    ['driver_updated'] = 'Driver %s information updated',
    ['driver_rating_updated'] = 'Driver %s rating updated to %s stars',
    ['driver_earnings_updated'] = 'Driver %s earnings updated: $%s',
    ['contact_driver'] = 'Contacting driver %s...',
    ['driver_response'] = 'Driver %s responded: %s',
    ['driver_no_response'] = 'No response from driver %s',
    
    -- Vehicle Management
    ['vehicle_assigned'] = 'Vehicle %s assigned to driver %s',
    ['vehicle_unassigned'] = 'Vehicle %s is now unassigned',
    ['vehicle_active'] = 'Vehicle %s is active and in service',
    ['vehicle_parked'] = 'Vehicle %s is parked',
    ['vehicle_maintenance'] = 'Vehicle %s is in maintenance',
    ['vehicle_out_of_service'] = 'Vehicle %s is out of service',
    ['vehicle_added'] = 'New vehicle %s added to fleet',
    ['vehicle_removed'] = 'Vehicle %s removed from fleet',
    ['vehicle_service_due'] = 'Vehicle %s service is due',
    ['vehicle_service_overdue'] = 'Vehicle %s service is overdue',
    ['service_scheduled'] = 'Maintenance scheduled for vehicle %s',
    ['service_completed'] = 'Maintenance completed for vehicle %s',
    
    -- Ride Management
    ['ride_started'] = 'Ride %s started',
    ['ride_in_progress'] = 'Ride %s is in progress',
    ['ride_completed'] = 'Ride %s completed',
    ['ride_cancelled'] = 'Ride %s cancelled',
    ['ride_fare_calculated'] = 'Ride fare calculated: $%s',
    ['ride_payment_received'] = 'Payment received for ride %s',
    ['ride_payment_pending'] = 'Payment pending for ride %s',
    ['customer_pickup'] = 'Customer pickup at %s',
    ['customer_destination'] = 'Destination: %s',
    ['ride_distance'] = 'Trip distance: %s miles',
    ['ride_duration'] = 'Trip duration: %s minutes',
    ['customer_rating'] = 'Customer rated ride %s stars',
    
    -- Emergency & Safety
    ['emergency_alert'] = 'EMERGENCY ALERT: %s',
    ['panic_button'] = 'Panic button activated by driver %s',
    ['emergency_response'] = 'Emergency response initiated',
    ['safety_check'] = 'Safety check requested for driver %s',
    ['driver_location_lost'] = 'Lost contact with driver %s',
    ['vehicle_breakdown'] = 'Vehicle breakdown reported: %s',
    ['accident_reported'] = 'Accident reported involving vehicle %s',
    ['police_notified'] = 'Police have been notified',
    ['medical_requested'] = 'Medical assistance requested',
    ['emergency_resolved'] = 'Emergency situation resolved',
    
    -- Financial & Earnings
    ['earnings_updated'] = 'Earnings updated: $%s',
    ['daily_revenue'] = 'Daily revenue: $%s',
    ['driver_payout'] = 'Driver payout: $%s',
    ['company_commission'] = 'Company commission: $%s',
    ['payment_processed'] = 'Payment processed: $%s',
    ['payment_failed'] = 'Payment failed: %s',
    ['fare_adjustment'] = 'Fare adjusted for ride %s: $%s',
    ['surge_pricing'] = 'Surge pricing active: %sx multiplier',
    ['discount_applied'] = 'Discount applied: %s%%',
    ['tip_received'] = 'Tip received: $%s',
    
    -- GPS & Navigation
    ['gps_tracking'] = 'GPS tracking enabled',
    ['gps_disabled'] = 'GPS tracking disabled',
    ['location_updated'] = 'Location updated for %s',
    ['route_calculated'] = 'Route calculated: %s miles, %s minutes',
    ['navigation_started'] = 'Navigation started to %s',
    ['destination_reached'] = 'Destination reached',
    ['off_route'] = 'Vehicle is off route',
    ['traffic_delay'] = 'Traffic delay detected: +%s minutes',
    ['fastest_route'] = 'Fastest route suggested',
    ['avoid_traffic'] = 'Alternative route to avoid traffic',
    
    -- Communication
    ['message_sent'] = 'Message sent to %s',
    ['message_received'] = 'Message received from %s',
    ['call_initiated'] = 'Voice call initiated with %s',
    ['call_ended'] = 'Call ended with %s',
    ['broadcast_sent'] = 'Broadcast message sent to all drivers',
    ['notification_sent'] = 'Notification sent: %s',
    ['alert_dismissed'] = 'Alert dismissed',
    ['announcement'] = 'Announcement: %s',
    
    -- Settings & Configuration
    ['settings_saved'] = 'Settings saved successfully',
    ['settings_reset'] = 'Settings reset to default',
    ['config_updated'] = 'Configuration updated',
    ['pricing_updated'] = 'Pricing configuration updated',
    ['zone_updated'] = 'Service zone updated',
    ['schedule_updated'] = 'Schedule updated',
    ['backup_created'] = 'System backup created',
    ['backup_restored'] = 'System backup restored',
    ['maintenance_mode'] = 'System is in maintenance mode',
    ['maintenance_complete'] = 'Maintenance mode disabled',
    
    -- Reports & Analytics
    ['report_generated'] = 'Report generated: %s',
    ['data_exported'] = 'Data exported successfully',
    ['analytics_updated'] = 'Analytics data updated',
    ['performance_summary'] = 'Performance summary: %s rides, $%s revenue',
    ['weekly_report'] = 'Weekly report available',
    ['monthly_report'] = 'Monthly report available',
    ['driver_performance'] = 'Driver performance report for %s',
    ['fleet_status'] = 'Fleet status report',
    
    -- Customer Service
    ['customer_complaint'] = 'Customer complaint received for ride %s',
    ['customer_compliment'] = 'Customer compliment received for driver %s',
    ['feedback_received'] = 'Customer feedback received: %s stars',
    ['refund_processed'] = 'Refund processed for ride %s: $%s',
    ['lost_item'] = 'Lost item reported for ride %s',
    ['customer_callback'] = 'Customer callback requested',
    
    -- Shift Management
    ['shift_started'] = 'Shift started for %s',
    ['shift_ended'] = 'Shift ended for %s',
    ['break_started'] = 'Break started for %s',
    ['break_ended'] = 'Break ended for %s',
    ['overtime_alert'] = 'Overtime alert for %s',
    ['shift_change'] = 'Shift change: %s replacing %s',
    ['schedule_conflict'] = 'Schedule conflict detected for %s',
    
    -- Weather & Conditions
    ['weather_alert'] = 'Weather alert: %s',
    ['road_closure'] = 'Road closure reported: %s',
    ['traffic_incident'] = 'Traffic incident: %s',
    ['construction_zone'] = 'Construction zone: %s',
    ['service_area_alert'] = 'Service area alert: %s',
    
    -- UI Elements
    ['dashboard'] = 'Dashboard',
    ['dispatch'] = 'Dispatch',
    ['drivers'] = 'Drivers',
    ['vehicles'] = 'Vehicles',
    ['rides'] = 'Rides',
    ['earnings'] = 'Earnings',
    ['settings'] = 'Settings',
    ['reports'] = 'Reports',
    ['help'] = 'Help',
    ['about'] = 'About',
    ['logout'] = 'Logout',
    
    -- Status Labels
    ['online'] = 'Online',
    ['offline'] = 'Offline',
    ['busy'] = 'Busy',
    ['available'] = 'Available',
    ['suspended'] = 'Suspended',
    ['active'] = 'Active',
    ['inactive'] = 'Inactive',
    ['parked'] = 'Parked',
    ['maintenance'] = 'Maintenance',
    ['completed'] = 'Completed',
    ['cancelled'] = 'Cancelled',
    ['in_progress'] = 'In Progress',
    ['pending'] = 'Pending',
    ['assigned'] = 'Assigned',
    ['urgent'] = 'Urgent',
    ['normal'] = 'Normal',
    ['scheduled'] = 'Scheduled',
    
    -- Actions
    ['assign'] = 'Assign',
    ['unassign'] = 'Unassign',
    ['contact'] = 'Contact',
    ['track'] = 'Track',
    ['view'] = 'View',
    ['edit'] = 'Edit',
    ['delete'] = 'Delete',
    ['add'] = 'Add',
    ['save'] = 'Save',
    ['cancel'] = 'Cancel',
    ['confirm'] = 'Confirm',
    ['refresh'] = 'Refresh',
    ['export'] = 'Export',
    ['import'] = 'Import',
    ['search'] = 'Search',
    ['filter'] = 'Filter',
    ['sort'] = 'Sort',
    ['print'] = 'Print',
    
    -- Form Labels
    ['name'] = 'Name',
    ['phone'] = 'Phone',
    ['email'] = 'Email',
    ['address'] = 'Address',
    ['license_plate'] = 'License Plate',
    ['vehicle_model'] = 'Vehicle Model',
    ['driver_license'] = 'Driver License',
    ['pickup_location'] = 'Pickup Location',
    ['destination'] = 'Destination',
    ['customer_name'] = 'Customer Name',
    ['ride_id'] = 'Ride ID',
    ['fare_amount'] = 'Fare Amount',
    ['distance'] = 'Distance',
    ['duration'] = 'Duration',
    ['rating'] = 'Rating',
    ['notes'] = 'Notes',
    ['date'] = 'Date',
    ['time'] = 'Time',
    
    -- Validation Messages
    ['required_field'] = 'This field is required',
    ['invalid_phone'] = 'Invalid phone number format',
    ['invalid_email'] = 'Invalid email address format',
    ['invalid_license'] = 'Invalid license number format',
    ['minimum_length'] = 'Minimum length: %s characters',
    ['maximum_length'] = 'Maximum length: %s characters',
    ['numeric_only'] = 'Only numbers allowed',
    ['alphanumeric_only'] = 'Only letters and numbers allowed',
    
    -- Time & Date
    ['today'] = 'Today',
    ['yesterday'] = 'Yesterday',
    ['this_week'] = 'This Week',
    ['last_week'] = 'Last Week',
    ['this_month'] = 'This Month',
    ['last_month'] = 'Last Month',
    ['minutes_ago'] = '%s minutes ago',
    ['hours_ago'] = '%s hours ago',
    ['days_ago'] = '%s days ago',
    
    -- Statistics
    ['total_rides'] = 'Total Rides',
    ['total_revenue'] = 'Total Revenue',
    ['average_rating'] = 'Average Rating',
    ['completion_rate'] = 'Completion Rate',
    ['response_time'] = 'Response Time',
    ['peak_hours'] = 'Peak Hours',
    ['busiest_zone'] = 'Busiest Zone',
    ['top_driver'] = 'Top Driver',
    ['fleet_utilization'] = 'Fleet Utilization',
    
    -- Alerts & Notifications
    ['new_notification'] = 'New notification',
    ['unread_messages'] = '%s unread messages',
    ['system_update'] = 'System update available',
    ['low_battery'] = 'Low battery warning for %s',
    ['fuel_warning'] = 'Low fuel warning for vehicle %s',
    ['inspection_due'] = 'Inspection due for vehicle %s',
    ['license_expiring'] = 'License expiring for driver %s',
    ['insurance_expiring'] = 'Insurance expiring for vehicle %s',
    
    -- Pricing & Billing
    ['base_fare'] = 'Base Fare',
    ['per_mile_rate'] = 'Per Mile Rate',
    ['per_minute_rate'] = 'Per Minute Rate',
    ['surge_multiplier'] = 'Surge Multiplier',
    ['airport_fee'] = 'Airport Fee',
    ['toll_charges'] = 'Toll Charges',
    ['waiting_time'] = 'Waiting Time',
    ['cancellation_fee'] = 'Cancellation Fee',
    ['cleaning_fee'] = 'Cleaning Fee',
    ['tip_amount'] = 'Tip Amount',
    ['total_fare'] = 'Total Fare',
    ['driver_earnings'] = 'Driver Earnings',
    ['company_fee'] = 'Company Fee',
    
    -- Service Areas
    ['downtown'] = 'Downtown',
    ['airport'] = 'Airport',
    ['hospital'] = 'Hospital',
    ['train_station'] = 'Train Station',
    ['shopping_mall'] = 'Shopping Mall',
    ['residential'] = 'Residential Area',
    ['business_district'] = 'Business District',
    ['entertainment'] = 'Entertainment District',
    ['industrial'] = 'Industrial Area',
    ['suburbs'] = 'Suburbs',
    
    -- Special Services
    ['wheelchair_accessible'] = 'Wheelchair Accessible',
    ['pet_friendly'] = 'Pet Friendly',
    ['luxury_service'] = 'Luxury Service',
    ['economy_ride'] = 'Economy Ride',
    ['shared_ride'] = 'Shared Ride',
    ['express_service'] = 'Express Service',
    ['scheduled_ride'] = 'Scheduled Ride',
    ['round_trip'] = 'Round Trip',
    ['airport_transfer'] = 'Airport Transfer',
    ['medical_transport'] = 'Medical Transport',
    
    -- Success Messages
    ['operation_successful'] = 'Operation completed successfully',
    ['data_saved'] = 'Data saved successfully',
    ['message_sent_success'] = 'Message sent successfully',
    ['assignment_successful'] = 'Assignment completed successfully',
    ['update_successful'] = 'Update completed successfully',
    ['deletion_successful'] = 'Deletion completed successfully',
    ['creation_successful'] = 'Creation completed successfully',
    
    -- Error Messages
    ['operation_failed'] = 'Operation failed',
    ['data_not_saved'] = 'Failed to save data',
    ['message_send_failed'] = 'Failed to send message',
    ['assignment_failed'] = 'Assignment failed',
    ['update_failed'] = 'Update failed',
    ['deletion_failed'] = 'Deletion failed',
    ['creation_failed'] = 'Creation failed',
    ['connection_error'] = 'Connection error',
    ['server_error'] = 'Server error',
    ['timeout_error'] = 'Request timeout',
    
    -- Confirmation Messages
    ['confirm_delete'] = 'Are you sure you want to delete this item?',
    ['confirm_assignment'] = 'Confirm assignment of %s to %s?',
    ['confirm_cancellation'] = 'Are you sure you want to cancel this operation?',
    ['confirm_logout'] = 'Are you sure you want to logout?',
    ['confirm_reset'] = 'Are you sure you want to reset all settings?',
    ['unsaved_changes'] = 'You have unsaved changes. Continue anyway?',
    
    -- Help & Support
    ['help_center'] = 'Help Center',
    ['contact_support'] = 'Contact Support',
    ['user_manual'] = 'User Manual',
    ['video_tutorials'] = 'Video Tutorials',
    ['faq'] = 'Frequently Asked Questions',
    ['troubleshooting'] = 'Troubleshooting Guide',
    ['keyboard_shortcuts'] = 'Keyboard Shortcuts',
    ['system_requirements'] = 'System Requirements',
    
    -- Footer
    ['copyright'] = '© 2025 LS Taxi Company. All rights reserved.',
    ['version_info'] = 'Dispatch Management System v3.2',
    ['powered_by'] = 'Powered by Los Scotia Scripts',
}

Config = Config or {}
Config.Locale = 'en'

Lang = setmetatable({}, {
    __index = function(_, key)
        if Translations[key] then
            return Translations[key]
        else
            return 'Translation missing: ' .. tostring(key)
        end
    end
})

function _(key, ...)
    local translation = Lang[key]
    if translation and select('#', ...) > 0 then
        return string.format(translation, ...)
    end
    return translation or key
end

-- Export for external use
exports('GetTranslation', function(key, ...)
    return _(key, ...)
end)

exports('GetAllTranslations', function()
    return Translations
end)

return Translations