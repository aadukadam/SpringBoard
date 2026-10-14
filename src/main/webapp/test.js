const summary = document.querySelector("#summary");
const wordCount = document.querySelector("#word-count");
const assessmentForm = document.querySelector("#assessment-form");
const runtimeWarning = document.querySelector("#runtime-warning");
const summaryTabs = document.querySelectorAll(".summary-tab");
const summaryPanels = document.querySelectorAll(".summary-panel");
const summaryPreview = document.querySelector("#summary-preview");
const formatButtons = document.querySelectorAll(".format-btn");

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

function renderSummaryPreview(value) {
    if (!summaryPreview) {
        return;
    }

    const rawText = value.trim();
    if (!rawText) {
        summaryPreview.innerHTML = '<p class="empty-preview">Your preview will appear here as you type.</p>';
        return;
    }

    const lines = rawText
        .split(/\n+/u)
        .map((line) => line.trim())
        .filter(Boolean)
        .map((line) => {
            if (/^[-*]\s+/.test(line)) {
                return `<li>${escapeHtml(line.replace(/^[-*]\s+/, ""))}</li>`;
            }
            return `<p>${formatInlineMarkdown(escapeHtml(line))}</p>`;
        });

    const bulletList = lines.some((line) => line.startsWith("<li>"));
    const html = bulletList
        ? `<ul>${lines.filter((line) => line.startsWith("<li>")).join("")}</ul>${lines.filter((line) => !line.startsWith("<li>")).join("")}`
        : lines.join("");

    summaryPreview.innerHTML = html;
}

function formatInlineMarkdown(value) {
    return value
        .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
        .replace(/__(.+?)__/g, "<strong>$1</strong>")
        .replace(/\*(.+?)\*/g, "<em>$1</em>")
        .replace(/_(.+?)_/g, "<em>$1</em>");
}

function escapeHtml(value) {
    return value.replace(/[&<>"']/g, (character) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    }[character]));
}

function updateWordCount() {
    const count = countWords(summary.value);
    wordCount.textContent = `${count} / 100 words`;
    wordCount.classList.toggle("count-over", count > 100);
    renderSummaryPreview(summary.value);
}

function setSummaryTab(tabName) {
    summaryTabs.forEach((tab) => {
        const isActive = tab.dataset.tab === tabName;
        tab.classList.toggle("is-active", isActive);
        tab.setAttribute("aria-selected", String(isActive));
    });

    summaryPanels.forEach((panel) => {
        const isActive = panel.dataset.panel === tabName;
        panel.classList.toggle("is-active", isActive);
        panel.hidden = !isActive;
    });
}

function applyFormatting(format) {
    if (!summary) {
        return;
    }

    const start = summary.selectionStart;
    const end = summary.selectionEnd;
    const selectedText = summary.value.slice(start, end) || "text";

    if (format === "bold") {
        insertSelection("**", "**", selectedText);
    }

    if (format === "italic") {
        insertSelection("*", "*", selectedText);
    }

    if (format === "list") {
        const selectedLines = summary.value.slice(start, end).split(/\n/u);
        const listText = selectedLines.map((line) => (!line.trim() ? "" : `- ${line.trim()}`)).join("\n");
        const before = summary.value.slice(0, start);
        const after = summary.value.slice(end);
        summary.value = `${before}${listText || "- "}${after}`;
        const newCaret = start + (listText || "- ").length;
        summary.focus();
        summary.setSelectionRange(newCaret, newCaret);
        summary.dispatchEvent(new Event("input"));
    }
}

function insertSelection(prefix, suffix, selectedText) {
    const start = summary.selectionStart;
    const end = summary.selectionEnd;
    const before = summary.value.slice(0, start);
    const after = summary.value.slice(end);
    summary.value = `${before}${prefix}${selectedText}${suffix}${after}`;
    const cursor = start + prefix.length + selectedText.length + suffix.length;
    summary.focus();
    summary.setSelectionRange(cursor, cursor);
    summary.dispatchEvent(new Event("input"));
}

summaryTabs.forEach((tab) => {
    tab.addEventListener("click", () => setSummaryTab(tab.dataset.tab));
});

formatButtons.forEach((button) => {
    button.addEventListener("click", () => applyFormatting(button.dataset.format));
});

summary.addEventListener("input", updateWordCount);
updateWordCount();
