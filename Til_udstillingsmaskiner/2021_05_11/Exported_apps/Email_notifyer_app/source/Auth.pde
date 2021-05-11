// Simple Authenticator          
  
  // Careful, this is terribly unsecure!!

import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

public class Auth extends Authenticator {

  public Auth() {
    super();
  }
  
  // Email account to use for authentication
  public PasswordAuthentication getPasswordAuthentication() {
    String username, password;
    username = "air-noreply@itu.dk";
    password = "cfh#xXqU";
    System.out.println("authenticating. . ");
    return new PasswordAuthentication(username, password);
  }
}
