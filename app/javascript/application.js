// THIS FILE IS NOT USED. TL;DR, maintain "package.json" if you make changes.
//
// All of the JS herein predates modules so use of 'esbuild' with forced
// bundling was very destructive. After wasting hours modifying JS code with
// exports and splats back into the global namespace after imports, it became
// clear that it was a fool's errand.
//
// Instead, this is now managed by a simple concatenator instead of 'esbuild';
// we don't care about minification or other obfuscation on an open source
// project like this and the code size isn't so large as to make time-on-wire
// all that different either.
//
// Procfile.dev lists the commands run by "bin/dev", with SASS supporting a
// watcher mode via '--watch' added there automatically. Unix 'cat' does not
// have such a thing, so instead task "nodemon" is used to monitor files and
// re-run the "cat" task if it sees changes.
//
// These tasks - along with the list of JavaScript files you will need to
// update if you add or remove anything here - are in "package.json".
