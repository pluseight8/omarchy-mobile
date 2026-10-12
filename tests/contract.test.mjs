import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";

const root = resolve(".");
const read = path => readFileSync(join(root, path), "utf8");
const manifest = JSON.parse(read("manifest.json"));
const qml = read("mobile/launcher/Launcher.qml");

test("manifest uses the documented Omarchy menu plugin shape", () => {
  assert.equal(manifest.schemaVersion, 1);
  assert.ok(manifest.kinds.includes("menu"));
  assert.equal(manifest.entryPoints.menu, "mobile/launcher/Launcher.qml");
  assert.ok(existsSync(join(root, manifest.entryPoints.menu)));
});

test("launcher implements the standard plugin lifecycle and scoped app API", () => {
  for (const hook of ["function open(payloadJson)", "function close()"]) {
    assert.ok(qml.includes(hook), "missing lifecycle hook: " + hook);
  }
  for (const api of ["sortedEntries", "entryName", "entrySubtext", "iconSource", "refreshIcons", "launch"]) {
    assert.ok(qml.includes("appLibrary." + api), "missing scoped app library method: " + api);
  }
  assert.ok(qml.includes("PanelWindow"));
  assert.ok(qml.includes("WlrLayershell.layer"));
  assert.ok(qml.includes("Border.surfaceSpec"));
  assert.ok(qml.includes("Commons.Color.menu"));
});

test("mobile cards expose touch-sized actions and native flick scrolling", () => {
  assert.match(qml, /Style\.space\(48\)/);
  assert.match(qml, /GridView\s*\{[\s\S]*?interactive:\s*true/);
  assert.ok(qml.includes("TapHandler"));
  assert.ok(qml.includes("onLongPressed"));
  assert.ok(qml.includes("root.launch(appCell.entry)"));
});

test("launcher sizing is responsive and has no Pixel physical-resolution constants", () => {
  assert.ok(qml.includes("width / Math.max(1, Math.floor(width / Style.space(144)))"));
  assert.doesNotMatch(qml, /\b(1080|2424)\b/);
});

test("compatibility record does not overstate unrun checks", () => {
  const record = JSON.parse(read("compatibility.json"));
  assert.equal(record.result, "STATIC_SOURCE_REVIEW_ONLY");
  assert.equal(record.upstream.latestReleaseCommit, record.upstream.omarchyPackageSourceCommit);
  assert.equal(record.runtimeTested, false);
  assert.equal(record.qmlLinted, true);
  assert.equal(record.armPackageBuildTested, false);
  assert.equal(record.pixel10Tested, false);
});

test("live upstream release and branch expose the launcher contracts when supplied", t => {
  const sources = [
    ["quattro", process.env.OMARCHY_UPSTREAM],
    ["latest release", process.env.OMARCHY_RELEASE]
  ].filter(([, path]) => Boolean(path));
  if (sources.length === 0) {
    t.skip("set OMARCHY_UPSTREAM and/or OMARCHY_RELEASE to run live source-contract checks");
    return;
  }
  for (const [label, upstream] of sources) {
    const upstreamFile = path => readFileSync(join(upstream, path), "utf8");
    const docs = upstreamFile("docs/omarchy-shell.md");
    const host = upstreamFile("shell/shell.qml");
    const appApi = upstreamFile("shell/services/PluginAppLibraryApi.qml");
    const menu = upstreamFile("shell/plugins/menu/Menu.qml");
    const style = upstreamFile("shell/Commons/Style.qml");
    const borderSurface = upstreamFile("shell/Ui/BorderSurface.qml");
    const overlayPath = join(upstream, "shell/Ui/OverlayWindow.qml");
    const overlay = existsSync(overlayPath) ? readFileSync(overlayPath, "utf8") : "";

    assert.match(docs, /Summoned menu surface/, label);
    assert.match(docs, /menu plugins receive an application-library facade/, label);
    assert.match(host, /pluginAppLibraryFor/, label);
    assert.match(host, /manifestHasKind\(manifest,\s*"menu"\)/, label);
    const menuOwnsPanel = /PanelWindow\s*\{/.test(menu) && /WlrLayershell\.layer/.test(menu);
    const upstreamWrapsPanel = /OverlayWindow/.test(menu) && /PanelWindow\s*\{/.test(overlay)
      && /WlrLayershell\.layer/.test(overlay);
    assert.ok(menuOwnsPanel || upstreamWrapsPanel, label + " no longer exposes the menu's fullscreen layer-shell surface");
    assert.match(style, /property QtObject spacing/, label);
    assert.match(borderSurface, /Rectangle\s*\{/, label);
    for (const method of ["entryName", "entrySubtext", "sortedEntries", "iconSource", "refreshIcons", "launch"]) {
      assert.match(appApi, new RegExp("function " + method + "\\("), label);
      assert.match(menu, new RegExp("appLibrary\\." + method + "\\("), label);
    }
  }
  assert.doesNotMatch(qml, /\bOverlayWindow\b/);
});

test("ARM64 Quickshell packaging recipe includes aarch64 when supplied", t => {
  const packages = process.env.OMARCHY_PACKAGES;
  if (!packages) {
    t.skip("set OMARCHY_PACKAGES to run the live package-source check");
    return;
  }
  const recipe = readFileSync(join(packages, "pkgbuilds/quickshell/PKGBUILD"), "utf8");
  const readme = readFileSync(join(packages, "README.md"), "utf8");
  assert.match(recipe, /arch\s*=\s*\([^)]*\baarch64\b[^)]*\)/s);
  assert.match(readme, /aarch64/);
});
