import Dependencies._

ThisBuild / scalaVersion     := "2.12.8"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "io.github.gvolpe"
ThisBuild / organizationName := "gvolpe"

lazy val root = (project in file("."))
  .settings(
    name := "scala-stm",
    libraryDependencies ++= Seq(
      Libraries.zioCore
    )
  )

// See https://www.scala-sbt.org/1.x/docs/Using-Sonatype.html for instructions on how to publish to Sonatype.
