---
title: "Creating a Public and Private RSA Key"
date: 2018-04-15T12:00:00-06:00
draft: false
description: A quick guide on creating SSH keys.
---

Create a `.ssh` directory:

```bash
cd ~
mkdir .ssh
cd .ssh
```

Generate RSA key pair:

```bash
ssh-keygen -b 1024 -t rsa -f id_rsa -P ""
```

Restrict access to your `id_rsa` private key:

```bash
chmod 400 ~/.ssh/id_rsa
```
