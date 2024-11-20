from appium import webdriver

desired_caps = {
    'platformName': 'Android',
    'platformVersion': '11',  # Update with the Android version of your device
    'deviceName': 'emulator-5554',  # Use your actual device name or emulator
    "app": r"build\app\outputs\flutter-apk\app-release.apk",  # Path to your app
    'automationName': 'UiAutomator2',  # Automation engine for Android
}

# Start the Appium session
driver = webdriver.Remote("http://127.0.0.1:4723/wd/hub", desired_caps)

# Now you can start interacting with the app
print("App launched successfully!")

# Close the driver after your test
driver.quit()
