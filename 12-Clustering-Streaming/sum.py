from __future__ import print_function
if __name__ == '__main__':
    from pyspark.sql import SparkSession
    spark = SparkSession.builder \
        .master("local") \
        .appName("summation") \
        .config("spark.some.config.option", "some-value") \
        .getOrCreate()

    bucket = spark._jsc.hadoopConfiguration().get("fs.gs.system.bucket")
    data = "gs://" + bucket + "/notebooks/jupyter/data/"

    resultDF = spark.range(5000).where("id > 500").selectExpr("sum(id)")

    print('Writing the results to:', data+'tmp/sum.csv')

    resultDF.write.format("csv")\
      .option("header", "True")\
      .mode("overwrite")\
      .save(data + "tmp/sum.csv")
