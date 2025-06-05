
# 🎤 System Design Interview: Google Sheets-Based Release Manager

## 1. Introduction

Hi, I’m Phillip Rolle, and today I’ll walk you through a system I designed and maintained for over five years: the **Google Sheets-Based Release Manager**. 
This system automated software release coordination and metadata management across over 1,500 production cloud servers using a simple but powerful interface—Google Sheets.

---

## 2. System Overview

- **Purpose**: Automate release channel management and metadata updates using Google Sheets as the source of truth.
- **Scale**: Managed 1,500+ cloud servers across staging and production.
- **Stack**: C#/PowerShell scripts, Windows Task Scheduler (or cron), Google Sheets API.
- **Production Duration**: Over 5 years, with continuous iteration and upgrades.

---

## 3. Problem Statement

We faced growing DevOps overhead and inconsistent server metadata updates, which led to:
- Deployment delays
- Human error
- Coordination failures between SRE and Release teams

**We needed**:
- A reliable source of truth
- A secure, auditable rollout mechanism
- Minimal access changes and learning curve

---

## 4. High-Level Architecture

**Core Components**:
- **Google Sheet**: Holds release metadata (ReleaseChannels, MaintenanceWindows, ServerTagAssignment).
- **Task Server**: Runs scheduled PowerShell/cron jobs every 5 minutes.
- **Cloud Metadata APIs**: GCP Compute Engine or AWS EC2.
- **Logging & Notification**: Local/cloud logs and email alerts.

**Task Server Flow**:
1. Evaluate metadata state
2. Trigger updates via cloud APIs
3. Log changes with timestamps and comments

---

## 5. Key Tasks & Logic

### 🔁 Update-ReleaseChannelMetadata
- **Dual-Key Approval**: `desiredVersionA` (SRE) and `desiredVersionB` (Release Manager) must match.
- **Logic**:
  - Compare sheet version to cloud metadata
  - If out-of-date, update server tags and log the action

### 🔄 Update-ServerTagAssignment
- **Fields**: `currentChannel` and `desiredChannel` must match
- **Logic**:
  - Auto-syncs sheet with actual server state
  - Reconciles mismatches and logs all sync events

---

## 6. Security & Governance

- **Dual-Key Model**: Prevents unilateral production changes
- **Role Separation**: SRE manages rollout; Release manages scheduling
- **Rollback Switch**: Immediate cancelation or reversion
- **Audit Trail**: All changes logged in both Sheets and server logs

---

## 7. Performance & Reliability

- **Threading & Backoff**: Reduced rollout time from 15–20 mins to 2–3 mins
- **Error Handling**: Local logs and email alerts
- **Version Sync Protection**: Dual-key + enabled flag
- **Prevented Downtime**: Fast rollback capability

---

## 8. Scale & Deployment

- **Environments**: Used in both staging and production
- **Peak Load**: 1,500+ servers
- **Polling Frequency**: Every 5 minutes
- **Dev Flexibility**: Devs could self-manage metadata in isolated environments

---

## 9. Cloud Provider Abstractions
### GCP:
- GCE metadata tags (e.g., `releaseChannel`, `releaseVersion`)
- OAuth + Sheets API + Cloud Logging

### AWS Equivalent:
- EC2 tags or SSM Parameter Store
- CloudWatch Logs + CloudTrail
- Scheduled Lambda or ECS task

---

## 10. What I’d Improve with GitOps

### Modernization Plan:
- Use Git as the source of truth
- CI/CD to propagate changes via IaC (Terraform/CDK)
- Replace dual-key with PR reviews
- Audit via Git history and CI logs

### Other Improvements:
- Convert scripts to Python or Go
- Serverless polling/updating
- Typed, schema-validated manifests

---

## 11. Takeaways

- Solved critical coordination and release issues
- Enabled safe, fast metadata changes at scale
- Introduced rollback protection and performance boosts
- Designed for evolution—eventually replaced by GitOps tooling
