// Example functions that send mail (smtp)


// A function to send mail

void sendMail(String subject, String body) {
  // Create a session
  String host = "smtp.office365.com"; // set smtp server to use  ---  e.g. "smtp.office365.com"
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "587"); // set smtp port to use  ---  e.g. "587" for office365 
  props.put("mail.smtp.auth", "true");
  props.put("mail.smtp.starttls.enable","true"); // We need TTLS, which gmail / office365 mails requires

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try
  {
    
    MimeMessage message = new MimeMessage(session); // Make a new message

    message.setFrom(new InternetAddress("air-noreply@itu.dk", "HoS Email Notifyer")); // From

    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse("halj@itu.dk", false)); // To
    
    InternetAddress ia [] = {new InternetAddress("air-noreply@itu.dk", "HoS Email Notifyer")};
    message.setReplyTo(ia); // Reply to

    message.setSubject(subject); // Subject text
    message.setText(body); // Body text

    Transport.send(message); // Send the message
    println("Mail sent!");
  }
  catch(Exception e) // Exception handling
  {
    e.printStackTrace();
  }

}
