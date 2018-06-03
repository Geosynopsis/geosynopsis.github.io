---
layout: post
title:  "Python tricks: class as the decorator to call methods in a class"
date:   2018-06-03 19:10
categories: [development]
---

Recently, I was writing a python module to modify the large images. The operations were memory-intensive. The script below gives an example of the kinds of operations:

{% highlight python %}

    import gdal
    
    
    class Raster(object):
        def __init__(self, data_path):
            self.data_source = gdal.Open(data_path)
            self.band_count = self.data_source.RasterCount
            self.x_size = self.data_source.RasterXSize
            self.y_size = self.data_source.RasterYSize
            self.geotransform = self.data_source.GetGeoTransform()
            self.projection = self.data_source.GetProjection()
    
        def band_ratio(self):
            # Read complete data of band and make ratio between the bands and save image
            pass
    
        def segmentation(self):
            # Read image bands and make segmentation based on the band values
            pass
    
        # ...
{% endhighlight %}

Therefore, I tried to apply the operation in chunk-wise fashion i.e., I read a small subset of an image, apply the method and save them and move to next subset. 

{% highlight python %}

    import gdal
    import numpy
    
    class Raster(object):
        def __init__(self, data_path):
            self.data_source = gdal.Open(data_path)
            self.band_count = self.data_source.RasterCount
            self.x_size = self.data_source.RasterXSize
            self.y_size = self.data_source.RasterYSize
            self.geotransform = self.data_source.GetGeoTransform()
            self.projection = self.data_source.GetProjection()
    
        def band_ratio(self, block_size):
            """
            This method will access the size of whole image and break them into list of indices and blocks as in figure
            and applies the band_ratio to each block.
             E.g.
    
            *----------*----------*----------*-----|
            |          |          |          |     |
            |          |          |          |     |
            |          |          |          |     |
            *----------*----------*----------*-----*
            |          |          |          |     |
            |          |          |          |     |
            |          |          |          |     |
            *----------*----------*----------*-----*
            |          |          |          |     |
            |          |          |          |     |
            *----------*----------*----------*-----|
            """
            x_list = numpy.arange(0, self.x_size, block_size)
            y_list = numpy.arange(0, self.y_size, block_size)
            x_block_sizes = numpy.append(x_list[1:] - x_list[:-1], self.x_size - x_list[-1])
            y_block_sizes = numpy.append(y_list[1:] - y_list[:-1], self.y_size - y_list[-1])
    
            x_mesh, y_mesh = numpy.meshgrid(
                x_list, y_list,
                sparse=False,
                indexing='ij'
            )
    
            x_block_mesh, y_block_mesh = numpy.meshgrid(
                x_block_sizes, y_block_sizes,
                sparse=False,
                indexing='ij',
            )
            for x, y, x_bloc, y_block in zip(x_mesh, y_mesh, x_block_mesh, y_block_mesh):
                # Read _block
                # Apply Operation
                # Write Block
                pass
            pass

{% endhighlight %}

However, I had many operations and to implement this mechanism for each of them was a bit of a drag.  So I decided to use python decorator. You can read more about decorator [here](http://python-3-patterns-idioms-test.readthedocs.io/en/latest/PythonDecorators.html#decorators-with-arguments).


I opted for Class as Decorator. The reason behind choosing class decorator was simply because I had many preparatory operations which I wanted to break and organize better. The problem with using Class as Decorator, however, is that we cannot simply use it to class methods in basic form.

Take following code for example. While running the code, the code will run for the function but fails for the class method. The instance reference or self itself isn't passed to to the decorator by default.

{% highlight python %}

    class Decorator(object):
        def __init__(self, func):
            if callable(func) is False:
                raise IOError(f"The `func` value {func}, is not callable")
            self.func = func
    
        def __call__(self, *args, **kwargs):
            print(f"I am calling {self.func.__name__}")
            res = self.func( *args, **kwargs)
            print(f"I finished calling {self.func.__name__}")
            return res
    
    @Decorator
    def test_func(message):
        print(message)
    
    
    class TestClass(object):
        @Decorator
        def test_method(self, message):
            print(message)
    
    
    test_func("I am function")
    t = TestClass()
    t.test_method("I am class method")
    
    
    
{% endhighlight %}  
{% highlight python %}
  
    ### RUN RESULT ####
    I am calling test_func
    I am function
    I finished calling test_func
    I am calling test_method
    Traceback (most recent call last):
      File "/home/abheeman/PycharmProjects/test/decorator_class_variable.py", line 105, in <module>
        t.test_method("I am class method")
      File "/home/abheeman/PycharmProjects/test/decorator_class_variable.py", line 88, in __call__
        res = self.func( *args, **kwargs)
    TypeError: test_method() missing 1 required positional argument: 'message'
{% endhighlight %}

A way around to pass the instance reference is by modifying the descriptor method `__get__`. The method is used to get the attribute of the owner class or its instance. The modified decorator as follows should work for the previous example.

{% highlight python %}

    class Decorator(object):
        _cls=None
        _obj=None
    
        def __init__(self, func):
            if callable(func) is False:
                raise IOError(f"The `func` value {func}, is not callable")
            self.func = func
    
        def __get__(self, instance, owner):
            self._cls = instance
            self._obj = owner
            return self.__call__
    
        def __call__(self, *args, **kwargs):
            print(f"I am calling {self.func.__name__}")
            if self._cls:
                res = self.func(self._cls, *args, **kwargs)
            else:
                res = self.func(*args, **kwargs)
            print(f"I finished calling {self.func.__name__}")
            return res
{% endhighlight %}


{% highlight python %}
{% endhighlight %}