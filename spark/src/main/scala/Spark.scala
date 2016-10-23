import java.io._
import java.util.function.{Function, Predicate}
import java.util.stream.Collectors

import scala.collection.JavaConversions._
import scala.collection.JavaConverters._
import org.json4s.native.Serialization.{read, write}
import com.ibm.watson.developer_cloud.tone_analyzer.v3.ToneAnalyzer
import com.ibm.watson.developer_cloud.tone_analyzer.v3.model.{Tone, ToneAnalysis, ToneOptions, ToneScore}
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

import scala.concurrent.{Await, Future}
import scala.io.BufferedSource
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.FiniteDuration

object Spark {
//  val config = new SparkConf(false)
//  val sc = SparkContext.getOrCreate(config)
//  val textFile: RDD[String] = sc.textFile("src/main/resources/blah.txt")
//  val linesWithSpark: RDD[String] = textFile.filter(line => line.contains("VIM"))
//  linesWithSpark.cache


  def queryResourcesFromStreamWatson(readFileName: String, writeFileName: String, isGood:Boolean): Unit = {
    implicit val formats = org.json4s.DefaultFormats
    val bw = BufferedWriter(writeFileName)
    var counter = 0
    ParseStream(readFileName).filter(_ != "").foreach(str => {
      bw.write(write(FeatureLabel(SentimentAnalysis(str), CurseFrequency(str), isGood)))
      bw.newLine()
      bw.flush()
      if (counter % 10 == 0) {
        println()
      }
      print(s"$counter ")
      counter += 1
    })
    bw.close()
  }

  def writeResourceToFile(fileName:String, resources:List[FeatureLabel]): Unit = {
    implicit val formats = org.json4s.DefaultFormats
    val bw = BufferedWriter(fileName)
    bw.write(resources.foldLeft("")((resource, acc) => s"${write(resource)}\n$acc"))
    bw.close()
  }

  def readResourceFromFile(fileName:String):List[FeatureLabel] = {
    implicit val formats = org.json4s.DefaultFormats
    val br = BufferedReader(fileName)
    val preParse = br.lines().collect(Collectors.toList[String])
    br.close()
    preParse.map(read[FeatureLabel]).toList
  }

  def main(args: Array[String]): Unit = {
    // Parse watson and store it into files
    val f1 = Future(queryResourcesFromStreamWatson("spark/src/main/resources/hope_stream.txt", "spark/src/main/resources/hope_resources.txt", isGood = true))
    val f2 = Future(queryResourcesFromStreamWatson("spark/src/main/resources/fuckyou_stream.txt",  "spark/src/main/resources/fuckyou_resources.txt", isGood = false))
    val f3 = Future(queryResourcesFromStreamWatson("spark/src/main/resources/hate_stream.txt",  "spark/src/main/resources/hate_resources.txt", isGood = false))
    val await = (f: Future[_]) => Await.result(f, new FiniteDuration(45, scala.concurrent.duration.MINUTES))
    await(f1)
    await(f2)
    await(f3)

    Await.result(f2, new FiniteDuration(45, scala.concurrent.duration.MINUTES))
    Await.result(f3, new FiniteDuration(45, scala.concurrent.duration.MINUTES))
  }

}

object SentimentAnalysis {
  def apply(text: String): Emotion = {
    val service = new ToneAnalyzer(ToneAnalyzer.VERSION_DATE_2016_05_19)
    val br = BufferedReader("spark/src/main/resources/secrets.txt")
    service.setUsernameAndPassword(br.readLine, br.readLine)
    br.close()

    // Call the service and get the tone
    val tone: ToneAnalysis = service.getTone(text, new ToneOptions.Builder().addTone(Tone.EMOTION).build()).execute()
    tone.getDocumentTone.getTones.get(0).getTones.foldLeft(Emotion())((emotion, tone) => emotion.fromTone(tone)).validate()
  }

  def queryWatsonForEmotions(fileName:String): List[Emotion] = {
    ParseStream(fileName).asJava.parallelStream().map[Emotion](new Function[String, Emotion] {
      override def apply(t: String): Emotion = SentimentAnalysis(t)
    }).collect(Collectors.toList[Emotion]).toList
  }
}

object CurseFrequency {
  import scala.io.Source
  val curseWords: Set[String] =  Source.fromInputStream(getClass.getResourceAsStream("curse_words.txt")).getLines().toSet

  def getFromPath(name:String):BufferedSource = {
    Source.fromInputStream(getClass.getResourceAsStream(name))
  }


  def apply(input:String):Double = {
    val occurrences:Double = curseWords.foldLeft(0.0)((acc, word) => acc + (if (input.toLowerCase.contains(word)) 1 else 0))
    val words = input.split("\\s")
    occurrences / words.length.toDouble
  }

  def listFrequenciesFromFile(fileName:String): List[Double] = {
    ParseStream(fileName).map(apply)
  }
}

case class Emotion(anger: Double = -1, disgust: Double = -1, fear: Double = -1, joy: Double = -1, sadness: Double = -1) {
  def fromTone(tone: ToneScore): Emotion = {
    tone.getName match {
      case "Fear"  => this.copy(fear = tone.getScore)
      case "Anger" => this.copy(anger = tone.getScore)
      case "Disgust" => this.copy(disgust = tone.getScore)
      case "Joy" => this.copy(joy = tone.getScore)
      case "Sadness" => this.copy(sadness = tone.getScore)
    }
  }

  def validate(): Emotion = {
    if (Emotion.unapply(this).get.productIterator.exists(a => a.asInstanceOf[Double] == -1)) {
      throw new IllegalStateException("Uninitialized emotion")
    }
    this
  }
}

case class FeatureLabel(emotion: Emotion, frequency: Double, isGood: Boolean)

object BufferedReader {
  def apply(file: String): BufferedReader = {
    new BufferedReader(new FileReader(new File(file)))
  }
}

object BufferedWriter {
  def apply(file: String): BufferedWriter = {
    new BufferedWriter(new FileWriter(new File(file)))
  }
}

object ParseStream {
  def apply(fileName:String): List[String] = {
    val br = BufferedReader(fileName)
    val result = br.lines().collect(Collectors.joining("\n")).split("===========")
    br.close()
    result.toList
  }
}