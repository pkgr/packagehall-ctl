# Package Upload Guide

This guide explains how to upload RPM and DEB packages to PackageHall.

## Prerequisites

1. A PackageHall server instance
2. An organization and repository created
3. A token with `push` permissions

## Create a Token

```bash
# Create a push token for your repository
packagehall-ctl token create \
  --org=myorg \
  --repo=myrepo \
  --name="CI Push Token" \
  --permissions=push

# Save the token value (only shown once!)
export PACKAGEHALL_TOKEN="your-token-here"
```

## Upload Endpoint

```
POST https://your-packagehall-server.com/upload
```

### Authentication

Provide the token via one of:
- **Header**: `Authorization: Bearer YOUR_TOKEN`
- **Basic Auth**: Username can be anything, password is the token
- **Query parameter**: `?token=YOUR_TOKEN`

## Upload a Package

### Using curl

```bash
curl -X POST \
  -H "Authorization: Bearer $PACKAGEHALL_TOKEN" \
  -F "file=@./mypackage-1.0.0-1.el9.x86_64.rpm" \
  -F "org=myorg" \
  -F "repo=myrepo" \
  -F "target=el/9" \
  -F "channel=main" \
  https://packages.example.com/upload
```

### Multi-Channel Upload

Upload to multiple channels at once:

```bash
curl -X POST \
  -H "Authorization: Bearer $PACKAGEHALL_TOKEN" \
  -F "file=@./mypackage_1.0.0_amd64.deb" \
  -F "org=myorg" \
  -F "repo=myrepo" \
  -F "target=ubuntu/24.04" \
  -F "channel=main,testing" \
  https://packages.example.com/upload
```

## Form Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `file` | Yes | The package file (.rpm or .deb) |
| `org` | Yes | Organization name |
| `repo` | Yes | Repository name |
| `target` | Yes | Target distribution (e.g., `el/9`, `ubuntu/24.04`) |
| `channel` | Yes | Channel name or comma-separated list (e.g., `main`, `main,testing`) |

## Target Format

Targets are written as `{dist}/{version}`:

- **Red Hat/CentOS**: `el/9`, `el/8`
- **Ubuntu**: `ubuntu/24.04`, `ubuntu/22.04`
- **Debian**: `debian/12`, `debian/11`

## Channels

Channels allow you to organize packages by stability or feature:

- `main` - Stable releases
- `testing` - Beta/RC releases
- `unstable` - Development builds
- `feature/xyz` - Feature branches (supports slashes)

## GPG Signing

PackageHall automatically signs packages and repository metadata if a GPG key is configured:

```bash
# Generate a GPG key for your organization
packagehall-ctl org generate-gpg-key \
  --org=myorg \
  --name="PackageHall" \
  --email=packages@example.com

# Get the public key
packagehall-ctl org get-gpg-key --org=myorg
```

Users can then import your GPG key:

```bash
# For RPM
curl -fsSL https://packages.example.com/myorg/gpg.key | gpg --import

# For DEB
curl -fsSL https://packages.example.com/myorg/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/myorg.gpg
```

## GitHub Actions Example

```yaml
name: Build and Publish

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build RPM
        run: |
          # Your build process here
          ./build-rpm.sh

      - name: Upload to PackageHall
        env:
          PACKAGEHALL_TOKEN: ${{ secrets.PACKAGEHALL_TOKEN }}
        run: |
          curl -X POST \
            -H "Authorization: Bearer $PACKAGEHALL_TOKEN" \
            -F "file=@./dist/mypackage.rpm" \
            -F "org=myorg" \
            -F "repo=myrepo" \
            -F "target=el/9" \
            -F "channel=main" \
            https://packages.example.com/upload
```

## Error Responses

### 400 Bad Request
- Missing required parameters
- Invalid package file
- Target not found

### 401 Unauthorized
- Invalid or missing token

### 403 Forbidden
- Token lacks `push` permission
- Organization/repository not found

### 413 Payload Too Large
- Package file exceeds size limit

### 500 Internal Server Error
- Server-side error (check server logs)

## Best Practices

1. **Use dedicated tokens** for CI/CD (create per-project tokens)
2. **Rotate tokens regularly** for security
3. **Tag releases** before uploading to track versions
4. **Test in `testing` channel** before promoting to `main`
5. **Sign packages** with GPG for security
6. **Use multi-channel uploads** to publish to multiple channels atomically
