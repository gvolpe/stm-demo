import sbt._

object Dependencies {

  object Versions {
    val zio                 = "1.0-RC4"

    val betterMonadicFor    = "0.3.0"
    val kindProjector       = "0.9.8"
    val scalaCheck          = "1.14.0"
    val scalaTest           = "3.0.5"
  }

  object Libraries {
    def zio(artifact: String): ModuleID = "org.scalaz"    %% artifact % Versions.zio

    lazy val zioCore             = zio("scalaz-zio")

    // Compiler plugins
    lazy val betterMonadicFor    = "com.olegpy"            %% "better-monadic-for"         % Versions.betterMonadicFor
    lazy val kindProjector       = "org.spire-math"        %% "kind-projector"             % Versions.kindProjector

    // Test
    lazy val scalaTest           = "org.scalatest"         %% "scalatest"                  % Versions.scalaTest
    lazy val scalaCheck          = "org.scalacheck"        %% "scalacheck"                 % Versions.scalaCheck
  }


}
