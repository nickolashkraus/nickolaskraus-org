---
title: "Hugo Aliases"
date: 2019-11-10T00:00:00-06:00
draft: false
description: Use Hugo aliases to create redirects to your page from other URLs.
---

## Overview
It is generally considered best practice to never change the URL of a resource on the internet. This is because other resources may reference your resource and if the URL to your resource has changed these references will break.

If the URL of a resource needs to be changed, the original URL should become a redirect to the new URL. This is a fundamental feature of the internet and is addressed at length in the [Hypertext Transfer Protocol specification (RFC 2616)](https://tools.ietf.org/html/rfc2616#section-10.3).

If that were not cause enough to adherent to redirection, Google penalizes indexed content that has moved (e.g. is now returning a 404), which will damage SEO.

## Hugo Aliases
Hugo [aliases](https://gohugo.io/content-management/urls/#aliases) allow you to create redirects to your page from other URLs. This is useful if you change the title of an article and want the URL slug to match.

To add an alias to content, simply add an `aliases` key to your content's frontmatter:

**TOML**

```toml
+++
aliases = ["./articles/original-url/"]
+++
```

**YAML**

```yaml
---
aliases: ["./articles/original-url/"]
---
```
