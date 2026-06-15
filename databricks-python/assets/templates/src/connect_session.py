"""Databricks Connect session — verifies serverless connectivity and catalog access."""

import sys

from databricks.connect import DatabricksSession

spark = DatabricksSession.builder.profile("dev").serverless().getOrCreate()

print(spark.conf.get("spark.databricks.workspaceUrl"))
print(spark.conf.get("spark.databricks.clusterUsageTags.clusterId"))
print(sys.version_info)

spark.table("samples.nyctaxi.trips").show(10, False)
