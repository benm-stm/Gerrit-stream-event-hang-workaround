# Gerrit-stream-event-hang-workaround
Gerrit stream event hang workaround

In order to ensure the availability of gerrit stream event (a bug in JGit for versions under 2.12 according to gerrit community)

We have to cron the script according to the activity on the server.

For our case we chose to schedual it every 30 min between 8AM and 9PM.

```
*/30 8-21 * * * cd /home/gerritadm/gerrit_site/streamevent_health_checker && ./streamevent_health_checker.sh
```
You also have to change the conf params according to your environment :)

##Have fun :D
