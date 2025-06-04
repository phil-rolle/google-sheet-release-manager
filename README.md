# Google Sheets Release Management System

This repository documents a legacy system designed to manage software release metadata for cloud-based infrastructure across multiple environments (staging, production). It includes metadata-driven upgrade logic, dual-key approval, rollback support, and a transition path to GitOps.

## 🔧 Overview

Originally built using PowerShell, scheduled tasks, and Google Sheets integration, the system:

- Automatically mapped and enforced release channels via cloud metadata.
- Used a dual-key model to control software rollout (SRE + Release Manager).
- Logged all updates and changes for auditing and rollback.
- Scaled to over 1500 servers with improvements like threading and backoff logic.

## 🧩 Key Components

- `Task Server`: Orchestrates metadata updates and enforces policy.
- `Server-Side Recurring Task`: Auto-updates services based on metadata tags.
- `ServerTagAssignment`: Google Sheet serving as live source of truth and audit trail.
- `ReleaseSheet`: Controlled dual-key release version assignment.

## ☁️ Cloud Support

- **GCP**: Used Stackdriver for logging, metadata tagging via gcloud.
- **AWS (modernized path)**: GitOps replacement could leverage:
  - SSM Parameter Store / EC2 Tags
  - CloudWatch Logs & Events
  - CodeDeploy, Lambda, or Systems Manager Automation for rollouts

## 📈 Scale & Impact

- **Managed servers**: 1500+ across staging and production
- **Runtime**: ~4 years in production with incremental improvements
- **Performance**: Metadata rollout time improved from ~20 mins to <3 mins

## 🔐 Security & Safety

- Dual-approval ("dual-key") enforcement for updates
- Read-only vs write-control split across teams
- Email alerts on failure and local/cloud logging
- Rollback and enable/disable flags for release safety

## 🚀 Transition to GitOps

The system was eventually replaced by a GitOps model that leverages version-controlled infrastructure definitions and CI/CD pipelines for improved auditability, reproducibility, and security.

---
