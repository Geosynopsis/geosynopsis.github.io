---
layout: post
title:  "Insecure docker registry"
date:   2018-06-03 19:10
categories: [development, technology]
tags: [docker, kubernetes]
title_image: /assets/images/posts/dockerlogo.png
---

### Hosting local registry
It is fairly easy to host a docker registry locally. All we need to do is pull the docker image of registry and 
host them. 

{% highlight bash %}
    
    docker run -p 5000:5000 --name localregistry registry:2
    
{% endhighlight %}

If we want to save the registry images at certain location, we can as well mount the directory as following:

{% highlight bash %}

    docker run -p 5000:5000 --name localregistry -v /path/to/dir:/var/lib/registry registry:2
    
{% endhighlight %}

The registry should be available at http://localhost:5000.

### Tagging, pushing and pulling image

We can tell docker to use the locally hosted registry by tagging image.

{% highlight bash %}
    
    docker pull nginx  # pulls image from the docker registry
    docker tag nginx localhost:5000/nginx   # Tags the nginx image to use registry localhost:5000
    
{% endhighlight %}

Now, we can push and pull the image from local registry with following commands.

{% highlight bash %}
    
    docker push localhost:5000/nginx  # pushes the tagged image to the registry
    docker pull localhost:5000/nginx   # pulls the image from the local registry
    
{% endhighlight %}

### Local registry behind Nginx
If we want to share the registry in an internal network, we can do so by opening the firewall for port 5000 for the 
given internal network. If the internal ip of the registry host is 10.100.0.1, we can tag push and pull in following 
way:

{% highlight bash %}
    
    docker tag nginx 10.100.0.1:5000/nginx # Tags the nginx image to use registry 10.100.0.1:5000
    docker push 10.100.0.1:5000/nginx  # Pushes the tagged image to the registry
    docker pull 10.100.0.1:5000/nginx   # Pulls the image from the local registry
    
{% endhighlight %}


If we have an internal domain controller running, it is advised to use a web server to expose the registry as 
service with internal domain name. This way, if we, at anytime, decide to migrate the registry to different computer, 
image tags doesn't need to be changed to match the ip of the registry host. And we can also secure other port than 80
which is used for exposing web services. I generally use Nginx to do that, however one can use any web server that 
supports reverse proxy. 
 
Let's imagine, the internal domain that is pointing towards the server is registry.example.internal. The Nginx 
configuration looks as follows:
 
{% highlight bash %}
    # default.conf
    server {
        listen       80;
        
        server_name  registry.example.internal;
        client_max_body_size 10G;  # You might have to change this to accomodate the maximum size of image you expect
         to push.
    
        location / {
            proxy_pass http://10.100.0.1:5000;
        }
    }
    
{% endhighlight %}

Now, if we run nginx with given configuration, the registry should be available at http://registry.example.internal 
and images can be tagged, pushed and pulled as follows:

{% highlight bash %}
    
    docker tag nginx registry.example.internal/nginx # Tags the nginx image to use registry 10.100.0.1:5000
    docker push registry.example.internal/nginx  # Pushes the tagged image to the registry
    docker pull registry.example.internal/nginx  # Pulls the image from the local registry
    
{% endhighlight %}

This is, in fact, the same procedure if we want to make registry available for entire internet as well. 
Only difference in that case is that we need to open the firewall for entire internet.

### Case of insecure registry
Essentially, it is not advised to use the insecure registry with docker and docker by itself doesn't entertain 
insecure registry. But if it is only for internal/developmental purpose, one might not want to go through all the 
hassle to make the registry to communicate through https. In such a case, we can make docker to use insecure 
registry with following command:
 
 {% highlight bash %}
    
    dockerd --insecure-registry=registry.example.internal
    
{% endhighlight %}

Or we can edit /etc/docker/daemon.json to accomodate the insecure registry

{% highlight bash %}
    # /etc/docker/daemon.json
    {
     ...
     "insecure-registries": ["registry.example.internal"]
    }
    
{% endhighlight %}


** Case with Kubernetes **

We have seen time and often a question appearing, how we can allow Kubernetes to use insecure registry. If Kubernetes
 is using the docker conainer platform, there is no especial settings you need to change for it to use the insecure 
 registry except the change in /etc/docker/daemon.json.