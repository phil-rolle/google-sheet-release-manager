# System Design FAQs: Categorized Guide

This guide consolidates and organizes common questions and answers from system design interviews about a metadata rollout and upgrade automation system, categorized by key themes for clarity and quick reference.

---

## 1. Core Architecture & Design Decisions

- **Why Google Sheets?**  
  Accessible, auditable, and easy to edit. Served as a simple control plane for non-technical users.

- **Why PowerShell + cron?**  
  Simple to implement, compatible with both Windows and Linux. Ideal for the initial phase.

- **Why not CI/CD from day one?**  
  CI/CD came later. The team first needed a low-friction, safe coordination layer for handoffs between SRE and Release.

- **Concurrency concerns?**  
  Design was idempotent. Only one task server wrote at a time. Race conditions were rare but possible.

- **Dual-key model?**  
  SREs and Release Managers each had an editable column. Updates only triggered when both matched. This enforced joint accountability.

---

## 2. Failure Handling, Rollback & Observability

- **Failure handling?**  
  Logged locally and to cloud (Stackdriver/CloudWatch). Sent email alerts for unrecoverable issues.

- **Rollback mechanism?**  
  Used toggle/flag columns in the sheet. In GitOps: revert the commit.

- **Self-healing behavior?**  
  Not implemented fully. Could be added via retries, compensation logic, and orchestrators like Step Functions.

- **Mid-rollout failure?**  
  All actions were idempotent and could be retried safely. Failures were isolated per server.

- **Observability?**  
  Success/failure counts, rollout duration, and logs were monitored. Would benefit from dashboards (Grafana, Looker, CloudWatch).

---

## 3. Security, Access, and Auditing

- **How were changes authorized?**  
  Google Sheets permissions scoped to SRE or Release team columns. All edits logged.

- **Secrets management?**  
  Vault (GCP Secret Manager). In AWS, would use Secrets Manager.

- **Auditing?**  
  Sheet logs, timestamps, and cloud logs. In AWS, recommend CloudTrail.

- **Git vs IAM approvals?**  
  Git provides traceability. IAM enforces access at runtime. Both are useful.

---

## 4. Scalability & Performance

- **Scale to 1,500+ servers?**  
  Polling frequency, parallelization, and exponential backoff were added to improve sync time from ~20 min → ~2–3 min.

- **How to scale to 10,000+ servers?**  
  Move from polling to event-driven (SNS, Pub/Sub). Shard by region or team. Use config stores like AppConfig or Parameter Store.

- **API rate limits?**  
  Centralized polling avoided per-server API calls. Batching and delay spread mitigated quota issues.

- **Cross-region support?**  
  GCP handled globally. In AWS, use replicated Parameter Stores or TTL-based caching.

---

## 5. GitOps Evolution & Migration

- **Why migrate to GitOps?**  
  Better version control, traceability, CI/CD integration, and scalability.

- **What changed in GitOps model?**  
  YAML/JSON config in Git, PR approvals, automated CI/CD pipelines. Git history replaced sheet auditing.

- **Rollback in GitOps?**  
  Revert the commit. Changes are auditable and easy to roll back via Git.

- **CI/CD integration?**  
  Git-based pipelines (GitHub Actions, CodePipeline) trigger config updates.

---

## 6. Cloud Agnostic & AWS Mapping

- **GCP → AWS Service Equivalents:**  
  - Sheets → Honeycode / S3 + JSON  
  - Metadata → EC2 Tags / SSM Parameters  
  - Stackdriver → CloudWatch  
  - Vault → AWS Secrets Manager  
  - Task Server → Lambda / Step Functions

- **Modern GitOps services in AWS:**  
  - Git: CodeCommit  
  - CD: CodePipeline / ArgoCD  
  - Config store: SSM Parameter Store / AppConfig  
  - Orchestration: Step Functions  
  - Observability: CloudWatch + CloudTrail

---

## 7. System Extension & Improvements

- **Feature flags?**  
  Could be implemented via LaunchDarkly or AWS AppConfig.

- **Dashboards for rollout tracking?**  
  Use CloudWatch Dashboards, Grafana, or GCP Monitoring.

- **Automatic rollback?**  
  Add health check integration and error-based rollback in orchestration logic.

- **Multiple team support?**  
  Use scopes or namespaces in config; enforce separation via IAM or folder structure.

- **UI for non-technical teams?**  
  Build a simple config dashboard backed by Git or DynamoDB, with RBAC controls.

- **Schema evolution?**  
  Validate formats on read; version schemas and provide migration tooling.

- **Dependencies or rollout order?**  
  Use dependency graphs or orchestrate with Argo Workflows / Step Functions.

---

## 8. Testing & Validation

- **Testing strategy?**  
  Used dry-runs, staging environments, and human review of sheets.

- **Validation of config?**  
  Scripts included runtime validation. Errors triggered alerts and halted updates.

- **What would you do differently?**  
  Use typed config, structured schema (e.g., JSON Schema), GitOps, and test automation from day one.

---