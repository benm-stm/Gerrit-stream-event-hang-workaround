# Gerrit-stream-event-hang-workaround
Gerrit stream event hang workaround

In order to ensure the availability of gerrit stream event (a bug in JGit for versions under 2.12 according to gerrit community)

We have to cron the script according to the activity on the server.

For our case we chose to schedual it every 30 min between 8AM and 9PM.

```
*/30 8-21 * * * cd /home/gerritadm/gerrit_site/streamevent_health_checker && ./streamevent_health_checker.sh
```
You also have to change the conf params according to your environment :)

- 1st approach: based on log files (not very reliable (added here just to keep trace of the investigations which i've done))

- 2nd approach: based on changes on an existing test commit (reliable)

=>here you have to create a new gerrit project and add its id to the commit-workround script (the script will disable and enable the concerned project to trig a new event)

Either way you use the first or the second approach is up to you

##Have fun :D
