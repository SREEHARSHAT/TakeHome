Security
For this hub, I want security to feel boring and predictable: workloads only get what they need, everything is encrypted by default, and we turn on a few AWS services that give us good signal without drowning the team.
IAM roles for EKS/ECS workloads
On the compute side, I don’t rely on a big, shared node role. For EKS I’d use IRSA, and for ECS I’d use task roles, so each service gets its own IAM role with a tight set of permissions.
I’d split things roughly like this:
•	Control plane role
•	Used by the 3GPP control plane and core APIs.
•	Can read/write only the DynamoDB tables that hold session/subscriber state.
•	Can write connection/audit logs to a specific S3 bucket or Firehose stream.
•	Can push metrics/logs to CloudWatch or a Datadog agent.
•	Ingestion / data processing role
•	Used by services pulling data from ground stations/other hubs.
•	Can read from “ingest” buckets/streams and write to “processed” or analytics buckets.
•	Has access only to the queues/topics it owns.
•	Telemetry / agent role
•	Used by Fluent Bit / Fluentd / OpenTelemetry collectors.
•	Can write logs to CloudWatch Logs or Firehose.
•	Can send metrics/traces to Datadog, with API keys coming from Secrets Manager/SSM.
What I don’t give to app roles:
•	No iam:*, organizations:*, or “assume any role you want” via broad sts:AssumeRole.
•	No infra admin rights like ec2:*, eks:*, ecs:*, cloudformation:*, route53:*.
•	No account wide s3:* or dynamodb:*, and no wildcard access to all streams/queues.
•	No KMS admin; at most they get encrypt/decrypt on a key that’s clearly scoped to that app.
If one service gets compromised, the damage should be limited to that service’s own data, not the entire account.
First 3 AWS security services
If I’m bringing this hub up from scratch, the first three services I’d turn on are:
1.	AWS KMS
•	Everything that can be encrypted (S3, DynamoDB, EBS, EKS secrets, future RDS) uses KMS.
•	I’d create a small set of CMKs per environment/data type and keep key policies tight.
•	Config/Security Hub then enforce that unencrypted resources are treated as misconfigurations.
2.	Amazon GuardDuty
•	GuardDuty watches CloudTrail, VPC Flow Logs, and DNS logs for weird behavior.
•	It’s a low effort way to catch things like odd API usage from workload roles, strange egress patterns, or credential abuse early.
3.	AWS Security Hub
•	Security Hub pulls findings from GuardDuty, Access Analyzer, Inspector, Config, etc., into one place.
•	I’d enable the relevant standards (e.g., CIS) and treat new high/critical findings like incidents.
•	From there, we hook it into ticketing/on call so issues don’t just sit in a console.
That gives us strong encryption, ongoing threat detection, and a clear view of where we’re drifting.
________________________________________
Observability
For observability, I want a small set of strong signals and a stack that’s familiar: Prometheus in the cluster, Datadog as the main UI, and CloudWatch as the durable backbone.
Top 3 metrics for container workloads
For the EKS/ECS workloads in this hub, these are the three metrics I’d care about most:
1.	End to end latency
•	P50/P95/P99 latency for the key control plane/data plane flows (attach/detach, messaging, etc.).
•	This is what customers feel, so it becomes the main SLO driver.
2.	Error rate
•	HTTP/gRPC errors plus domain specific error counters from the 3GPP components.
•	Always broken down by service and AZ so we can quickly tell if it’s a bad rollout, an AZ issue, or upstream.
3.	Saturation and backlog
•	CPU/memory usage, throttling, pod restarts, and queue/topic lag.
•	These are what we use for autoscaling and to see whether the hub is keeping up with bursts or falling behind.
If latency, errors, and saturation all look good, the platform is usually in a healthy place.
Logging, monitoring, and alerting stack
Here’s the stack I’d actually run:
•	Metrics
•	Prometheus in cluster to scrape Kubernetes/ECS and app metrics.
•	Datadog as the main view (either direct agent scrape or Prometheus federation) with SLOs, dashboards, and APM.
•	Logs
•	Apps log structured JSON to stdout.
•	Fluent Bit / Fluentd  send logs to CloudWatch Logs first.
•	Important log groups (like connection logs) also go to S3 via Firehose for long term retention, and optionally into Datadog Logs for better search and correlation.
•	Tracing
•	OpenTelemetry collectors export traces to Datadog APM, with higher sampling on critical user flows and lower sampling on background jobs.
•	Alerting
•	SLO based alerts in Datadog for latency, error rate, and saturation/backlog.
•	Platform alerts (cluster health, capacity, TGW/NAT status) out of CloudWatch/Prometheus.
•	Security alerts from GuardDuty and Security Hub into the same on call tooling, with separate runbooks from pure reliability issues.
This keeps the setup realistic to operate, lines up with the tools Skylo already calls out, and can be reused for additional hubs without reinventing the stack every time.
