<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList,java.util.Arrays,java.util.LinkedHashMap,java.util.LinkedHashSet,java.util.List,java.util.Locale,java.util.Map,java.util.Set,java.util.regex.Pattern" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private List<String> findKeywords(String text, List<String> keywords) {
        List<String> matches = new ArrayList<>();
        for (String keyword : keywords) {
            String wholeKeyword = "(?<![A-Za-z0-9])" + Pattern.quote(keyword) + "(?![A-Za-z0-9])";
            if (Pattern.compile(wholeKeyword).matcher(text).find()) matches.add(keyword);
        }
        return matches;
    }

    private String toJsonString(String value) {
        StringBuilder json = new StringBuilder("\"");
        for (char character : value.toCharArray()) {
            switch (character) {
                case '"':
                    json.append("\\\"");
                    break;
                case '\\':
                    json.append("\\\\");
                    break;
                case '\b':
                    json.append("\\b");
                    break;
                case '\f':
                    json.append("\\f");
                    break;
                case '\n':
                    json.append("\\n");
                    break;
                case '\r':
                    json.append("\\r");
                    break;
                case '\t':
                    json.append("\\t");
                    break;
                case '<':
                    json.append("\\u003c");
                    break;
                case '>':
                    json.append("\\u003e");
                    break;
                case '&':
                    json.append("\\u0026");
                    break;
                default:
                    if (character < 0x20) {
                        json.append(String.format("\\u%04x", (int) character));
                    } else {
                        json.append(character);
                    }
            }
        }
        return json.append('"').toString();
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    String name = request.getParameter("name") == null ? "" : request.getParameter("name").trim();
    String email = request.getParameter("email") == null ? "" : request.getParameter("email").trim();
    String mobile = request.getParameter("mobile") == null ? "" : request.getParameter("mobile").trim();
    String summary = request.getParameter("summary") == null ? "" : request.getParameter("summary").trim();
    List<String> errors = new ArrayList<>();

    if (name.length() < 2 || name.length() > 80) errors.add("Enter a name between 2 and 80 characters.");
    if (email.length() > 120 || !email.matches("^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$"))
        errors.add("Enter a valid email address.");
    if (!mobile.matches("^[6-9][0-9]{9}$")) errors.add("Enter a valid 10-digit Indian mobile number.");
    if (summary.trim().isEmpty() || summary.length() > 2000) errors.add("Write a summary of up to 2,000 characters.");

    int wordCount = summary.trim().isEmpty() ? 0 : summary.split("\\s+").length;
    String normalized = summary.toLowerCase(Locale.ROOT);
    List<String> matchedTopics = new ArrayList<>();
    Set<String> matchedKeywords = new LinkedHashSet<>();
    Map<String, List<String>> topicKeywords = new LinkedHashMap<>();
    topicKeywords.put("Spring Core", Arrays.asList("ioc", "inversion of control", "dependency injection", "application context", "applicationcontext", "bean", "beans"));
    topicKeywords.put("Spring JDBC", Arrays.asList("jdbctemplate", "jdbc template", "rowmapper", "row mapper", "datasource", "data source", "sql", "preparedstatement", "prepared statement"));
    topicKeywords.put("Hibernate", Arrays.asList("orm", "object relational mapping", "entity", "entities", "sessionfactory", "session factory", "hql", "persistence", "lazy loading"));
    for (Map.Entry<String, List<String>> topic : topicKeywords.entrySet()) {
        List<String> topicMatches = findKeywords(normalized, topic.getValue());
        if (!topicMatches.isEmpty()) {
            matchedTopics.add(topic.getKey());
            matchedKeywords.addAll(topicMatches);
        }
    }

    int score = 0;
    String feedback;
    if (wordCount > 100) {
        feedback = "Your summary is over the 100-word limit. Edit it and try again.";
    } else if (matchedTopics.size() < 2) {
        feedback = "We found " + matchedKeywords.size() + " concept keyword(s), but they must cover at least two topics. Topic names alone do not count.";
    } else if (wordCount < 50) {
        score = 5;
        feedback = "Short but relevant: " + matchedKeywords.size() + " concept keyword(s) across " + matchedTopics.size() + " topics.";
    } else if (wordCount == 100 && matchedTopics.size() == 3) {
        score = 10;
        feedback = "Perfect: exactly 100 words with concept keywords from all three topics.";
    } else if (wordCount >= 90) {
        score = 9;
        feedback = "Strong summary: " + matchedKeywords.size() + " concept keyword(s) across " + matchedTopics.size() + " topics.";
    } else {
        score = 7;
        feedback = "Good start: " + matchedKeywords.size() + " concept keyword(s) across " + matchedTopics.size() + " topics.";
    }
    boolean eligible = errors.isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Verify your test | Springboard</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body class="subpage">
<header class="site-header">
    <a class="brand" href="about.html"><span class="brand-mark">S</span><span>Spring<span class="brand-light">board</span></span></a>
    <a class="header-link" href="test.html">Back to test</a>
</header>
<main class="narrow-shell">
    <div class="eyebrow"><span class="eyebrow-dot"></span> STEP 02 · VERIFICATION</div>
    <h1 class="page-title">One last <span class="serif-accent">check.</span></h1>
    <p class="page-intro">We checked your details and matched your summary against the learning topics.</p>
    <% if (!eligible) { %>
    <section class="panel error-panel" aria-live="polite">
        <h2>Please fix these details</h2>
        <ul class="error-list">
            <% for (String error : errors) { %><li><%= escapeHtml(error) %></li><% } %>
        </ul>
        <a class="button button-secondary" href="test.html">Edit my details</a>
    </section>
    <% } else { %>
    <section class="panel verification-card">
        <div class="verification-heading">
            <span class="status-icon" aria-hidden="true">✓</span>
            <div><h2>Details verified</h2><p>Your information is ready for the result.</p></div>
        </div>
        <dl class="detail-list">
            <div><dt>Name</dt><dd><%= escapeHtml(name) %></dd></div>
            <div><dt>Email</dt><dd><%= escapeHtml(email) %></dd></div>
            <div><dt>Mobile</dt><dd><%= escapeHtml(mobile) %></dd></div>
            <div><dt>Summary length</dt><dd><%= wordCount %> words</dd></div>
        </dl>
        <div class="topic-check">
            <span class="mini-label">TOPICS FOUND</span>
            <div class="topic-pills">
                <% for (String topic : matchedTopics) { %><span class="topic-pill topic-pill-found"><%= escapeHtml(topic) %> ✓</span><% } %>
                <% if (matchedTopics.isEmpty()) { %><span class="topic-pill topic-pill-missing">No topic keywords found</span><% } %>
            </div>
            <span class="mini-label matched-concepts-label">CONCEPT KEYWORDS FOUND</span>
            <div class="topic-pills">
                <% for (String keyword : matchedKeywords) { %><span class="topic-pill topic-pill-found"><%= escapeHtml(keyword) %></span><% } %>
                <% if (matchedKeywords.isEmpty()) { %><span class="topic-pill topic-pill-missing">No Spring concepts found</span><% } %>
            </div>
        </div>
        <div class="score-preview">
            <div><span class="mini-label">PREVIEW SCORE</span><p><%= escapeHtml(feedback) %></p></div>
            <strong><%= score %><span>/10</span></strong>
        </div>
        <button class="button button-primary button-full" id="show-result" type="button">See my result <span aria-hidden="true">→</span></button>
    </section>
    <% } %>
    <aside class="scoring-note">
        <strong>How scoring works</strong>
        <p>Topic names by themselves do not count: explain concepts such as dependency injection, JdbcTemplate, RowMapper, ORM, or entities. Keywords must cover at least two topics. 1–49 relevant words: 5 points · 50–89: 7 · 90–99: 9 · exactly 100 with all three topics: 10.</p>
    </aside>
    <footer class="page-footer">Written by Aditi Kadam <span>·</span> Spring learning checkpoint</footer>
</main>
<% if (eligible) { %>
<script>
    document.querySelector("#show-result").addEventListener("click", () => {
        const result = {
            name: <%= toJsonString(name) %>,
            email: <%= toJsonString(email) %>,
            mobile: <%= toJsonString(mobile) %>,
            summary: <%= toJsonString(summary) %>,
            wordCount: <%= wordCount %>,
            score: <%= score %>,
            topics: [<% for (int i = 0; i < matchedTopics.size(); i++) { if (i > 0) { %>,<% } %><%= toJsonString(matchedTopics.get(i)) %><% } %>],
            keywords: [<% int keywordIndex = 0; for (String keyword : matchedKeywords) { if (keywordIndex++ > 0) { %>,<% } %><%= toJsonString(keyword) %><% } %>],
            feedback: <%= toJsonString(feedback) %>
        };
        sessionStorage.setItem("springboardResult", JSON.stringify(result));
        window.location.href = "result.html";
    });
</script>
<% } %>
</body>
</html>
