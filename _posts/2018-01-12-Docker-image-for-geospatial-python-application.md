---
layout: post
title:  "Docker image for geospatial python application"
date:   2018-01-12 13:45
tag: Docker Python Geospatial
categories: [technology, development]
title_image: /assets/images/posts/dockerlogo.png
---
In this blog post, we will build a Docker image that supports geospatial python application. We take [Miniconda][miniconda] as a base image where we install the geospatial libraries like [GDAL/OGR][gdal], [Geopandas][geopandas], [Shapely][shapely], [Fiona][fiona], [Descartes][descartes], [Pyproj][pyproj], [Rasterio][rasterio] etc. The final image will be available in Docker hub so that you guys can pull the prebuilt image from there.


We are starting from Miniconda as it comes already with Python and [Conda package manager][conda] installed. We could have used Anaconda instead of Miniconda, but Anaconda is a pretty huge image (as of today, 1GB compressed size) with more than 100 python libraries installed most of which we might not require for the application.
Therefore, our first three lines of dockerfile are as follows:

{% highlight python %}
FROM continuumio/miniconda   # Base image.
RUN conda update conda       # Update conda to the latest version.
RUN conda config --add channels conda-forge
{% endhighlight %}

We add [conda-forge][condaforge] to the channel as it provides a vast number of libraries which are not covered by the default channels.
 
Unlike pip, Conda package manager can also install the dependencies outside of the python. For example, if we try installing GDAL using pip in the latest images of Miniconda or python, we get following error:

{% highlight python %}
Collecting gdal
  Downloading GDAL-2.2.3.tar.gz (475kB)
    100% |████████████████████████████████| 481kB 909kB/s 
    Complete output from command python setup.py egg_info:
    running egg_info
    creating pip-egg-info/GDAL.egg-info
    writing pip-egg-info/GDAL.egg-info/PKG-INFO
    writing top-level names to pip-egg-info/GDAL.egg-info/top_level.txt
    writing dependency_links to pip-egg-info/GDAL.egg-info/dependency_links.txt
    writing manifest file 'pip-egg-info/GDAL.egg-info/SOURCES.txt'
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
      File "/tmp/pip-build-fiZSEy/gdal/setup.py", line 339, in <module>
        **extra )
      File "/opt/conda/lib/python2.7/distutils/core.py", line 151, in setup
        dist.run_commands()
      File "/opt/conda/lib/python2.7/distutils/dist.py", line 953, in run_commands
        self.run_command(cmd)
      File "/opt/conda/lib/python2.7/distutils/dist.py", line 972, in run_command
        cmd_obj.run()
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/egg_info.py", line 280, in run
        self.find_sources()
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/egg_info.py", line 295, in find_sources
        mm.run()
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/egg_info.py", line 526, in run
        self.add_defaults()
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/egg_info.py", line 562, in add_defaults
        sdist.add_defaults(self)
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/py36compat.py", line 36, in add_defaults
        self._add_defaults_ext()
      File "/opt/conda/lib/python2.7/site-packages/setuptools/command/py36compat.py", line 119, in _add_defaults_ext
        build_ext = self.get_finalized_command('build_ext')
      File "/opt/conda/lib/python2.7/distutils/cmd.py", line 312, in get_finalized_command
        cmd_obj.ensure_finalized()
      File "/opt/conda/lib/python2.7/distutils/cmd.py", line 109, in ensure_finalized
        self.finalize_options()
      File "/tmp/pip-build-fiZSEy/gdal/setup.py", line 214, in finalize_options
        self.gdaldir = self.get_gdal_config('prefix')
      File "/tmp/pip-build-fiZSEy/gdal/setup.py", line 188, in get_gdal_config
        return fetch_config(option)
      File "/tmp/pip-build-fiZSEy/gdal/setup.py", line 141, in fetch_config
        raise gdal_config_error, e""")
      File "<string>", line 4, in <module>
    __main__.gdal_config_error: [Errno 2] No such file or directory
    
    ----------------------------------------
Command "python setup.py egg_info" failed with error code 1 in /tmp/pip-build-fiZSEy/gdal/

{% endhighlight %}

Python GDAL requires `libgdal` and other header files to be present in your system. These non-python dependencies are automatically installed if they aren't present in the system while using Conda package manager. 

Now we install the geospatial libraries with the following line.

{%highlight python%}
conda install -y rasterio geopandas gdal
{% endhighlight %}


In the given line we install only three libraries as those libraries already install the rest as dependencies.
 
If we want to install each library in step, we should make sure of the order. We should install GDAL at the end as other higher-level libraries like Rasterio installs the older version of GDAL.  And importing GDAL throws header file related error if installation carried out in the different order.

To put the whole Dockerfile together:

{% highlight python %}
FROM continuumio/miniconda
RUN conda update -y conda
RUN conda config --add channels conda-forge
RUN conda install -y gdal rasterio geopandas
{% endhighlight %}

Wow! The docker image turned out to be quite huge (~ 1 GB Compressed). However, you can find the image [here.][dockerimage]


[miniconda]: https://conda.io/miniconda.html
[conda]: https://conda.io/docs/
[condaforge]: https://conda-forge.org/
[gdal]: http://www.gdal.org/
[geopandas]: http://geopandas.org/
[rasterio]: https://github.com/mapbox/rasterio
[shapely]:   https://github.com/Toblerity/Shapely
[fiona]: https://github.com/Toblerity/Fiona
[descartes]: https://bitbucket.org/sgillies/descartes/
[pyproj]: https://github.com/jswhit/pyproj
[dockerimage]: https://hub.docker.com/r/abheeman/geoconda/