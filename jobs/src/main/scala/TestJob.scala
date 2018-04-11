/* Test Job to sanity check infrastructure */
package com.realest_estate
import org.apache.spark.sql.SparkSession


object TestJob {
  def main(args: Array[String]) = {
    val spark = SparkSession.builder.appName("Test").getOrCreate()
    print("\n\n\n\nAm I glad to see you!")
    println("~~~~~~~~~~~~~~~~~~~~~!\n\n\n\n")
    spark.stop()

  }
}
