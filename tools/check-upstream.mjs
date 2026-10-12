import { appendFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { execFileSync } from "node:child_process";

const root = resolve(".");
const record = JSON.parse(readFileSync(join(root, "compatibility.json"), "utf8"));
const upstreamPath = process.env.OMARCHY_UPSTREAM;
const packagesPath = process.env.OMARCHY_PACKAGES;
let currentCommit = "not supplied";
let changedFiles = [];
let currentPackagesCommit = "not supplied";
let packageChangedFiles = [];
let reviewRequired = false;

const watched = [
  /^docs\/omarchy-shell\.md$/,
  /^shell\/shell\.qml$/,
  /^shell\/services\/AppLibrary\.qml$/,
  /^shell\/services\/PluginAppLibraryApi\.qml$/,
  /^shell\/services\/PluginRegistry\.qml$/,
  /^shell\/Ui\/(OverlayWindow|BorderSurface)\.qml$/,
  /^shell\/Commons\/(Style|Color|Border)\.qml$/,
  /^install\/omarchy-(aarch64|x86_64-only)\.packages$/,
  /^shell\/plugins\/menu\//
];
const watchedPackages = [
  // Quickshell is the direct package-repository dependency of the mobile shell prototype.
  // Optional app recipes are tracked by Omarchy's package lists, not as shell API contracts.
  /^pkgbuilds\/quickshell(?:-git)?\//,
  /^repos\//,
  /^README\.md$/,
  /^\.github\/workflows\//
];

if (upstreamPath) {
  if (!existsSync(join(upstreamPath, ".git"))) {
    throw new Error("OMARCHY_UPSTREAM is not a Git checkout: " + upstreamPath);
  }
  currentCommit = execFileSync("git", ["-C", upstreamPath, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
  const pin = record.upstream.reviewedCommit;
  try {
    changedFiles = execFileSync("git", ["-C", upstreamPath, "diff", "--name-only", pin + "..HEAD"], { encoding: "utf8" })
      .split(/\r?\n/)
      .filter(Boolean);
  } catch {
    throw new Error("Pinned upstream commit " + pin + " is missing from " + upstreamPath + "; fetch full history before comparison.");
  }
  reviewRequired = changedFiles.some(path => watched.some(pattern => pattern.test(path)));
} else {
  console.warn("OMARCHY_UPSTREAM is unset; reporting the reviewed pin without a live source comparison.");
}

const relevant = changedFiles.filter(path => watched.some(pattern => pattern.test(path)));
if (packagesPath) {
  if (!existsSync(join(packagesPath, ".git"))) {
    throw new Error("OMARCHY_PACKAGES is not a Git checkout: " + packagesPath);
  }
  currentPackagesCommit = execFileSync("git", ["-C", packagesPath, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
  const pin = record.upstream.packagesReviewedCommit;
  try {
    packageChangedFiles = execFileSync("git", ["-C", packagesPath, "diff", "--name-only", pin + "..HEAD"], { encoding: "utf8" })
      .split(/\r?\n/)
      .filter(Boolean);
  } catch {
    throw new Error("Pinned package commit " + pin + " is missing from " + packagesPath + "; fetch full history before comparison.");
  }
  if (packageChangedFiles.some(path => watchedPackages.some(pattern => pattern.test(path)))) reviewRequired = true;
} else {
  console.warn("OMARCHY_PACKAGES is unset; package-recipe changes are not being compared.");
}
const relevantPackages = packageChangedFiles.filter(path => watchedPackages.some(pattern => pattern.test(path)));
const summary = [
  "# Omarchy and package source comparison",
  "",
  "- Reviewed pin: " + record.upstream.reviewedCommit,
  "- Candidate HEAD: " + currentCommit,
  "- Upstream ref reviewed: " + record.upstream.reviewedRef,
  "- Plugin-contract files changed: " + relevant.length,
  "- Reviewed package pin: " + record.upstream.packagesReviewedCommit,
  "- Candidate package HEAD: " + currentPackagesCommit,
  "- Package-recipe files changed: " + relevantPackages.length,
  "- Human review required: " + (reviewRequired ? "yes" : "no"),
  "",
  "## Omarchy source",
  "",
  relevant.length ? relevant.map(path => "- " + path).join("\n") : "No watched plugin-contract files changed.",
  "",
  "## Package source",
  "",
  relevantPackages.length ? relevantPackages.map(path => "- " + path).join("\n") : "No watched package-recipe files changed."
].join("\n");

console.log(summary);

if (process.env.GITHUB_OUTPUT) {
  appendFileSync(process.env.GITHUB_OUTPUT, [
    "needs_review=" + reviewRequired,
    "issue_title=Omarchy upstream compatibility review",
    "candidate_upstream_commit=" + currentCommit,
    "candidate_packages_commit=" + currentPackagesCommit,
    "changed_files_json=" + JSON.stringify(relevant.concat(relevantPackages)),
    ""
  ].join("\n"));
}
if (process.env.GITHUB_STEP_SUMMARY) {
  appendFileSync(process.env.GITHUB_STEP_SUMMARY, summary + "\n");
}
if (process.env.UPSTREAM_REPORT_PATH) {
  writeFileSync(process.env.UPSTREAM_REPORT_PATH, [
    "A scheduled source comparison found changes in Omarchy or omarchy-pkgs files used by the mobile project.",
    "",
    "This is a review signal, not proof of a breaking change. Do not update the tested pin or publish a compatible release until the plugin contract and runtime checks have been reviewed.",
    "",
    summary
  ].join("\n"));
}
