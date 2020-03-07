---
layout: post
title:  "AREA_OR_POINT: Raster space and it's effect on resampling"
date:   2020-03-07 23:18
tag: Geospatial
categories: [development]
title_image: /assets/images/posts/PixelAsPoint.png
---

Recently I was working with a small routine to resample satellite images. We wanted to resample products of Sentinel 2 and Landsat 8 images where we hit a problem. The problem occurred as we ignored the value AREA_OR_POINT tag of image metadata. AREA_OR_POINT defines the raster space of the image, and in this blog post, we go in detail what it means and how it affects the resampling process.

## Raster Space

Raster space defines what a pixel represents: a point (**PixelAsPoint**) or an area (**PixelAsArea**), and depends on the way we collect the underlying data. For example, let us suppose we collect distances to a wall at an interval of every meter on width and height direction with a device with a thin laser beam and represent them in raster space with 1m x 1m resolution. In such a case, the pixels represent the points, and naturally, the pixels fill values are equal to the distances at corresponding points. Now, let us imagine we are taking a picture of the same wall, the sensor of the camera would measure the amount of light entering its every part to create an image. In such a case, each pixel represents an average amount of light reflected from the corresponding area on the wall. Therefore, it is logical that we opt for a PixelAsArea raster space.

Does that mean there's a clear instruction when to take raster space choices? Well, somewhat. It always depends on the interpretation. For example, we could represent digital elevation models (DEM) in PixelAsPoint or PixelAsArea raster space depending on the original data source: local survey points or aerial stereo image. We could even assume that a pixel of a photograph quantifies reflection coming from a point and represent in PixelAsPoint. USGS went with the latter choice, even though I can't contemplate why USGS chose PixelAsPoint representation. If anybody has any idea behind this decision, please do let me know.

Now that we know what those representations are, let's try to understand how they affect the resampling, and consequently, reprojection of the image.

## Resampling: PixelAsArea

When we represent an image in PixelAsArea raster space, its bounds are fixed. No matter whether we upsample or downsample it, it represents the same area in the real world. In the following figure, we upsample an image by a factor of 2. We split each pixel in the middle on both directions such that the resulting image consists of four pixels for each pixel in the original image. Each pixel in the upscaled image now describes the one-quarter area the original pixel represents.

![alt text][PixelAsArea]

## Resampling: PixelAsPoint

When we represent an image in PixelAsPoint raster space, centres of corner pixels are fixed. On upsampling, we add points to split the distance between the centres by chosen factor and interpolate its value, whereas, on downsampling, we remove the points between and recalculate the value of remaining points. In the following figure, we upscale an image two times: each time with a factor of two. One can easily see that the bounds of the image change on scaling, while the pixel-centres at the edges retain their positions.

![alt text][PixelAsPoint]

## Why this big fuss on some old thing?

In recent years, we are witnessing a lot of new developments in the areas of image processing fueled by progress in computing, machine learning etc. The community is adopting new libraries for image processing, such as xarray (python), where the image representation is different compared to the libraries like GDAL. The geospatial community have been working with GDAL for a long time, and hence, it considers this raster space representation (read from metadata) while resampling and reprojecting. If we want to use newer libraries, as they provide more convenient representation, we are pushed to use lower-level APIs of GDAL which works with arrays or use numpy/scipy based method. Consequently, we have to make our hands dirty to calculate the resampling and reprojection space. Therefore, it is worth revisiting this theory to consider it in our applications.

[PixelAsPoint]: /assets/images/posts/PixelAsPoint.png
[PixelAsArea]: /assets/images/posts/PixelAsArea.png