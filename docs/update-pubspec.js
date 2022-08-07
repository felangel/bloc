const dependencyOverrides = new RegExp(
  '<span class="token key atrule">dependency_overrides.*?\r*\n{2}',
  "gs"
);

function getRelativeImportRegExp(package) {
  return new RegExp(
    `\\s+<span class="token key atrule">path</span><span class="token punctuation">:</span> ../../packages/${package}.*?\r*\n{1}`,
    "gs"
  );
}

const angularBlocImport = getRelativeImportRegExp("angular_bloc");
const blocImport = getRelativeImportRegExp("bloc");
const blocConcurrencyImport = getRelativeImportRegExp("bloc_concurrency");
const blocTestImport = getRelativeImportRegExp("bloc_test");
const flutterBlocImport = getRelativeImportRegExp("flutter_bloc");
const hydratedBlocImport = getRelativeImportRegExp("hydrated_bloc");
const replayBlocImport = getRelativeImportRegExp("replay_bloc");
const sealedFlutterBlocImport = getRelativeImportRegExp("sealed_flutter_bloc");

const blocImports = [
  { value: angularBlocImport, version: "^8.0.0" },
  { value: blocTestImport, version: "^9.0.3" },
  { value: blocConcurrencyImport, version: "^0.2.0" },
  { value: blocImport, version: "^8.1.0" },
  { value: flutterBlocImport, version: "^8.0.1" },
  { value: hydratedBlocImport, version: "^8.1.0" },
  { value: replayBlocImport, version: "^0.2.2" },
  { value: sealedFlutterBlocImport, version: "^8.0.0" },
];

function updatePubspec() {
  const container = Docsify.dom.getNode("#main");
  const yamlCode = Docsify.dom.findAll(container, "code.lang-yaml");

  for (let i = yamlCode.length; i--; ) {
    const code = yamlCode[i];
    var innerHtml = code.innerHTML.replaceAll(dependencyOverrides, "");
    blocImports.forEach(function (blocImport) {
      innerHtml = innerHtml.replaceAll(
        blocImport.value,
        ` ${blocImport.version}\n`
      );
    });
    code.innerHTML = innerHtml;
  }
}

const install = function (hook) {
  hook.doneEach(updatePubspec);
};

window.$docsify.plugins = [].concat(install, window.$docsify.plugins);
