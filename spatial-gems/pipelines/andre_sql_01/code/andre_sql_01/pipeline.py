from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from andre_sql_01.config.ConfigStore import *
from andre_sql_01.functions import *
from prophecy.utils import *

def pipeline(spark: SparkSession) -> None:
    pass

def main():
    spark = SparkSession.builder.enableHiveSupport().appName("andre_sql_01").getOrCreate()
    Utils.initializeFromArgs(spark, parse_args())
    spark.conf.set("prophecy.metadata.pipeline.uri", "pipelines/andre_sql_01")
    spark.conf.set("spark.default.parallelism", "4")
    spark.conf.set("spark.sql.legacy.allowUntypedScalaUDF", "true")
    registerUDFs(spark)
    
    MetricsCollector.instrument(spark = spark, pipelineId = "pipelines/andre_sql_01", config = Config)(pipeline)

if __name__ == "__main__":
    main()
