#!/usr/bin/env node
var task                    = require('child_process').exec,
    fs                      = require('fs'),
    pathLib                 = require('path'),
    os                      = require('os'),
    inWindows               = (os.platform() === 'win32');

String.prototype.replaceAll = function(find, replace) {
    var str = this;
    return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
};

var App = function(plugin_name) {

    if (!process.env.CORDOVA_PATH_BINARY || !process.env.CORDOVA_CUSTOM_VERSION || !process.env.CORDOVA_PLUGIN_PATH) {
        process.exit(0);
    }

    this.CORDOVA_PATH_BINARY = new Buffer(process.env.CORDOVA_PATH_BINARY, 'base64').toString();
    this.CORDOVA_CUSTOM_VERSION = new Buffer(process.env.CORDOVA_CUSTOM_VERSION, 'base64').toString();
    this.plugin_name = plugin_name;
    this.plugin_path = this.getPath(new Buffer(process.env.CORDOVA_PLUGIN_PATH, 'base64').toString());
    this.plugin_path_android = pathLib.join(this.plugin_path, "../", "android");
    console.log("Path to Webview+ Project ", this.plugin_path_android, "Plugin path", this.plugin_path);
};

App.prototype = {

    getPath: function(path) {
        if (inWindows) {
            return path.replaceAll('/', pathLib.sep);
        } else {
            return path;
        }
    },
    getPlugins: function(callback) {
        task(this.CORDOVA_PATH_BINARY + " plugins", function (error, stdout, stderr) {
            try{
                if(error) throw new Error(stderr);
                if(this.ctx.CORDOVA_CUSTOM_VERSION >= "3.5.0-0.1.0"){
                    var tmp_list = [];
                    stdout.split("\\n").forEach(function(plugin_info){
                        tmp_list.push(plugin_info.split(" ")[0]);
                    });
                    stdout = JSON.stringify(tmp_list);
                }
                var plugins = JSON.parse(stdout.toString().replaceAll("'", '"'));
                console.log("Plugin list: ", plugins);
                if(Boolean(plugins) && Array.isArray(plugins))
                {
                    this.cllbck.call(this.ctx, plugins);
                }else{
                    this.cllbck.call(this.ctx, false);
                }
            }catch(e){
                console.log(e);
            }finally{
                process.exit(1);
            }
        }.bind({ cllbck : callback, ctx : this }));
    },

    processPlugin: function(plugins) {
        if( plugins.indexOf(this.plugin_name) !== -1 ){
            this.removeChromium();
        }
    },
    removeChromium: function() {

        var CORDOVA_LIBRARY_PATH = this.getPath("./platforms/android/libs/cordova-3.2.0.jar");
        var PROJECT_PROPERTIES_PATH = (this.CORDOVA_CUSTOM_VERSION === "3.2.0-0.1.0") ? pathLib.join(process.cwd(), "platforms", "android", "project.properties") : pathLib.join(process.cwd(), "platforms" , "android", "CordovaLib" , "project.properties");
        var CORDOVA_FRAMEWORK_WEBVIEW_PATH = this.getPath("./platforms/android/CordovaLib/src/org/apache/cordova/CordovaWebView.java");
        var PROJECT_PROPERTIES_RELATIVE_PATH = (this.CORDOVA_CUSTOM_VERSION === "3.2.0-0.1.0") ? process.cwd() + "/platforms/android/" : process.cwd() + "/platforms/android/CordovaLib/";
        var RELATIVE_CHROMIUM_PATH = pathLib.relative(this.getPath(PROJECT_PROPERTIES_RELATIVE_PATH), this.getPath(this.plugin_path_android));
        var project_properties_data = fs.readFileSync(PROJECT_PROPERTIES_PATH);

        if ( project_properties_data.toString('utf-8').indexOf(this.plugin_name) !== -1 ) {

            console.log("Removing Chromium" , PROJECT_PROPERTIES_PATH, "Cordova version", this.CORDOVA_CUSTOM_VERSION);

            if (this.CORDOVA_CUSTOM_VERSION === "3.2.0-0.1.0") {
                fs.renameSync(pathLib.join(this.plugin_path, "resources", "cordova-3.2.0.jar"), pathLib.join(CORDOVA_LIBRARY_PATH));
                fs.renameSync(pathLib.join(process.cwd(), "platforms", "android", "libs", "cordova-ludei-framework.jar"), pathLib.join(this.plugin_path, "resources", "cordova-ludei-framework.jar"));
                if (fs.existsSync(CORDOVA_LIBRARY_PATH)) {
                    fs.unlinkSync(CORDOVA_LIBRARY_PATH);
                }

                var fileContents = fs.readFileSync(PROJECT_PROPERTIES_PATH).toString('utf-8');
                var stringToDelete = "\nandroid.library.reference.1=" + RELATIVE_CHROMIUM_PATH.toString();

                fs.writeFileSync(PROJECT_PROPERTIES_PATH, fileContents.replace(stringToDelete, ""));
                console.log("Chromium deleted correctly.");
            }

            if(this.CORDOVA_CUSTOM_VERSION >= "3.3.0-0.1.0"){
                var cordova_webview_contents = fs.readFileSync(CORDOVA_FRAMEWORK_WEBVIEW_PATH).toString('utf-8');
                var extend_original = "import com.ludei.chromium.LudeiWebView;\n public class CordovaWebView extends LudeiWebView";
                var extend_end = "public class CordovaWebView extends WebView";

                fs.unlinkSync(CORDOVA_FRAMEWORK_WEBVIEW_PATH);

                fs.writeFileSync(CORDOVA_FRAMEWORK_WEBVIEW_PATH, cordova_webview_contents.replace(extend_original, extend_end));

                var fileContents = fs.readFileSync(PROJECT_PROPERTIES_PATH).toString('utf-8');
                var stringToDelete = "\nandroid.library.reference.1=" + RELATIVE_CHROMIUM_PATH.toString();

                fs.writeFileSync(PROJECT_PROPERTIES_PATH, fileContents.replace(stringToDelete, ""));
                console.log("Chromium deleted correctly.");
            }

            // Change the api level to the original one if needed
            var android_manifest_path = pathLib.join( process.cwd() , "platforms", "android", "AndroidManifest.xml");
            if(fs.existsSync(android_manifest_path)){
                var manifest_data = fs.readFileSync(android_manifest_path).toString("utf8");
                var manigest_reg_exp = /<uses-sdk (.*) \/>/i;
                var results = manifest_data.match(manigest_reg_exp);
                if(results){
                    console.log("Update minSdkVersion to 10 (Gingerbread)");
                    var needed_sdk = "<uses-sdk android:minSdkVersion='10' android:targetSdkVersion='19' />";
                    manifest_data = manifest_data.replace(manigest_reg_exp, needed_sdk);
                    fs.writeFileSync(android_manifest_path, manifest_data, 'utf8');
                }
            }else{
                console.error("Cannot locate Android Manifest");
            }

        } else {
            console.log("Webview+ isn't installed in the project. Stopping");
        }

        console.log("Hook execution finished.");
        process.exit(0);
    }
}

var cocoon_app = new App('com.ludei.webview.plus');

cocoon_app.getPlugins(function(plugins) {
    this.processPlugin(plugins);
});