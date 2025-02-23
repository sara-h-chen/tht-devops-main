# Explain decisions made during the implmentation of the test
- refactored the `ecr` repository to contain all supporting infrastructure. `supporting-infrastructure` workspace contains all the resources that do not "churn". only microservices kept in their own unique workspaces, for independent deployments.
- not using HCP variable set. Details in `supporting-infrastructure` is shared across all workspaces, since it contains the underpinning infrastructure anyway.
- refactored code to take out the account details for the sake of this assessment; I considered this sensitive information, much like you would hide sensitive information in real life. In real life situation/prod, would be using profiles instead to separate creds/accounts/environments.
- difficult to adhere to the free tier requirement in the assignment. NAT Gateway, as an example, is not free tier. I could try to build NAT instances using the AMIs already available, but there is a tradeoff between resiliency/security and cost. Need to think about SSH access, exposed attack surface, scalability. Just proceeded without fulfilling this requirement, due to time taken to write and refactor.
- Same as above, interface endpoints are also not AWS free tier. But it is understandable to want to keep traffic within the VPC, so just proceeded without changing code.
- removed the unneeded ingress of port 32768 from the security group, port is associated with Trojan, but also completely unnecessary. in general, exposing higher ports should be avoided.
- disabled container insights for cost purposes.
- At least 2 desired_count on ecs service and distinctInstance for HA, and for rolling out changes.
- force_new_deployment so blue/green can be managed via image tags instead of a new task definition each time, reducing "churn" on infrastructure code.
- availability_zone_rebalancing for scalability
- use awsvpc as network setting as it avoids us having to deal with port clashes, especially if host sharing, and if services were to come up/down. Let AWS deal with the NICs. moved instance target type to ip to support this, as each container can now receive its own ip.
- had to change repo from immutable to mutable, because I was building from an apple m3 chip. Also needed to remove provenance attestations.

# What is missing 
- deployment maximum healthy percent should be set, along with the minimum to align with deployment strategy.
- running containers as a user/pid, to prevent privilege escalation from within container.

# What could be improved 
- only able to improve some of the hygiene on the code, not anything within the modules. Some of the code needs cleaning up as this can cause bugs, e.g. `order_api_repository_arn` and `order_processor_repository_ARN`, which should be caught during a PR.
- deletion of resources is not very clean, e.g. unable to destroy stack because the ecs cluster will try to delete before the service does. Dependencies between resources need to be figured out, and these dependencies to be given an explicit depends_on to prevent fragility in the code.

# What I would do if this was in a production environment and I had more time
- The assessment does not really give us an idea for how much load we're expecting on our db, so PROVISIONED throughput was chosen as a default for DynamoDB. If running in prod, better to monitor to get an idea for how much is required, then optimize RCU/WCU based on that. If multiple tables and one already consumes all the Free Tier quota, then could be better to switch to ON-DEMAND and autoscale from there, based on requirements.
- Usage of HTTP. Understandable that this is only for the sake of this assessment, and it's not production grade, but in real world, HTTPS. Can leverage ACM + ALB if not willing to manage own SSL certs.
- Autoscaling group should be finetuned to load. Binpacking of tasks.
- current container has 20 layers, and is over 200MB each. make containers leaner, with fewer layers, to improve performance, especially since this is such a simple app.