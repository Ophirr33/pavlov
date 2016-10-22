import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object Spark extends App {
  val config = new SparkConf(false)
  val sc = SparkContext.getOrCreate(config)
  val textFile: RDD[String] = sc.textFile("blah.txt")
  val linesWithSpark: RDD[String] = textFile.filter(line => line.contains("VIM"))
  linesWithSpark.cache
  println(linesWithSpark.count)
}