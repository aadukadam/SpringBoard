const summary = document.querySelector("#summary");
const wordCount = document.querySelector("#word-count");
const assessmentForm = document.querySelector("#assessment-form");
const runtimeWarning = document.querySelector("#runtime-warning");

if (window.location.protocol === "file:") {
    assessmentForm.addEventListener("submit", (event) => {
        event.preventDefault();
        runtimeWarning.hidden = false;
        runtimeWarning.textContent = "Verification uses JSP and must run on Apache Tomcat. Deploy the WAR and open the site at http://localhost:8080/spring-learning-checkpoint/about.html; do not open this page directly as a file.";
        runtimeWarning.scrollIntoView({ behavior: "smooth", block: "center" });
    });
}

function countWords(value) {
    const trimmed = value.trim();
    return trimmed ? trimmed.split(/\s+/u).length : 0;
}

summary.addEventListener("input", () => {
    const count = countWords(summary.value);
    wordCount.textContent = `${count} / 100 words`;
    wordCount.classList.toggle("count-over", count > 100);
});
