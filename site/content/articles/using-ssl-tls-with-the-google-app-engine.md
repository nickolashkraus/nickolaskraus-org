---
title: "Using SSL/TLS with Google App Engine"
date: 2018-03-04T00:00:00-06:00
draft: false
description: Enabling SSL/TLS for your Google App Engine production environment can be done trivially. Nevertheless, some circumstances require that your local development server also use SSL/TLS. Since the local development server provided by the Google Cloud SDK, dev_appserver.py, does not come with SSL/TLS out of the box, some configuration is required to accomplish this.
---

Enabling SSL/TLS for your Google App Engine production environment can be done trivially. Nevertheless, some circumstances require that your local development server also use SSL/TLS. Since the local development server provided by the Google Cloud SDK, `dev_appserver.py`, does not come with SSL/TLS out of the box, some configuration is required to accomplish this.

## In Production
[Link](https://cloud.google.com/appengine/docs/standard/python/sockets/ssl_support)

Employing SSL/TLS in production is relatively straight forward. From the Google Cloud Platform documentation:

> If you want to use native Python SSL, you must enable it by specifying `ssl` for the `libraries` configuration in your application's `app.yaml`.

`app.yaml`

```yaml
libraries:
- name: ssl
  version: latest
```

## For Local Development

Using SSL/TLS with the local development server, `dev_appserver.py`, is slightly more involved. This solution requires two interventions:

1. Set up a reverse proxy server in front of the local development server to proxy SSL traffic to the server.

2. Patching the `requests` Python library so that the `dev_appserver.py` can initiate out-bound requests over HTTPS.


### Step 1: Set up a reverse proxy server

To solve this, I configured an Nginx server to act as a reverse proxy for SSL traffic. The walk-through for accomplishing this on macOS can be found [here](https://nickolaskraus.org/articles/how-to-create-a-self-signed-certificate-for-nginx-on-macos)

### Step 2: Patch the `requests` Python library

To use requests, you'll need to install both `requests` and `requests-toolbelt`. Once installed, use the `requests_toolbelt.adapters.appengine` module to configure requests to use `URLFetch`:

```python
import requests
import requests_toolbelt.adapters.appengine

# Use the App Engine Requests adapter. This makes sure that Requests uses
# URLFetch.
requests_toolbelt.adapters.appengine.monkeypatch()
```

To issue an HTTPS request, set the `validate_certificate` parameter to true when calling the `urlfetch.fetch()` method. This is handled transparently in `requests-toolbelt` [here](https://github.com/requests/toolbelt/blob/master/requests_toolbelt/adapters/appengine.py#L175).
