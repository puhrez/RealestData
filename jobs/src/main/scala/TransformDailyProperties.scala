package com.realest_estate
import org.apache.spark.sql.{
  DataFrame, SparkSession, SQLContext, ColumnName, SaveMode}
import org.apache.spark.sql.functions._

object TransformDailyProperties {
  val spark = SparkSession.builder
      .appName("Transform Daily Properties")
      .getOrCreate()
  import spark.implicits._

  def read_csv(path: String): DataFrame = {
    spark.read
      .format("csv")
      .option("header", "true")
      .option("inferSchema", "true")
      .load(path).cache()
  }
  def enrichLotFrontage(DF: DataFrame): DataFrame = {
    DF.withColumn(
      "LotFrontage",
      when(
        $"LotFrontage" === "NA",
        lit(null)
      ).otherwise($"LotFrontage"))
  }
  def withBiggerThan(col: String, compCol: ColumnName, comp: Double)(DF: DataFrame): DataFrame = {
    DF.withColumn(
      col,
      when(
        compCol > comp,
        lit(true)
      ).otherwise(false)
    )
  }
  def withGarageAreaBiggerThan1000SqFt(DF: DataFrame): DataFrame = {
    withBiggerThan(
      "GarageAreaGT1000SqFt",
      $"GarageArea",
      1000)(DF)
  }
  def main(args: Array[String]) {
    val propertiesDF = read_csv("fixtures/daily_properties.csv")
      .transform(enrichLotFrontage)
      .transform(withGarageAreaBiggerThan1000SqFt)

    val recordsCount = propertiesDF.count()
    println(s"\n\n\n\nRecords: $recordsCount \n\n\n")
    propertiesDF.write
      .format("csv")
      .mode(SaveMode.Overwrite)
      .option("header", "true")
      .save("fixtures/transformed_daily_properties.csv")
  }
}
