#!/bin/bash

# Get location of this script
DIR_REPO="$( cd "$(dirname $0)" ; pwd -P )"

# Record directories for future use
DIR_APP="$DIR_REPO/aic"
DIR_AIC="$DIR_APP/aic"

# Install dependencies
cd "$DIR_APP";

pod update;

# Create dummy plists
if [ ! -f "$DIR_AIC/Config.plist" ]; then

	echo "No existing Config.plist found, one will be created..."

	OPTIONS=`cat <<- EOF
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>Testing</key>
	    <dict>
	        <key>printDataErrors</key>
	        <true/>
	    </dict>
	    <key>DataConstants</key>
	    <dict>
	        <key>appDataJSON</key>
	        <string>http://localhost:8888/appData.json</string>
	        <key>memberCardSOAPRequestURL</key>
	        <string>http://localhost:8888/api/1?token=foobar</string>
	        <key>ignoreOverrideImageCrop</key>
	        <true/>
		</dict>
	</dict>
	</plist>
	EOF`

	echo "$OPTIONS" > "$DIR_AIC/Config.plist"
	chown $(logname) "$DIR_AIC/Config.plist"

	echo "Created stub /aic/aic/Config.plist"

fi

# Create dummy GoogleServices plist
if [ ! -f "$DIR_AIC/GoogleService-Info.plist" ]; then

	echo "No existing GoogleService-Info.plist, one will be created..."

	OPTIONS=`cat <<- EOF
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>CLIENT_ID</key>
		<string>1234567890-1234567890.apps.googleusercontent.com</string>
		<key>REVERSED_CLIENT_ID</key>
		<string>com.googleusercontent.apps.12345678901234567890abc</string>
		<key>API_KEY</key>
		<string>1234567890abc1234567890abc</string>
		<key>GCM_SENDER_ID</key>
		<string>1234567890</string>
		<key>PLIST_VERSION</key>
		<string>1</string>
		<key>BUNDLE_ID</key>
		<string>edu.artic.anon-mobile-app</string>
		<key>PROJECT_ID</key>
		<string>AnonMobileApp</string>
		<key>STORAGE_BUCKET</key>
		<string>anon-mobile-app.appspot.com</string>
		<key>IS_ADS_ENABLED</key>
		<false/>
		<key>IS_ANALYTICS_ENABLED</key>
		<false/>
		<key>IS_APPINVITE_ENABLED</key>
		<true/>
		<key>IS_GCM_ENABLED</key>
		<true/>
		<key>IS_SIGNIN_ENABLED</key>
		<true/>
		<key>GOOGLE_APP_ID</key>
		<string>1:364666648134:ios:18dac0682c0e18fd</string>
		<key>DATABASE_URL</key>
		<string>https://anon-mobile-app.firebaseio.com</string>
	</dict>
	</plist>
	EOF`

	echo "$OPTIONS" > "$DIR_AIC/GoogleService-Info.plist"
	chown $(logname) "$DIR_AIC/GoogleService-Info.plist"

	echo "Created stub /aic/aic/GoogleService-Info.plist"
	echo "Edit it with your Firebase app and tracking id's when ready"

fi

# Open the workspace in Xcode
cd "$DIR_APP" && open aic.xcworkspace
