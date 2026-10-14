const resultContent = document.querySelector("#result-content");

function makeElement(tag, className, text) {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (text !== undefined) element.textContent = text;
    return element;
}

function showError(message) {
    resultContent.replaceChildren(makeElement("p", "error-message", message));
}

function renderResult(result) {
    const header = makeElement("div", "result-heading");
    header.append(makeElement("span", "result-sparkle", result.score > 0 ? "✦" : "↗"));
    const headingCopy = makeElement("div");
    headingCopy.append(makeElement("div", "eyebrow", result.score > 0 ? "NICELY DONE" : "A FRESH START"));
    const title = makeElement("h1", "page-title");
    title.append(document.createTextNode(result.score > 0 ? "You made it " : "Keep "));
    title.append(makeElement("span", "serif-accent", result.score > 0 ? "click." : "growing."));
    headingCopy.append(title);
    header.append(headingCopy);

    const scoreBlock = makeElement("div", "score-block");
    scoreBlock.append(makeElement("strong", "score-number", String(result.score)));
    scoreBlock.append(makeElement("span", "score-total", "/ 10"));
    const scoreText = makeElement("p", "result-feedback", result.feedback);

    const stats = makeElement("div", "result-stats");
    stats.append(makeElement("div", "result-stat", `${result.wordCount} words`));
    stats.append(makeElement("div", "result-stat", result.course ? `${result.course} focus` : `${result.topics.length} / 3 topics matched`));
    stats.append(makeElement("div", "result-stat", `${result.topics.length} / 3 topics matched`));

    const matched = makeElement("div", "topic-pills");
    for (const topic of result.topics) {
        matched.append(makeElement("span", "topic-pill topic-pill-found", `${topic} ✓`));
    }
    for (const topic of ["Spring Core", "Spring JDBC", "Hibernate"]) {
        if (!result.topics.includes(topic)) {
            matched.append(makeElement("span", "topic-pill topic-pill-missing", `${topic} · not found`));
        }
    }
    const conceptsLabel = makeElement("p", "mini-label matched-concepts-label", "CONCEPT KEYWORDS FOUND");
    const concepts = makeElement("div", "topic-pills");
    for (const keyword of result.keywords) {
        concepts.append(makeElement("span", "topic-pill topic-pill-found", keyword));
    }
    if (result.keywords.length === 0) {
        concepts.append(makeElement("span", "topic-pill topic-pill-missing", "No Spring concepts found"));
    }

    const summary = makeElement("blockquote", "submitted-summary", `“${result.summary}”`);
    const attribution = makeElement("p", "result-attribution", `${result.name} · ${result.email} · ${result.mobile}`);
    const buttons = makeElement("div", "result-actions");
    const retry = makeElement("a", "button button-primary", "Try again →");
    retry.href = "test.html";
    const home = makeElement("a", "button button-secondary", "Back to the guide");
    home.href = "about.html";
    buttons.append(retry, home);

    resultContent.replaceChildren(header, scoreBlock, scoreText, stats, matched, conceptsLabel, concepts, summary, attribution, buttons);
}

const storedResult = sessionStorage.getItem("springboardResult");
if (!storedResult) {
    window.location.replace("test.html");
} else {
    let result;
    try {
        result = JSON.parse(storedResult);
    } catch {
        showError("We could not read your result. Please return to the test and try again.");
        resultContent.append(makeElement("a", "button button-secondary", "Return to the test"));
        resultContent.querySelector("a").href = "test.html";
    }
    if (result) {
        renderResult(result);
        sessionStorage.removeItem("springboardResult");
    }
}
