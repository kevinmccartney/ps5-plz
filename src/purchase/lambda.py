from selenium import webdriver
import os
import debugpy
# from chromedriver_py import binary_path # this will get you the path variable

# https://stackoverflow.com/a/64687459
if os.environ.get('PS5_PLZ_ENV') == 'LOCAL':
  debugpy.listen(('0.0.0.0', 5678))
  print("Waiting for debugger attach")
  debugpy.wait_for_client()
  debugpy.breakpoint()
  print('break on this line')

chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-gpu')
chrome_options.add_argument('--window-size=1280x1696')
chrome_options.add_argument('--user-data-dir=/tmp/user-data')
chrome_options.add_argument('--hide-scrollbars')
chrome_options.add_argument('--enable-logging')
chrome_options.add_argument('--log-level=0')
chrome_options.add_argument('--v=99')
chrome_options.add_argument('--single-process')
chrome_options.add_argument('--data-path=/tmp/data-path')
chrome_options.add_argument('--ignore-certificate-errors')
chrome_options.add_argument('--homedir=/tmp')
chrome_options.add_argument('--disk-cache-dir=/tmp/cache-dir')
chrome_options.add_argument('user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36')
chrome_options.binary_location = os.getcwd() + "/bin/headless-chromium"
# chrome_options.executable_path = 
 
driver = webdriver.Chrome(chrome_options=chrome_options)

def lambda_handler(event, context):
  print("Hello, world")

if __name__ == "__main__":
  lambda_handler('', '')

