# Interface Contract — domus-listing

## Scope

This contract covers the domUs listing screen, the default screen shown to any authenticated user. It is the authoritative reference for QA testing of this item.

---

## Endpoints

### GET /

**Purpose**: Display the domUs listing screen.

**Authentication**: Required. Unauthenticated requests are redirected to GET /login.

**Authorization**: Any authenticated role (guest, user, admin).

**Inputs**: none

**Response**:
- HTTP 200 with the domUs listing page
- Unauthenticated (no session or expired session): HTTP 302 redirect to GET /login

---

## Page content

The page contains two sections:

### Running domUs section

Heading: "Running"

Displays a table of all domUs currently in `running` status. Each row contains:

| Column | Description |
|---|---|
| Name | domU name |
| vCPUs | number of virtual CPUs |
| Memory (MB) | allocated memory in MB |
| Disk (GB) | allocated disk in GB |
| NIC | NIC type (`NAT`, `HOST ONLY`, `BRIDGED`, or `none` if no NIC) |
| CPU % | simulated current CPU utilisation percentage |
| Mem Used (MB) | simulated current memory usage in MB |

If no domUs are running, the section displays: "No running domUs."

### Configured domUs section

Heading: "Configured"

Displays a table of all registered domUs regardless of status. Each row contains:

| Column | Description |
|---|---|
| Name | domU name |
| vCPUs | number of virtual CPUs |
| Memory (MB) | allocated memory in MB |
| Disk (GB) | allocated disk in GB |
| NIC | NIC type (`NAT`, `HOST ONLY`, `BRIDGED`, or `none` if no NIC) |
| Status | `running` or `idle` |

If no domUs are configured, the section displays: "No configured domUs."

---

## Session behavior

Inherited from the authentication contract (see `user-model-and-auth.md`): session expires after 60 minutes of inactivity; expired sessions are cleared and the user is redirected to GET /login.
