lazy val jobs = (project in file(".")).
  settings(
    organization  := "com.realest_estate",
    scalaVersion in ThisBuild := "2.11.8",
    version := "0.1.0",
    name := "Jobs",
    libraryDependencies ++= Seq(
      "org.apache.spark" %% "spark-core" % "2.3.0",
      "org.apache.spark" %% "spark-sql" % "2.3.0"
    )
   )
