# System Design Interview Q&A

### Why did you choose Google Sheets over a database or config tool?

We chose Google Sheets because it was easy to use, auditable, and accessible to both technical and non-technical stakeholders. It allowed for quick iteration and visibility without needing to build a UI or manage a database.

### Why PowerShell and scheduled tasks instead of a modern orchestrator?

At the time, we prioritized speed of implementation and familiarity. PowerShell and scheduled tasks were sufficient for our needs and easy to deploy across Windows-based infrastructure. If I were to redesign it today, I’d use a cloud-native orchestrator like GCP Workflows or AWS Step Functions.

### What were the limitations of using Sheets as a source of truth?

Sheets don’t scale well for complex workflows or large datasets. There’s also limited validation and version control. We mitigated this with strict formatting, dual-key approvals, and audit logging, but eventually moved to a GitOps model for better control.

### What happens if the sheet is misconfigured?

We built in validation logic in the scripts to catch common errors, and used email alerts to notify stakeholders of issues. The system was also designed to fail safely—no changes would be applied if validation failed.

### How did you ensure only authorized users could make changes?

We used Google Workspace permissions to restrict access to the sheets. Only SREs and release managers had edit access, and all changes were logged. In a modern setup, I’d use IAM roles and Git-based approvals.

### How did the system scale to 1500+ servers?

We used metadata tagging via `gcloud` to push changes in parallel, and the server-side polling was lightweight. The system scaled well within GCP. For AWS, we could replicate this using EC2 tags and SSM Parameter Store.

### How did you monitor and respond to failures?

We logged all actions locally and to Stackdriver (now Cloud Logging), and sent email alerts on failure. This gave us visibility into what went wrong and where. In AWS, I’d use CloudWatch Logs and SNS for similar functionality.

### How would you extend this system to AWS?

I’d replace:
- Google Sheets → Git + YAML in CodeCommit or GitHub
- gcloud metadata → EC2 Tags or SSM Parameters
- PowerShell scripts → Lambda or Step Functions
- Stackdriver → CloudWatch
- Email alerts → SNS or EventBridge

This would preserve the core logic while aligning with AWS-native tools.

### How did you handle concurrency or race conditions in updates?

We designed the system to be idempotent—each update could be safely retried. Since the metadata updates were atomic and the sheet was the single source of truth, we avoided race conditions by ensuring only one task server wrote changes at a time.

### What were the biggest operational challenges?

The biggest challenge was ensuring reliability in a system built on loosely coupled components like Sheets and scheduled scripts. We addressed this with extensive logging, alerts, and manual override mechanisms.

### How did you test changes to the system?

We had a staging environment that mirrored production. All changes to the sheet or scripts were tested there first. We also used dry-run modes in scripts to simulate changes before applying them.

### What would you do differently if you were starting from scratch?

I’d start with a GitOps approach using version-controlled configs and CI/CD pipelines. I’d also use cloud-native services for orchestration and observability from day one.

### How did you ensure rollback safety?

Each server had a metadata flag that could disable a release. We could roll back by reverting the sheet and re-running the task. In a modern setup, I’d use feature flags or deployment rings for safer rollbacks.

### How did you manage secrets or sensitive data?

The system didn’t handle secrets directly, but if it had, we would have used GCP Secret Manager. In AWS, I’d use Secrets Manager or Parameter Store with encryption.

### How did you handle schema or format changes in the sheet?

We versioned the sheet format and built backward compatibility into the scripts. We also documented expected formats and validated them before applying changes.

### How would you make this system more self-healing?

I’d add health checks and auto-retries for failed updates, and possibly use a workflow engine that supports retries and compensation logic. In AWS, Step Functions would be a good fit.

### How would you support multi-tenant or team-based releases?

I’d partition the metadata by team or service, and use access controls in the sheet or config repo. In a modern setup, I’d use namespaces or scoped IAM roles to isolate environments.

### How would you visualize or audit past releases?

We logged all changes with timestamps and user info. For better visibility, I’d integrate with a dashboard (e.g., Grafana or Looker) or use a Git-based changelog.

### How did you ensure consistency across environments (e.g., staging vs. production)?

We used separate sheets for each environment and enforced a consistent schema. The scripts were environment-aware and validated that metadata changes matched expected formats before applying them.

### How did you handle partial deployments or mid-rollout failures?

The system was designed to be idempotent and retry-safe. If a failure occurred mid-rollout, the task could be re-run without side effects. We also logged per-server status to identify and isolate issues.

### How would you support canary or phased rollouts?

We could tag a subset of servers with a “canary” label and apply changes only to them. In a modern setup, I’d use deployment rings or feature flag platforms like LaunchDarkly or AWS AppConfig.

### How would you integrate this system with CI/CD pipelines?

I’d replace the sheet with a Git-based config repo and trigger updates via CI/CD (e.g., GitHub Actions or AWS CodePipeline). This would allow for automated validation, approvals, and rollbacks.

### How would you handle cross-region consistency or latency?

In GCP, we relied on the global nature of metadata APIs. In AWS, I’d use regional Parameter Stores with replication or a centralized config service with caching and TTLs to reduce latency.

### How would you support audit and compliance requirements?

We logged all changes with timestamps, user info, and before/after states. In a modern system, I’d use Git commit history, signed commits, and integrate with audit tools like AWS CloudTrail or GCP Audit Logs.

### How would you handle schema evolution in metadata or config?

I’d version the schema and use a migration layer in the scripts to handle backward compatibility. In a GitOps setup, I’d use schema validation tools like JSON Schema or OpenAPI.

### How would you make this system more observable?

I’d add metrics for rollout duration, success/failure rates, and per-server status. In AWS, I’d use CloudWatch dashboards; in GCP, I’d use Cloud Monitoring with custom metrics.

### How would you support rollback in a GitOps model?

Rollback would be as simple as reverting a commit and re-running the pipeline. This gives us versioned, auditable, and reproducible rollbacks with minimal risk.

### How would you handle dependencies between services during rollout?

I’d define rollout order in the config and enforce it in the orchestration logic. For more complex dependencies, I’d use a DAG-based workflow engine like Argo Workflows or AWS Step Functions.

