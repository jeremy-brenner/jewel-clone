echo "Rebuilding Webview+"
pushd plugins/com.ludei.webview.plus/android/
ant clean
ant release
popd
