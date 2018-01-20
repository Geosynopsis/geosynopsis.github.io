---
layout: post
title:  "Certificate for jekyll rendered static site"
date:   2018-01-20 19:10
categories: [development,]
---

I have built this blog using [Jekyll][jekyll]. Jekyll is a simple, blog-aware, static site generator. GitHub Pages natively support Jekyll, and I was planning to publish the blog using Pages. But at the later part, I decided to publish the blog using Netlify as its more convenient from handling point-of-view. The build process in Netlify is comparatively more transparent than in Pages, and configurations like domain settings are quite comfortable for users.


Apart from that, [Netlify][netlify] offers free managed SSL from ["Let's Encrypt"][letsencrypt] certificate provider. The certificate gets renewed automatically once the current one expires. The hook here, however, is that the domain should use the nameservers of Netlify which is not always convenient.


For instance, I bought the domain from [Google Domains][googledomains] as it offers multiple features including the creation of email aliases. At the Google Domains end, the requirement for many features including email alias is that the domain must use google's nameservers.


Fortunately, Netlify supports custom certificate. But its slightly tricky to generate a certificate for the domain and the user has to renew the certificate him/herself.


I used the manual certificate generation process of "Let's Encrypt". The official instructions are here.


The easiest way to create a certificate is by using CertBot which I installed with the following command.


{% highlight python %}
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install certbot
{% endhighlight %}


The certificate can be generated manually with following command.


{% highlight python %}
certbot certonly --manual --server https://acme-v01.api.letsencrypt.org/directory -d domain.com -d www.domain.com
{% endhighlight %}

![Image]({{site.url}}/assets/images/posts/dockerlogo.png)

After acceptance of the IP being logged, it instructs to put a file with the specified name and content at the particular path (http://domain_needing_certificate/.well-known/acme-challenge/name_of_file) for each domain that we want to generate a certificate.


However, according to Jekyll documentation, dot files are excluded by default and we need to put the folder or file in the include list. Therefore, I need to specify in `_config.yml`  to include the folder `.well-known`.


{% highlight python %}
# _config.yml
include: [".well-known"]
{% endhighlight %}


After you have published those files, the certificate is generated. Let's Encrypt creates three records, which consist of the `cert.pem chain.pem private.pem`. So I included those keys in the Netlify Domain Settings.



[jekyll](https://jekyllrb.com)
[netlify](https://www.netlify.com)
[googledomains](https://domains.google)
[letsencrypt](https://letsencrypt.org)