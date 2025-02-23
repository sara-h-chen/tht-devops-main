# Explain decisions made during the implmentation of the test
- `supporting-infrastructure` workspace contains all the resources that do not "churn". only microservices kept in their own unique workspaces, for independent deployments.
- not using hcp var set as details in `supporting-infrastructure` is shared across all workspaces, since it contains the underpinning infrastructure anyway
- Taking out the account details for the sake of this assessment, because I don't really feel comfortable sharing it since it's a private account; in real life situation, would be using profiles instead to separate creds/accounts/environments
- 

# What is missing 


# What could be improved 
- only able to work on some of the hygiene on the code, not anything within the modules.
- The assessment does not really give us an idea for how much load we're expecting on our db, so PROVISIONED throughput was chosen as a default for DynamoDB. If running in prod, better to monitor to get an idea for how much is required, then optimize RCU/WCU based on that. If multiple tables and one already consumes all the Free Tier quota, then could be better to switch to ON-DEMAND and autoscale from there, based on requirements. 

# What I would do if this was in a production environment and I had more time