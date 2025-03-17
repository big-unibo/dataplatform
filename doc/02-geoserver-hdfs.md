# Serving Rasters from HDFS with GeoServer

GeoServer does not natively support retrieving raster images stored on HDFS, and existing plugins have not been effective in addressing this limitation. To resolve this, a custom HDFS-Geotiff plugin was developed, inspired by the GeoTools S3-Geotiff plugin. 

## GeoTools HDFS-GeoTiff Plugin

The source code for this plugin is available on GitHub in the repository:  
[https://github.com/alexbaiardi/geotools.git](https://github.com/alexbaiardi/geotools.git) (branch: `HDFS-plugin`).

The HDFS-Plugin is an extension of the GeoTIFF module, originally designed to handle local GeoTIFF files. It introduces the `HDFSGeoTiffFormat`, an adapter that wraps an input stream from HDFS into a temporary local file. This temporary file is stored in the `/tmp/geotools/hdfs` directory and then processed using a standard `GeoTiffReader`.

## Installing the HDFS-GeoTiff Plugin in GeoServer

To install the HDFS-Plugin in GeoServer, follow these steps:

1. **Install Hadoop**  
   Ensure Hadoop is installed on the server running GeoServer. You can install Hadoop by downloading the appropriate version from [Apache Hadoop](https://hadoop.apache.org/) and following the installation instructions.

2. **Set Up HDFS Configuration Files**  
   Copy the necessary HDFS configuration files (`core-site.xml` and `hdfs-site.xml`) to a location accessible to GeoServer. These files provide connection details for your HDFS cluster. Set the `HADOOP_CONF_DIR` environment variable to point to the directory containing the configuration files.

3. **Build the Plugin JAR**  
   Compile the plugin source code to generate the JAR file using Maven, as configured in the geotools repository.

4. **Copy the Plugin JAR File**  
   Copy the generated plugin JAR file into the GeoServer `WEB-INF/lib/` directory. The path to this folder is typically:  
   `.../geoserver/WEB-INF/lib/`

5. **Restart GeoServer**  
   Restart GeoServer to load the plugin, HDFS libraries, and configuration files. During the startup process, GeoServer will automatically detect and install the plugin.


Once the setup is complete, GeoServer will be able to interact with HDFS and process raster files stored in the cluster.

GeoServer's caching mechanism is utilized in conjunction with the plugin, which stores raster files in the temporary folder of the local machine (/tmp/geotools/hdfs). When a raster is requested, it is initially loaded from HDFS into the local machine. For subsequent requests, GeoServer checks its cache for the local file instead of reloading it from HDFS. If the local file is deleted, you must reset the cache for the corresponding store to ensure proper functionality.

In the repository's `images` folder, you will find a `Dockerfile` to build a custom GeoServer image. This image starts from the official GeoServer base image, installs Hadoop, and includes the HDFS-Geotiff plugin that must be downloaded from the following link:  
[**Download HDFS-Geotiff Plugin**](https://github.com/alexbaiardi/geotools/releases/tag/HDFS-GeoTiff)

Additionally, the image includes a Python script designed to manage the size of the temporary folder. The script ensures that the temporary folder does not exceed 50 GB by deleting files that have not been accessed recently and cleaning the corresponding cache. This script is scheduled to run every hour via a cron job, maintaining optimal disk usage.