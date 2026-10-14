# Springboard — Spring Learning Checkpoint

A traditional JSP web project by **Aditi Kadam**. It is not a Spring application: the guide and test are HTML/CSS/JavaScript, and `verification.jsp` checks submitted form values and scores the summary.

## Pages

`about.html` → `test.html` → `verification.jsp` → `result.html`

The knowledge guide introduces three Spring courses: Spring Core (IoC, beans, and dependency injection), Spring JDBC (JdbcTemplate and row mapping), and Hibernate (ORM, entities, and persistence). The test collects name, email, a 10-digit Indian mobile number, a chosen course focus, and a summary.

## Scoring

The verification page checks name, email, and mobile on the server and searches the summary for whole, case-insensitive concept keywords. Merely naming Spring Core, Spring JDBC, or Hibernate does not count; explain their concepts instead. Strong responses are rewarded for both depth and the number of topics covered, with a meaningful rating from 0 to 10 rather than a hard zero for every weak response.

## Run the website (required for verification)

Java 17+ and Maven are required. `verification.jsp` is server-side JSP, so do **not** open the pages using a `file:///...` URL; a browser cannot execute JSP. The test page shows a reminder if submitted as a local file.

From this project folder, start the website with:

```powershell
mvn package org.codehaus.cargo:cargo-maven3-plugin:1.10.29:run
```

Cargo downloads and starts a compatible Tomcat 10 container automatically on the first run. Keep the Maven command running while using the website.

Then open **http://localhost:8080/spring-learning-checkpoint/about.html**. The form posts to `verification.jsp`, where JSP validates the submitted name, email, mobile number, summary length, and topic keywords. Continue to `result.html` to see the score.
