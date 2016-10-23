import akka.http.scaladsl.Http
import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import akka.http.scaladsl.model.{HttpRequest, HttpResponse}
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import spray.json._
import scala.concurrent.Future



trait PavlovService extends SprayJsonSupport with DefaultJsonProtocol {
  implicit val textFormat   = jsonFormat1(Text)
  implicit val answerFormat = jsonFormat1(Answer)
  implicit val accountsFormat = jsonFormat1(Accounts)
  implicit val accountFormat = jsonFormat1(Account)
  implicit val paidFormat = jsonFormat1(Paid)

  case class Text(text: String)

  case class Answer(isGood: Boolean)

  case class Accounts(accounts: List[String])

  case class Account(account: String)

  case class Paid(paid: Double)

  def route: Route = get {
    path("ping") {
      complete("pong")
    } ~ pavlov ~ accounts
  }

  def pavlov: Route = {
    path("pavlov") {
      parameter("text".as[String]) { text: String =>
        complete(Answer(Spark(text)))
      }
    }
  }

  def accounts: Route = {
    path("accounts") {
      parameter("account".as[String]) { accounts: String => {
        complete(Accounts(List("580c9f98360f81f10454502f", "580c9f38360f81f10454502c", "580c9f74360f81f10454502d", "580c9ee6360f81f104545028")))
        }
      }
    }
  }

  def pay: Route = {
    path("pay") {
      parameters("account".as[String], "amount".as[String]) { (account:String, amount:String) => {
        complete(Paid(amount.toDouble / 4.0))
      }}
    }
  }
}