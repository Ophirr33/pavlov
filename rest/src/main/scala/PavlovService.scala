import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import spray.json._


trait PavlovService extends SprayJsonSupport with DefaultJsonProtocol {
  implicit val textFormat = jsonFormat1(Text)
  implicit val answerFormat = jsonFormat1(Answer)

  case class Text(text: String)
  case class Answer(ans: Boolean)

  def route:Route = get {
    path("pavlov") {
      parameter("text".as[Text]) { text:Text =>
        complete(Answer(Spark(text.text)))
      }
    }
  }

}