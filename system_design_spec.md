# System Design Document: Task Server & Metadata Rollout Automation

## Overview

This document outlines the design, implementation, and operational impact of a PowerShell-based Task Server system developed to manage server release metadata in a multi-environment cloud infrastructure.

The system ensured safe and reliable propagation of software release tags across >1500 cloud servers via metadata tagging and Google Sheets as the source of truth.

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Architecture Overview](#architecture-overview)
3. [Core Components](#core-components)
4. [Data Flow](#data-flow)
5. [Metadata Control Logic](#metadata-control-logic)
6. [Dual-Key Approval Mechanism](#dual-key-approval-mechanism)
7. [Error Handling & Resilience](#error-handling--resilience)
8. [Security Considerations](#security-considerations)
9. [Scaling & Performance Improvements](#scaling--performance-improvements)
10. [GitOps Migration Path](#gitops-migration-path)
11. [Future Considerations](#future-considerations)

---

## Problem Statement

The cloud infrastructure team needed a centralized, low-risk way to govern and roll out software updates across large numbers of ephemeral and persistent cloud servers. Manual updates and uncontrolled metadata changes led to inconsistencies, production risks, and unreliable release tracking.

---

## Architecture Overview

- **Language:** PowerShell
- **Scheduling:** OS-level cron jobs (Windows Task Scheduler or Linux cron)
- **Source of Truth:** Google Sheets (with two key sheets: `ServerTagAssignment` and `ReleaseSheet`)
- **Communication:** Google Sheets API, Cloud Metadata API (GCP) or AWS EC2 Tags
- **Logging:** Local log files + Cloud Logging
- **Notification:** Email alerts for failures or rollback triggers

---

## Core Components

### 1. Task Server

- Executes scheduled PowerShell tasks every 5 minutes.
- Polls and reconciles state between:
  - Server metadata tags
  - Release control sheet (`ReleaseSheet`)
  - Server-channel mapping sheet (`ServerTagAssignment`)

### 2. Google Sheets Integration

- Pulls full state from `ReleaseSheet` and `ServerTagAssignment`
- Applies approval logic via dual-key system
- Uses batch operations to minimize API quota consumption

---

## Data Flow

- To be expanded on and diagrammed

---

## Metadata Control Logic

- Fetch all cloud assets
- For each server:
  - If it has metadata but is missing from `ServerTagAssignment`, add it.
  - If sheet metadata mismatches server's, reconcile:
    - Update sheet OR
    - Update server tags (depending on logic)
  - If `desiredVersionA == desiredVersionB && enabled == TRUE`, then update `releaseVersion`
  - If `rollback == TRUE`, revert to prior version

---

## Dual-Key Approval Mechanism

- **desiredVersionA**: Editable by SRE
- **desiredVersionB**: Editable by Release Manager
- Changes only take effect when **both versions match**
- Prevents unilateral rollouts and enforces accountability

---

## Error Handling & Resilience

- Threaded updates to avoid API limits
- Exponential backoff for retries
- Local + cloud logs
- Email alerts for:
  - API failures
  - Sheet sync mismatches
  - Unauthorized edits
- Rollback support via explicit column toggle (`rollback == TRUE`)

---

## Security Considerations

- Sheets access controlled via Google Workspace roles
- Metadata API credentials scoped and rotated
- Server updates gated by multi-party approvals
- Audit trail via sheet comments + cloud logs

---

## Scaling & Performance Improvements

- Original sequential update logic improved with parallelism
- Full metadata rollout time dropped from ~20 minutes to ~2-3 minutes
- Decreased Google API usage by shifting from per-server polling to centralized polling

---

## GitOps Migration Path

Eventually replaced with GitOps workflow:
- Desired state stored in Git (Helm charts / Terraform modules)
- Reconciliation handled by FluxCD/ArgoCD
- Tagging replaced by parameter store or label injection (AWS SSM / GCP labels)
- Branch protection enforced dual-key approvals
- Rollbacks became Git reversions

---

## Future Considerations

- Abstract metadata storage to a DB or Parameter Store
- Move sheet logic to custom UI for stronger validation
- Extend to ephemeral/test environments with dynamic opt-in
- Formalize release pipeline via GitHub Actions or CI/CD tooling

---


