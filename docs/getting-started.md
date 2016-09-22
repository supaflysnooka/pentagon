# Getting Started

```
$ mkproject delme
...
Setting project for delme to /Users/justin/Documents/work/reactive/workspace/projects/delme
$ pip install -e ../kubernetes-demo/pentagon # Using a local copy of this repo
$ pentagon-startproject -n foo
$ tree foo
foo
├── README.md
├── ansible-requirements.yml
├── config
│   ├── local
│   │   ├── ansible.cfg
│   │   ├── ssh_config
│   │   └── vars -> ../private/vars
│   ├── private
│   │   └── vars
│   └── requirements.txt
├── default
│   ├── account
│   │   └── vars.sh
│   ├── clusters
│   │   ├── production
│   │   │   ├── cluster-config
│   │   │   ├── kubernetes
│   │   │   │   └── namespaces.yml
│   │   │   ├── resources
│   │   │   └── vars.sh
│   │   └── working
│   │       ├── cluster-config
│   │       ├── kubernetes
│   │       │   └── namespaces.yml
│   │       ├── resources
│   │       └── vars.sh
│   ├── resources
│   │   ├── all.yml
│   │   ├── env.yml
│   │   ├── environment.yml
│   │   ├── first_run.yml
│   │   └── vpn
│   │       └── stack.yml
│   └── vpc
│       ├── Makefile
│       ├── main.tf
│       ├── terraform.tfplan
│       ├── terraform.tfvars
│       └── variables.tf
├── docs
│   └── readme.md
├── plugins
│   ├── filter_plugins
│   │   └── flatten.py
│   └── inventory
│       ├── base
│       ├── ec2.ini
│       └── ec2.py
└── roles

22 directories, 27 files
```