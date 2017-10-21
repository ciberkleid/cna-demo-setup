# CNA Demo Setup Pipeline

Concourse Pipeline intended for demonstration of end-to-end application stack delivery on Pivotal Cloud Foundry.

Implements a generic pipeline which consists of a flow as; 
```
Unit Tests -> Application Build Process -> Cloud Foundry Services creation -> Cloud Foundry App Deployment -> Environment specific tasks -> Delivery Smoke tests
```

# Pre-Requisites

- [Concourse](https://concourse.ci/installing.html)
- [Concourse CLI: fly](https://github.com/concourse/fly)
- [Access to Cloud Foundry Endpoint](https://run.pivotal.io)
- Google Cloud Credentials
- Google Cloud Storage Bucket (state store)

# Getting Started

```
git clone https://github.com/ciberkleid/cna-demo-setup
cd cna-demo-setup
```

Create an application specification file similar to `application-spec.json` and upload it to google storage cloud bucket. `stack-file` variable must point to the application-spec template uploaded.

Create the pipeline by executing;

```
pipeline-name=stack01
concourse-target=local
fly -t $concourse-target set-pipeline -p $pipeline_name -c pipeline/ci/pipeline.yml  -l pipeline/ci/credentials.yml -v stack-file=environments/stack01.json
```



# Stack removal

Execute `destroy-environment` task in order to remove all the application and services.


