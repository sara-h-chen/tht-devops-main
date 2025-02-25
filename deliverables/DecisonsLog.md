# Explain decisions made during the implmentation of the test
### Part 1
- Refactored the `ecr` repository to contain all supporting infrastructure. The `supporting-infrastructure` workspace contains all the resources that do not "churn". Only microservices kept in their own unique workspaces, for independent deployments.
- I did not use HCP variable sets to share variables across workspaces. The outputs from `supporting-infrastructure` is shared across all workspaces, since it contains the underpinning infrastructure anyway. However, if this was not the case, then I would have used HCP variable sets to explicitly share to specific workspaces.
- Refactored the code to take out the account details for the sake of this assessment; I considered this sensitive information, much like you would hide sensitive information in real life. In real life situation/prod, would be using profiles instead to separate creds/accounts/environments, so coding up things like account details would not have been necessary.
- It was difficult to adhere to the free tier requirement in the assignment. NAT Gateway, as an example, is not free tier. I could try to build NAT instances using the AMIs already available, but there is a tradeoff between resiliency/security and cost, e.g. with a NAT instance, you would need to think about SSH access, exposed attack surface, scalability. Thus, I just proceeded without fulfilling this requirement, due to the sheer amount of time it would have taken to refactor and write the code for once I realized what needed to be done. As above, interface endpoints are also not AWS free tier. But it is understandable to want to keep traffic within the VPC, so I just proceeded without changing code, and abandoned the idea of trying to port all the services to free tier, and focus on lowering costs instead.
- Removed the unneeded ingress of port 32768 from the security group. This port, particulary, is associated with Trojan. In general, exposing higher ports should be avoided.
- Disabled Container Insights for cost purposes.
- `force_new_deployment` so blue/green can be managed via image tags instead of a new task definition each time, reducing "churn" on infrastructure code. Chose this approach over updating the task definition as, equally, you can "version control" with image tags, but reduces bottlenecks on Terraform pipelines.
- `availability_zone_rebalancing` for scalability.
- Unfortunately, had to change ECR repo from `immutable` to `mutable`, because I was building from an Apple M3 chip. Also needed to remove provenance attestations from Docker builds.
- Deliver AWS Logs to Log Group with region prefix, in case this is being sent to central location, e.g. Logging account for security scanning by something like Wiz or ArcticWolf. Added this to the IAM permissions.
- `orders` Dynamo table has `range_key` of `created_at` so that orders can be sorted by timestamp, if a customer wants to get their latest order within the last time period.

### Part 2


# What is missing
### Part 1
- A deployment maximum healthy percent should be set, along with the minimum which aligns with deployment strategy, e.g. allowing 200% if attempting to reduce downtime and willing to pay a bit extra, or running 50% and risk downtime (since we have 2 `desired_count`).
- Set containers to run as a user/pid, to prevent privilege escalation from within container to breakout onto host.
- Multi-region capabilities. The code is currently very geared towards a single deployment.
- Using `bridge` mode for dynamic port mapping, and binpacking, but this could be an issue for service discovery and security groups. In production systems, would use `awsvpc`.
- Reduced the `maximumScalingStepSize` to reduce the risk of scaling out of control. Additionally, lowered the `targetCapacity` to reduce the risk of downtime should the autoscaling group require time to scale out. 

# What could be improved
### Part 1
- Would have loved to have refactored and moved all the VPC + networking into the `supporting-infrastructure` folder/workspace to prevent the networking layer from being affected by "churn", should the cluster need to be rebuilt.
- Given the time, I was only able to improve some of the hygiene on the code, not anything within the modules. Some of the code needs cleaning up as this can cause bugs, e.g. `order_api_repository_arn` but `order_processor_repository_ARN`, which should be caught during a PR.
- The deletion of resources is not very clean, e.g. unable to destroy stack because the ecs cluster will try to delete before the service does. Dependencies between resources need to be figured out, and these dependencies to be given an explicit depends_on to prevent fragility in the code.
- The `environment` variable that currently holds the value of `devopstht` is not very reflective of an actual environment. The configuration should be parameterized, allowing the variables to be broken out into `dev`, `uat` and `prod` to reflect the values of each, since each environment is likely to be configured slightly differently.

### Part 2


# What I would do if this was in a production environment and I had more time
### Part 1
- The assessment does not really give us an idea for how much load we're expecting on our db, so `PROVISIONED` throughput was chosen as a default for DynamoDB. If running in prod, it would be better to monitor to get an idea for how much is required, then optimize RCU/WCU based on that. For example, if we have multiple tables in our environment and one already consumes all the Free Tier quota, then it could be more cost-effective to switch to `ON-DEMAND` and autoscale from there, based on load requirements.
- Usage of HTTP. Understandable that this is only for the sake of this assessment, and this is not production grade, but in real world, this should almost definitely be HTTPS. Especially since we can leverage ACM + ALB if not willing to manage own SSL certs; we have absolutely 0 reason not to.
- The Autoscaling group should be finetuned to the workload, i.e. desired capacity should allow for some level of binpacking of tasks. Instance family type should also be chosen based on workload.
- The current container for `order-api` has 20 layers, and is over 70 MB, for this simple app. If this was prod, we should be making the containers leaner, with fewer layers, to improve performance and reduce attack surface.
- Placement constraints when running more instances, for HA purposes.
- If running larger workloads on a bigger instance, could try using `awsvpc` and VPC trunking instead, allowing for better binpacking of containers into a host. This avoids us having to deal with port clashes, especially if host sharing between multiple containers, and if containers were to come up/down, as we can now leave AWS to deal with the NICs. This will change the target type on the ALB from `instance` to `ip` to support this, as each container can now receive its own ip.
- At least 2 `desired_count` on the ECS service for High Availability (HA), and for rolling out changes.
- I would have loved to have written test cases for the Python code running the apps, and included it as part of a CI/CD pipeline, along with linters. I would have also included instructions on how to run these manually in `Instructions.md`.

### Part 2
