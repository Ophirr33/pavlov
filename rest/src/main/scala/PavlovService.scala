import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import spray.json._


trait PavlovService extends SprayJsonSupport with DefaultJsonProtocol {
  implicit val textFormat   = jsonFormat1(Text)
  implicit val answerFormat = jsonFormat1(Answer)
  implicit val accountsFormat = jsonFormat1(Accounts)
  implicit val accountFormat = jsonFormat1(Account)

  case class Text(text: String)

  case class Answer(ans: Boolean)

  case class Accounts(accounts: List[String])

  case class Account(account: String)

  def route: Route = get {
    path("ping") {
      complete("pong")
    } ~ pavlov
  }

  def pavlov: Route = {
    path("pavlov") {
      parameter("text".as[Text]) { text: Text =>
        complete(Answer(Spark(text.text)))
      }
    }
  }

  def accounts: Route = {
    path("accounts") {
      parameter("account".as[Account]) { accounts: Account =>
        complete(Accounts(List("123456", "142524", "135246")))
      }
    }
  }
}