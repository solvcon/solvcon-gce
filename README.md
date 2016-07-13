# SOLVCON in Google Compute Engine

This repository sets up the bash environment for running [SOLVCON](http://solvcon.net/) in [Google Compute Engine (GCE)](https://cloud.google.com/compute/).  It provides tools for creating, provisioning, and accessing virtual-machine (VM) intances in GCE.  Clone the repository to install:

```bash
$ git clone http://github.com/solvcon/solvcon-gce ~/opt/gce
```

To enable it, run `source ~/opt/gce/etc/gcerc`.  Append the following line in ``.bashrc`` to enable it automatically:

```bash
if [ -f source ~/opt/gce/etc/gcerc ]; then source source ~/opt/gce/etc/gcerc; fi
```

## Set up Google Cloud Platform SDK

`solvcon-gce` are essentially wrappers to [Google Cloud Platform (GCP) SDK](https://cloud.google.com/sdk/) command-line tool.  `solvcon-gce` will try to load the SDK from `~/opt/google-cloud-sdk`.  If it's not there and not in `PATH`, you can install it (to the assumed path) using the following script:

```bash
~/opt/gce/bin/admin/install-google-cloud-sdk.sh
```

## Setup a Project

Before using `solvcon-gce` scripts, you need to sign up the GCE service and create a [project](https://cloud.google.com/compute/docs/projects), and initialize the cloud SDK by running `gcloud init`.  See https://cloud.google.com/sdk/docs/.  After a project is created, you also need to do the following setup in the [Google Compute Platform console](https://console.cloud.google.com):

1. [Enable "Compute Engine API"](https://console.cloud.google.com/apis/).
2. [Add a project-wide SSH key](https://console.cloud.google.com/compute/metadata/sshKeys).  Accounts logged into the GCE instance using a project-side SSH key can run `sudo` in the instance.

(GCP offers a 60-day free-trial program, including $300 credits: https://cloud.google.com/free-trial/ .)

## Cache Conda Packages

To save time from downloading conda packages from the Anaconda server, `solvcon-gce` needs to cache them in a [Google Cloud Storage](https://cloud.google.com/storage) bucket.  Before the cache is in-place, Anaconda won't be available in the instance.  `gstart` would complain like:

```
bash: /var/lib/conda/packages//Miniconda3-latest-Linux-x86_64.sh: No such file or directory
<your-home-directory>/opt/gce/bin/admin/install-conda.sh: line 12: conda: command not found
bash: /var/lib/conda/packages//Miniconda2-latest-Linux-x86_64.sh: No such file or directory
<your-home-directory>/opt/gce/bin/admin/install-conda.sh: line 18: conda: command not found
```

To populate the cache, run:

```bash
$ gce-prepare-conda-packages <bucket_name>
```

Before executing the above command, you need to create the bucket using [Google Cloud Console](https://console.cloud.google.com).  Please note that the bucket should be created in the same zone that the `solvcon-gce` tools assume, otherwise additional charges may incur.  For now it is `asia-east1-c`. `<bucket_name>` looks like `gs://<bucket_name_you_tell_google_cloud>/`.

This step could be optional, but so far we do not implement the code which does not to use cache when creating an instance. Please make your own bucket cache for now.

## Use an Instance

Run `gcloud config set project PROJECT_ID` to tell `gcloud` your project ID, which was assigned when the project was created.  Then run `gstart <instance_name> <bucket_name>` to create a GCE VM instance. `<bucket_name>` looks like `gs://<bucket_name_you_tell_google_cloud>/`. It usually takes 2 minutes.  `gstart` also runs the provisioning scripts.

After `gstart` finishes, run `gssh <instance_name>` to connect to the instance.

Before conda packages are cached in the project, execution of `gstart` will show error messages, but still work.  See the above section for making the cache work.

To remove the instance (and stops being charged), run `gce-delete-instance <instance_name>`.

## Trouble Shooting

### SSH Connection Refused

#### Unlock Keyphrase

If your SSH connectioned is refused after issuing `gstart`, please make sure you have unlocked your key phrase of the project-wide SSH key.

#### Project SSH Key Comment

The comment of your project SSH key will be parsed by Google Cloud Platform. It will use the comment to generate the username. Make sure the generated username is what you expect if you do not use a typical SSH key comment, which looks like `username@hostname`.
