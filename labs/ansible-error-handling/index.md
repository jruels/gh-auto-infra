# Ansible Error Handling
## Scenario

We have to set up automation to pull down a data file, from a notoriously unreliable third-party system, for integration purposes. Create a playbook that attempts to download https://bit.ly/3dtJtR7 and save it as `transaction_list` to `localhost`. 

The playbook should gracefully handle the site being down by outputting the message "Site appears to be down. Try again later." to stdout. If the task succeeds, the playbook should write "File downloaded." to stdout. Whether the playbook errors or not, it should always output "Attempt completed." to stdout.

## Error Handling - Introduction

In this lab, we will explore how to handle errors that may occur while running Ansible playbooks. Specifically, we will focus on how to handle errors related to Windows modules.

## Step 1: Create the report.yml Playbook

### Create playbook

#### Prerequisites

On the Ansible Control Node:

1. If you havent already done so, clone the gh-auto-infra repo.
2. Click `Pull` to get the latest updates from the repository.

Edit report.yml in the vi editor:

1. Go to the ansible-error-handling folder
   ```bash
   cd gh-auto-infra/labs/ansible-error-handling
   ```
2. create report.yml
   ```bash
   vi report.yml
   ```
1. Enter the name and content details below:

First, we'll specify our **host** and **tasks** (**name**, and **debug** message):

```yaml
---
- hosts: localhost
  tasks:
    - name: download transaction_list
      get_url:
        url: https://bit.ly/3dtJtR7
        dest: /home/ansible/gh-auto-infra/labs/ansible-error-handling/transaction_list
    - debug: msg="File downloaded"
```

#### Add connection failure logic

We need to reconfigure a bit here, adding a **block** keyword and a **rescue**, in case the URL we're reaching out to is down:

```yaml
---
- hosts: localhost
  tasks:
    - name: download transaction_list
      block:
        - get_url:
            url: https://bit.ly/3dtJtR7
            dest: /home/gh-auto-infra/labs/ansible-error-handling/transaction_list
        - debug: msg="File downloaded"
      rescue:
        - debug: msg="Site appears to be down.  Try again later."
```

#### Add an always message

An **always** block here will let us know that the playbook at least made an attempt to download the file:

```yaml
---
- hosts: localhost
  tasks:
    - name: download transaction_list
      block:
        - get_url:
            url: https://bit.ly/3dtJtR7
            dest: /home/ansible/gh-auto-infra/labs/ansible-error-handling/transaction_list
        - debug: msg="File downloaded"
      rescue:
        - debug: msg="Site appears to be down.  Try again later."
      always:
        - debug: msg="Attempt completed."
```

#### Replace '#BLANKLINE' with '\n'

We can use the **replace** module for this task, and we'll sneak it in between the **get_url** and first **debug** tasks.

```yaml
---
- hosts: localhost
  tasks:
    - name: download transaction_list
      block:
        - get_url:
            url: https://bit.ly/3dtJtR7
            dest: /home/ansible/gh-auto-infra/labs/ansible-error-handling/transaction_list
        - replace:
            path: /home/ansible/gh-auto-infra/labs/ansible-error-handling/transaction_list
            regexp: "#BLANKLINE"
            replace: '\n'
        - debug: msg="File downloaded"
      rescue:
        - debug: msg="Site appears to be down.  Try again later."
      always:
        - debug: msg="Attempt completed."
```

## 

## Run the playbook 

Enter the `error-handling` directory

```bash
cd /home/ansible/gh-auto-infra/labs/ansible-error-handling
```

Run the playbook

```
ansible-playbook report.yml
```

If all went well, we can read the downloaded text file:

```
cat /home/ansible/gh-auto-infra/labs/ansible-error-handling/transaction_list
```

After confirming the playbook successfully downloads and updates the `transaction_list` file, run the `break_stuff.yml` playbook in the `maint` directory to simulate an unreachable host. 

```sh
ansible-playbook ~/gh-auto-infra/labs/ansible-error-handling/maint/break_stuff.yml --tags service_down
```

Confirm the host is no longer reachable 
```sh
curl -L -o transaction_list https://bit.ly/3dtJtR7
```

Run the playbook again and confirm it gracefully handles the failure.

```bash
ansible-playbook report.yml
```

Restore the service using `break_stuff.yml`, and confirm the `report.yml` playbook reports the service is back online.

```
ansible-playbook ~/gh-auto-infra/labs/ansible-error-handling/maint/break_stuff.yml --tags service_up
```

```
ansible-playbook report.yml
```

Congratulations! You have successfully edited an Ansible playbook to handle errors, committed and pushed changes to GitHub, and updated the Ansible control host to execute the modified playbook.
