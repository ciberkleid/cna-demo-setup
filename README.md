# cna-demo
Easy to set up cloud-native architecture demo for PCF. Consists of two apps, greeting-ui and fortune-service, and leverages all three services in Spring Cloud Services as well as PCF Metrics distributed tracing.

To set up and run:

1. Clone the setup repo and the two project repos into the same directory:
```
mkdir cna-demo
cd cna-demo
git clone https://github.com/ciberkleid/cna-demo-setup.git
git clone https://github.com/ciberkleid/fortune-service.git
git clone https://github.com/ciberkleid/greeting-ui.git
```

2. Use the cf CLI to target the space to which you wish to deploy

3. From the cna-demo-setup directory, run the script named 00_setup.sh:
```
cd cna-demo-setup
. ./00_setup.sh
```

4. Answer the prompts from the script:

* Provide the git address to back the Config Server
    * The default value is https://github.com/ciberkleid/app-config. You can clone this repo and enter the new value.
* Choose whether or not to leverage container-to-container networking
    * If 'Y', make sure spring.cloud.services.registrationMethod is set to direct and not route in application.yml in the app-config repo. 
    * Also, if 'Y', make sure you have the cf CLI 'network-policy-plugin' installed (see https://docs.pivotal.io/pivotalcf/1-11/devguide/deploy-apps/cf-networking.html)
* Choose whether or not to build the apps
    * If 'Y', the script will run "mvn clean install" for both fortune-service and greeting-ui

The script will create the necessary services and deploy the two applications to the targeted space. It will also set the TRUST_CERTS environment variable and, optionally, enable access between the apps for C2C networking.

5. [Optional] To delete the apps, routes, and services created by the 00_setup.sh script, run the script named 01_cleanup.sh. Answer the prompts to control whether or not both apps and services are deleted.
```
. ./01_cleanup.sh
```
