# packagehall-ctl

Command-line tool for managing PackageHall repositories, organizations, and packages.

Can be used with [Packager.io](https://go.packager.io), a hosted version of the PackageHall app.

## Installation

### Quick Install (Linux/macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/pkgr/packagehall-ctl/main/install.sh | sh
```

### Manual Installation

Download the latest binary for your platform from the [releases page](https://github.com/pkgr/packagehall-ctl/releases):

- **macOS (Intel)**: `packagehall-ctl-darwin-amd64`
- **macOS (Apple Silicon)**: `packagehall-ctl-darwin-arm64`
- **Linux (x86_64)**: `packagehall-ctl-linux-amd64`
- **Linux (ARM64)**: `packagehall-ctl-linux-arm64`
- **Windows**: `packagehall-ctl-windows-amd64.exe`

Make it executable and move to your PATH:

```bash
chmod +x packagehall-ctl-*
sudo mv packagehall-ctl-* /usr/local/bin/packagehall-ctl
```

## Quick Start

### Configure the CLI (Recommended)

The easiest way to get started is to configure your default endpoint and token:

```bash
# Interactive configuration
packagehall-ctl configure
```

This will prompt you for:
- **Endpoint**: Your PackageHall server URL (default: `https://go.packager.io`)
- **Token**: Your authentication token (optional, hidden input)

Configuration is saved to `~/.packagehall/config.yaml` and used automatically for all commands.

### Connect to a PackageHall Server

```bash
# Using saved configuration (after running 'configure')
packagehall-ctl org list

# Local Unix socket (default when no config file exists)
packagehall-ctl org list

# Override with flags (useful for testing or multiple servers)
packagehall-ctl --admin=https://go.packager.io --token=YOUR_TOKEN org list
```

### Common Operations

```bash
# Create an organization
packagehall-ctl org create --name=myorg --description="My Organization"

# Create a repository
packagehall-ctl repo create --org=myorg --name=myrepo --description="My Repository"

# Create a push token
packagehall-ctl token create --org=myorg --repo=myrepo --name="CI Token" --permissions=push

# List packages
packagehall-ctl package list --org=myorg --repo=myrepo

# Get JSON output
packagehall-ctl --format=json org list
```

## Usage

```
Global Flags:
  --admin string    Admin socket path or HTTP URL (default "unix://packagehall-admin.sock")
  --format string   Output format: table or json (default "table")
  --token string    Authentication token for HTTP endpoints

Commands:
  configure  Configure packagehall-ctl with default endpoint and token
  config     Manage configuration
  org        Manage organizations
  repo       Manage repositories
  token      Manage authentication tokens
  target     Manage distribution targets
  package    Manage packages
  blob       Manage blob storage
  channel    Manage channels
```

### Configuration Management

```bash
# Interactive configuration setup
packagehall-ctl configure

# Show current configuration (token is masked for security)
packagehall-ctl config show

# Configuration is stored at ~/.packagehall/config.yaml
```

**Configuration Priority**: CLI flags > config file > built-in defaults

This means you can set default values in the config file and override them with flags when needed.

### Organization Management

```bash
# Create organization
packagehall-ctl org create --name=myorg --description="My Organization"

# List organizations
packagehall-ctl org list

# Delete organization
packagehall-ctl org delete --name=myorg

# GPG key management
packagehall-ctl org generate-gpg-key --org=myorg --name="GPG Key" --email=user@example.com
packagehall-ctl org get-gpg-key --org=myorg
packagehall-ctl org set-gpg-key --org=myorg --key-id=ABCD1234
```

### Repository Management

```bash
# Create repository
packagehall-ctl repo create --org=myorg --name=myrepo --description="My Repo" --url=https://github.com/myorg/myrepo

# List repositories
packagehall-ctl repo list --org=myorg

# Edit repository
packagehall-ctl repo edit --org=myorg --repo=myrepo --description="Updated description" --visibility=public

# Delete repository
packagehall-ctl repo delete --org=myorg --repo=myrepo
```

### Token Management

```bash
# Create repository-scoped token
packagehall-ctl token create --org=myorg --repo=myrepo --name="CI Token" --permissions=push

# Create organization-scoped token
packagehall-ctl token create --org=myorg --name="Org Admin" --permissions=org_admin

# List tokens
packagehall-ctl token list --org=myorg
packagehall-ctl token list --org=myorg --repo=myrepo

# Delete token
packagehall-ctl token delete --org=myorg --name="CI Token"
```

### Target Management

```bash
# Create target
packagehall-ctl target create --target=ubuntu/24.04 --description="Ubuntu 24.04" --format=deb --architecture=amd64

# List targets
packagehall-ctl target list

# Update target
packagehall-ctl target update --target=ubuntu/24.04 --description="Ubuntu 24.04 LTS"
```

### Package Management

```bash
# List packages
packagehall-ctl package list --org=myorg --repo=myrepo

# Delete package
packagehall-ctl package delete --org=myorg --repo=myrepo --package-id=UUID
```

### Blob Management

```bash
# List blobs
packagehall-ctl blob list

# Delete blob
packagehall-ctl blob delete --blob-id=SHA256
```

## Permission Levels

Hierarchical permission system (higher levels inherit lower permissions):

1. **superadmin**: Full system access (Unix socket only)
2. **org_admin**: Create/manage repos, tokens, GPG keys within organization
3. **repo_admin**: Update repository settings
4. **push**: Upload packages
5. **pull**: Download packages and access metadata

## License

See the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

- GitHub Issues: https://github.com/pkgr/packagehall-ctl/issues
