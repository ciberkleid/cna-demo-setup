def jobName = "fortune-service-build-and-upload"
def job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()

jobName = "fortune-service-stage-e2e"
job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()

jobName = "fortune-service-prod-tag-release"
job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()

jobName = "greeting-ui-build-and-upload"
job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()

jobName = "greeting-ui-stage-e2e"
job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()

jobName = "greeting-ui-prod-tag-release"
job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 1
job.save()