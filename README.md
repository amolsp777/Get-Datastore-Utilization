Get Datastore utilization & summary report v2 | PowerCLI

Summary 
As a VMware Admin or System Admin, it is required to keep monitor your environment. We have all the monitoring parameters configured in our VMWare environment but still, we should have some utilization report handy.  
Here I will cover the VMware Datastore utilization & summary report which I had created a long time ago, but this is the latest version with some additional Dashboard formatting. 
I used Dashimo v0.0.22  module to generate a very nice HTML dashboard report. 
I have been asked to present the Datastore count & utilization to I started googling my requirement so I have found many good codes that will give the LUN usage output. I started using the reference and created own custom reporting format. 
Very good support by LucD

This PowerCLI script will help you to get the report of datastores along with free space Percentage. 
HTML report will help you to quickly address:
