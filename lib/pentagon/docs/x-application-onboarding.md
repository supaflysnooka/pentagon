# Adding an application to the Kubernetes system

To setup your application for Kubernetes deployment, you need to accomplish the following high level tasks:

1. Decide on a name for your application. Use this everywhere
1. Create a Dockerfile
1. Create an empty ECR repository
1. Add deploy scripts (`scripts` directory)
1. Add bin scripts (`bin` directory)
1. Define your Kubernetes Deployment, Service, and Secret configuration
1. Create a CircleCI build
1. Ship a GitHub release (pushes to -> production namespace)

## Step 1: Name your application

Decide on a name for your application and use it everywhere: e.g. GitHub Repo, ECR Repo, Kubernetes config, etc.

## Step 2: Create a Dockerfile

Make sure to use the EXPOSE command in your Dockerfile to specify what port(s) your application
will be listening on.

## Step 3: Create an empty ECR repository

Create an empty ECR repository under the organization. Then setup permissions:
* Give `nodes.<cluster>.k8s.reactiveops.com` IAM role R/O permissions
* Give `circleci` IAM user R/W permissions
* Give ReactiveOps team R/O permissions

## Step 4: Define your Kubernetes Deployment, Service, and Secret configuration

1. Copy the `kubernetes-templates` directory to the top level path of your application as `deploy`.
2. Rename the files, replacing 'example-app' with the name of your application (see step 1)
3. Find-replace 'example-app' with your application name in both files.
4. Update Service file with port(s) that your Docker application will expose (from Step 2).
5. Configure a Secret if necessary. If your application requires credentials that are NOT stored in GitHub, then you will need to create a Secret.  See example-app.secret.yml for reference. This file should be uploaded to S3 (with KMS) to com.reactiveops.kubernetes-secrets. If you don't need a Secret, delete the secret file.
6. Update Deployment file
  * Specify the port(s) your container will be listening on (from step 2)
  * Configure liveness/readiness probes with a port/URL that will return 200 if app working correctly
  * Specify any required environment variables your application needs (e.g. database URL)
  * Specify any required secret values you need. Can be available via filesystem or environment variable

## Step 7: Create a CircleCI build
1. Create a CircleCI build for your repository
2. Setup environment variables in CircleCI UI
  * KUBECONFIG_DATA=base64(kubeconfig)
  * AWS_ACCESS_KEY_ID=
  * AWS_SECRET_ACCESS_KEY=
  * AWS_DEFAULT_REGION=
3. Copy circle.yml from `<SOMEWHERE>` to the top-level of your application
4. Find-replace 'example_app' in circle.yml with your application name.

## Step 9: Ship to production via GitHub Release
Todo: Doc this
