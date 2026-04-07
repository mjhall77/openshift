# Helpful Openshift Commands

# Enable bash completion - run as root
- To enable Bash completion for the OpenShift CLI (oc), you can generate the completion script directly from the CLI tool and source it into your shell environment. 
```console
oc completion bash > /etc/bash_completion.d/oc_bash_completion
source /etc/bash_completion.d/oc_bash_completion
```
