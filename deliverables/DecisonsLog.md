# Explain decisions made during the implmentation of the test
- refactored the `ecr` repository to contain all supporting infrastructure. `supporting-infrastructure` workspace contains all the resources that do not "churn". only microservices kept in their own unique workspaces, for independent deployments.
- not using HCP variable set. Details in `supporting-infrastructure` is shared across all workspaces, since it contains the underpinning infrastructure anyway.
- Taking out the account details for the sake of this assessment, because I don't really feel comfortable sharing it since it's a private account; in real life situation, would be using profiles instead to separate creds/accounts/environments
- finding it difficult to adhere to the free tier requirement. NAT Gateway, as an example, is not free tier. I could try to build NAT instances using the AMIs already available, but there is a tradeoff between resiliency/security and cost. Need to think about SSH access, exposed attack surface, scalability.
- Same as above, interface endpoints are also not AWS free tier. But it is understandable to want to keep traffic within the VPC.
- removed the unneeded ingress of port 32768 from the security group. Associated with Trojan. But also completely unnecessary, and in general, exposing higher ports should be avoided.
- disabled container insights for cost purposes.
- set cpu as 1 to have 2 containers on same host.
- At least 2 desired_count on ecs service for HA, and updating the service.
- force_new_deployment so blue/green can be managed via image tags instead of a new task definition each time, reducing churn on infrastructure code.


# What is missing 


# What could be improved 
- only able to work on some of the hygiene on the code, not anything within the modules. Some of the code needs cleaning up as this can cause bugs, e.g. `order_api_repository_arn` and `order_processor_repository_ARN`, which should be caught during a PR.

# What I would do if this was in a production environment and I had more time
- The assessment does not really give us an idea for how much load we're expecting on our db, so PROVISIONED throughput was chosen as a default for DynamoDB. If running in prod, better to monitor to get an idea for how much is required, then optimize RCU/WCU based on that. If multiple tables and one already consumes all the Free Tier quota, then could be better to switch to ON-DEMAND and autoscale from there, based on requirements.
- Usage of HTTP. Understandable that this is only for the sake of this assessment, and it's not production grade, but in real world, HTTPS. Can leverage ACM + ALB if not willing to manage own SSL certs.
- Autoscaling group should be finetuned to load. Binpacking of tasks, and number of eni's are a consideration when considering these numbers.