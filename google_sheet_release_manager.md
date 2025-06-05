# ServerTagAssignment and Release Management Automation System

## Overview

This document outlines the design, implementation, and lifecycle of a homegrown server release channel management and automation system. This system governed release channels and software versioning across over 1,500 cloud-based servers over a 4-year production lifespan. It was later deprecated in favor of a GitOps-based model.

---

## Problem Statement

The DevOps team needed to:

- Offload some of our growing workload.
- Provide a way for SRE to update servers without needing to learn DevOps or require access to DevOps tools/repositories

The SRE team needed a scalable, secure, and auditable way to manage:

- Which software release version each server was on.
- How and when updates were applied.
- Coordinated approval between SREs and Release Managers.

Key goals included:

- Reducing risk from uncoordinated rollouts.
- Preventing unauthorized or premature updates.
- Maintaining clear observability of server states.

---

## Core Components

### 1. ReleaseChannel Document (Google Sheets)
**Purpose**: Source of truth for release channel assignment and control.

This document (see [here](https://docs.google.com/spreadsheets/d/1EbljChZRlw6sobgAGGOX2SMOqvOGgYL6eZtTIIjfGVM/edit?gid=0#gid=0) for an example) consisted of three main sheets:


#### a.`ReleaseChannels`

- **Fields**:
  - `ServerName`
  - `currentReleaseChannel`
  - `desiredReleaseChannel`
  - `lastUpdateTime`
  - `Comments`
- **Functionality**:
  - Tracked current vs. desired state.
  - Allowed safe, centralized updates via metadata propagation.
  - Dual-key system: SREs updated `desiredVersionA`, Release Managers updated `desiredVersionB`. Both had to match to trigger rollouts.
    
#### b.`MaintenanceWindow`

- **Fields**:
  - `ServerName`
  - `currentReleaseChannel`
  - `desiredReleaseChannel`
  - `lastUpdateTime`
  - `Comments`
- **Functionality**:
  - Tracked current vs. desired state.
  - Allowed safe, centralized updates via metadata propagation.
  - Dual-key system: SREs updated `desiredVersionA`, Release Managers updated `desiredVersionB`. Both had to match to trigger rollouts.

#### c.`ServerTagAssignment`

- **Fields**:
  - `ServerName`
  - `currentReleaseChannel`
  - `desiredReleaseChannel`
  - `lastUpdateTime`
  - `Comments`
- **Functionality**:
  - Tracked current vs. desired state.
  - Allowed safe, centralized updates via metadata propagation.
  - Dual-key system: SREs updated `desiredVersionA`, Release Managers updated `desiredVersionB`. Both had to match to trigger rollouts.

---

### 2. Task Server

- **Tech Stack**: PowerShell, Windows Task Scheduler (Windows), `cron` (Linux).
- **Responsibilities**:
  - **Task 1: Metadata Updater**
    - Compared server metadata with release sheet.
    - If `desiredVersionA == desiredVersionB` and different from actual metadata:
      - Updated metadata tags on servers.
      - Logged changes.
  - **Task 2: ServerTagAssignment Sync**
    - Synced server list from cloud to sheet.
    - Added new servers to sheet.
    - Updated current metadata values.
    - Wrote notes and timestamps into `Comments` column.
- **Scheduling**: Every 5 minutes.
- **Performance Improvements**:
  - Introduced threading and exponential backoff.
  - Reduced update propagation time from ~15 min to ~2–3 min.

---

### 3. Server-Side Recurring Task

- **Language**: PowerShell.
- **Scheduling**: `cron` or Windows Task Scheduler.
- **Logic**:
  - On every 5-minute interval:
    - Check local metadata tags.
    - If version mismatch detected:
      - Pull and apply latest Docker image or reinstall Windows app.
  - Errors logged locally and to cloud (e.g. Stackdriver).
  - On-call team alerted via email for unrecoverable errors.

---

## Security and Safety Features

- **Dual-Key Control**:
  - Prevented unilateral changes.
  - Ensured mutual sign-off from SRE and Release.
- **Permission Scoping**:
  - SREs could only write to `desiredVersionA`.
  - Release could only write to `desiredVersionB`.
- **Rollback Columns**:
  - Added to sheet to disable rollouts or revert versions.
- **Auditing**:
  - All actions logged in `Comments` and cloud logs.
  - Changes timestamped and attributed.

---

## Environments and Scale

- **Environments**: Implemented in both Staging and Production.
- **Scale**: Managed over 1,500 servers at peak.
- **Duration in Production**: ~4 years with continuous improvements.

---

## Transition to GitOps

### Why the Change?

- Increasing complexity.
- Need for more robust version control and traceability.
- Expansion of DevOps skills and cloud-native tooling.

### GitOps Migration Highlights

- Server tags now defined declaratively in Git.
- CI/CD pipelines apply metadata via Infrastructure as Code (IaC).
- Eliminated manual sheet updates and scripting.

---

## Cloud-Agnostic Design Notes

While originally built on GCP, this system could be replicated in AWS using:

| GCP Concept            | AWS Equivalent                         |
|------------------------|----------------------------------------|
| Metadata Tags          | EC2 Instance Tags / SSM Parameter Store |
| Stackdriver Logging    | CloudWatch Logs                        |
| Vault (Secrets Mgmt)   | AWS Secrets Manager                    |
| Google Sheets API      | Amazon Honeycode, S3-based config, or DynamoDB |
| Cron/Task Scheduler    | EventBridge Scheduler / Lambda / SSM Run Command |

---

## Trade-Offs and Limitations

| Area            | Trade-Off |
|------------------|-----------|
| Google Sheets    | Fast to prototype but limited scalability/API rate limits |
| Script-based     | Lacked type safety or unit tests |
| Manual Dependency | Required Vault, Secrets, and Service Accounts setup |
| Metadata reliance | Servers couldn't self-identify channel logic |
| No DR/HA         | Task server was not fault tolerant |

---

## Outcome and Retrospective

This system:

- Empowered the SRE team to manage release lifecycles safely.
- Provided cross-functional auditability and accountability.
- Handled thousands of metadata updates and rollouts with minimal disruption.
- Served as a launchpad for the team’s GitOps and DevOps evolution.

---

## Appendix

### Sample ServerTagAssignment Row:

| ServerName | currentReleaseChannel | desiredReleaseChannel | lastUpdateTime     | Comments                           |
|------------|------------------------|------------------------|--------------------|------------------------------------|
| app-prod-1 | stable                 | canary                 | 2025-06-04T17:40Z  | Updated from stable → canary       |

---
