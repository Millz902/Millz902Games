# Los Scotia Server Scanner

A comprehensive server scanning utility for Los Scotia FiveM server. This resource helps identify conflicts, missing dependencies, and potential issues in your server configuration.

## Features

- **Resource Conflict Detection**: Identifies resources that conflict with each other
- **Missing Dependencies**: Finds missing dependencies between resources
- **SQL Integrity Checks**: Validates SQL files for potential errors
- **Webhook Analysis**: Detects duplicate or misconfigured webhooks
- **System Checks**: Verifies critical systems (banking, phone, inventory) for conflicts
- **Configuration Validation**: Identifies common configuration errors

## Usage

### In-Game Commands

- `/serverscan` - Run a full server scan (admin only)
- `/serverscan_menu` - Open the server scanner menu with options (admin only)

### Keybinds

- `DELETE` - Open the server scanner menu (admin only)

### Console Commands

- `server_scan` - Run a server scan from the server console

## Scan Results

Scan results are displayed in several ways:

1. In-game notifications with summary results
2. Detailed console output with colored warnings and errors
3. Results file saved to the server directory

## Admin-Only

All scanning functionality is restricted to server admins to prevent misuse.

## Author

Created by Los Scotia Development Team

## License

This resource is private and for use only on the Los Scotia FiveM server.